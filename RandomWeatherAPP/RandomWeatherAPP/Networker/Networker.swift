//
//  Networker.swift
//  RandomWeatherAPP
//
//  Created by simon rebiere on 01/05/2022.
//

import Foundation
import Combine

enum HTTPMethods: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

//makes the request
protocol NetworkingMethods {
    //This function takes a generic endpoint to handle all request in the same way,
    //Endpoint contains all necessary informations for the URL to be constructed
    func fetchDecodable<DecodableObject: Decodable>(endpoint: EndpointType,
                                                    type: DecodableObject.Type,
                                                    decoder: JSONDecoder) -> AnyPublisher<DecodableObject, Error>
}

struct Networker: NetworkingMethods {
    func fetchDecodable<DecodableObject: Decodable>(endpoint: EndpointType,
                                                    type: DecodableObject.Type,
                                                    decoder: JSONDecoder) -> AnyPublisher<DecodableObject, Error> {
        guard let url = composeURL(endpoint: endpoint) else {
            return Fail(error: NetworkingError(errorType: .badRequest, message: "Error while creating URL")).eraseToAnyPublisher()
        }
        
        let urlSession: URLSession = URLSession(configuration: .default)
        
        return urlSession.dataTaskPublisher(for: url)
            .tryMap({ element -> Data in
                guard let response = element.response as? HTTPURLResponse else {
                    throw NetworkingError(errorType: .badRequest,
                                          message: "could not convert cast response in HTTPURLResponse")
                }
                guard response.statusCode == 200 else {
                    throw NetworkingError(errorType: .networkError(code: response.statusCode),
                                          message: response.description)
                }
                return element.data
            })
            .decode(type: DecodableObject.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
    
    //In order to create the url needed for the request, it is passed to this function, which will extract informations
    //from the endpoint. The viability of this url will be verified in the caller.
    private func composeURL(endpoint: EndpointType) -> URL? {
        var urlComponents = URLComponents(string: endpoint.baseUrl + endpoint.path + endpoint.additionalInfos)
        urlComponents?.queryItems = endpoint.queryParams

        return urlComponents?.url
    }
}
