# JsonMapper
JsonMapper is a simple, fast and secure way to access Json



# Example

```swift


let dict = ["data": ["man": ["age": 10, "name": "Peter", "height": 180.0]]]
let map = JsonMapper(dict)
print(map["data"]["man"]["age"].intValue ?? 0) // 10
print(map["data"]["man"]["name"].stringValue ?? "") // Peter
print(map["data"]["man"]["height"].floatValue ?? 0) // 180.0


```


# Code 

```swift

struct JsonMapper {
    
    private var originData: Any?
    
    var boolValue: Bool? {
        return originData as? Bool ?? numValue?.boolValue
    }

    var stringValue: String? {
        return originData as? String
    }
    
    var numValue: NSNumber? {
        return originData as? NSNumber
    }
    
    
    init(_ data: Any?) {
        self.originData = data
    }
    
    
    func value<T>() -> T? {
        return originData as? T
    }
    
    subscript(key: String) -> JsonMapper {
        return JsonMapper((originData as? [String: Any])?[key])
    }
    
    subscript(index: Int) -> JsonMapper {
        guard let array = originData as? [Any],
            index < array.count else { return JsonMapper(nil) }
        return JsonMapper(array[index])
    }
    
}


extension JsonMapper {
    
    var int8Value: Int8? { return numValue?.int8Value }
    
    var uint8Value: UInt8? { return numValue?.uint8Value }
    
    var int16Value: Int16? { return numValue?.int16Value }
    
    var uint16Value: UInt16? { return numValue?.uint16Value }
    
    var int32Value: Int32? { return numValue?.int32Value }
    
    var uint32Value: UInt32? { return numValue?.uint32Value }
    
    
    var int64Value: Int64? { return numValue?.int64Value  }
    
    var uint64Value: UInt64? { return numValue?.uint64Value }
    
    var floatValue: Float? { return numValue?.floatValue }
    
    var doubleValue: Double? { return numValue?.doubleValue }
    
    @available(OSX 10.5, *)
    var intValue: Int? { return numValue?.intValue }
    
    @available(OSX 10.5, *)
    var uintValue: UInt? { return numValue?.uintValue }

}

```


