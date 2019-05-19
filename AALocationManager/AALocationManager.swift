//
//  LocationManager.swift
//  SubcommPoolsIOS Service
//
//  Created by Angel Antonov on 10.03.19.
//  Copyright © 2019 Angel Antonov. All rights reserved.
//

import CoreLocation

public enum RequestAuthorizationType {
    case whenInUse
    case always
}

public protocol LocationManager {
    var delegate: CLLocationManagerDelegate? { get set }
    
    func startUpdatingLocation()
    func stopUpdatingLocation()
    func requestWhenInUseAuthorization()
    func requestAlwaysAuthorization()
    
    static func locationServicesEnabled() -> Bool
    static func authorizationStatus() -> CLAuthorizationStatus
}

extension CLLocationManager: LocationManager {}

public class AALocationManager: NSObject {
    
    /**
     Determines how much times locationManagers didUpdateLocations method will be called.
     -1 for inifnite calls.
    */
    public var maxLocationUpdates: Int
    
    private var locationManager: LocationManager
    private var locationUpdatesCounter: Int
    private var locationManagerType: LocationManager.Type
    
    private var requestAuthorizationType: RequestAuthorizationType
    
    public var locationFound: ((CLLocation) -> ())?
    public var informationMessage: ((String) -> ())?
    
    public var authorizationStatusRestrictedMessage = "You have restirected the app from using location services. Please go to Settings and enable them if you want to use the feature."
    public var authorizationStatusDeniedMessage = "You have denied the app from using location services. Please go to Settings and enable them if you want to use the feature."
    public var authorizationStatusUnknownErrorMessage = "Unknown error"
    
    public var locationServicesDisabledMessage = "Location services are not enabled. Please go to Settings and enable them if you want to use the feature."
    
    /**
     - Parameters:
        - maxLocationUpdates: Determines how much times locationManagers didUpdateLocations method will be called.
        - requestAuthorizationType: Determines wether it calls requestWhenInUseAuthorization() or requestAlwaysAuthorization() of the location manager
        - locationManager: CLLocationManager that could be used for unit tests
        - locationManagerType: CLLocationManager type that could be used for unit tests
     */
    public init(maxLocationUpdates: Int = -1,
         requestAuthorizationType: RequestAuthorizationType = .whenInUse,
         locationManager: LocationManager = CLLocationManager(),
         locationManagerType: LocationManager.Type = CLLocationManager.self) {
        self.locationManager = locationManager
        self.locationManagerType = locationManagerType
        
        self.maxLocationUpdates = maxLocationUpdates
        self.locationUpdatesCounter = maxLocationUpdates
        
        self.requestAuthorizationType = requestAuthorizationType
        
        super.init()
        
        self.locationManager.delegate = self
    }
    
    /**
     Starts locating if the app is authorized to do so. Otherwise asks for location services authorization or informs the user if the app is alread unauthorized to use location services.
     */
    public func startLocating() {
        self.checkIfLocationServicesEnabled()
    }
    
    /**
     Stops locating the user.
     */
    public func stopLocating() {
        self.locationManager.stopUpdatingLocation()
    }
    
    private func locate() {
        locationUpdatesCounter = maxLocationUpdates
        self.locationManager.startUpdatingLocation()
    }
    
    private func checkIfLocationServicesEnabled() {
        if self.locationManagerType.locationServicesEnabled() {
            switch self.locationManagerType.authorizationStatus() {
            case .notDetermined:
                switch requestAuthorizationType {
                case .whenInUse:
                    self.locationManager.requestWhenInUseAuthorization()
                case .always:
                    self.locationManager.requestAlwaysAuthorization()
                }
            case .restricted:
                self.informationMessage?(self.authorizationStatusRestrictedMessage)
            case .denied:
                self.informationMessage?(self.authorizationStatusDeniedMessage)
            case .authorizedAlways, .authorizedWhenInUse:
                self.locate()
            @unknown default:
                self.informationMessage?(self.authorizationStatusUnknownErrorMessage)
            }
        } else {
            self.informationMessage?(self.locationServicesDisabledMessage)
        }
    }
}

extension AALocationManager: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.locationFound?(location)
        }
        
        locationUpdatesCounter -= 1
        
        if locationUpdatesCounter == 0 {
            self.locationManager.stopUpdatingLocation()
            return
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            self.locate()
        }
    }
}

