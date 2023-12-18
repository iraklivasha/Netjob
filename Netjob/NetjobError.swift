//
//  NetjobError.swift
//  Netjob
//
//  Created by Irakli Vashakidze on 01/06/2020.
//  Copyright © 2023 Irakli Vashakidze. All rights reserved.
//

import Foundation

public enum NetjobError: Error {
    case requestFailed(_ error: Error?)
    case timeout(error: Error?)
    case notFound(error: Error)
    case unauthorized(error: Error)
    case badRequest(error: Error)
    case decodingFailed(error: Error)
    case prohibited(error: Error)
    
    init(statusCode: Int, error: Error) {
        switch statusCode {
        case 400:
            self = .badRequest(error: error)
        case 401:
            self = .unauthorized(error: error)
        case 403:
            self = .prohibited(error: error)
        case 404:
            self = .notFound(error: error)
        case 422:
            self = .decodingFailed(error: error)
        case 408:
            self = .timeout(error: error)
        default:
            self = .requestFailed(error)
        }
    }
    
    public var code: Int {
        switch self {
        case .timeout: return 408
        case .prohibited(_): return 403
        case .notFound: return 404
        case .unauthorized: return 401
        case .badRequest(_): return 400
        case .decodingFailed(_): return 422
        case .requestFailed(_): return 1000
        }
    }
}
