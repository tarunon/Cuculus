//
//  TestAssets.swift
//
//
//  Created by tarunon on 2019/09/06.
//

import Foundation

func globalFunction() -> Int {
    return 1
}

func globalFunction_hooked() -> Int {
    return 0
}

protocol TestAsset {
    static func function() -> Int
    static func function_hooked() -> Int
    static var property: Int { get }
    static var property_hooked: Int { get }
    static subscript(_ i: Int) -> Int { get }
    static subscript(hooked i: Int) -> Int { get }
    static func genericFunction<T>(_ arg: T) -> Int
    static func genericFunction_hooked<T>(_ arg: T) -> Int
    static func throwsFunction() throws -> Int
    static func throwsFunction_hooked() throws -> Int

    func function() -> Int
    func function_hooked() -> Int
    var property: Int { get }
    var property_hooked: Int { get }
    subscript(_ i: Int) -> Int { get }
    subscript(hooked i: Int) -> Int { get }
    func genericFunction<T>(_ arg: T) -> Int
    func genericFunction_hooked<T>(_ arg: T) -> Int
    func throwsFunction() throws -> Int
    func throwsFunction_hooked() throws -> Int
}

struct TestStruct: TestAsset {
    static var instance = TestStruct()
    static func function() -> Int {
        return 1
    }

    static func function_hooked() -> Int {
        return 0
    }

    static var property: Int {
        return 1
    }

    static var property_hooked: Int {
        return 0
    }

    static subscript(i: Int) -> Int {
        return 1
    }

    static subscript(hooked i: Int) -> Int {
        return 0
    }

    static func genericFunction<T>(_ arg: T) -> Int {
        return 1
    }

    static func genericFunction_hooked<T>(_ arg: T) -> Int {
        return 0
    }

    static func throwsFunction() throws -> Int {
        return 1
    }

    static func throwsFunction_hooked() throws -> Int {
        return 0
    }

    func function() -> Int {
        return 1
    }

    func function_hooked() -> Int {
        return 0
    }

    var property: Int {
        return 1
    }

    var property_hooked: Int {
        return 0
    }

    subscript(i: Int) -> Int {
        return 1
    }

    subscript(hooked i: Int) -> Int {
        return 0
    }

    func genericFunction<T>(_ arg: T) -> Int {
        return 1
    }

    func genericFunction_hooked<T>(_ arg: T) -> Int {
        return 0
    }

    func throwsFunction() throws -> Int {
        return 1
    }

    func throwsFunction_hooked() throws -> Int {
        return 0
    }
}

enum TestEnum: TestAsset {
    case instance
    static func function() -> Int {
        return 1
    }

    static func function_hooked() -> Int {
        return 0
    }

    static var property: Int {
        return 1
    }

    static var property_hooked: Int {
        return 0
    }

    static subscript(i: Int) -> Int {
        return 1
    }

    static subscript(hooked i: Int) -> Int {
        return 0
    }

    static func genericFunction<T>(_ arg: T) -> Int {
        return 1
    }

    static func genericFunction_hooked<T>(_ arg: T) -> Int {
        return 0
    }

    static func throwsFunction() throws -> Int {
        return 1
    }

    static func throwsFunction_hooked() throws -> Int {
        return 0
    }

    func function() -> Int {
        return 1
    }

    func function_hooked() -> Int {
        return 0
    }

    var property: Int {
        return 1
    }

    var property_hooked: Int {
        return 0
    }

    subscript(i: Int) -> Int {
        return 1
    }

    subscript(hooked i: Int) -> Int {
        return 0
    }

    func genericFunction<T>(_ arg: T) -> Int {
        return 1
    }

    func genericFunction_hooked<T>(_ arg: T) -> Int {
        return 0
    }

    func throwsFunction() throws -> Int {
        return 1
    }

    func throwsFunction_hooked() throws -> Int {
        return 0
    }
}

class TestClass: TestAsset {
    static var instance = TestClass()
    class func function() -> Int {
        return 1
    }

    class func function_hooked() -> Int {
        return 0
    }

    class var property: Int {
        return 1
    }

    class var property_hooked: Int {
        return 0
    }

    class subscript(i: Int) -> Int {
        return 1
    }

    class subscript(hooked i: Int) -> Int {
        return 0
    }

    class func genericFunction<T>(_ arg: T) -> Int {
        return 1
    }

    class func genericFunction_hooked<T>(_ arg: T) -> Int {
        return 0
    }

    class func throwsFunction() throws -> Int {
        return 1
    }

    class func throwsFunction_hooked() throws -> Int {
        return 0
    }

    func function() -> Int {
        return 1
    }

    func function_hooked() -> Int {
        return 0
    }

    var property: Int {
        return 1
    }

