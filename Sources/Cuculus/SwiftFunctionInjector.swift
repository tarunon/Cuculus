//
//  File.swift
//  
//
//  Created by tarunon on 2019/09/03.
//

import Foundation

/// Management class for Swift Function Inject.
/// When release this object, the method work as original.
public class SwiftFunctionInjector<T> {
    var internalInjector: CFunctionInjector

    /// Create FunctionInjector for change origin method behavior.
    /// - Parameter target: The target method. Support struct/enum or top level function.
    public init(_ target: T) throws {
        guard SwiftFunctionInjector.isFunctionType(type: T.self) else {
            throw CFunctionInjector.Error(message: "Argument is not function. \(T.self)")
        }
        internalInjector = try CFunctionInjector(unsafeBitCast(target, to: SwiftFuncWrapper.self).instructionPtr())
    }

    static func isFunctionType<T>(type: T.Type) -> Bool {
        // Check metadata kind value which is located at the head of metadata.
        // Function type kind is defined as 2
        // Reference: https://github.com/apple/swift/blob/master/include/swift/ABI/MetadataKind.def
        let typeKind = unsafeBitCast(type, to: UnsafePointer<UInt8>.self)
        let funcKind = 2
        return typeKind.pointee == funcKind
    }

    /// Change target method behavior as destination method.
    /// - Parameter destination: The destination method. Should be same type as target.
    public func inject(_ destination: T) {
        internalInjector.inject(unsafeBitCast(destination, to: SwiftFuncWrapper.self).instructionPtr())
    }
    
    /// Change origin method behavior as original.
    public func reset() {
        internalInjector.reset()
    }
}
