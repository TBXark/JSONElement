//
//  main.swift
//  JsonMapper
//
//  Created by Tbxark on 08/11/2016.
//  Copyright © 2016 Tbxark. All rights reserved.
//

import Foundation


let dict = ["data": ["man": ["age": 10, "name": "Peter", "height": 180.0]]]
let map = JsonMapper(dict)
print(map["data"]["man"]["age"].intValue ?? 0) // 10
print(map["data"]["man"]["name"].stringValue ?? "") // Peter
print(map["data"]["man"]["height"].floatValue ?? 0) // 
