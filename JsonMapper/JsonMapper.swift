//
//  JsonMapper.swift
//  JsonMapper
//
//  Created by Tbxark on 08/11/2016.
//  Copyright © 2016 Tbxark. All rights reserved.
//

import Foundation

public enum JSONElement: Codable {
    
    case null
    public var isNull: Bool {
        if case .null = self {
            return true
        } else {
            return false
        }
    }
    
    case int(Int)
    public var intValue: Int? {
        if case let .int(value) = self {
            return value
        } else {
            return nil
        }
    }
    
    case float(Float)
    public var floatValue: Float? {
        if case .float(let value) = self {
            return value
        } else {
            return nil
        }
    }
    
    case bool(Bool)
    public var boolValue: Bool? {
        if case .bool(let value) = self {
            return value
        } else {
            return nil
        }
    }
    
    case string(String)
    public var stringValue: String? {
        if case .string(let value) = self {
            return value
        } else {
            return nil
        }
    }
    
    case object([String: JSONElement])
    public var objectValue: [String: JSONElement]? {
        if case .object(let value) = self {
            return value
        } else {
            return nil
        }
    }
    
    case array([JSONElement])
    public var arrayValue: [JSONElement]? {
        if case .array(let value) = self {
            return value
        } else {
            return nil
        }
    }
    
    public var rawValue: Any? {
        switch self {
        case .null:
            return nil
        case .int(let value):
            return value
        case .float(let value):
            return value
        case .bool(let value):
            return value
        case .string(let value):
            return value
        case .object(let value):
            var dict = [String: Any]()
            for (k, v) in value {
                dict[k] = v.rawValue
            }
            return dict
        case .array(let value):
            return value.map({ $0.rawValue })
        }
    }
    
    public init(jsonValue: Any?) throws {
        if let value = jsonValue {
            let jsonData = try JSONSerialization.data(withJSONObject: [value], options: [])
            self = (try JSONDecoder().decode(JSONElement.self, from: jsonData)).arrayValue?.first ?? JSONElement.null
        } else {
            self = .null
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Float.self) {
            self = .float(value)
        } else  if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode([String: JSONElement].self) {
            self = .object(value)
        } else if let value = try? container.decode([JSONElement].self) {
            self = .array(value)
        } else {
            self = .null
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .null:
            try container.encodeNil()
        case .int(let value):
            try container.encode(value)
        case .float(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .string(let value):
            try container.encode(value)
        case .object(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        }
    }
}

public struct JSONMapper {
    
    private var originData: Any?
    
    public var boolValue: Bool? {
        return originData as? Bool ?? numValue?.boolValue
    }
    
    public var stringValue: String? {
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
    
    public func value<T>(keyPath: String, type: T.Type = T.self) -> T? {
        var keys = keyPath.split(separator: ".")
        var map = self
        while !keys.isEmpty  {
            map = map[String(keys.removeFirst())]
        }
        return map.originData as? T
    }

    
    public subscript(key: String) -> JSONMapper {
        return JSONMapper(data: (originData as? [String: Any])?[key])
    }
    
    public subscript(index: Int) -> JSONMapper {
        guard let array = originData as? [Any],
            index < array.count else {
                return JSONMapper(data: nil)
        }
        return JSONMapper(data: array[index])
    }
    
}

extension JSONMapper {
    
    public var int8Value: Int8? {
        return numValue?.int8Value
    }
    
    public var uint8Value: UInt8? {
        return numValue?.uint8Value
    }
    
    public var int16Value: Int16? {
        return numValue?.int16Value
    }
    
    public var uint16Value: UInt16? {
        return numValue?.uint16Value
    }
    
    public var int32Value: Int32? {
        return numValue?.int32Value
    }
    
    public var uint32Value: UInt32? {
        return numValue?.uint32Value
    }
    
    public var int64Value: Int64? {
        return numValue?.int64Value
    }
    
    public var uint64Value: UInt64? {
        return numValue?.uint64Value
    }
    
    public var floatValue: Float? {
        return numValue?.floatValue
    }
    
    var doubleValue: Double? {
        return numValue?.doubleValue
    }
    
    @available(OSX 10.5, *)
    public var intValue: Int? {
        return numValue?.intValue
    }
    
    @available(OSX 10.5, *)
    public var uintValue: UInt? {
        return numValue?.uintValue
    }
    
}

extension JSONDecoder {
    public func decodeJSONStringToModel<T: Decodable>(json: String) throws -> T {
        guard let data = json.data(using: String.Encoding.utf8) else {
            throw NSError(domain: "org.swift.JSONEncoder",
                          code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Can not convert string to data"])
        }
        let model = try decode(T.self, from: data)
        return model
    }
}

extension JSONEncoder {
    
    public func encodeModelToJSONObj<T: Encodable>(value: T) throws -> Any {
        let data = try self.encode(value)
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        return json
    }
    
    public func encodeModelToJSONString<T: Codable>(value: T) throws -> String {
        let data = try encode(value)
        guard let json = String(bytes: data, encoding: String.Encoding.utf8) else {
            throw NSError(domain: "org.swift.JSONEncoder",
                          code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Can not convert data to string"])
        }
        return json
    }
    
}

extension JSONDecoder {
    public convenience init(date: JSONDecoder.DateDecodingStrategy = JSONDecoder.DateDecodingStrategy.deferredToDate,
                            data: JSONDecoder.DataDecodingStrategy = JSONDecoder.DataDecodingStrategy.base64,
                            nonConformingFloat: JSONDecoder.NonConformingFloatDecodingStrategy = JSONDecoder.NonConformingFloatDecodingStrategy.throw,
                            key: JSONDecoder.KeyDecodingStrategy = JSONDecoder.KeyDecodingStrategy.useDefaultKeys) {
        self.init()
        self.dateDecodingStrategy = date
        self.dataDecodingStrategy = data
        self.nonConformingFloatDecodingStrategy = nonConformingFloat
        self.keyDecodingStrategy = key
    }
}

extension JSONEncoder {
    public convenience init(date: JSONEncoder.DateEncodingStrategy = JSONEncoder.DateEncodingStrategy.deferredToDate,
                            data: JSONEncoder.DataEncodingStrategy = JSONEncoder.DataEncodingStrategy.base64,
                            nonConformingFloat: JSONEncoder.NonConformingFloatEncodingStrategy = JSONEncoder.NonConformingFloatEncodingStrategy.throw,
                            key: JSONEncoder.KeyEncodingStrategy = JSONEncoder.KeyEncodingStrategy.useDefaultKeys) {
        self.init()
        self.dateEncodingStrategy = date
        self.dataEncodingStrategy = data
        self.nonConformingFloatEncodingStrategy = nonConformingFloat
        self.keyEncodingStrategy = key
    }
}
