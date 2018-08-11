//
//  JSONSerializable.swift
//  Anemone SDK
//
//  Created by Angel Luis Garcia on 14/02/2017.
//  Copyright © 2017 Syltek Solutions S.L. All rights reserved.
//

import Foundation

public protocol JSONSerializable {
    func toJson() -> JSONObject
}
