# JsonMapper

`JsonMapper` is a simple, fast and secure way to access Json.

Because `Any` can't be used in `Codable`, it can be replaced with `JSONElement` for properties of type `Any`.

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
let map = JSONMapper(data: dict)
// 直接获取
if let value = map["data"]["man"]["age"].intValue {
    print(value)
}
// 使用Key获取
if let value: Double = map["data"]["man"]["height"].value() {
    print(value)
}
// 使用Keypath获取
if let value = map.value(keyPath: "data.man.name", type: String.self) {
    print(value)
}

if let manDict: Any = map["data"]["man"].value() {
    let data = try JSONSerialization.data(withJSONObject: manDict, options: [])
    let man = try JSONDecoder().decode(Human.self, from: data)
    if let value = man.extra.arrayValue {
        print(value.map({ $0.rawValue }))
        if let str = value.first?.intValue {
            print(str)
        }

    }
}
// Output
// 10
// 180.0
// Peter
// [Optional(123), Optional("123"), Optional([Optional(123)]), Optional(["123": 123]), Optional(true)]
// 123



```
