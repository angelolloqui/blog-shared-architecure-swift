//
//  Address.swift
//  Anemone SDK
//
//  Created by Angel Garcia on 12/12/2016.
//  Copyright © 2016 Syltek Solutions S.L. All rights reserved.
//

import Foundation
import CoreLocation

public struct Address {
    public let name: String?
    public let streetName: String?
    public let streetNumber: String?
    public let locality: String?
    public let subLocality: String?
    public let administrativeArea: String?
    public let subAdministrativeArea: String?
    public let postalCode: String?
    public let countryCode: String?
    public let countryName: String?
    public let coordinate: Coordinate?
    public let timeZone: TimeZone?

    public init(
        name: String? = nil,
        streetName: String? = nil,
        streetNumber: String? = nil,
        locality: String? = nil,
        subLocality: String? = nil,
        administrativeArea: String? = nil,
        subAdministrativeArea: String? = nil,
        postalCode: String? = nil,
        countryCode: String? = nil,
        countryName: String? = nil,
        coordinate: Coordinate? = nil,
        timeZone: TimeZone? = nil) {
        self.name = name
        self.streetName = streetName
        self.streetNumber = streetNumber
        self.locality = locality
        self.subLocality = subLocality
        self.administrativeArea = administrativeArea
        self.subAdministrativeArea = subAdministrativeArea
        self.postalCode = postalCode
        self.countryCode = countryCode
        self.countryName = countryName
        self.coordinate = coordinate
        self.timeZone = timeZone
    }

    public func formattedShortAddress() -> String {
        if let name = name {
            return name
        }

        var addressComponents: [String] = []

        if let streetName = streetName {
            addressComponents.append(streetName)

            if let streetNumber = streetNumber {
                addressComponents.append(streetNumber)
            }
        }
        if let locality = locality {
            addressComponents.append(locality)
        }

        if addressComponents.isEmpty {
            return formattedDistrict()
        }

        addressComponents = addressComponents.filter { !$0.isEmpty }
        return addressComponents.joined(separator: ", ")
    }

    public func formattedFullAddress() -> String {
        if let name = name {
            return name
        }

        var addressComponents: [String] = []

        if let streetName = streetName {
            addressComponents.append(streetName)

            if let streetNumber = streetNumber {
                addressComponents.append(streetNumber)
            }
        }

        if let postalCode = postalCode {
            addressComponents.append(postalCode)
        }

        if let locality = locality {
            addressComponents.append(locality)
        }

        if let countryName = countryName {
            addressComponents.append(countryName)
        }

        addressComponents = addressComponents.filter { !$0.isEmpty }
        return addressComponents.joined(separator: ", ")
    }

    public func formattedDistrict() -> String {
        return subLocality ?? locality ?? formattedRegion()
    }

    public func formattedRegion() -> String {
        var addressComponents: [String] = []

        if  let administrativeArea = administrativeArea {
            addressComponents.append(administrativeArea)
        } else if let subAdministrativeArea = subAdministrativeArea {
            addressComponents.append(subAdministrativeArea)
        } else if let locality = locality {
            addressComponents.append(locality)
        }

        if let countryName = countryName {
            addressComponents.append(countryName)
        }

        addressComponents = addressComponents.filter { !$0.isEmpty }
        return addressComponents.joined(separator: ", ")
    }
}

extension Address: JSONMappable {
    public init(json: JSONObject) throws {
        if json.has("html_attributions") || json.has("result") {
            try self.init(googlePlaceJson: try json.getJSONObject("result"))
        } else {
            try self.init(serverJSON: json)
        }
    }

