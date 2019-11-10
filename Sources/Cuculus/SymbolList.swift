//
//  SymbolTable.swift
//  Cuculus
//
//  Created by tarunon on 2019/11/10.
//

import Foundation
import MachO

// dlfcn.h
// #define    RTLD_DEFAULT    ((void *) -2)    /* Use default search algorithm. */
let RTLD_DEFAULT = UnsafeMutableRawPointer(bitPattern: -2)

public struct Symbol {
    public var name: String
    public var address: UnsafeMutableRawPointer
}

struct SymbolList: Sequence {
    struct _Iterator: IteratorProtocol {
        typealias Element = Symbol

        struct SegmentCommandList: Sequence {
            var header: UnsafePointer<mach_header>
            struct _Iterator: IteratorProtocol {
                typealias Element = UnsafeMutablePointer<segment_command_64>
                var index: UInt32
                var count: UInt32
                var curCmd: UnsafeMutablePointer<segment_command_64>

                init(header: UnsafePointer<mach_header>) {
                    index = 0
                    count = header.pointee.ncmds
                    curCmd = UnsafeMutablePointer(mutating: UnsafeRawPointer(header).advanced(by: MemoryLayout<mach_header_64>.size).assumingMemoryBound(to: segment_command_64.self))
                }

                mutating func next() -> UnsafeMutablePointer<segment_command_64>? {
                    if count <= index { return nil }
                    defer {
                        index += 1
                        curCmd = UnsafeMutableRawPointer(curCmd).advanced(by: Int(curCmd.pointee.cmdsize)).assumingMemoryBound(to: segment_command_64.self)
                    }
                    return curCmd
                }
            }
            func makeIterator() -> _Iterator {
                return _Iterator(header: header)
            }
        }

        struct SymbolTableIterator: IteratorProtocol {
            typealias Element = Symbol

            static let linkeditName = SEG_LINKEDIT.data(using: String.Encoding.utf8)!.map({ $0 })
            let header: UnsafePointer<mach_header>
            let slide: Int

            var linkeditCmd: UnsafeMutablePointer<segment_command_64>!
            var symtabCmd: UnsafeMutablePointer<symtab_command>!

            var linkeditBase: Int!
            var symbolTable: UnsafeMutablePointer<nlist_64> {
                return UnsafeMutablePointer(bitPattern: linkeditBase + Int(symtabCmd.pointee.symoff))!
            }
            var strTable: UnsafeMutablePointer<UInt8> {
                return UnsafeMutablePointer(bitPattern: linkeditBase + Int(symtabCmd.pointee.stroff))!
            }

            var symbolCount: UInt32!
            var symbolIndex: UInt32!

            init?(imageIndex: UInt32) {
                guard let header = _dyld_get_image_header(imageIndex) else {
                    return nil
                }
                self.header = header
                self.slide = _dyld_get_image_vmaddr_slide(imageIndex)

                SegmentCommandList(header: header).forEach { cmd in
                    if cmd.pointee.cmd == LC_SEGMENT_64 {
                        if UInt8(cmd.pointee.segname.0) == SymbolTableIterator.linkeditName[0] &&
                           UInt8(cmd.pointee.segname.1) == SymbolTableIterator.linkeditName[1] &&
                           UInt8(cmd.pointee.segname.2) == SymbolTableIterator.linkeditName[2] &&
                           UInt8(cmd.pointee.segname.3) == SymbolTableIterator.linkeditName[3] &&
                           UInt8(cmd.pointee.segname.4) == SymbolTableIterator.linkeditName[4] &&
                           UInt8(cmd.pointee.segname.5) == SymbolTableIterator.linkeditName[5] &&
                           UInt8(cmd.pointee.segname.6) == SymbolTableIterator.linkeditName[6] &&
                           UInt8(cmd.pointee.segname.7) == SymbolTableIterator.linkeditName[7] &&
                           UInt8(cmd.pointee.segname.8) == SymbolTableIterator.linkeditName[8] &&
                           UInt8(cmd.pointee.segname.9) == SymbolTableIterator.linkeditName[9] {
                            linkeditCmd = cmd
                        }
                    } else if cmd.pointee.cmd == LC_SYMTAB {
                        symtabCmd = UnsafeMutableRawPointer(cmd).assumingMemoryBound(to: symtab_command.self)
                    }
                }

                linkeditBase = slide + Int(linkeditCmd.pointee.vmaddr) - Int(linkeditCmd.pointee.fileoff)
                if linkeditCmd == nil || symtabCmd == nil {
                    symbolCount = 0
                    return
                }
                symbolCount = symtabCmd.pointee.nsyms
                symbolIndex = 0
            }

            mutating func next() -> Symbol? {
                while symbolIndex < symbolCount {
                    defer {
                        symbolIndex += 1
                    }
                    let nlist = symbolTable.advanced(by: Int(symbolIndex)).pointee
                    if nlist.n_sect == NO_SECT {
                        continue
                    }
                    var symbol = Symbol(
                        name: String(cString: strTable.advanced(by: Int(nlist.n_un.n_strx))),
                        address: UnsafeMutableRawPointer(bitPattern: Int(linkeditBase) + Int(nlist.n_value))!
                    )
                    if symbol.name.hasPrefix("_$s") || symbol.name.hasPrefix("_$S") {
                        if nlist.n_type == 15 { // Note: if n_type is 15, require to set offset in address
                            symbol.address = dlsym(RTLD_DEFAULT, String(symbol.name.dropFirst()))
                        }
                    }
                    return symbol
                }
                return nil
            }
        }
        let imageCount = _dyld_image_count()
        var imageIndex: UInt32! {
            didSet {
                self.symbolTable = SymbolTableIterator(imageIndex: self.imageIndex)
                if symbolTable == nil {
                    self.imageIndex += 1
                }
            }
        }

        var symbolTable: SymbolTableIterator!

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

    typealias Iterator = _Iterator
    func makeIterator() -> _Iterator {
        return _Iterator()
    }
}
