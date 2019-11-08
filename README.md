# Cuculus

A library for Swift Function Hooking. 
**Use at your own risk.** 

```swift
let cat = Cat()
XCTAssertEqual(cat.bark(), "nyan")
let injector = try! SwiftFunctionInjector("Cat.bark")
try! injector.inject("Cat._bark")
XCTAssertEqual(cat.bark(), "bowwow")
```

## Support
| environment | |
|--|--|
| iOS | × |
| iPhone Simulator | ○ |
| macOS | ○ |

| swift | |
|--|--|
| 5.1 | ○ |
| 5.0 | ○ |
| 4.2 | ○ |
