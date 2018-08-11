//
//  IKeyValueStorage.swift
//  Anemone SDK
//
//  Created by Manuel Gonzalez Villegas on 5/12/16.
//  Copyright © 2016 Syltek Solutions S.L. All rights reserved.
//

import Foundation

public protocol IKeyValueStorage: class {

    func string(name: String) -> String?

    func setString(name: String, value: String?)

    func bool(name: String) -> Bool?

    func setBool(name: String, value: Bool?)

    func int(name: String) -> Int?

    func setInt(name: String, value: Int?)

    func double(name: String) -> Double?

    func setDouble(name: String, value: Double?)

}
