//
//  JsonMapper.swift
//  JsonMapper
//
//  Created by Tbxark on 08/11/2016.
//  Copyright © 2016 Tbxark. All rights reserved.
//
import Foundation

@dynamicMemberLookup
public enum JSONElement: Codable, Equatable, Hashable {

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

    indirect case object([String: JSONElement])
    public var objectValue: [String: JSONElement]? {
        if case .object(let value) = self {
            return value
        } else {
            return nil
        }
    }

    indirect case array([JSONElement])
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

    public init(_ value: Any?) {
        if let v = value {
            if let _v = v as? Int {
                self = .int(_v)
            } else if let _v = v as? Float {
                self = .float(_v)
            } else if let _v = v as? Double {
                self = .float(Float(_v))
            } else if let _v = v as? Bool {
                self = .bool(_v)
            } else if let _v = v as? String {
                self = .string(_v)
            } else if let _v = v as? [String: Any] {
                self = .object(_v.mapValues({ JSONElement($0) }))
            } else if let _v = v as? [Any] {
                self = .array(_v.map({ JSONElement($0) }))
            } else {
                do {
                    if let m = v as? Encodable {
                        let json = try JSONElement(model: m)
                        self = json
                    } else {
                        let json = try JSONElement(unknownValue: v)
                        self = json
                    }
                } catch {
                    self = .null
                }
            }

        } else {
            self = .null
        }
    }

    public init(model: Encodable, jsonDecoder: JSONDecoder = JSONDecoder(), jsonEncoder: JSONEncoder = JSONEncoder()) throws {
        let jsonData = try model.data(using: jsonEncoder)
        self = try jsonDecoder.decode(JSONElement.self, from: jsonData)
    }

    public init(rawJSON: [Any], jsonDecoder: JSONDecoder = JSONDecoder()) throws {
        let jsonData = try JSONSerialization.data(withJSONObject: rawJSON, options: [])
        self = try jsonDecoder.decode(JSONElement.self, from: jsonData)
    }

    public init(rawJSON: [String: Any], jsonDecoder: JSONDecoder = JSONDecoder()) throws {
        let jsonData = try JSONSerialization.data(withJSONObject: rawJSON, options: [])
        self = try jsonDecoder.decode(JSONElement.self, from: jsonData)
    }

    public init(rawJSON: String, jsonDecoder: JSONDecoder = JSONDecoder()) throws {
        let data = rawJSON.data(using: String.Encoding.utf8) ?? Data()
        self = try jsonDecoder.decode(JSONElement.self, from: data)
    }

    public init(rawJSON: Data, jsonDecoder: JSONDecoder = JSONDecoder()) throws {
        let jsonData = try JSONSerialization.data(withJSONObject: rawJSON, options: [])
        self = try jsonDecoder.decode(JSONElement.self, from: jsonData)
    }

    public init(unknownValue: Any, jsonDecoder: JSONDecoder = JSONDecoder()) throws {
        let jsonData = try JSONSerialization.data(withJSONObject: [unknownValue], options: [])
        self = (try jsonDecoder.decode(JSONElement.self, from: jsonData)).arrayValue?.first ?? JSONElement.null
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Float.self) {
            self = .float(value)
        } else if let value = try? container.decode(Bool.self) {
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

    public func decode<T: Decodable>(jsonEncoder: JSONEncoder = JSONEncoder(),
                                     jsonDecoder: JSONDecoder = JSONDecoder(),
                                     type: T.Type = T.self) throws -> T {
        let data = try jsonEncoder.encode(self)
        return try jsonDecoder.decode(T.self, from: data)
    }


    public subscript(dynamicMember member: String) -> JSONElement {
        switch self {
        case .object(let value):
            return value[member] ?? .null
        case .array(let value):
            guard let index = Int(member), value.count > index else {
                return .null
            }
            return value[index]
        default:
            return .null
        }
    }
    
    public subscript(keyPath path: String) -> JSONElement {
        var current = self
        for key in path.split(separator: ",") {
            switch self {
            case .null:
                return .null
            case .object(let value):
                current = value[String(key)] ?? .null
            case .array(let value):
                guard let index = Int(key), value.count > index else {
                    return .null
                }
                current = value[index]
            default:
                return .null
            }
        }
        return current
    }
}

public protocol JSONElementDecodable {
    init?(json: JSONElement)
}

@dynamicMemberLookup
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

    public init(data: Data) {
        guard let obj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
            self.originData = nil
            return
        }
        self.originData = obj
    }

    public init(raw: Any?) {
        self.originData = raw
    }

    public func value<T>(type: T.Type = T.self) -> T? {
        return originData as? T
    }

    public func value<T>(keyPath: String, type: T.Type = T.self) -> T? {
        var keys = keyPath.split(separator: ".")
        var map = self
        while !keys.isEmpty {
            map = map[String(keys.removeFirst())]
        }
        return map.originData as? T
    }

    public subscript(key: String) -> JSONMapper {
        return JSONMapper(raw: (originData as? [String: Any])?[key])
    }

    public subscript(index: Int) -> JSONMapper {
        guard let array = originData as? [Any],
              index < array.count else {
            return JSONMapper(raw: nil)
        }
        return JSONMapper(raw: array[index])
    }
    
    public subscript(keyPath path: String) -> JSONMapper {
        var current = self
        for key in path.split(separator: ",") {
            guard let v = current.originData else {
                return JSONMapper(raw: nil)
            }
            if let dict = v as? [String: Any] {
                current = JSONMapper(raw: dict[String(key)])
            } else if let array = v as? [Any], let index = Int(key), array.count > index {
                current = JSONMapper(raw: array[index])
            } else {
                return JSONMapper(raw: nil)
            }
        }
        return current
    }

    public subscript(dynamicMember member: String) -> JSONMapper {
        guard let v = self.originData,
              let dict = v as? [String: Any] else {
            return JSONMapper(raw: nil)
        }
        return JSONMapper(raw: dict[member])
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

extension Encodable {
    public func data(using encoder: JSONEncoder = JSONEncoder()) throws -> Data {
        return try encoder.encode(self)
    }

    public func string(using encoder: JSONEncoder = JSONEncoder()) throws -> String {
        return try String(data: encoder.encode(self), encoding: .utf8)!
    }
}