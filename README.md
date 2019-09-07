# Cuculus

A library for Swift Function Hooking. 
**Use at your own risk.** 

```swift
let cat = Cat()
XCTAssertEqual(cat.bark(), "nyan")
let injector = try! SwiftFunctionInjector(cat.bark)
injector.inject(cat._bark)
XCTAssertEqual(cat.bark(), "bowwow")
```

## Support
| function | |
|--|--|
| top level function | ○ |
| struct | ○ |
| enum | ○ |
| class | × |
| protocol | × |

| argument/return type | |
|--|--|
| concrete type | ○ |
| generics | × |
| variable arguments | ○ |

| environment | |
|--|--|
| iOS | × |
| iPhone Simulator | ○ |
| macOS | ○ |

| swift | |
|--|--|
| 5.1 | ○ |
| 5.0 | ○ |
| 4.3 | × |
