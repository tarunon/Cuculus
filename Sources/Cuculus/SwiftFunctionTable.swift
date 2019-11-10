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
    return _swiftDemangle(mangledName: mangledName, mangledNameLength: UInt(mangledName.utf8.count), outputBuffer: nil, outputBufferSize: nil, flags: 0).map { String(cString: $0) } ?? ""
}

public struct SwiftFunction {
    public var funcName: String
    public var symbol: Symbol
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
            uniquingKeysWith: { Int(bitPattern: $0.address) < Int(bitPattern: $1.address) ? $0 : $1  }
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
        return (!funcName.hasPrefix("static ") != candidate.hasPrefix("static ")) && candidate.contains(escapedFuncName)
    }
    
    func match(_ funcName: String, select: ([SwiftFunction]) -> SwiftFunction?) -> SwiftFunction? {
        if let symbol = table[funcName] {
            return SwiftFunction(funcName: funcName, symbol: symbol)
        }
        return select(Array(table.filter({ SwiftFunctionTable.match(funcName: funcName, candidate: $0.key) }).map({ SwiftFunction(funcName: $0.key, symbol: $0.value) })))
    }
}
