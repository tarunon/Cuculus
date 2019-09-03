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
    /// - Parameter origin: The origin method. Support struct/enum or top level function.
    public init(_ origin: T) throws {
        guard SwiftFunctionInjector.isFunctionType(type: T.self) else {
            throw CFunctionInjector.Error(message: "Argument is not function. \(T.self)")
        }
        internalInjector = try CFunctionInjector(unsafeBitCast(origin, to: SwiftFuncWrapper.self).instructionPtr())
    }

    static func isFunctionType<T>(type: T.Type) -> Bool {
        // Check metadata kind value which is located at the head of metadata.
        // Function type kind is defined as 2
        // Reference: https://github.com/apple/swift/blob/master/include/swift/ABI/MetadataKind.def
        let typeKind = unsafeBitCast(type, to: UnsafePointer<UInt8>.self)
        let funcKind = 2
        return typeKind.pointee == funcKind
    }

    /// Change origin method behavior as target method.
    /// - Parameter target: The target method. Should be same type as origin.
    public func inject(_ target: T) {
        internalInjector.inject(unsafeBitCast(target, to: SwiftFuncWrapper.self).instructionPtr())
    }
}
