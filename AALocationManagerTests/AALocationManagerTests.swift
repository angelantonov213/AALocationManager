//
//  AALocationManagerTests.swift
//  AALocationManagerTests
//
//  Created by Angel Antonov on 18.05.19.
//  Copyright © 2019 Angel Antonov. All rights reserved.
//

import XCTest
import CoreLocation
@testable import AALocationManager

class AALocationManagerTests: XCTestCase {
    
    var mockLocationManager: MockLocationManager?
    var sut: AALocationManager?
    
    func test_UpdatingIsInfinite() {
        mockLocationManager = MockLocationManager()
        sut = AALocationManager(locationManager: mockLocationManager!)
        
        var count: Int = 0
        
        sut?.locationFound = { _ in
            count += 1
            
            if count > 15 {
                XCTAssert(true)
            }
        }
        
        sut?.startLocating()
    }
    
    func test_UpdatingIsExactNumber() {
        var count: Int = 0
        let target: Int = 6
        
        mockLocationManager = MockLocationManager()
        sut = AALocationManager(maxLocationUpdates: target, locationManager: mockLocationManager!, locationManagerType: MockLocationManager.self)
        
        mockLocationManager?.stopUpdatingLocationCalled = {
            XCTAssertEqual(count, target)
        }
        
        sut?.locationFound = { _ in
            count += 1
        }
        
        sut?.startLocating()
    }
}


class MockLocationManager: NSObject, LocationManager {
    static func authorizationStatus() -> CLAuthorizationStatus {
        return .authorizedWhenInUse
    }
    
    static func locationServicesEnabled() -> Bool {
        return true
    }
    
    var delegate: CLLocationManagerDelegate?
    var stopUpdatingLocationCalled: (() -> ())?
    
    override init() {
        
    }
    
    func startUpdatingLocation() {
        for _ in 0..<20 {
            self.delegate?.locationManager?(CLLocationManager(), didUpdateLocations: [CLLocation(latitude: 20.0, longitude: 20.0)])
        }
    }
    
    func stopUpdatingLocation() {
        self.stopUpdatingLocationCalled?()
    }
    
    func requestWhenInUseAuthorization() {
        
    }
}
