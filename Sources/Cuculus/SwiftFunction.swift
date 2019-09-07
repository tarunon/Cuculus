
struct SwiftFuncWrapper {
    var trampolinePtr: UnsafeMutablePointer<UInt64>
    var functionObject: UnsafeMutablePointer<SwiftFuncObject>
}

struct SwiftFuncObject {
    var originalTypePtr: UnsafeMutablePointer<UInt64>
    var unknown: UnsafeMutablePointer<UInt64>
    var address: UInt64
    var selfPtr: UnsafeMutablePointer<UInt64>
}


extension SwiftFuncWrapper {
    func instructionPtr() -> UnsafeMutableRawPointer {
        return valueTypeMethodPtr() ?? topLevelFunctionPtr()
    }

    private func topLevelFunctionPtr() -> UnsafeMutableRawPointer {
        return UnsafeMutableRawPointer(bitPattern: UInt(functionObject.pointee.address))!
    }

    private func valueTypeMethodPtr() -> UnsafeMutableRawPointer? {
        let closureThunk = UnsafeMutablePointer<UInt64>(bitPattern: UInt(functionObject.pointee.address))!
        #if swift(>=5.1)
        // Getting actual function ptr from instruction.
        // 0:  55                      push   rbp
        // 1:  48 89 e5                mov    rbp,rsp
        // 4:  5d                      pop    rbp
        // 5:  e9 XX XX ff ff          jmp    0xffffXXXX
        if (closureThunk.pointee << 16) == 0xe95de58948550000 {
            let relativeJmpRel = UInt64(bitPattern: Int64(Int32(
                bitPattern: UInt32(closureThunk.pointee >> 48)
                    + UInt32((closureThunk.advanced(by: 1).pointee << 48) >> 32)
                    + 0xa
            )))
            return UnsafeMutableRawPointer(bitPattern: UInt(functionObject.pointee.address &+ relativeJmpRel))!
        }
        #elseif swift(>=4.2)
        // Getting actual function ptr from instruction
        // 0:  55                      push   rbp
        // 1:  48 89 e5                mov    rbp,rsp
        // 4:  e8 XX XX ff ff          call   0xffffXXXX
        if (closureThunk.pointee << 24) == 0xe8e5894855000000 {
            let relativeCallRel = UInt64(bitPattern: Int64(Int32(
                bitPattern: UInt32(closureThunk.pointee >> 40)
                    + UInt32((closureThunk.advanced(by: 1).pointee << 56) >> 32)
                    + 0x9
            )))
            print(String((0x12345678deadbeaf << 56) >> 32, radix: 16))
            return UnsafeMutableRawPointer(bitPattern: UInt(functionObject.pointee.address &+ relativeCallRel))!
        }
        #endif
        return nil
    }
    
    // TODO: Will add other way to indetify instruction pointer, such as class/protocol.
}
