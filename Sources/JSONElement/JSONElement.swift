//
//  JSONElement.swift
//  JSONElement
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
    public func `as`<T: Decodable>(_ type: T.Type = T.self, jsonEncoder: JSONEncoder = JSONEncoder(), jsonDecoder: JSONDecoder = JSONDecoder()) throws -> T {
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

