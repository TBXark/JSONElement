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
}

let dict = ["data": ["man": ["age": 10, "name": "Peter", "height": 180.0]]]


let map = JsonMapper(data: dict)
print(map["data"]["man"]["age"].intValue ?? 0) // 10
print(map["data"]["man"]["name"].stringValue ?? "") // Peter
print(map["data"]["man"]["height"].floatValue ?? 0) // 180.0


let man = Human(age: 10, name: "Tim", height: 160)
let str = JSONCodableHelper.encodeModelToJSONString(value: man)
print(str ?? "")
