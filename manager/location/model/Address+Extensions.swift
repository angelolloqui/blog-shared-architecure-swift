//
//  Address+Extensions.swift
//  My Sports
//
//  Created by Angel Luis Garcia on 26/07/2017.
//  Copyright © 2017 Syltek Solutions S.L. All rights reserved.
//

import Foundation
import AnemoneSDK
import LMGeocoder

extension Address {
    init(_ placemark: LMAddress, coordinate: Coordinate?) {
        self.name = nil
        self.streetNumber = placemark.streetNumber
        self.administrativeArea = placemark.administrativeArea
        self.subAdministrativeArea = placemark.subAdministrativeArea
        self.countryCode = placemark.isOcountryCode
        self.countryName = placemark.country
        self.streetName = placemark.route
        self.postalCode = placemark.postalCode
        self.timeZone = nil
        self.subLocality = placemark.subLocality
        if placemark.locality != nil || placemark.subLocality != nil {
            self.locality = placemark.locality
        } else {
            self.locality = placemark.lines?.first { line in
                let notArea = line != placemark.administrativeArea && line != placemark.subAdministrativeArea
                let notCountry = line != placemark.country
                let notCode = line != placemark.postalCode && line != placemark.route
                return notArea && notCountry && notCode
            }
        }

        if let coordinate = coordinate {
            self.coordinate = coordinate
        } else {
            self.coordinate = Coordinate(placemark.coordinate)
        }

    }
}
