//
//  Request.swift
//  Netjob
//
//  Created by Irakli Vashakidze on 19.12.23.
//  Copyright © 2023 MRSOOL. All rights reserved.
//

import Foundation
import Combine

public protocol Request {
    func withParameters(_ params: Any) -> Request
    func withURLParameters(_ params: [String: String]) -> Request
    func withHeaders(_ headers: [String: String]) -> Request
    func withMethod(_ method: HTTPMethod) -> Request
    func withCachePolicy(_ policy: URLRequest.CachePolicy) -> Request
    func withContentType(_ contentType: String) -> Request
    func withNetwork(_ network: Network) -> Request
    func withConfiguration(_ config: URLSessionConfiguration) -> Request
    func withCodingStrategy(_ strategy: CodingStrategy) -> Request
    func withSSLPinningEnabled(_ enabled: Bool) -> Request
    func withCertFilaPath(_ filePath: String) -> Request
    func withCallbackQueue(_ queue: DispatchQueue) -> Request
    func withMockResponsePath(_ path: String?) -> Request
    @discardableResult func request<T: Decodable>(completion: @escaping NetjobCallback<T>) -> CancellableTask
    func requestPublisher<T: Decodable>() -> AnyPublisher<T, NetjobError>
}

class RequestObj: Endpoint, Request {
    
    /// The last path component to the endpoint. will be appended to the base url in the service
    private(set) var url: String

    /// The encoded parameters
    private(set) var parameters: Any?
    
    /// The encoded parameters
    private(set) var urlParameters: [String: String]?

    /// The HTTP headers to be appended in the request, default is nil
    private(set) var headers: [String: String]?

    /// Http method
    private(set) var method: HTTPMethod = .get
    
    /// How long (in seconds) a task should wait for additional data to arrive. The timer is reset whenever new data arrives.
    private(set) var timeout: TimeInterval = 30
    
    /// Caching policy for the endpoint
    private(set) var cachePolicy: URLRequest.CachePolicy = .reloadIgnoringLocalAndRemoteCacheData
    
    private(set) var requestContentType: String = "application/json"
    
    private(set) var network: Network = Netjob.shared
    private(set) var configuration: URLSessionConfiguration?
    private(set) var codingStrategy: CodingStrategy = CodingStrategy.instance
    private(set) var sslPinningEnabled: Bool = false
    private(set) var certFilaPath: String?
    private(set) var callbackQueue: DispatchQueue = .main
    private(set) var mockResponsePath: String? = nil
    
    init(url: String) {
        self.url = url
    }
    
    func withParameters(_ params: Any) -> Request {
        self.parameters = params
        return self
    }
    
    func withURLParameters(_ params: [String: String]) -> Request {
        self.urlParameters = params
        return self
    }
    
    func withHeaders(_ headers: [String: String]) -> Request {
        self.headers = headers
        return self
    }
    
    func withMethod(_ method: HTTPMethod) -> Request {
        self.method = method
        return self
    }
    
    func withCachePolicy(_ policy: URLRequest.CachePolicy) -> Request {
        self.cachePolicy = policy
        return self
    }
    
    func withContentType(_ contentType: String) -> Request {
        self.requestContentType = contentType
        return self
    }
    
    func withNetwork(_ network: Network) -> Request {
        self.network = network
        return self
    }
    
    func withConfiguration(_ config: URLSessionConfiguration) -> Request {
        self.configuration = config
        return self
    }
    
    func withCodingStrategy(_ strategy: CodingStrategy) -> Request {
        self.codingStrategy = strategy
        return self
    }
    
    func withSSLPinningEnabled(_ enabled: Bool) -> Request {
        self.sslPinningEnabled = enabled
        return self
    }
    
    func withCertFilaPath(_ filePath: String) -> Request {
        self.certFilaPath = filePath
        return self
    }
    
    func withCallbackQueue(_ queue: DispatchQueue) -> Request {
        self.callbackQueue = queue
        return self
    }
    
    func withMockResponsePath(_ path: String?) -> Request {
        self.mockResponsePath = path
        return self
    }
    
    private var _network: Network {
        if let path = self.mockResponsePath {
            return NetjobMock(file: path)
        }
        
        return Netjob.shared
    }
    
    @discardableResult public func request<T: Decodable>(completion: @escaping NetjobCallback<T>) -> CancellableTask {
        self._network.request(endpoint: self, completion: completion)
    }
    
    public func requestPublisher<T: Decodable>() -> AnyPublisher<T, NetjobError> {
        self._network.requestPublisher(endpoint: self)
    }
}
