# JsonMapper

`JsonMapper` is a simple, fast and secure way to access Json.

Because `Any` can't be used in `Codable`, it can be replaced with `JSONElement` for properties of type `Any`.



## Installation

### Swift Package Manager

Add the dependency in your `Package.swift` file:

```swift
let package = Package(
    name: "myproject",
    dependencies: [
        .package(url: "https://github.com/TBXark/JsonMapper.git", .upToNextMajor(from: "1.2.0"))
        ],
    targets: [
        .target(
            name: "myproject",
            dependencies: ["JsonMapper"]),
        ]
)
```

### Carthage

Add the dependency in your `Cartfile` file:

```bash
github "TBXark/JsonMapper" ~> 1.2.0.
```

### CocoaPods

Add the dependency in your `Podfile` file:

```ruby
pod 'JsonMapper', :git=>'https://github.com/TBXark/JsonMapper.git', '~> 7.18.0
```

# Example

```swift


struct Human: Codable {
    let age: Int
    let name: String
    let height: Double
    let extra: JSONElement // Any?
}

let dict = ["data": ["man": ["age": 10, "name": "Peter", "height": 180.0, "extra": [123, "123", [123], ["123": 123], true]]]]

// MARK: - JSONMapper
print("-- JSONMapper --")
let json = JSONMapper(raw: dict)
// 直接获取
if let value = json["data"]["man"]["age"].intValue {
    print(value)
}
// 使用Key获取
if let value = json["data"]["man"]["height"].value(type: Double.self) {
    print(value)
}

// 使用 dynamicMemberLookup 获取
if let value = json.data.man.height.value(type: Double.self) {
    print(value)
}

// 使用Keypath获取
if let value = json.value(keyPath: "data.man.name", type: String.self) {
    print(value)
}

if let manDict: Any = json["data"]["man"].value() {
    let data = try JSONSerialization.data(withJSONObject: manDict, options: [])
    let man = try JSONDecoder().decode(Human.self, from: data)
    if let value = man.extra.arrayValue {
        print(value.map({ $0.rawValue }))
        if let str = value.first?.intValue {
            print(str)
        }

    }
}

//
// Output:
//
//-- JSONMapper --
//10
//180.0
//180.0
//Peter
//[Optional(123), Optional("123"), Optional([Optional(123)]), Optional(["123": 123]), Optional(true)]
//123

```
