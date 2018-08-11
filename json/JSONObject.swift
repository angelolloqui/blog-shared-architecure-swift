//
//  JSONObject.swift
//  Anemone SDK
//
//  Created by Angel Garcia on 17/01/2017.
//  Copyright © 2017 Syltek Solutions S.L. All rights reserved.
//

import Foundation

public class JSONObject {
    var data: [String: Any]

    init() {
        data = [:]
    }

    init(data: [String: Any]) {
        self.data = data
    }

    public convenience init(string: String) throws {
        guard let data = string.data(using: .utf8) else {
            throw AnemoneException.jsonInvalidFormat
        }
        try self.init(data: data)
    }

    public convenience init(data: Data) throws {
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw AnemoneException.jsonInvalidFormat
        }
        self.init(data: json)
    }

    public func has(_ key: String) -> Bool {
        return data[key] != nil && !(data[key] is NSNull)
    }

    public func getAny(_ key: String) throws -> Any {
        guard let value = data[key] else {
            throw AnemoneException.jsonInvalidFormat
        }
        return value
    }

    public func getInt(_ key: String) throws -> Int {
        guard let value = data[key] as? Int else {
            throw AnemoneException.jsonInvalidFormat
        }
        return value
    }

    public func getDouble(_ key: String) throws -> Double {
        guard let value = data[key] as? Double else {
            throw AnemoneException.jsonInvalidFormat
        }
        return value
    }

    public func getBoolean(_ key: String) throws -> Bool {
        guard let value = data[key] as? Bool else {
            throw AnemoneException.jsonInvalidFormat
        }
        return value
    }

    public func optBoolean(_ key: String) -> Bool? {
        return try? getBoolean(key)
    }

    public func getString(_ key: String) throws -> String {
        guard let value = data[key] as? String else {
            throw AnemoneException.jsonInvalidFormat
        }
        return value
    }

    public func optString(_ key: String) -> String? {
        return try? getString(key)
    }

    public func getDate(_ key: String) throws -> Date {
        guard let value = data[key] as? String else {
            throw AnemoneException.jsonInvalidFormat
        }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone.utc
        guard let date = dateFormatter.date(from: value) else {
            throw AnemoneException.jsonInvalidFormat
        }
        return date
    }

    public func optDate(_ key: String) -> Date? {
        return try? getDate(key)
    }

    public func getJSONObject(_ key: String) throws -> JSONObject {
        guard let value = data[key] as? [String: Any] else {
            throw AnemoneException.jsonInvalidFormat
        }
        return JSONObject(data: value)
    }

    public func optJSONObject(_ key: String) -> JSONObject? {
        return try? getJSONObject(key)
    }

    public func getJSONArray(_ key: String) throws -> JSONArray {
        guard let value = data[key] as? [Any] else {
            throw AnemoneException.jsonInvalidFormat
        }
        return JSONArray(data: value)
    }

    public func getStringArray(_ key: String) throws -> [String] {
        guard let value = data[key] as? [String] else {
            throw AnemoneException.jsonInvalidFormat
        }
        return value
    }

    public func getIntArray(_ key: String) throws -> [Int] {
        guard let value = data[key] as? [Int] else {
            throw AnemoneException.jsonInvalidFormat
        }
        return value
    }

    public func getAnyArray(_ key: String) throws -> [Any] {
        guard let value = data[key] as? [Any] else {
            throw AnemoneException.jsonInvalidFormat
        }
        return value
    }

    public func asMap() -> [String: Any] {
        return data
    }

    public func setAny(_ key: String, _ value: Any?) {
        data[key] = value
    }

    public func setInt(_ key: String, _ value: Int?) {
        data[key] = value
    }

    public func setDouble(_ key: String, _ value: Double?) {
        data[key] = value
    }

    public func setString(_ key: String, _ value: String?) {
        data[key] = value
    }

    public func setBoolean(_ key: String, _ value: Bool?) {
        data[key] = value
    }

    public func setObject(_ key: String, _ value: JSONObject?) {
        data[key] = value?.data
    }

    public func setArray(_ key: String, _ value: [Any]?) {
        data[key] = value
    }

    public func setJSONArray(_ key: String, _ value: JSONArray?) {
        data[key] = value?.data
    }

    public func setDate(_ key: String, _ value: Date?) {
        guard let value = value else {
            data[key] = nil
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone.utc
        data[key] = dateFormatter.string(from: value)
    }

    public func toData() throws -> Data {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: []) else {
                throw AnemoneException.jsonInvalidFormat
        }
        return jsonData
    }

    public func toString() throws -> String {
        let jsonData = try toData()
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                throw AnemoneException.jsonInvalidFormat
        }
        return jsonString.replacingOccurrences(of: "\\/", with: "/")
    }
}
