//
//  CFunctionInjector.swift
//  
//  Copied from https://github.com/tarunon/XCTAssertAutolayout/blob/master/Sources/XCTAssertAutolayout/Core/AssertAutolayoutContext.swift
//

import Foundation

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
    /// - Parameter symbol: c function name
    /// - Throws: Error that fail CFunctionInjector initialize
    init(_ origin: UnsafeMutableRawPointer) throws {
        // make the memory containing the original function writable
        let pageSize = sysconf(_SC_PAGESIZE)
        if pageSize == -1 {
            throw Error(message: "failed to read memory page size: errno=\(errno)")
        }

        let start = Int(bitPattern: origin)
        let end = start + 2
        let pageStart = start & -pageSize
        let status = mprotect(UnsafeMutableRawPointer(bitPattern: pageStart),
                              end - pageStart,
                              PROT_READ | PROT_WRITE | PROT_EXEC)
        if status == -1 {
            throw Error(message: "failed to change memory protection: errno=\(errno)")
        }
        self.originalFunctionPointer0 = origin.assumingMemoryBound(to: Int64.self)
        self.escapedInstructionBytes0 = originalFunctionPointer0.pointee
        self.originalFunctionPointer8 = UnsafeMutablePointer(bitPattern: Int(bitPattern: origin) + 8)!
        self.escapedInstructionBytes8 = originalFunctionPointer8.pointee
    }

    deinit {
        reset()
    }

    /// Inject c function to c function.
    /// Ref: https://github.com/thomasfinch/CRuntimeFunctionHooker/blob/master/inject.c
    ///
    /// - Parameters:
    ///   - target: c function pointer.
    func inject(_ target: UnsafeRawPointer) {
        assert(Thread.isMainThread)

        // Set the first instruction of the original function to be a jump to the replacement function.

        let targetAddress = Int64(Int(bitPattern: target))

        // 1. mov rax %target
        originalFunctionPointer0.pointee = 0xb848 | targetAddress << 16
        // 2. jmp rax
        originalFunctionPointer8.pointee = 0xe0ff << 16 | targetAddress >> 48
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
