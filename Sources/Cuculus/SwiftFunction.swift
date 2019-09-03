
// Ref: https://academy.realm.io/jp/posts/sash-zats-swift-swizzling/
struct SwiftFuncWrapper {
    var trampolinePtr: UnsafeMutablePointer<UInt64>
    var functionObject: UnsafeMutablePointer<SwiftFuncObject>

    func instructionPtr() -> UnsafeMutableRawPointer {
        return valueTypeMethodPtr() ?? topLevelFunctionPtr()
    }

    private func topLevelFunctionPtr() -> UnsafeMutableRawPointer {
        return UnsafeMutableRawPointer(bitPattern: UInt(functionObject.pointee.address))!
    }

    private func valueTypeMethodPtr() -> UnsafeMutableRawPointer? {
        let closureThunk = UnsafeMutablePointer<UInt64>(bitPattern: UInt(functionObject.pointee.address))!
        // Getting actual function ptr from instruction.
        // 0:  55                      push   rbp
        // 1:  48 89 e5                mov    rbp,rsp
        // 4:  5d                      pop    rbp
        // 5:  e9 XX XX ff ff          jmp    0xffffXXXX
        if (closureThunk.pointee << 16) == 0xe95de58948550000 {
            let relativeJmpRel = closureThunk.pointee >> 48 + (closureThunk.advanced(by: 1).pointee << 48) >> 32 + 0xffffffff0000000a
            return UnsafeMutableRawPointer(bitPattern: UInt(functionObject.pointee.address &+ relativeJmpRel))!
        }
        return nil
    }
    
    // TODO: Will add other way to indetify instruction pointer, such as class/protocol.
}

// Ref: https://academy.realm.io/jp/posts/sash-zats-swift-swizzling/
struct SwiftFuncObject {
    var originalTypePtr: UnsafeMutablePointer<UInt64>
    var unknown: UnsafeMutablePointer<UInt64>
    var address: UInt64
    var selfPtr: UnsafeMutablePointer<UInt64>
}
