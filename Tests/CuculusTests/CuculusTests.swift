import XCTest
@testable import Cuculus
import MachO

final class CuculusTests: XCTestCase {    
    func testTopLevelFunction() {
        XCTAssertEqual(catBark(), "nyan")
        let injector = try! SwiftFunctionInjector("catBark")
        try! injector.inject("dogBark")
        XCTAssertEqual(catBark(), "bowwow")
    }

    func testStructInstanceMethod() {
        let cat = CatS()
        XCTAssertEqual(cat.bark(), "nyan")
        let injector = try! SwiftFunctionInjector("CatS.bark")
        try! injector.inject("CatS._bark")
        XCTAssertEqual(cat.bark(), "bowwow")
    }

    func testStructStaticMethod() {
        XCTAssertEqual(CatS.bark(), "nyan")
        let injector = try! SwiftFunctionInjector("static CatS.bark")
        try! injector.inject("static CatS._bark")
        XCTAssertEqual(CatS.bark(), "bowwow")
    }

    func testEnumInstanceMethod() {
        let cat = CatE.tama
        XCTAssertEqual(cat.bark(), "nyan")
        let injector = try! SwiftFunctionInjector("CatE.bark")
        try! injector.inject("CatE._bark")
        XCTAssertEqual(cat.bark(), "bowwow")
    }

    func testEnumStaticMethod() {
       XCTAssertEqual(CatE.bark(), "nyan")
       let injector = try! SwiftFunctionInjector("static CatE.bark")
       try! injector.inject("static CatE._bark")
       XCTAssertEqual(CatE.bark(), "bowwow")
    }
    
    func testStruct1AargumentMethod() {
        let cat = CatS()
        XCTAssertEqual(cat.eat(0), true)
        let injector = try! SwiftFunctionInjector("CatS.eat")
        try! injector.inject("CatS._eat")
        XCTAssertEqual(cat.eat(0), false)
    }
    
    func testStructGenericsMethod() {
        let cat = CatS()
        XCTAssertEqual(cat.eatCollection([1, 2, 3]), true)
        let injector = try! SwiftFunctionInjector("CatS.eatCollection")
        try! injector.inject("CatS._eatCollection")
        XCTAssertEqual(cat.eatCollection([1, 2, 3]), false)
    }
    
    func testGenericsStructMethod() {
        let animal = Animal<Int>()
        XCTAssertEqual(animal.eat(0), true)
        let injector = try! SwiftFunctionInjector("Animal.eat")
        try! injector.inject("Animal._eat")
        XCTAssertEqual(animal.eat(0), false)
    }
    
    func testStructVariableArgsMethod() {
        let cat = CatS()
        XCTAssertEqual(cat.eatVariable(1, 2, 3), true)
        let injector = try! SwiftFunctionInjector("CatS.eatVariable")
        try! injector.inject("CatS._eatVariable")
        XCTAssertEqual(cat.eatVariable(1, 2, 3), false)
    }
    
    func testComputedProperty() {
        let cat = CatS()
        XCTAssertEqual(cat.name, "tama")
        let injector = try! SwiftFunctionInjector("CatS.name", console: true)
        try! injector.inject("CatS._name")
        XCTAssertEqual(cat.name, "mike")
    }
    
    func testKanaFunction() {
        let cat = CatS()
        XCTAssertEqual(cat.和名(), "たま")
        let injector = try! SwiftFunctionInjector("CatS.和名")
        try! injector.inject("CatS._和名")
        XCTAssertEqual(cat.和名(), "みけ")
    }
    
    func testClassInstanceMethod() {
        let cat = CatC()
        XCTAssertEqual(cat.bark(), "nyan")
        let injector = try! SwiftFunctionInjector("CatC.bark")
        try! injector.inject("CatC._bark")
        XCTAssertEqual(cat.bark(), "bowwow")
    }
    
    func testSubclassInstanceMethod() {
        let cat: CatC = CatCSubclass()
        XCTAssertEqual(cat.bark(), "nyan2")
        let injector = try! SwiftFunctionInjector("CatCSubclass.bark")
        try! injector.inject("CatCSubclass._bark2")
        XCTAssertEqual(cat.bark(), "bowwow2")
    }
    
    func testExistentialInstanceMethod() {
        let cat = CatPInstance()
        XCTAssertEqual(cat.bark(), "nyan")
        let injector = try! SwiftFunctionInjector("CatP.bark")
        try! injector.inject("CatP._bark")
        XCTAssertEqual(cat.bark(), "bowwow")
    }

    static var allTests = [
        ("testTopLevelFunction", testTopLevelFunction),
        ("testStructInstanceMethod", testStructInstanceMethod),
        ("testStructStaticMethod", testStructStaticMethod),
        ("testEnumInstanceMethod", testEnumInstanceMethod),
        ("testEnumStaticMethod", testEnumStaticMethod),
        ("testStruct1AargumentMethod", testStruct1AargumentMethod),
        ("testStructGenericsMethod", testStructGenericsMethod),
        ("testGenericsStructMethod", testGenericsStructMethod),
        ("testStructVariableArgsMethod", testStructVariableArgsMethod),
        ("testComputedProperty", testComputedProperty),
        ("testKanaFunction", testKanaFunction),
        ("testClassInstanceMethod", testClassInstanceMethod),
        ("testSubclassInstanceMethod", testSubclassInstanceMethod),
        ("testExistentialInstanceMethod", testExistentialInstanceMethod)
    ]
}
