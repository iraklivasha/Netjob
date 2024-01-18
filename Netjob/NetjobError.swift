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
    case unauthorized
    case badRequest(error: Error)
    case decodingFailed(error: Error)
    case prohibited(error: Error)
    case user(message: String)
    case server(error: Error)
    case cancelled
    case unknown(error: Error?)
    
    init(statusCode: Int, error: Error, message: String? = nil) {
        switch statusCode {
        case 400:
            self = .badRequest(error: error)
        case 401:
            self = .unauthorized
        case 403:
            self = .prohibited(error: error)
        case 404:
            self = .notFound(error: error)
        case 422:
            self = .decodingFailed(error: error)
        case 408:
            self = .timeout(error: error)
        case 500:
            self = .server(error: error)
        case 1000:
            self = .requestFailed(error)
        case 1001:
            self = .user(message: message ?? "")
        case -999:
            self = .cancelled
        default:
            self = .unknown(error:error)
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
        case .cancelled: return -999
        case .user(_): return 1001
        case .server(_): return 500
        case .unknown(_): return 1002
        }
    }
    
    var message: String {
        switch self {
        case .unknown:          return "Something went wrong"
        case .notFound:         return "Resource not found"
        case .prohibited:       return "Forbidden"
        case .server:           return "Internal server error"
        case .cancelled:        return "Cancelled"
        case .unauthorized:     return "Unauthorized access"
        case .decodingFailed:   return "Invalid content"
        case .timeout:          return "Network timeout"
        case .requestFailed:    return "Request failed"
        case .badRequest:       return "Bad request"
        case .user(let m):      return m
        }
    }
}
