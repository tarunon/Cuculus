//
//  SwiftFunctionTable
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

public struct SwiftFunction {
    public var funcName: String
    public var symbol: Symbol
    
    var actualSymbolName: String {
        if symbol.name.hasPrefix("_") {
            return String(symbol.name[symbol.name.index(symbol.name.startIndex, offsetBy: 1)...])
        }
        return symbol.name
    }
}

public struct Symbol {
    public var name: String
    public var address: UnsafeMutableRawPointer
}

struct SwiftFunctionTable {
    var table: [String: Symbol]
    
    private init() {
        #if compiler(>=5.0)
        self.table = Dictionary(
            SymbolList().lazy
                .filter { $0.name.hasPrefix("_$s") }
                .filter { symbol -> Bool in
                    // https://github.com/apple/swift/blob/swift-5.0-branch/docs/ABI/Mangling.rst
                    let iv = [
                        "i", // entity-spec ::= label-list type file-discriminator? 'i' ACCESSOR // subscript
                        "v", // entity-spec ::= decl-name label-list? type 'v' ACCESSOR          // variable
                        ]
                        .flatMap { entitySpec -> [String] in
                            [
                                entitySpec + "m", // ACCESSOR ::= 'm' // materializeForSet
                                entitySpec + "s", // ACCESSOR ::= 's' // setter
                                entitySpec + "g", // ACCESSOR ::= 'g' // getter
                                entitySpec + "G", // ACCESSOR ::= 'G' // global getter
                                entitySpec + "w", // ACCESSOR ::= 'w' // willSet
                                entitySpec + "W", // ACCESSOR ::= 'W' // didSet
                                entitySpec + "r", // ACCESSOR ::= 'r' // read
                                entitySpec + "M", // ACCESSOR ::= 'M' // modify (temporary)
                            ]
                        }
                    return (iv + ["F"]) // entity-spec ::= decl-name label-list function-signature generic-signature? 'F'    // function
                        .flatMap { [$0, $0 + "Z"] } // static ::= 'Z'
                        .contains(where: { symbol.name.hasSuffix($0) })
                }
                .map { (key: swiftDemangle($0.name), value: $0) },
            uniquingKeysWith: { $1 }
        )
        #elseif compiler(>=4.2)
        self.table = Dictionary(
            SymbolList().lazy
                .filter { $0.name.hasPrefix("_$S") }
                .filter { symbol -> Bool in
                    // https://github.com/apple/swift/blob/swift-4.2-branch/docs/ABI/Mangling.rst
                    let iv = [
                        "i", // entity-spec ::= label-list type file-discriminator? 'i' ACCESSOR // subscript
                        "v", // entity-spec ::= decl-name label-list? type 'v' ACCESSOR          // variable
                        ]
                        .flatMap { entitySpec -> [String] in
                            [
                                entitySpec + "m", // ACCESSOR ::= 'm' // materializeForSet
                                entitySpec + "s", // ACCESSOR ::= 's' // setter
                                entitySpec + "g", // ACCESSOR ::= 'g' // getter
                                entitySpec + "G", // ACCESSOR ::= 'G' // global getter
                                entitySpec + "w", // ACCESSOR ::= 'w' // willSet
                                entitySpec + "W", // ACCESSOR ::= 'W' // didSet
                            ]
                    }
                    return (iv + ["F"]) // entity-spec ::= decl-name label-list function-signature generic-signature? 'F'    // function
                        .flatMap { [$0, $0 + "Z"] } // static ::= 'Z'
                        .contains(where: { symbol.name.hasSuffix($0) })
                }
                .map { (key: swiftDemangle($0.name), value: $0) },
            uniquingKeysWith: { $1 }
        )
        #endif
    }
    
    static var instance = SwiftFunctionTable()
    
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
    
    func match(_ funcName: String, select: ([SwiftFunction]) -> SwiftFunction?) -> SwiftFunction? {
        if let symbol = table[funcName] {
            return SwiftFunction(funcName: funcName, symbol: symbol)
        }
        return select(Array(table.filter({ SwiftFunctionTable.match(funcName: funcName, candidate: $0.key) }).map({ SwiftFunction(funcName: $0.key, symbol: $0.value) })))
    }
}

struct SymbolList: Sequence {
    typealias Iterator = SymbolIterator
    func makeIterator() -> SymbolIterator {
        return SymbolIterator()
    }
}

struct SymbolIterator: IteratorProtocol {
    typealias Element = Symbol
    struct SymbolTable: IteratorProtocol {
        typealias Element = Symbol
        
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
        
        private mutating func curNext() {
            curCmd = UnsafeMutableRawPointer(curCmd).advanced(by: Int(curCmd.pointee.cmdsize)).assumingMemoryBound(to: segment_command_64.self)
        }
        
        private mutating func reduce() {
            (0..<header.pointee.ncmds).map { _ in }.forEach { self.curNext() }
            linkedBase = slide + Int(linkeditCmd.pointee.vmaddr) - Int(linkeditCmd.pointee.fileoff)
            if linkeditCmd == nil || symtabCmd == nil {
                symbolCount = 0
                return
            }
            symbolCount = symtabCmd.pointee.nsyms
            symbolIndex = 0
        }
        
        mutating func next() -> Symbol? {
            if symbolCount <= symbolIndex {
                return nil
            }
            defer {
                symbolIndex += 1
            }
            let symbol = Symbol(
                name: String(cString: strTable.advanced(by: Int(symbolTable.advanced(by: Int(symbolIndex)).pointee.n_un.n_strx))),
                address: UnsafeMutableRawPointer(bitPattern: Int(linkedBase) + Int(symbolTable.advanced(by: Int(symbolIndex)).pointee.n_value))!
            )
            return symbol
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
    
    mutating func next() -> Symbol? {
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
