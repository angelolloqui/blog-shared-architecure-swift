//
//  LocationManager.swift
//  My Sports
//
//  Created by Angel Garcia on 12/12/2016.
//  Copyright © 2016 Syltek Solutions S.L. All rights reserved.
//

import Foundation
import CoreLocation
import LMGeocoder
import AnemoneSDK

public class LocationManager: NSObject, ILocationManager {
    private let defaultMinAccuracy = 500.0
    private let defaultMaxAge = 60.0
    private let defaultTimeout = 30.0

    let locationManager: CLLocationManager
    let geocoder: LMGeocoder
    let service: LMGeocoderService
    let httpClient: IHttpClient
    let googleApiKey: String

    var requests: [LocationRequest] = [] {
        didSet {
            if requests.isEmpty {
                locationManager.stopUpdatingLocation()
            } else {
                updateLocationAccuracy()
                locationManager.startUpdatingLocation()
            }
        }
    }

    init(locationManager: CLLocationManager, geocoder: LMGeocoder, service: LMGeocoderService = .googleService, httpClient: IHttpClient, googleApiKey: String) {
        self.locationManager = locationManager
        self.geocoder = geocoder
        self.service = service
        self.httpClient = httpClient
        self.googleApiKey = googleApiKey
        super.init()
        self.locationManager.delegate = self
    }

    public var locationStatus: LocationServiceStatus {
        guard type(of: locationManager).locationServicesEnabled() else {
            return .disabled
        }
        let status = type(of: locationManager).authorizationStatus()
        return LocationServiceStatus(status: status)
    }

    public var lastLocation: Location? {
        guard let location = locationManager.location else { return nil }
        return Location(location)
    }

    public func findLocation(allowRequestPermission: Bool) -> Promise<Location> {
        return findLocation(allowRequestPermission: allowRequestPermission, minAccuracy: defaultMinAccuracy, maxAge: defaultMaxAge, timeout: defaultTimeout)
    }

    public func findLocation(allowRequestPermission: Bool, minAccuracy: Double, maxAge: TimeInterval, timeout: TimeInterval) -> Promise<Location> {
        return Promise { fullfill, reject in
            let request = LocationRequest(minAccuracy: minAccuracy, maxAge: maxAge, timeout: timeout, fulfill: fullfill, reject: reject)
            self.addRequest(request, allowRequestPermission: allowRequestPermission)
        }
    }

    public func findAddress(coordinate: Coordinate) -> Promise<Address> {
        return Promise { fulfill, reject in
            let location = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            self.geocoder.reverseGeocodeCoordinate(location, service: self.service) { placemarks, error in
                if let placemark = placemarks?.first {
                    fulfill(Address(placemark, coordinate: coordinate))
                } else {
                    reject(error ?? AnemoneException.notFound)
                }
            }
        }
    }

    public func findAddresses(text: String) -> Promise<[Address]> {
        return Promise { fulfill, reject in
            self.geocoder.geocodeAddressString(text, service: self.service) { placemarks, error in
                if let placemarks = placemarks {
                    let addresses = placemarks.map { Address($0, coordinate: nil) }
                    fulfill(addresses)
                } else {
                    reject(error ?? AnemoneException.notFound)
                }
            }
        }
    }

    public func findAddress(placeAutocomplete: PlaceAutocomplete) -> Promise<Address> {
        let endpoint = "https://maps.googleapis.com/maps/api/place/details/json"
        let params: [String: Any] = [
            "key": googleApiKey,
            "placeid": placeAutocomplete.id
        ]
        return httpClient.get(endpoint: endpoint, params: params).then { JSONTransformer().map($0) }
    }

    public func findAutocomplete(text: String) -> Promise<[PlaceAutocomplete]> {
        let endpoint = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
        var params: [String: Any] = [
            "key": googleApiKey,
            "input": text,
            "types": "geocode"
        ]
        if let location = lastLocation {
            params["location"] = location.coordinate
            params["radius"] = 100000
        }

        let transformer = JSONTransformer()
        transformer.rootKey = "predictions"
        return httpClient.get(endpoint: endpoint, params: params).then { transformer.map($0) }
    }

    public func hasPermission() -> Bool {
        return self.locationStatus == .authorized
    }

    public func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

}

extension LocationManager: CLLocationManagerDelegate {

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = self.lastLocation else { return }
        let validRequests = requests.filter { $0.isLocationValid(location: location) }

        validRequests.forEach { request in
            if let index = self.requests.index(of: request) {
                self.requests.remove(at: index)
            }
            request.timer?.invalidate()
            request.fulfill(location)
        }
    }

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            if !requests.isEmpty {
                locationManager.startUpdatingLocation()
            }
        } else {
            rejectPendingRequests(error: AnemoneException.denied)
        }
    }

}

// MARK: Internal utility methods
extension LocationManager {

    func addRequest(_ request: LocationRequest, allowRequestPermission: Bool) {

        //If location is rejected, then return error
        if self.locationStatus == .denied || self.locationStatus == .disabled {
            request.reject(AnemoneException.denied)
            return
        }

        //If last location is already valid then early return
        if  let lastLocation = lastLocation,
            request.isLocationValid(location: lastLocation) {
            request.fulfill(lastLocation)
            return
        }

        //If no permission given yet, then just request it
        if self.locationStatus == .notDetermined {
            if !allowRequestPermission {
                request.reject(AnemoneException.denied)
                return
            }

            requestLocationPermission()
        }

        //If timeout, set timer to be able to fail request after timeout
        if request.timeout > 0 {
            request.timer = Timer.scheduledTimer(timeInterval: TimeInterval(request.timeout),
                                                 target: self, selector: #selector(LocationManager.requestTimeOut(_:)),
                                                 userInfo: request,
                                                 repeats: false)
        }

        requests.append(request)
    }

    func updateLocationAccuracy() {
        let bestAccuracy = requests.reduce(kCLLocationAccuracyThreeKilometers) { acc, req in
            return min(req.minAccuracy ?? acc, acc)
        }
        locationManager.desiredAccuracy = bestAccuracy
    }

    @objc
    func requestTimeOut(_ timer: Timer) {
        guard let request = timer.userInfo as? LocationRequest, let index = self.requests.index(of: request) else { return }
        request.reject(AnemoneException.timeout)
        self.requests.remove(at: index)
    }

    func rejectPendingRequests(error: Error) {
        self.requests.forEach({ $0.reject(error) })
        self.requests.removeAll()
    }
}
