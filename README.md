# Cuculus

A library for Swift Function Hooking. 
**Use at your own risk.** 

```swift
let cat = Cat()
XCTAssertEqual(cat.bark(), "nyan")
let injector = try! SwiftFunctionInjector("Cat.bark")
injector.inject("Cat._bark")
XCTAssertEqual(cat.bark(), "bowwow")
```

## Support

| \ | global | valuetype | class | protocol extension |
|--|--|--|--|--|
| static func | ○ | ○ | ○ | ○ |
| static computed property | ○ | ○ | ○ | ○ |
| static stored property | × | × | × | - |
| static subscript | - | ○ | ○ | ○ |
| instance func | - | ○ | ○ | ○ |
| instance computed property | - | ○ | ○ | ○ |
| instance stored property | - | ※1 | ○ | - |
| instance subscript | - | ○ | ○ | ○ |

※ Inlinable function is possible to not work.
※1 It's possible to hook if access from existential.

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
