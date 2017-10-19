<img src="https://travis-ci.org/valdirunars/TypeSwift.svg?branch=master"/>

# TypeSwift
A set of tools for parsing TypeScript models into Swift ones

## Features

- [X] Classes
- [X] Interfaces
- [X] Functions
  - Major limitations
    - Only literal values in expressions
    - Variable declarations are limited to `var`
    - type conversions are not currently supported in code blocks (such as function blocks)
      - example1: ``let folder: string = `path/to/${folder}`; // CANNOT PARSE TypeScript``
      - example2: ``var folder = `path/to/${folder}`; // SWIFT: var folder = "path/to/\(folder)"``
- [ ] Lambdas
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
    readonly y: number
}

export class Foo implements Protocol {
    public readonly x: number = 3;
    private readonly y: number;
    
    constructor(x: number, y: number) {
      this.x = x
      this.y = y
    }
}

class Bar {
    protected property : Array<[boolean, string]>
    
    constructor(property: [(Bool, String)]) {
      this.property = property
    }
}
```

Would be converted to

```swift
protocol Protocol {
    var y: NSNumber { get }
}

public struct Foo: Protocol {
    public var x: NSNumber = 3
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
