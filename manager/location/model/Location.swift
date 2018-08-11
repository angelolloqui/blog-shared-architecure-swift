//
//  Location.swift
//  My Sports
//
//  Created by Angel Garcia on 12/12/2016.
//  Copyright © 2016 Syltek Solutions S.L. All rights reserved.
//

import Foundation
import CoreLocation
import AnemoneSDK

public struct Location {
    public let timestamp: Date
    public let accuracy: Double?
    public let coordinate: Coordinate
}

extension Location {
    init(_ location: CLLocation) {
        self.timestamp = location.timestamp
        self.accuracy = location.horizontalAccuracy
        self.coordinate = Coordinate(location.coordinate)
    }
}

extension Location: Equatable {}
public func == (lhs: Location, rhs: Location) -> Bool {
    return lhs.timestamp == rhs.timestamp && lhs.coordinate == rhs.coordinate && lhs.accuracy == rhs.accuracy
}

extension Location: JSONMappable {
    public init(json: JSONObject) throws {
        self.timestamp = Date()
        self.accuracy = nil
        self.coordinate = try Coordinate(json: json)
    }
}
