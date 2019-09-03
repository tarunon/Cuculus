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

    static var allTests = [
        ("testTopLevelFunction", testTopLevelFunction),
        ("testStructInstanceMethod", testStructInstanceMethod),
        ("testStructStaticMethod", testStructStaticMethod),
        ("testEnumInstanceMethod", testEnumInstanceMethod),
        ("testEnumStaticMethod", testEnumStaticMethod),
    ]
}
