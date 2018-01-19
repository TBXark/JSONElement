//
//  JsonMapper.swift
//  JsonMapper
//
//  Created by Tbxark on 08/11/2016.
//  Copyright © 2016 Tbxark. All rights reserved.
//

import Foundation

public struct JsonMapper {
    
    private var originData: Any?
    
    public var boolValue: Bool? {
        return originData as? Bool ?? numValue?.boolValue
    }

    public  var stringValue: String? {
        return originData as? String
    }
    
    public var numValue: NSNumber? {
        return originData as? NSNumber
    }
    
    
    public init(json: String) {
        guard let data = json.data(using: String.Encoding.utf8),
            let obj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
            self.originData = nil
            return
        }
        self.originData = obj
    }
    
    public init(data: Any?) {
        self.originData = data
    }
    
    
    public func value<T>() -> T? {
        return originData as? T
    }
    
    public subscript(key: String) -> JsonMapper {
        return JsonMapper(data: (originData as? [String: Any])?[key])
    }
    
    public subscript(index: Int) -> JsonMapper {
        guard let array = originData as? [Any],
            index < array.count else { return JsonMapper(data: nil) }
        return JsonMapper(data: array[index])
    }
    
}


extension JsonMapper {
    
    public var int8Value: Int8? { return numValue?.int8Value }
    
    public var uint8Value: UInt8? { return numValue?.uint8Value }
    
    public var int16Value: Int16? { return numValue?.int16Value }
    
    public var uint16Value: UInt16? { return numValue?.uint16Value }
    
    public var int32Value: Int32? { return numValue?.int32Value }
    
    public var uint32Value: UInt32? { return numValue?.uint32Value }
    
    
    public var int64Value: Int64? { return numValue?.int64Value  }
    
    public var uint64Value: UInt64? { return numValue?.uint64Value }
    
    public var floatValue: Float? { return numValue?.floatValue }
    
    var doubleValue: Double? { return numValue?.doubleValue }
    
    @available(OSX 10.5, *)
    public var intValue: Int? { return numValue?.intValue }
    
    @available(OSX 10.5, *)
    public var uintValue: UInt? { return numValue?.uintValue }

}



public struct JSONCodableHelper {
    public static let decoder: JSONDecoder = {
        let json = JSONDecoder()
        json.dateDecodingStrategy = .millisecondsSince1970
        return json
    }()
    
    
    public static let encoder: JSONEncoder = {
        let json = JSONEncoder()
        json.dateEncodingStrategy = .millisecondsSince1970
        return json
    }()
    
    
    public static func decodeJSONStringToModel<T: Codable>(json: String) -> T? {
        guard let data = json.data(using: String.Encoding.utf8),
            let model = try? JSONDecoder().decode(T.self, from: data) else { return nil }
        
        return model
    }
    
    public static func encodeModelToJSONObj<T: Codable>(value: T) -> Any? {
        guard let data = try? encoder.encode(value),
            let json = try? JSONSerialization.jsonObject(with: data, options: [])  else { return nil}
        return json
    }
    
    public static func encodeModelToJSONString<T: Codable>(value: T) -> String? {
        guard let data = try? encoder.encode(value),
            let json = String(bytes: data, encoding: String.Encoding.utf8) else { return nil}
        return json
    }
}


