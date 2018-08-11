//
//  LocationManager+Request.swift
//  My Sports
//
//  Created by Angel Garcia on 16/12/2016.
//  Copyright © 2016 Syltek Solutions S.L. All rights reserved.
//

import Foundation

// MARK: Internal class to keep request data
extension LocationManager {
    class LocationRequest: NSObject {
        let minAccuracy: Double?
        let maxAge: TimeInterval
        let timeout: TimeInterval
        let fulfill: (Location) -> Void
        let reject: (Error) -> Void
        var timer: Timer?

        init (minAccuracy: Double?, maxAge: TimeInterval, timeout: TimeInterval, fulfill: @escaping (Location) -> Void, reject: @escaping (Error) -> Void) {
            self.minAccuracy = minAccuracy
            self.maxAge = maxAge
            self.timeout = timeout
            self.fulfill = fulfill
            self.reject = reject
        }

        func isLocationValid(location: Location) -> Bool {

            //Check the accuaracy
            if let minAccuracy = minAccuracy {
                guard let locationAccuracy = location.accuracy else { return false }
                if minAccuracy < locationAccuracy {
                    return false
                }
            }

            //Check the age
            if maxAge > 0 && -location.timestamp.timeIntervalSinceNow > maxAge {
                return false
            }

            return true
        }

    }
}

func == (lhs: LocationManager.LocationRequest, rhs: LocationManager.LocationRequest) -> Bool {
    return lhs === rhs
}
