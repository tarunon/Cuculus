import XCTest
import Cuculus
import MachO

final class CuculusTests: XCTestCase {
    func assert(
        function: () -> Int,
        originalFunctionName: String,
        originalFunctionSelect: ([SwiftFunction]) -> SwiftFunction? = SwiftFunctionInjector.selectFunction(_:),
        hookedFunctionName: String,
        hookedFunctionSelect: ([SwiftFunction]) -> SwiftFunction? = SwiftFunctionInjector.selectFunction(_:),
        debug: Bool = false,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        do {
            XCTAssertEqual(function(), 1, file: file, line: line)
            let injector = try SwiftFunctionInjector(originalFunctionName, selectFunction: originalFunctionSelect, debug: debug)
            try injector.inject(hookedFunctionName, selectFunction: hookedFunctionSelect)
            XCTAssertEqual(function(), 0, file: file, line: line)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testGlobalFunc() {
        assert(
            function: globalFunction,
            originalFunctionName: "globalFunction",
            hookedFunctionName: "globalFunction_hooked"
        )
    }

    func testStructFunc() {
        let instance = TestStruct.instance
        let type = TestStruct.self

        assert(
            function: type.function,
            originalFunctionName: "static TestStruct.function",
            hookedFunctionName: "static TestStruct.function_hooked"
        )

        assert(
            function: { type.property },
            originalFunctionName: "static TestStruct.property",
            hookedFunctionName: "static TestStruct.property_hooked"
        )

        #if compiler(>=5.0)
        assert(
            function: { type[0] },
            originalFunctionName: "static TestStruct.subscript",
            hookedFunctionName: "static TestStruct.subscript",
            hookedFunctionSelect: { $0.first(where: { $0.funcName.contains("hooked:") }) }
        )
        #endif

        assert(
            function: { type.genericFunction(0) },
            originalFunctionName: "static TestStruct.genericFunction",
            hookedFunctionName: "static TestStruct.genericFunction_hooked"
        )

        assert(
            function: { try! type.throwsFunction() },
            originalFunctionName: "static TestStruct.throwsFunction",
            hookedFunctionName: "static TestStruct.throwsFunction_hooked"
        )

        assert(
            function: instance.function,
            originalFunctionName: "TestStruct.function",
            hookedFunctionName: "TestStruct.function_hooked"
        )

        assert(
            function: { instance.property },
            originalFunctionName: "TestStruct.property",
            hookedFunctionName: "TestStruct.property_hooked"
        )

        assert(
            function: { instance[0] },
            originalFunctionName: "TestStruct.subscript",
            hookedFunctionName: "TestStruct.subscript",
            hookedFunctionSelect: { $0.first(where: { $0.funcName.contains("hooked:") }) }
        )

        assert(
            function: { instance.genericFunction(0) },
            originalFunctionName: "TestStruct.genericFunction",
            hookedFunctionName: "TestStruct.genericFunction_hooked"
        )

        assert(
            function: { try! instance.throwsFunction() },
            originalFunctionName: "TestStruct.throwsFunction",
            hookedFunctionName: "TestStruct.throwsFunction_hooked"
        )
    }

    func testEnumFunc() {
        let instance = TestEnum.instance
        let type = TestEnum.self

        assert(
            function: type.function,
            originalFunctionName: "static TestEnum.function",
            hookedFunctionName: "static TestEnum.function_hooked"
        )

        assert(
            function: { type.property },
            originalFunctionName: "static TestEnum.property",
            hookedFunctionName: "static TestEnum.property_hooked"
        )

        #if compiler(>=5.0)
        assert(
            function: { type[0] },
            originalFunctionName: "static TestEnum.subscript",
            hookedFunctionName: "static TestEnum.subscript",
            hookedFunctionSelect: { $0.first(where: { $0.funcName.contains("hooked:") }) }
        )
        #endif

        assert(
            function: { type.genericFunction(0) },
            originalFunctionName: "static TestEnum.genericFunction",
            hookedFunctionName: "static TestEnum.genericFunction_hooked"
        )

        assert(
            function: { try! type.throwsFunction() },
            originalFunctionName: "static TestEnum.throwsFunction",
            hookedFunctionName: "static TestEnum.throwsFunction_hooked"
        )

        assert(
            function: instance.function,
            originalFunctionName: "TestEnum.function",
            hookedFunctionName: "TestEnum.function_hooked"
        )

        assert(
            function: { instance.property },
            originalFunctionName: "TestEnum.property",
            hookedFunctionName: "TestEnum.property_hooked"
        )

        assert(
            function: { instance[0] },
            originalFunctionName: "TestEnum.subscript",
            hookedFunctionName: "TestEnum.subscript",
            hookedFunctionSelect: { $0.first(where: { $0.funcName.contains("hooked:") }) }
        )

        assert(
            function: { instance.genericFunction(0) },
            originalFunctionName: "TestEnum.genericFunction",
            hookedFunctionName: "TestEnum.genericFunction_hooked"
        )

        assert(
            function: { try! instance.throwsFunction() },
            originalFunctionName: "TestEnum.throwsFunction",
            hookedFunctionName: "TestEnum.throwsFunction_hooked"
        )
    }

    func testClassFunc() {
        let instance = TestClass.instance
        let type = TestClass.self

        assert(
            function: type.function,
            originalFunctionName: "static TestClass.function",
            hookedFunctionName: "static TestClass.function_hooked"
        )

        assert(
            function: { type.property },
            originalFunctionName: "static TestClass.property",
            hookedFunctionName: "static TestClass.property_hooked"
        )

        #if compiler(>=5.0)
        assert(
            function: { type[0] },
            originalFunctionName: "static TestClass.subscript",
            hookedFunctionName: "static TestClass.subscript",
            hookedFunctionSelect: { $0.first(where: { $0.funcName.contains("hooked:") }) }
        )
        #endif

        assert(
            function: { type.genericFunction(0) },
            originalFunctionName: "static TestClass.genericFunction",
            hookedFunctionName: "static TestClass.genericFunction_hooked"
        )

        assert(
            function: { try! type.throwsFunction() },
            originalFunctionName: "static TestClass.throwsFunction",
            hookedFunctionName: "static TestClass.throwsFunction_hooked"
        )

        assert(
            function: instance.function,
            originalFunctionName: "TestClass.function",
            hookedFunctionName: "TestClass.function_hooked"
        )

        assert(
            function: { instance.property },
            originalFunctionName: "TestClass.property",
            hookedFunctionName: "TestClass.property_hooked"
        )

        assert(
            function: { instance[0] },
            originalFunctionName: "TestClass.subscript",
            hookedFunctionName: "TestClass.subscript",
            hookedFunctionSelect: { $0.first(where: { $0.funcName.contains("hooked:") }) }
        )

        assert(
            function: { instance.genericFunction(0) },
            originalFunctionName: "TestClass.genericFunction",
            hookedFunctionName: "TestClass.genericFunction_hooked"
        )

        assert(
            function: { try! instance.throwsFunction() },
            originalFunctionName: "TestClass.throwsFunction",
            hookedFunctionName: "TestClass.throwsFunction_hooked"
        )
    }

    func testSubclassFunc() {
        let instance = TestSubclass.subclassInstance
        let type = TestSubclass.self

        assert(
            function: type.function,
            originalFunctionName: "static TestSubclass.function",
            hookedFunctionName: "static TestSubclass.function_hooked"
        )

        assert(
            function: { type.property },
            originalFunctionName: "static TestSubclass.property",
            hookedFunctionName: "static TestSubclass.property_hooked"
        )

        #if compiler(>=5.0)
        assert(
            function: { type[0] },
            originalFunctionName: "static TestSubclass.subscript",
            hookedFunctionName: "static TestSubclass.subscript",
            hookedFunctionSelect: { $0.first(where: { $0.funcName.contains("hooked:") }) }
        )
        #endif

        assert(
            function: { type.genericFunction(0) },
            originalFunctionName: "static TestSubclass.genericFunction",
            hookedFunctionName: "static TestSubclass.genericFunction_hooked"
        )

        assert(
            function: { try! type.throwsFunction() },
            originalFunctionName: "static TestSubclass.throwsFunction",
            hookedFunctionName: "static TestSubclass.throwsFunction_hooked"
        )

        assert(
            function: instance.function,
            originalFunctionName: "TestSubclass.function",
            hookedFunctionName: "TestSubclass.function_hooked"
        )

        assert(
            function: { instance.property },
            originalFunctionName: "TestSubclass.property",
            hookedFunctionName: "TestSubclass.property_hooked"
        )

        assert(
            function: { instance[0] },
            originalFunctionName: "TestSubclass.subscript",
            hookedFunctionName: "TestSubclass.subscript",
            hookedFunctionSelect: { $0.first(where: { $0.funcName.contains("hooked:") }) }
        )

        assert(
            function: { instance.genericFunction(0) },
            originalFunctionName: "TestSubclass.genericFunction",
            hookedFunctionName: "TestSubclass.genericFunction_hooked"
        )

        assert(
            function: { try! instance.throwsFunction() },
            originalFunctionName: "TestSubclass.throwsFunction",
            hookedFunctionName: "TestSubclass.throwsFunction_hooked"
        )
    }

    func testExistentialFunc() {
        let instance = TestExistentialImpl.instance
        let type = TestExistentialImpl.self

        assert(
            function: type.function,
            originalFunctionName: "static TestExistential.function",
            hookedFunctionName: "static TestExistential.function_hooked"
        )

        assert(
            function: { type.property },
            originalFunctionName: "static TestExistential.property",
            hookedFunctionName: "static TestExistential.property_hooked"
        )

        #if compiler(>=5.0)
        assert(
            function: { type[0] },
            originalFunctionName: "static TestExistential.subscript",
            hookedFunctionName: "static TestExistential.subscript",
            hookedFunctionSelect: { $0.first(where: { $0.funcName.contains("hooked:") }) }
        )
        #endif

        assert(
            function: { type.genericFunction(0) },
            originalFunctionName: "static TestExistential.genericFunction",
            hookedFunctionName: "static TestExistential.genericFunction_hooked"
        )

        assert(
            function: { try! type.throwsFunction() },
            originalFunctionName: "static TestExistential.throwsFunction",
            hookedFunctionName: "static TestExistential.throwsFunction_hooked"
        )

        assert(
            function: instance.function,
            originalFunctionName: "TestExistential.function",
            hookedFunctionName: "TestExistential.function_hooked"
        )

        assert(
            function: { instance.property },
            originalFunctionName: "TestExistential.property",
            hookedFunctionName: "TestExistential.property_hooked"
        )

        assert(
            function: { instance[0] },
            originalFunctionName: "TestExistential.subscript",
            hookedFunctionName: "TestExistential.subscript",
            hookedFunctionSelect: { $0.first(where: { $0.funcName.contains("hooked:") }) }
        )

        assert(
            function: { instance.genericFunction(0) },
            originalFunctionName: "TestExistential.genericFunction",
            hookedFunctionName: "TestExistential.genericFunction_hooked"
        )

        assert(
            function: { try! instance.throwsFunction() },
            originalFunctionName: "TestExistential.throwsFunction",
            hookedFunctionName: "TestExistential.throwsFunction_hooked"
        )
    }

    func testGenericStructFunc() {
        let instance = TestGenericStruct<Int>.init()
        let type = TestGenericStruct<Int>.self

        assert(
            function: type.function,
            originalFunctionName: "static TestGenericStruct.function",
            hookedFunctionName: "static TestGenericStruct.function_hooked"
        )

        assert(
            function: { type.property },
            originalFunctionName: "static TestGenericStruct.property",
            hookedFunctionName: "static TestGenericStruct.property_hooked"
        )

        #if compiler(>=5.0)
        assert(
            function: { type[0] },
            originalFunctionName: "static TestGenericStruct.subscript",
            hookedFunctionName: "static TestGenericStruct.subscript",
            hookedFunctionSelect: { $0.first(where: { $0.funcName.contains("hooked:") }) }
        )
        #endif

        assert(
            function: { type.genericFunction(0) },
            originalFunctionName: "static TestGenericStruct.genericFunction",
            hookedFunctionName: "static TestGenericStruct.genericFunction_hooked"
        )

        assert(
            function: { try! type.throwsFunction() },
            originalFunctionName: "static TestGenericStruct.throwsFunction",
            hookedFunctionName: "static TestGenericStruct.throwsFunction_hooked"
        )

        assert(
            function: instance.function,
            originalFunctionName: "TestGenericStruct.function",
            hookedFunctionName: "TestGenericStruct.function_hooked"
        )

        assert(
            function: { instance.property },
            originalFunctionName: "TestGenericStruct.property",
            hookedFunctionName: "TestGenericStruct.property_hooked"
        )

        assert(
            function: { instance[0] },
            originalFunctionName: "TestGenericStruct.subscript",
            hookedFunctionName: "TestGenericStruct.subscript",
            hookedFunctionSelect: { $0.first(where: { $0.funcName.contains("hooked:") }) }
        )

        assert(
            function: { instance.genericFunction(0) },
            originalFunctionName: "TestGenericStruct.genericFunction",
            hookedFunctionName: "TestGenericStruct.genericFunction_hooked"
        )

        assert(
            function: { try! instance.throwsFunction() },
            originalFunctionName: "TestGenericStruct.throwsFunction",
            hookedFunctionName: "TestGenericStruct.throwsFunction_hooked"
        )
    }

    static var allTests = [
        ("testGlobalFunc", testGlobalFunc),
        ("testStructFunc", testStructFunc),
        ("testEnumFunc", testEnumFunc),
        ("testClassFunc", testClassFunc),
        ("testSubclassFunc", testSubclassFunc),
        ("testExistentialFunc", testExistentialFunc),
        ("testGenericStructFunc", testGenericStructFunc),
    ]
}
