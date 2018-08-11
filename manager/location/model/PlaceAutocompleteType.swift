//
//  PlaceAutocompleteType.swift
//  Anemone SDK
//
//  Created by Angel Luis Garcia on 09/05/2017.
//  Copyright © 2017 Syltek Solutions S.L. All rights reserved.
//

import Foundation

public enum PlaceAutocompleteType {
    case neighborhood, district, city, region, station, other

    init(rawValue: String) {
        switch rawValue {
        case "bus_station",
             "train_station",
             "transit_station",
             "subway_station":
            self = .station

        case "neighborhood":
            self = .neighborhood

        case "sublocality",
             "sublocality_level_1":
            self = .district

        case "locality":
            self = .city

        case "administrative_area_level_1",
             "administrative_area_level_2",
             "administrative_area_level_3",
             "administrative_area_level_4":
            self = .region

        default:
            self = .other
        }
    }

}
