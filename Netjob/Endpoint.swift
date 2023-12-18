//
//  Endpoint.swift
//  Netjob
//
//  Created by Irakli Vashakidze on 01/06/2020.
//  Copyright © 2023 Irakli Vashakidze. All rights reserved.
//

import Foundation
import Combine

private let netjobCodingStrategy = CodingStrategy()

/// Endpoint interface
public protocol Endpoint {

    /// The last path component to the endpoint. will be appended to the base url in the service
    var url: String { get }

    /// The encoded parameters
    var parameters: Any? { get }
    
    /// The encoded parameters
    var urlParameters: [String: String]? { get }

    /// The HTTP headers to be appended in the request, default is nil
    var headers: [String: String]? { get }

    /// Http method
    var method: HTTPMethod { get }
    
    /// How long (in seconds) a task should wait for additional data to arrive. The timer is reset whenever new data arrives.
    var timeout: TimeInterval { get }
    
    /// Caching policy for the endpoint
    var cachePolicy: URLRequest.CachePolicy { get }
    
    var requestContentType: String { get }
    
    var network: Network { get }
    var configuration: URLSessionConfiguration? { get  }
    var codingStrategy: CodingStrategy { get }
    var sslPinningEnabled: Bool { get }
    var certFilaPath: String? { get }
    var callbackQueue: DispatchQueue { get }
}

public extension Endpoint {
    
    var parameters: Any? { nil }
    var urlParameters: [String: String]? { nil }
    var headers: [String: String]? { nil }
    var timeout: TimeInterval { 30 }
    var sslPinningEnabled: Bool { false }
    var certFilaPath: String? { nil }
    var cachePolicy: URLRequest.CachePolicy { .returnCacheDataElseLoad }
    var callbackQueue: DispatchQueue { DispatchQueue.main }
    var requestContentType: String { "application/json" }
    var configuration: URLSessionConfiguration? { nil }
    var codingStrategy: CodingStrategy { return netjobCodingStrategy }
    var network: Network { Netjob.shared }
    
    @discardableResult
    func requestData(success: @escaping DataResponse, failure: @escaping ErrorResponse)  -> NetjobRequest {
        self.network.request(endpoint: self, 
                             success: success,
                             failure: failure)
    }

    @discardableResult
    func request<T: Decodable>(success: @escaping DecodableResponse<T>, failure: @escaping ErrorResponse) -> NetjobRequest {
        self.network.request(endpoint: self, 
                             success: success,
                             failure: failure)
    }
    
    func requestPublisher<T: Decodable>(endpoint: Endpoint) -> AnyPublisher<T, Error> {
        self.network.requestPublisher(endpoint: endpoint)
    }
}

// Request
extension Endpoint {
    var httpRequest: URLRequest {
        
        let url = urlWith(url: self.url,
                          query: (self.method == .get || self.method == .delete) ? self.parameters as? [String: Any] : self.urlParameters)
        
        var request = URLRequest(url: url)
        request.httpMethod              = self.method.rawValue.uppercased()
        request.allHTTPHeaderFields     = self.headers
        request.cachePolicy             = self.cachePolicy
        request.httpShouldHandleCookies = false
        request.setValue(self.requestContentType, forHTTPHeaderField: "Content-Type")
        
        if self.method == .post || self.method == .patch {
            
            if (self.requestContentType == "application/x-www-form-urlencoded") {
                request.httpBody = self.urlStringFrom(parameters: self.parameters).data(using: .utf8)
                request.setValue("\(request.httpBody?.count ?? 0)", forHTTPHeaderField: "Content-Length")
            } else {
                request.encodeParameters(parameters: self.parameters ?? [:])
            }
        }
        
        return request
    }
    
    private func urlWith(url: String, query: [String: Any]?) -> URL {
        // make sure the base url is valid
        guard let baseUrl = URL(string: url) else {
            fatalError("Invalid URL: \(url)")
        }
        // if there are any query items
        guard let query = query else { return baseUrl }
        
        // create the url query
        var components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true)
        components?.queryItems = query.map { element in URLQueryItem(name: element.key, value: String(describing: element.value)) }
        
        guard let url = components?.url else { return baseUrl }
        return url
    }
    
    private func urlStringFrom(parameters: Any?) -> String {
        
        var str = ""
        let params = (parameters as? [String: Any] ?? [:])
        for (i, kv) in params.enumerated() {
            if let v = kv.value as? String {
                str.append("\(kv.key)=\(v)")
                if i < params.count - 1 {
                    str.append("&")
                }
            }
        }
        
        return str
    }
}