    private init(serverJSON json: JSONObject) throws {
        self.streetName = try? json.getString("street")
        self.postalCode = try? json.getString("postal_code")
        self.locality = try? json.getString("city")
        self.coordinate = try? Coordinate(json: json.getJSONObject("coordinate"))
        self.name = try? json.getString("name")
        self.streetNumber = try? json.getString("street_number")
        self.subLocality = try? json.getString("sub_locality")
        self.administrativeArea = try? json.getString("administrative_area")
        self.subAdministrativeArea = try? json.getString("sub_administrative_area")
        self.countryCode = try? json.getString("country_code")
        self.countryName = json.optString("country") ?? json.optString("country_name")
        if let timezone = try? json.getString("timezone") {
            self.timeZone = TimeZone(identifier: timezone)
        } else {
            self.timeZone = nil
        }
    }

    private init(googlePlaceJson json: JSONObject) throws {
        self.name = try json.getString("name")
        let coordinateJson = try json.getJSONObject("geometry").getJSONObject("location")
        self.coordinate = Coordinate(lat: try coordinateJson.getDouble("lat"), lon: try coordinateJson.getDouble("lng"))

        var streetNumber: String? = nil
        var streetName: String? = nil
        var locality: String? = nil
        var subLocality: String? = nil
        var administrativeArea: String? = nil
        var subAdministrativeArea: String? = nil
        var postalCode: String? = nil
        var countryName: String? = nil
        var countryCode: String? = nil

        let addressComponents = try json.getJSONArray("address_components").asJSONList()

        for component in addressComponents {
            guard let types = try? component.getStringArray("types") else { continue }
            let name = try? component.getString("long_name")

            if types.contains("street_number") {
                streetNumber = name
            } else if types.contains("route") {
                streetName = name
            } else if types.contains("locality") {
                locality = name
            } else if types.contains("sublocality") {
                subLocality = name
            } else if types.contains("administrative_area_level_1") {
                administrativeArea = name
            } else if types.contains("administrative_area_level_2") {
                subAdministrativeArea = name
            } else if types.contains("postal_code") {
                postalCode = name
            } else if types.contains("country") {
                countryName = name
                countryCode = try? component.getString("short_name")
            }
        }

        self.streetNumber = streetNumber
        self.streetName = streetName
        self.locality = locality
        self.subLocality = subLocality
        self.administrativeArea = administrativeArea
        self.subAdministrativeArea = subAdministrativeArea
        self.postalCode = postalCode
        self.countryName = countryName
        self.countryCode = countryCode
        self.timeZone = nil
    }
}

extension Address: JSONSerializable {
    public func toJson() -> JSONObject {
        let json = JSONObject()
        json.setString("street", streetName)
        json.setString("postal_code", postalCode)
        json.setString("city", locality)
        json.setObject("coordinate", coordinate?.toJson())
        json.setString("name", name)
        json.setString("street_number", streetNumber)
        json.setString("sub_locality", subLocality)
        json.setString("administrative_area", administrativeArea)
        json.setString("sub_administrative_area", subAdministrativeArea)
        json.setString("country_code", countryCode)
        json.setString("country", countryName)
        json.setString("timezone", timeZone?.identifier)

        return json
    }
}

extension Address {

    public init(_ placemark: CLPlacemark, coordinate: Coordinate?) {
        self.name = placemark.name
        self.streetName = placemark.thoroughfare
        self.streetNumber = placemark.subThoroughfare
        self.locality = placemark.locality
        self.subLocality = placemark.subLocality
        self.administrativeArea = placemark.administrativeArea
        self.subAdministrativeArea = placemark.subAdministrativeArea
        self.postalCode = placemark.postalCode
        self.countryCode = placemark.isoCountryCode
        self.countryName = placemark.country
        self.timeZone = placemark.timeZone

        if let coordinate = coordinate {
            self.coordinate = coordinate
        } else if let location = placemark.location {
            self.coordinate = Coordinate(location.coordinate)
        } else {
            self.coordinate = nil
        }

    }

}

extension Address: Equatable {}
public func == (lhs: Address, rhs: Address) -> Bool {
    return lhs.coordinate == rhs.coordinate
}
