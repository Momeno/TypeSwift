<img src="https://travis-ci.org/valdirunars/TypeSwift.svg?branch=master"/>

# TypeSwift

A set of tools for parsing TypeScript models into Swift ones

## Features

- [X] Classes
- [X] Interfaces
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
interface Bar {
    readonly x: number
}

export class Foo {
    public readonly x: number;
    private y: number;
} class Bar {
    protected property : Array<[boolean, string]>
}
```

Would be converted to

```swift
protocol Bar {
    var x: NSNumber { get }
}

public struct Foo {
    public let x: NSNumber
    private var y: NSNumber
}

struct Bar {
    internal var property: [(Bool, String)]
}
```
