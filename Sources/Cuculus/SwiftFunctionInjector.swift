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
    var console: Bool
        
    public static func selectFunction(_ keys: AnySequence<String>) -> String? {
        return keys.first(where: { _ in true })
    }

    /// Create FunctionInjector for change origin method behavior.
    /// - Parameter target: The target method. Support struct/enum or top level function.
    public init(_ targetFuncName: String, selectFunction: (AnySequence<String>) -> String? = selectFunction(_:), console: Bool = false) throws {
        self.console = console
        guard let pair = SwiftMangleTable.instance.match(targetFuncName, select: selectFunction) else {
            throw CFunctionInjector.Error(message: "function name \(targetFuncName) is not found on mangle table")
        }
        if console {
            print("Function selected: \(pair)")
        }
        internalInjector = try CFunctionInjector(String(pair.actualSymbolName))
    }

    /// Change target method behavior as destination method.
    /// - Parameter destination: The destination method. Should be same type as target.
    public func inject(_ destinationFuncName: String, selectFunction: (AnySequence<String>) -> String? = selectFunction(_:)) throws {
        guard let pair = SwiftMangleTable.instance.match(destinationFuncName, select: selectFunction) else {
            throw CFunctionInjector.Error(message: "function name \(destinationFuncName) is not found on mangle table")
        }
        if console {
            print("Function selected: \(pair)")
        }
        try internalInjector.inject(pair.actualSymbolName)
    }
    
    /// Change origin method behavior as original.
    public func reset() {
        internalInjector.reset()
    }
}