    var property_hooked: Int {
        return 0
    }

    subscript(i: Int) -> Int {
        return 1
    }

    subscript(hooked i: Int) -> Int {
        return 0
    }

    func genericFunction<T>(_ arg: T) -> Int {
        return 1
    }

    func genericFunction_hooked<T>(_ arg: T) -> Int {
        return 0
    }

    func throwsFunction() throws -> Int {
        return 1
    }

    func throwsFunction_hooked() throws -> Int {
        return 0
    }
}

class TestSubclass: TestClass {
    static var subclassInstance: TestClass = TestSubclass()
    override class func function() -> Int {
        return 1
    }

    override class func function_hooked() -> Int {
        return 0
    }

    override class var property: Int {
        return 1
    }

    override class var property_hooked: Int {
        return 0
    }

    override class subscript(i: Int) -> Int {
        return 1
    }

    override class subscript(hooked i: Int) -> Int {
        return 0
    }

    override class func genericFunction<T>(_ arg: T) -> Int {
        return 1
    }

    override class func genericFunction_hooked<T>(_ arg: T) -> Int {
        return 0
    }

    override class func throwsFunction() throws -> Int {
        return 1
    }

    override class func throwsFunction_hooked() throws -> Int {
        return 0
    }

    override func function() -> Int {
        return 1
    }

    override func function_hooked() -> Int {
        return 0
    }

    override var property: Int {
        return 1
    }

    override var property_hooked: Int {
        return 0
    }

    override subscript(i: Int) -> Int {
        return 1
    }

    override subscript(hooked i: Int) -> Int {
        return 0
    }

    override func genericFunction<T>(_ arg: T) -> Int {
        return 1
    }

    override func genericFunction_hooked<T>(_ arg: T) -> Int {
        return 0
    }

    override func throwsFunction() throws -> Int {
        return 1
    }

    override func throwsFunction_hooked() throws -> Int {
        return 0
    }
}

protocol TestExistential: TestAsset {

}

extension TestExistential {
    static func function() -> Int {
        return 1
    }

    static func function_hooked() -> Int {
        return 0
    }

    static var property: Int {
        return 1
    }

    static var property_hooked: Int {
        return 0
    }

    static subscript(i: Int) -> Int {
        return 1
    }

    static subscript(hooked i: Int) -> Int {
        return 0
    }

    static func genericFunction<T>(_ arg: T) -> Int {
        return 1
    }

    static func genericFunction_hooked<T>(_ arg: T) -> Int {
        return 0
    }

    static func throwsFunction() throws -> Int {
        return 1
    }

    static func throwsFunction_hooked() throws -> Int {
        return 0
    }

    func function() -> Int {
        return 1
    }

    func function_hooked() -> Int {
        return 0
    }

    var property: Int {
        return 1
    }

    var property_hooked: Int {
        return 0
    }

    subscript(i: Int) -> Int {
        return 1
    }

    subscript(hooked i: Int) -> Int {
        return 0
    }

    func genericFunction<T>(_ arg: T) -> Int {
        return 1
    }

    func genericFunction_hooked<T>(_ arg: T) -> Int {
        return 0
    }

    func throwsFunction() throws -> Int {
        return 1
    }

    func throwsFunction_hooked() throws -> Int {
        return 0
    }
}

struct TestExistentialImpl: TestExistential {
    static var instance = TestExistentialImpl()
}

struct TestGenericStruct<T>: TestAsset {
    static func function() -> Int {
        return 1
    }

    static func function_hooked() -> Int {
        return 0
    }

    static var property: Int {
        return 1
    }

    static var property_hooked: Int {
        return 0
    }

    static subscript(i: Int) -> Int {
        return 1
    }

    static subscript(hooked i: Int) -> Int {
        return 0
    }

    static func genericFunction<T>(_ arg: T) -> Int {
        return 1
    }

    static func genericFunction_hooked<T>(_ arg: T) -> Int {
        return 0
    }

    static func throwsFunction() throws -> Int {
        return 1
    }

    static func throwsFunction_hooked() throws -> Int {
        return 0
    }

    func function() -> Int {
        return 1
    }

    func function_hooked() -> Int {
        return 0
    }

    var property: Int {
        return 1
    }

    var property_hooked: Int {
        return 0
    }

    subscript(i: Int) -> Int {
        return 1
    }

    subscript(hooked i: Int) -> Int {
        return 0
    }

    func genericFunction<T>(_ arg: T) -> Int {
        return 1
    }

    func genericFunction_hooked<T>(_ arg: T) -> Int {
        return 0
    }

    func throwsFunction() throws -> Int {
        return 1
    }

    func throwsFunction_hooked() throws -> Int {
        return 0
    }
}

