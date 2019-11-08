//
//  CFunctionInjector.swift
//  
//  Copied from https://github.com/tarunon/XCTAssertAutolayout/blob/master/Sources/XCTAssertAutolayout/Core/AssertAutolayoutContext.swift
//

import Foundation

// dlfcn.h
// #define    RTLD_DEFAULT    ((void *) -2)    /* Use default search algorithm. */
let RTLD_DEFAULT = UnsafeMutableRawPointer(bitPattern: -2)

class CFunctionInjector {
    struct Error : LocalizedError, CustomStringConvertible {
        var message: String
        var description: String { return message }
        var errorDescription: String? { return description }
    }

    var originalFunctionPointer0: UnsafeMutablePointer<Int64>
    var originalFunctionPointer8: UnsafeMutablePointer<Int64>
    var escapedInstructionBytes0: Int64
    var escapedInstructionBytes8: Int64

    /// Initialize CFunctionInjector object.
    /// This method remove original c functions memory protection.
    /// Ref: https://github.com/thomasfinch/CRuntimeFunctionHooker/blob/master/inject.c
    ///
    /// - Parameter target: The target functions instruction pointer.
    /// - Throws: Error that fail CFunctionInjector initialize
    init(_ target: UnsafeMutableRawPointer) throws {
        assert(Thread.isMainThread)
        
        // make the memory containing the original function writable
        let pageSize = sysconf(_SC_PAGESIZE)
        if pageSize == -1 {
            throw Error(message: "failed to read memory page size: errno=\(errno)")
        }

        let start = Int(bitPattern: target)
        let end = start + 2
        let pageStart = start & -pageSize
        let status = mprotect(UnsafeMutableRawPointer(bitPattern: pageStart),
                              end - pageStart,
                              PROT_READ | PROT_WRITE | PROT_EXEC)
        if status == -1 {
            throw Error(message: "failed to change memory protection: errno=\(errno)")
        }
        self.originalFunctionPointer0 = target.assumingMemoryBound(to: Int64.self)
        self.escapedInstructionBytes0 = originalFunctionPointer0.pointee
        self.originalFunctionPointer8 = UnsafeMutablePointer(bitPattern: Int(bitPattern: target) + 8)!
        self.escapedInstructionBytes8 = originalFunctionPointer8.pointee
    }
    
    convenience init(_ symbolName: String) throws {
        guard let target = dlsym(RTLD_DEFAULT, symbolName) else {
            throw Error(message: "symbol not found: \(symbolName)")
        }
        try self.init(target)
    }

    deinit {
        reset()
    }

    /// Inject c function to c function.
    /// Ref: https://github.com/thomasfinch/CRuntimeFunctionHooker/blob/master/inject.c
    ///
    /// - Parameters:
    ///   - target: The destination functions instruction pointer.
    func inject(_ destination: UnsafeRawPointer) {
        assert(Thread.isMainThread)

        // Set the first instruction of the original function to be a jump to the replacement function.

        let destinationAddress = Int64(Int(bitPattern: destination))

        // 1. mov rax %target
        originalFunctionPointer0.pointee = 0xb848 | destinationAddress << 16
        // 2. jmp rax
        originalFunctionPointer8.pointee = 0xe0ff << 16 | destinationAddress >> 48
    }
    
    func inject(_ symbolName: String) throws {
        guard let destination = dlsym(RTLD_DEFAULT, symbolName) else {
            throw Error(message: "symbol not found: \(symbolName)")
        }
        inject(destination)
    }

    /// Reset function injection.
    /// Ref: https://github.com/thomasfinch/CRuntimeFunctionHooker/blob/master/inject.c
    ///
    /// - Parameter symbol: c function name.
    func reset() {
        assert(Thread.isMainThread)
        originalFunctionPointer0.pointee = escapedInstructionBytes0
        originalFunctionPointer8.pointee = escapedInstructionBytes8
    }
}
