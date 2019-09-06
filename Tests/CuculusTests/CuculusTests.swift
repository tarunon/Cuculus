import XCTest
import Cuculus

func catBark() -> String {
    return "nyan"
}

func dogBark() -> String {
    return "bowwow"
}

struct CatS {
    static func bark() -> String {
        return "nyan"
    }

    static func _bark() -> String {
        return "bowwow"
    }

    func bark() -> String {
        return "nyan"
    }

    func _bark() -> String {
        return "bowwow"
    }
}

enum CatE {
    case tama
    static func bark() -> String {
        return "nyan"
    }

    static func _bark() -> String {
        return "bowwow"
    }

    func bark() -> String {
        return "nyan"
    }

    func _bark() -> String {
        return "bowwow"
    }
}

extension CatS {
    func eat(_ food: Any) -> Bool {
        return true
    }
    
    func _eat(_ food: Any) -> Bool {
        return false
    }
    
    func eatCollection<T: Collection>(_ foods: T) -> Bool {
        return !foods.isEmpty
    }
    
    func _eatCollection<T: Collection>(_ foods: T) -> Bool {
        return foods.isEmpty
    }

    func eatVariable(_ foods: Any ...) -> Bool {
        return !foods.isEmpty
    }
    
    func _eatVariable(_ foods: Any ...) -> Bool {
        return foods.isEmpty
    }
}

struct Animal<Food> {
    func eat(_ food: Food) -> Bool {
        return true
    }
    
    func _eat(_ food: Food) -> Bool {
        return false
    }
}

final class CuculusTests: XCTestCase {
    func testTopLevelFunction() {
        XCTAssertEqual(catBark(), "nyan")
        let injector = try! SwiftFunctionInjector(catBark)
        injector.inject(dogBark)
        XCTAssertEqual(catBark(), "bowwow")
    }

    func testStructInstanceMethod() {
        let cat = CatS()
        XCTAssertEqual(cat.bark(), "nyan")
        let injector = try! SwiftFunctionInjector(cat.bark)
        injector.inject(cat._bark)
        XCTAssertEqual(cat.bark(), "bowwow")
    }

    func testStructStaticMethod() {
        XCTAssertEqual(CatS.bark(), "nyan")
        let injector = try! SwiftFunctionInjector(CatS.bark)
        injector.inject(CatS._bark)
        XCTAssertEqual(CatS.bark(), "bowwow")
    }

    func testEnumInstanceMethod() {
        let cat = CatE.tama
        XCTAssertEqual(cat.bark(), "nyan")
        let injector = try! SwiftFunctionInjector(cat.bark)
        injector.inject(cat._bark)
        XCTAssertEqual(cat.bark(), "bowwow")
    }

    func testEnumStaticMethod() {
       XCTAssertEqual(CatE.bark(), "nyan")
       let injector = try! SwiftFunctionInjector(CatE.bark)
       injector.inject(CatE._bark)
       XCTAssertEqual(CatE.bark(), "bowwow")
    }
    
    func testStruct1AargumentMethod() {
        let cat = CatS()
        XCTAssertEqual(cat.eat(0), true)
        let injector = try! SwiftFunctionInjector(cat.eat)
        injector.inject(cat._eat)
        XCTAssertEqual(cat.eat(0), false)
    }
    
    // TODO: Is not work yet generics method.
    func _testStructGenericsMethod() {
        let cat = CatS()
        XCTAssertEqual(cat.eatCollection([1, 2, 3]), true)
        let injector = try! SwiftFunctionInjector(cat._eatCollection as ([Int]) -> (Bool))
        injector.inject(cat._eatCollection)
        XCTAssertEqual(cat.eatCollection([1, 2, 3]), false)
    }
    
    // TODO: is not work yet generics structures method.
    func _testGenericsStructMethod() {
        let animal = Animal<Int>()
        XCTAssertEqual(animal.eat(0), true)
        let injector = try! SwiftFunctionInjector(animal.eat)
        injector.inject(animal._eat)
        XCTAssertEqual(animal.eat(0), false)
    }
    
    func testStructVariableArgsMethod() {
        let cat = CatS()
        XCTAssertEqual(cat.eatVariable(1, 2, 3), true)
        let injector = try! SwiftFunctionInjector(cat.eatVariable)
        injector.inject(cat._eatVariable)
        XCTAssertEqual(cat.eatVariable(1, 2, 3), false)
    }

    static var allTests = [
        ("testTopLevelFunction", testTopLevelFunction),
        ("testStructInstanceMethod", testStructInstanceMethod),
        ("testStructStaticMethod", testStructStaticMethod),
        ("testEnumInstanceMethod", testEnumInstanceMethod),
        ("testEnumStaticMethod", testEnumStaticMethod),
        ("testStruct1AargumentMethod", testStruct1AargumentMethod),
        // ("testStructGenericsMethod", testStructGenericsMethod),
        // ("testGenericsStructMethod", testGenericsStructMethod),
        ("testStructVariableArgsMethod", testStructVariableArgsMethod),
    ]
}
