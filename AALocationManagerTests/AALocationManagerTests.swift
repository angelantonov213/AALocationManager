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
    
    func test_requestWhenInUseAuthorization_called() {
        let mockLocationManager = MockLocationManager_AuthorizationType(requestAuthorizationType: .whenInUse)
        sut = AALocationManager(maxLocationUpdates: 1, requestAuthorizationType: .whenInUse, locationManager: mockLocationManager, locationManagerType: MockLocationManager.self)
        
        sut?.locationFound = { _ in
            XCTAssertEqual(mockLocationManager.requestAuthorizationType_whenInUsed_called, 1)
            XCTAssertEqual(mockLocationManager.requestAuthorizationType_always_called, 0)
        }
        
        sut?.startLocating()
    }
    
    func test_requestAlwaysAuthorization_called() {
        let mockLocationManager = MockLocationManager_AuthorizationType(requestAuthorizationType: .always)
        sut = AALocationManager(maxLocationUpdates: 1, requestAuthorizationType: .always, locationManager: mockLocationManager, locationManagerType: MockLocationManager.self)
        
        sut?.locationFound = { _ in
            XCTAssertEqual(mockLocationManager.requestAuthorizationType_whenInUsed_called, 0)
            XCTAssertEqual(mockLocationManager.requestAuthorizationType_always_called, 1)
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
    
    func requestAlwaysAuthorization() {
        
    }
}

class MockLocationManager_AuthorizationType: NSObject, LocationManager {
    private var requestAuthorizationType: RequestAuthorizationType!
    
    static func authorizationStatus() -> CLAuthorizationStatus {
        return .notDetermined
    }
    
    static func locationServicesEnabled() -> Bool {
        return true
    }
    
    var delegate: CLLocationManagerDelegate?
    var stopUpdatingLocationCalled: (() -> ())?
    
    var requestAuthorizationType_whenInUsed_called = 0
    var requestAuthorizationType_always_called = 0
    
    
    init(requestAuthorizationType: RequestAuthorizationType) {
        self.requestAuthorizationType = requestAuthorizationType
    }
    
    func startUpdatingLocation() {
        
    }
    
    func stopUpdatingLocation() {
        self.stopUpdatingLocationCalled?()
    }
    
    func requestWhenInUseAuthorization() {
        requestAuthorizationType_whenInUsed_called += 1
    }
    
    func requestAlwaysAuthorization() {
        requestAuthorizationType_always_called += 1
    }
}
