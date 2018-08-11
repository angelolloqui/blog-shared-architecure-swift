//
//  JSONArray.swift
//  Anemone SDK
//
//  Created by Angel Garcia on 17/01/2017.
//  Copyright © 2017 Syltek Solutions S.L. All rights reserved.
//

import Foundation

public class JSONArray {
    var data: [Any]

    init() {
        self.data = []
    }

    init(data: [Any]) {
        self.data = data
    }

    init(objects: [JSONObject]) {
        self.data = objects.map { $0.data }
    }

    public func getJSONObject(_ index: Int) throws -> JSONObject {
        guard index < data.count, let value = data[index] as? [String: Any] else {
            throw AnemoneException.jsonInvalidFormat
        }
        return JSONObject(data: value)
    }

    public func flatMap<T>(_ transform: (JSONObject) throws -> T?) rethrows -> [T] {
        return try data.compactMap { item in
            guard let data = item as? [String: Any] else { return nil }
            return try transform(JSONObject(data: data))
        }
    }

    public func asList<T>() throws -> [T] {
        guard let data = self.data as? [T] else {
            throw AnemoneException.jsonInvalidFormat
        }
        return data
    }

    public func asJSONList() -> [JSONObject] {
        return data.compactMap { obj in
            guard let data = obj as? [String: Any] else { return nil }
            return JSONObject(data: data)
        }
    }

    public func add(_ object: JSONObject) {
        self.data.append(object.data)
    }

    public func addAll(_ objects: [JSONObject]) {
        self.data.append(contentsOf: objects.map { $0.data })
    }

    public func addInt(_ value: Int) {
        self.data.append(value)
    }

    public func addDouble(_ value: Double) {
        self.data.append(value)
    }

    public func addString(_ value: String) {
        self.data.append(value)
    }

    public func addBoolean(_ value: Bool) {
        self.data.append(value)
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
