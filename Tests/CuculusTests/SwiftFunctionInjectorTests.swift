import XCTest
@testable import Cuculus

final class SwiftFunctionInjectorTests: XCTestCase {

    func testIsFunctionType() {
        func shouldBeFuncType<T>(_ type: T.Type) {
            XCTAssertTrue(SwiftFunctionInjector<Void>.isFunctionType(type: type), "\(type) should be function type")
        }

        shouldBeFuncType((() -> Void).self)
        shouldBeFuncType(((() -> Void) -> Void).self)

        func shouldNotBeFuncType<T>(_ type: T.Type) {
            XCTAssertFalse(SwiftFunctionInjector<Void>.isFunctionType(type: type), "\(type) shouldn't be function type")
        }

        shouldNotBeFuncType(Int.self)
        shouldNotBeFuncType(Array<() -> Void>.self)
    }
    
    func testSwiftFunctionHook() {
        struct Cat {
            func bark() -> String {
                return "にゃーん"
            }
            
            func myBark() -> String {
                return "わん"
            }
        }
        
        let cat = Cat()
        let targetInstructionPtr = unsafeBitCast(cat.bark, to: SwiftFuncWrapper.self)
            .instructionPtr()
        let destinationInstructionPtr = unsafeBitCast(cat.myBark, to: SwiftFuncWrapper.self)
            .instructionPtr()
        let injector = try! CFunctionInjector(targetInstructionPtr)
        injector.inject(destinationInstructionPtr)
        
        XCTAssertEqual(cat.bark(), "わん")
    }
}
