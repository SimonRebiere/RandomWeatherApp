//
//  TestAllRegionWeatherInteractor.swift
//  RandomWeatherAPPTests
//
//  Created by simon rebiere on 08/05/2022.
//

import Foundation
import XCTest
import Combine
@testable import RandomWeatherAPP

class TestAllRegionWeatherInteractor: XCTestCase {
    
    var interactor: AllRegionWeatherInteractor!
    var service: MockLocationWeatherService!
    
    override func setUp() {
        service = MockLocationWeatherService()
        interactor = AllRegionWeatherInteractor(locationService: service)
    }
}

class MockLocationWeatherService: LocationWeatherServiceMethods {
    
    var shouldFail: Bool = false
    
    func getWeather(for location: String) -> AnyPublisher<LocationWeatherResponse, Error> {
        if shouldFail {
            return Fail(error: NetworkingError(errorType: .badRequest, message: "Error while creating URL")).eraseToAnyPublisher()
        }
    }
}
