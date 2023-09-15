//
//  NetjobError.swift
//  Netjob
//
//  Created by Qutaibah Essa on 01/06/2020.
//  Copyright © 2020 MRSOOL. All rights reserved.
//

import Foundation

public enum NetjobError: Error {
    case general(error: Error?)
    case timeout
    case serverError
    case notFound
    case unauthorized
    case badRequest(error: Error?)
    case decodingFailed(error: Error?)
    case nilData
    case prohibited(error: Error?)
    case custom(message: String)
    case cancelled
    
    var embeddedError: Error? {
        switch self {
        case .decodingFailed(let error):
            return error
        case .badRequest(let error):
            return error
        case .decodingFailed(let error):
            return error
        case .general(let error):
            return error
        case .prohibited(let error):
            return error
        default:
            return nil
        }
    }

    init(statusCode: Int, error: Error?) {
        switch statusCode {
        case 400:
            self = .badRequest(error: error)
        case 401:
            self = .unauthorized
        case 403:
            self = .prohibited(error: error)
        case 404:
            self = .notFound
        case 422:
            self = .decodingFailed(error: error)
        case 500..<600:
            self = .serverError
        default:
            self = .general(error: error)
        }
    }
    
    public var code: Int {
        switch self {
        case .timeout: return 800
        case .serverError: return 500
        case .prohibited(_): return 403
        case .notFound: return 404
        case .unauthorized: return 401
        case .badRequest(_): return 400
        case .decodingFailed(_): return 422
        case .nilData: return 801
        case .custom(_): return 802
        case .cancelled: return -999
        default: return 1000
        }
    }
}
