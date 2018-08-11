//
//  UserDefaults+IKeyValueStorage.swift
//  Anemone SDK
//
//  Created by Manuel Gonzalez Villegas on 7/12/16.
//  Copyright © 2016 Syltek Solutions S.L. All rights reserved.
//

import Foundation

extension UserDefaults: IKeyValueStorage {

    public func string(name: String) -> String? {
        return string(forKey: name)
    }

    public func setString(name: String, value: String?) {
        set(value, forKey: name)
    }

    public func bool(name: String) -> Bool? {
        guard object(forKey: name) != nil else { return nil }
        return bool(forKey: name)
    }

    public func setBool(name: String, value: Bool?) {
        set(value, forKey: name)
    }

    public func int(name: String) -> Int? {
        guard object(forKey: name) != nil else { return nil }
        return integer(forKey: name)
    }

    public func setInt(name: String, value: Int?) {
        set(value, forKey: name)
    }

    public func double(name: String) -> Double? {
        guard object(forKey: name) != nil else { return nil }
        return double(forKey: name)
    }

    public func setDouble(name: String, value: Double?) {
        set(value, forKey: name)
    }

}
