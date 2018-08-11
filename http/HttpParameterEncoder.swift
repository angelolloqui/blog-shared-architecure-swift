//
//  HttpParameterEncoder.swift
//  Anemone SDK
//
//  Created by Angel Luis Garcia on 09/10/2017.
//  Copyright © 2017 Syltek Solutions S.L. All rights reserved.
//
// swiftlint:disable force_cast
// swiftlint:disable force_unwrapping

import Foundation

public protocol IHttpParameterEncoder {
    var contentType: String { get }
    func stringEncode(_ params: [String: Any]) throws -> String
    func dataEncode(_ params: [String: Any]) throws -> Data
}

public class HttpUrlParameterEncoder: IHttpParameterEncoder {

    public init() {}

    public var contentType: String {
        return "application/x-www-form-urlencoded"
    }

    public func stringEncode(_ params: [String: Any]) throws -> String {
        return try urlEncoded(params)
    }

    public func dataEncode(_ params: [String: Any]) throws -> Data {
        return try urlEncoded(params).data(using: .utf8) ?? Data()
    }

    private func urlEncoded(_ params: [String: Any]) throws -> String {
        let encodedParameters = try params.keys.sorted().map { (key) -> String in
            let value = params[key]!
            let encoded = try self.urlEncoded(value: value)
            return "\(key)=\(encoded)"
        }
        return encodedParameters.joined(separator: "&")
    }

    func urlEncoded(value: Any) throws -> String {
        if let arrayValue = value as? [Any] {
            return try urlEncoded(value: arrayValue.map(urlEncoded).joined(separator: ","))
        }
        if let date = value as? Date {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            dateFormatter.timeZone = TimeZone.utc
            return dateFormatter.string(from: date)
        }
        if let data = value as? Data {
            return try urlEncoded(value: data.base64EncodedString())
        }
        if let stringValue = value as? CustomStringConvertible {
            let allowedCharacterSet = (CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted)
            if let encoded = stringValue
                .description
                .addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) {
                return encoded
            }
        }

        throw AnemoneException.jsonInvalidFormat
    }
}

public class HttpJsonParameterEncoder: IHttpParameterEncoder {

    public init() {}

    public var contentType: String {
        return "application/json"
    }

    public func stringEncode(_ params: [String: Any]) throws -> String {
        return String(data: try dataEncode(params), encoding: .utf8) ?? ""
    }

    public func dataEncode(_ params: [String: Any]) throws -> Data {
        return try jsonEncoded(params).toData()
    }

    private func jsonEncoded(_ params: [String: Any]) throws -> JSONObject {
        let json = JSONObject()
        try params.forEach { key, value in
            switch value {
            case is JSONSerializable: json.setObject(key, (value as! JSONSerializable).toJson())
            case is Int: json.setInt(key, value as? Int)
            case is Double: json.setDouble(key, value as? Double)
            case is Float: json.setDouble(key, Double(value as! Float))
            case is Bool: json.setBoolean(key, value as? Bool)
            case is String: json.setString(key, value as? String)
            case is Date: json.setDate(key, value as? Date)
            case is Data: json.setString(key, (value as? Data)?.base64EncodedString())
            case is [String: Any]: json.setObject(key, try jsonEncoded(value as! [String: Any]))
            case is [Any]: json.setJSONArray(key, try jsonEncoded(value as! [Any]))
            case is CustomStringConvertible: json.setString(key, (value as! CustomStringConvertible).description)
            default: throw AnemoneException.jsonInvalidFormat
            }
        }
        return json
    }

    private func jsonEncoded(_ array: [Any]) throws -> JSONArray {
        let json = JSONArray()
        try array.forEach { value in
            switch value {
            case is JSONSerializable: json.add((value as! JSONSerializable).toJson())
            case is JSONObject: json.add(value as! JSONObject)
            case is Int: json.addInt(value as! Int)
            case is Double: json.addDouble(value as! Double)
            case is Float: json.addDouble(Double(value as! Float))
            case is Bool: json.addBoolean(value as! Bool)
            case is String: json.addString(value as! String)
            case is [String: Any]: json.add(try jsonEncoded(value as! [String: Any]))
            case is CustomStringConvertible: json.addString((value as! CustomStringConvertible).description)
            default: throw AnemoneException.jsonInvalidFormat
            }
        }
        return json
    }
}
