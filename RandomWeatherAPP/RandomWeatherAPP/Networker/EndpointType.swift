//
//  EndpointType.swift
//  RandomWeatherAPP
//
//  Created by simon rebiere on 01/05/2022.
//

import Foundation

protocol EndpointType {
    var baseUrl: String { get }
    var path: String { get }
    var method: HTTPMethods { get }
    var queryParams: [URLQueryItem]? { get set}
    var additionalInfos: String { get set }
}

extension EndpointType {
    var baseUrl: String { return "https://www.metaweather.com/" }
}
