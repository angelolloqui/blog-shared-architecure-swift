//
//  ILocationManager.swift
//  My Sports
//
//  Created by Angel Garcia on 12/12/2016.
//  Copyright © 2016 Syltek Solutions S.L. All rights reserved.
//

import Foundation
import AnemoneSDK

public protocol ILocationManager {
    var lastLocation: Location? { get }
    var locationStatus: LocationServiceStatus { get }

    func findLocation(allowRequestPermission: Bool) -> Promise<Location>
    func findLocation(allowRequestPermission: Bool, minAccuracy: Double, maxAge: TimeInterval, timeout: TimeInterval) -> Promise<Location>

    func findAddress(coordinate: Coordinate) -> Promise<Address>
    func findAddress(placeAutocomplete: PlaceAutocomplete) -> Promise<Address>

    func findAddresses(text: String) -> Promise<[Address]>

    func findAutocomplete(text: String) -> Promise<[PlaceAutocomplete]>

    func hasPermission() -> Bool
    func requestLocationPermission()
}

extension ILocationManager {
    func formatDistance(coordinate: Coordinate?) -> String? {
        guard let fromCoordinate = self.lastLocation?.coordinate, let coordinate = coordinate else { return nil }
        return coordinate.formattedDistance(from: fromCoordinate)
    }
}
