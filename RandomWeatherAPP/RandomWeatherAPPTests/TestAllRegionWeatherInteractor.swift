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
    
    func testLoadData() {
        let expectation = XCTestExpectation(description: "success")
        service.expecation = expectation
        interactor.loadDatas()
        
        wait(for: [expectation], timeout: 0.2)
    }
    
    func testLoadData_failure() {
        let failExpectation = XCTestExpectation(description: "failure")
        service.shouldFail = true
        service.expecation = failExpectation
        interactor.loadDatas()
        
        wait(for: [failExpectation], timeout: 0.2)
    }
    
    func testShowMoreDetails() {
        let locationVm = LocationModel(title: "title", country: "country", actualTemp: 2.0, nextDaysWeather: [], state: "state", imageURL: "url")
        interactor.viewModel.models.append(locationVm)
        interactor.showMoreDetails(for: "title")
        
        XCTAssertFalse(locationVm.detailHidden)
    }
    
    
    func testShowMoreDetails_failure() {
        let locationVm = LocationModel(title: "title", country: "country", actualTemp: 2.0, nextDaysWeather: [], state: "state", imageURL: "url")
        interactor.viewModel.models.append(locationVm)
        interactor.showMoreDetails(for: "titi")
        
        XCTAssertTrue(locationVm.detailHidden)
    }
}

class MockLocationWeatherService: LocationWeatherServiceMethods {
    
    var shouldFail: Bool = false
    
    var expecation: XCTestExpectation? = nil
    
    func getWeather(for location: String) -> AnyPublisher<LocationWeatherResponse, Error> {
        if shouldFail {
            expecation?.fulfill()
            return Fail(error: NetworkingError(errorType: .badRequest, message: "Error while creating URL")).eraseToAnyPublisher()
        }
        expecation?.fulfill()
        return Just(getResponse())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func getResponse() -> LocationWeatherResponse{
        let consolidatedWeatherResponse = ConsolidatedWeather(id: 1, weatherStateName: "sunny", weatherStateAbbr: "sn", windDirectionCompass: "north", created: "date", applicableDate: "date", minTemp: 3.0, maxTemp: 5.0, theTemp: 4.0, windSpeed: 25.0, windDirection: 24.0, airPressure: 3.0, humidity: 5, visibility: 35.0, predictability: 2)
        let parentResponse = Parent(title: "title", locationType: "city", woeid: 23343, lattLong: "lat")
        let sourceResponse = Source(title: "title", slug: "slug", url: "url", crawlRate: 2)
        let response = LocationWeatherResponse(consolidatedWeather: [consolidatedWeatherResponse], time: "time", sunRise: "sunRise time", sunSet: "sunSet time", timezoneName: "europe", parent: parentResponse, sources: [sourceResponse], title: "title", locationType: "city", woeid: 23343, lattLong: "lat", timezone: "euro")
        return response
    }
}
