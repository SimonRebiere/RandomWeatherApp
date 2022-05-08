//
//  NetworkingError.swift
//  RandomWeatherAPP
//
//  Created by simon rebiere on 01/05/2022.
//

import Foundation

//Errors returned to services in case of failure
struct NetworkingError: Error {
    let errorType: NetworkingErrorType
    let message: String
}

enum NetworkingErrorType {
    case emptyData
    case decodingFailed
    case networkError(code: Int)
    case badRequest
    
    var description: String {
        switch self {
        case .emptyData: return "The service recovered empty data where it should not."
        case .decodingFailed: return "Failed to decode data sent."
        case .networkError(let code): return "Networking Error: status code: \(code)"
        case .badRequest: return "Error while creating the request"
        }
    }
}
