//
//  LocationWeatherEndpoint.swift
//  RandomWeatherAPP
//
//  Created by simon rebiere on 01/05/2022.
//

import Foundation
import Combine

struct LocationWeatherEndpoint: EndpointType {
    var path: String { "api/location/" }
    var method: HTTPMethods { .get }
    
    var queryParams: [URLQueryItem]?
    var additionalInfos: String
    
    init(queryParams: [URLQueryItem]? = nil, additionalInfos: String = "") {
        self.queryParams = queryParams
        self.additionalInfos = additionalInfos
    }
}
