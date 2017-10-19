<img src="https://travis-ci.org/valdirunars/TypeSwift.svg?branch=master"/>

# TypeSwift
A set of tools for parsing TypeScript models into Swift ones

## Features

- [X] Classes
- [X] Interfaces
- [ ] Functions
- [ ] Enums
- [ ] Index Signatures

## How To Use

### Installation

```swift
.package(url: "https://github.com/valdirunars/TypeSwift.git", from: "0.0.1")
```

### Usage
```swift
try! TypeSwift.sharedInstance.convert(file: fileURL,
                                 to: .swift,
                                 output: outURL)

// or alternatively
let string: String? = TypeSwift.sharedInstance.convertedString(from: typescript, to: .swift)
```

### Example conversion

This typescript string

```typescript
interface Protocol {
    readonly x: number
}

export class Foo implements Protocol {
    public x: number = 3;
    private readonly y: number;
}

class Bar {
    protected property : Array<[boolean, string]>
}
```

Would be converted to

```swift
protocol Protocol {
    var x: NSNumber { get }
}

public struct Foo: Protocol {
    public var x: NSNumber = 1
    private let y: NSNumber
    
    init(_ x: NSNumber, _ y: NSNumber) {
      self.x = x
      self.y = y
    }
    init(x: NSNumber, y: NSNumber) {
      self.x = x
      self.y = y
    }
}

struct Bar {
    internal var property: [(Bool, String)]

    init(_ property: [(Bool, String)]) {
      self.property = property
    }
    
    init(property: [(Bool, String)]) {
      self.property = property
    }
}
```
