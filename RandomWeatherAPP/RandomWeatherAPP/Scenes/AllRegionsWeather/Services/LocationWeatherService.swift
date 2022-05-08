//
//  LocationWeatherService.swift
//  RandomWeatherAPP
//
//  Created by simon rebiere on 01/05/2022.
//

import Foundation
import Combine

protocol LocationWeatherServiceMethods {
    func getWeather(for location: String) -> AnyPublisher<LocationWeatherResponse, Error>
}

struct LocationWeatherService: LocationWeatherServiceMethods {
    
    let networker: NetworkingMethods
    
    init(networker: NetworkingMethods = Networker()) {
        self.networker = networker
    }
    
    func getWeather(for location: String) -> AnyPublisher<LocationWeatherResponse, Error> {
        return networker.fetchDecodable(endpoint: LocationWeatherEndpoint(additionalInfos: location), type: LocationWeatherResponse.self, decoder: JSONDecoder())
    }
}
