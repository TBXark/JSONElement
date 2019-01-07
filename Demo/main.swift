//
//  main.swift
//  Demo
//
//  Created by Tbxark on 04/02/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import Foundation


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
//Program ended with exit code: 0
