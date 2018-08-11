//
//  KeychainStorage.swift
//  Anemone SDK
//
//  Created by Manuel González Villegas on 29/3/17.
//  Copyright © 2017 Syltek Solutions S.L. All rights reserved.
//

import Foundation
import KeychainAccess

public class KeychainStorage: IKeyValueStorage {
    let keychain: Keychain

    public init() {
        keychain = Keychain(service: "com.syltek.mysports")
            .accessibility(.afterFirstUnlock)
    }

    public func string(name: String) -> String? {
        guard let value = self.get(name: name) as? String else {
            return nil
        }

        return value
    }

    public func setString(name: String, value: String?) {
        self.set(name: name, value: value)
    }

    public func bool(name: String) -> Bool? {
        guard let value = self.get(name: name) as? Bool else {
            return nil
        }

        return value
    }

    public func setBool(name: String, value: Bool?) {
        self.set(name: name, value: value)
    }

    public func int(name: String) -> Int? {
        guard let value = self.get(name: name) as? Int else {
            return nil
        }

        return value
    }

    public func setInt(name: String, value: Int?) {
        self.set(name: name, value: value)
    }

    public func double(name: String) -> Double? {
        guard let value = self.get(name: name) as? Double else {
            return nil
        }

        return value
    }

    public func setDouble(name: String, value: Double?) {
        self.set(name: name, value: value)
    }

    private func get(name: String) -> Any? {
        guard let data = try? keychain.getData(name),
            let datos = data,
            let value = NSKeyedUnarchiver.unarchiveObject(with: datos) else {
                return nil
        }

        return value
    }

    private func set(name: String, value: Any?) {
        if let value = value {
            try? keychain.set(NSKeyedArchiver.archivedData(withRootObject: value), key: name)
        } else {
            try? keychain.remove(name)
        }
    }

}
