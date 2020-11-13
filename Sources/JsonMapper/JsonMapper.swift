//
//  JsonMapper.swift
//  JsonMapper
//
//  Created by Tbxark on 08/11/2016.
//  Copyright © 2016 Tbxark. All rights reserved.
//
import Foundation


// MARK: - JSONElement
@dynamicMemberLookup
public enum JSONElement: Codable, Equatable, Hashable {
    
    // MARK: getter
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
    
    case decimal(Decimal)
    public var decimalValue: Decimal? {
        if case .decimal(let value) = self {
            return value
        } else if case .int(let value) = self {
            return Decimal(value)
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
        case .decimal(let value):
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
    
    // MARK: init
    public init(_ value: Any?) {
        if let v = value {
            if let _v = v as? Int {
                self = .int(_v)
            } else if let _v = v as? Float {
                self = .decimal(Decimal(Double(_v)))
            } else if let _v = v as? Double {
                self = .decimal(Decimal(_v))
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
        let jsonData = try model.encodeToJsonData(using: jsonEncoder)
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
        self = try jsonDecoder.decode(JSONElement.self, from: rawJSON)
    }
    
    public init(unknownValue: Any, jsonDecoder: JSONDecoder = JSONDecoder()) throws {
        let jsonData = try JSONSerialization.data(withJSONObject: [unknownValue], options: [])
        self = (try jsonDecoder.decode(JSONElement.self, from: jsonData)).arrayValue?.first ?? JSONElement.null
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Decimal.self) {
            self = .decimal(value)
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
        case .decimal(let value):
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
    
    // MARK: transform
    public func `as`<T: Decodable>(type: T.Type = T.self, jsonEncoder: JSONEncoder = JSONEncoder(), jsonDecoder: JSONDecoder = JSONDecoder()) throws -> T {
        let data = try jsonEncoder.encode(self)
        return try jsonDecoder.decode(T.self, from: data)
    }
    
    
    // MARK: subscript
    public subscript(key: String) -> JSONElement {
        switch self {
        case .null:
            return .null
        case .object(let value):
            return value[String(key)] ?? .null
        case .array(let value):
            guard let index = Int(key), value.count > index else {
                return .null
            }
            return value[index]
        default:
            return .null
        }
    }
    
    public subscript(index: Int) -> JSONElement {
        switch self {
        case .array(let value):
            guard value.count > index else {
                return .null
            }
            return value[index]
        default:
            return JSONElement.null
        }
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
        for key in path.split(separator: ".").map({ String($0)}) {
            let v = current[key]
            if v.isNull{
                return JSONElement.null
            } else {
                current = v
            }
        }
        return current
    }
}


// MARK: - JSONMapper
@dynamicMemberLookup
public struct JSONMapper {
    
    private var originData: Any?
    
    // MARK: init
    public init(rawJSON: String) {
        guard let data = rawJSON.data(using: String.Encoding.utf8),
              let obj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
            self.originData = nil
            return
        }
        self.originData = obj
    }
    
    public init(rawJSON: Data) {
        guard let obj = try? JSONSerialization.jsonObject(with: rawJSON, options: .allowFragments) else {
            self.originData = nil
            return
        }
        self.originData = obj
    }
    
    public init(_ raw: Any?) {
        self.originData = raw
    }
    
    // MARK: transform
    func `as`<T>(_ type: T.Type = T.self) -> T? {
        return originData.flatMap({ $0 as? T })
    }
    
    // MARK: subscript
    public subscript(key: String) -> JSONMapper {
        return JSONMapper((originData as? [String: Any])?[key])
    }
    
    public subscript(index: Int) -> JSONMapper {
        guard let array = originData as? [Any],
              index < array.count else {
            return JSONMapper(nil)
        }
        return JSONMapper(array[index])
    }
    
    public subscript(keyPath path: String) -> JSONMapper {
        var current = self
        for key in path.split(separator: ".") {
            guard let v = current.originData else {
                return JSONMapper(nil)
            }
            if let dict = v as? [String: Any] {
                current = JSONMapper(dict[String(key)])
            } else if let array = v as? [Any], let index = Int(key), array.count > index {
                current = JSONMapper(array[index])
            } else {
                return JSONMapper(nil)
            }
        }
        return current
    }
    
    public subscript(dynamicMember member: String) -> JSONMapper {
        guard let v = self.originData,
              let dict = v as? [String: Any] else {
            return JSONMapper(nil)
        }
        return JSONMapper(dict[member])
    }
    
    // MARK: getter
    public var boolValue: Bool? {
        return originData as? Bool ?? numValue?.boolValue
    }
    
    public var stringValue: String? {
        return originData as? String
    }
    
    public var numValue: NSNumber? {
        return originData as? NSNumber
    }
    
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

// MARK: - Codable 
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
    public func encodeToJsonData(using encoder: JSONEncoder = JSONEncoder()) throws -> Data {
        return try encoder.encode(self)
    }
    
    public func encodeToJsonString(using encoder: JSONEncoder = JSONEncoder()) throws -> String {
        return try String(data: encoder.encode(self), encoding: .utf8)!
    }
}
