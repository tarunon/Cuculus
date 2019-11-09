//
//  SwiftMangleTable
//  
//
//  Created by tarunon on 2019/11/08.
//

import Foundation
import MachO

@_silgen_name("swift_demangle")
func _swiftDemangle(mangledName: UnsafePointer<Int8>?, mangledNameLength: UInt, outputBuffer: UnsafeMutablePointer<Int8>?, outputBufferSize: UnsafeMutablePointer<UInt>?, flags: UInt32) -> UnsafeMutablePointer<Int8>?

func swiftDemangle(_ mangledName: String) -> String {
    return mangledName.utf8CString.withUnsafeBufferPointer { (mangledNameUTF8CStr) in
        let demangledNamePtr = _swiftDemangle(mangledName: mangledNameUTF8CStr.baseAddress, mangledNameLength: UInt(mangledNameUTF8CStr.count - 1), outputBuffer: nil, outputBufferSize: nil, flags: 0)
        if let demangledNamePtr = demangledNamePtr {
            let demangledName = String(cString: demangledNamePtr)
            free(demangledNamePtr)
            return demangledName
        }
        return mangledName
    }
}


struct SwiftMangleTable {
    var table: [String: String]
    struct Pair {
        var funcName: String
        var symbolName: String
        
        var actualSymbolName: String {
            if symbolName.hasPrefix("_") {
                return String(symbolName[symbolName.index(symbolName.startIndex, offsetBy: 1)...])
            }
            return symbolName
        }
    }
    
    private init() {
        self.table = Dictionary(
            SymbolNameList().lazy
                .filter { $0.hasPrefix("_$s") }
                .map { (key: swiftDemangle($0), value: $0) }
                .filter { key, value in
                    ![
                        "curry thunk of",
                        "partial apply forwarder for",
                        "property descriptor for",
                        "method descriptor for"
                    ].contains(where: { key.hasPrefix($0) })
                },
            uniquingKeysWith: { $1 }
        )
    }
    
    static var instance = SwiftMangleTable()
    
    static func match(funcName: String, candidate: String) -> Bool {
        let escapedFuncName = funcName.replacingOccurrences(of: "static ", with: "")
        return (!funcName.hasPrefix("static ") != candidate.hasPrefix("static ")) &&
            (
                candidate.contains(escapedFuncName + " ") ||
                candidate.contains(escapedFuncName + "(") ||
                candidate.contains(escapedFuncName + "<") ||
                candidate.contains(escapedFuncName + ".")
            )
    }
    
    func match(_ funcName: String, select: (AnySequence<String>) -> String?) -> Pair? {
        if let symbolName = table[funcName] {
            return Pair(funcName: funcName, symbolName: symbolName)
        }
        if let key = select(AnySequence(table.keys.filter({ SwiftMangleTable.match(funcName: funcName, candidate: $0) }))),
            let value = table[key] {
            return Pair(funcName: key, symbolName: value)
        }
        return nil
    }
}

struct SymbolNameList: Sequence {
    typealias Iterator = SymbolNameIterator
    __consuming func makeIterator() -> SymbolNameIterator {
        return SymbolNameIterator()
    }
}

struct SymbolNameIterator: IteratorProtocol {
    typealias Element = String
    struct SymbolTable: IteratorProtocol {
        typealias Element = String
        
        static let linkeditName = SEG_LINKEDIT.data(using: String.Encoding.utf8)!.map({ $0 })
        let header: UnsafePointer<mach_header>
        let slide: Int

        var linkeditCmd: UnsafeMutablePointer<segment_command_64>!
        var symtabCmd: UnsafeMutablePointer<symtab_command>!
        var curCmd: UnsafeMutablePointer<segment_command_64> {
            didSet {
                if curCmd.pointee.cmd == LC_SEGMENT_64 {
                    if UInt8(curCmd.pointee.segname.0) == SymbolTable.linkeditName[0] &&
                       UInt8(curCmd.pointee.segname.1) == SymbolTable.linkeditName[1] &&
                       UInt8(curCmd.pointee.segname.2) == SymbolTable.linkeditName[2] &&
                       UInt8(curCmd.pointee.segname.3) == SymbolTable.linkeditName[3] &&
                       UInt8(curCmd.pointee.segname.4) == SymbolTable.linkeditName[4] &&
                       UInt8(curCmd.pointee.segname.5) == SymbolTable.linkeditName[5] &&
                       UInt8(curCmd.pointee.segname.6) == SymbolTable.linkeditName[6] &&
                       UInt8(curCmd.pointee.segname.7) == SymbolTable.linkeditName[7] &&
                       UInt8(curCmd.pointee.segname.8) == SymbolTable.linkeditName[8] &&
                       UInt8(curCmd.pointee.segname.9) == SymbolTable.linkeditName[9] {
                        linkeditCmd = curCmd
                    }
                } else if curCmd.pointee.cmd == LC_SYMTAB {
                    symtabCmd = UnsafeMutableRawPointer(curCmd).assumingMemoryBound(to: symtab_command.self)
                }
            }
        }
        
        var linkedBase: Int!
        var symbolTable: UnsafeMutablePointer<nlist_64> {
            return UnsafeMutablePointer(bitPattern: linkedBase + Int(symtabCmd.pointee.symoff))!
        }
        var strTable: UnsafeMutablePointer<UInt8> {
            return UnsafeMutablePointer(bitPattern: linkedBase + Int(symtabCmd.pointee.stroff))!
        }
        
        var symbolCount: UInt32!
        var symbolIndex: UInt32!

        init?(imageIndex: UInt32) {
            guard let header = _dyld_get_image_header(imageIndex) else {
                return nil
            }
            self.header = header
            self.slide = _dyld_get_image_vmaddr_slide(imageIndex)
            self.curCmd = UnsafeMutablePointer(mutating: UnsafeRawPointer(header).advanced(by: MemoryLayout<mach_header_64>.size).assumingMemoryBound(to: segment_command_64.self))
            
            self.reduce()
        }
        
        mutating func curNext() {
            curCmd = UnsafeMutableRawPointer(curCmd).advanced(by: Int(curCmd.pointee.cmdsize)).assumingMemoryBound(to: segment_command_64.self)
        }
        
        mutating func reduce() {
            (0..<header.pointee.ncmds).map { _ in }.forEach { self.curNext() }
            linkedBase = slide + Int(linkeditCmd.pointee.vmaddr) - Int(linkeditCmd.pointee.fileoff)
            if linkeditCmd == nil || symtabCmd == nil {
                symbolCount = 0
                return
            }
            symbolCount = symtabCmd.pointee.nsyms
            symbolIndex = 0
        }
        
        mutating func next() -> String? {
            if symbolCount <= symbolIndex {
                return nil
            }
            defer {
                symbolIndex += 1
            }
            return String(cString: strTable.advanced(by: Int(symbolTable.advanced(by: Int(symbolIndex)).pointee.n_un.n_strx)))
        }
    }
    let imageCount = _dyld_image_count()
    var imageIndex: UInt32! {
        didSet {
            self.symbolTable = SymbolTable(imageIndex: self.imageIndex)
            if symbolTable == nil {
                self.imageIndex += 1
            }
        }
    }
    
    var symbolTable: SymbolTable!
    
    init() {
        defer {
            imageIndex = 0
        }
    }
    
    mutating func next() -> String? {
        while imageIndex < imageCount {
            if let result = symbolTable.next() {
                return result
            } else {
                imageIndex += 1
            }
        }
        return nil
    }
}
