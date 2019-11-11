//
//  File.swift
//  
//
//  Created by tarunon on 2019/09/03.
//

import Foundation

/// Management class for Swift Function Inject.
/// When release this object, the method work as original.
public class SwiftFunctionInjector {
    var internalInjector: CFunctionInjector
    var debug: Bool
        
    public static func selectFunction(_ functions: [SwiftFunction]) -> SwiftFunction? {
        return functions.sorted(by: { $0.symbol.name.count < $1.symbol.name.count }).first(where: { _ in true })
    }

    static func chooseFunction(_ functions: [SwiftFunction], select: ([SwiftFunction]) -> SwiftFunction?) -> SwiftFunction? {
        if functions.count > 1 {
            return select(functions)
        }
        return functions.first
    }

    /// Create FunctionInjector for change origin method behavior.
    /// - Parameter target: The target method. Support struct/enum or top level function.
    public init(_ targetFuncName: String, selectFunction: ([SwiftFunction]) -> SwiftFunction? = selectFunction(_:), debug: Bool = false) throws {
        self.debug = debug
        guard let function = SwiftFunctionInjector.chooseFunction(SwiftFunctionTable.instance.match(targetFuncName), select: selectFunction) else {
            throw CFunctionInjector.Error(message: "function name \(targetFuncName) is not found on mangle table")
        }
        if debug {
            print("Function selected: \(function)")
        }
        internalInjector = try CFunctionInjector(function.symbol.address)
    }

    /// Change target method behavior as destination method.
    /// - Parameter destination: The destination method. Should be same type as target.
    public func inject(_ destinationFuncName: String, selectFunction: ([SwiftFunction]) -> SwiftFunction? = selectFunction(_:)) throws {
        guard let function = SwiftFunctionInjector.chooseFunction(SwiftFunctionTable.instance.match(destinationFuncName), select: selectFunction) else {
            throw CFunctionInjector.Error(message: "function name \(destinationFuncName) is not found on mangle table")
        }
        if debug {
            print("Function selected: \(function)")
        }
        internalInjector.inject(function.symbol.address)
    }
    
    /// Change origin method behavior as original.
    public func reset() {
        internalInjector.reset()
    }
}
