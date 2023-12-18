//
//  NetworkService.swift
//  Netjob
//
//  Created by Irakli Vashakidze on 01/06/2020.
//  Copyright © 2023 Irakli Vashakidze. All rights reserved.
//

import Foundation
import Combine

class AnyCodable: Codable {}

public typealias NetjobCallback<T> = (Swift.Result<T, NetjobError>) -> Void
public typealias NetjobDataCallback = (Swift.Result<Data, NetjobError>) -> Void

extension Dictionary {
    var data: Data {
        let data = try? JSONSerialization.data(withJSONObject: self, options: .fragmentsAllowed)
        return data ?? Data()
    }
}

public protocol Network {
    
    @discardableResult func request<T: Decodable>(endpoint: Endpoint,
                                                  completion: @escaping NetjobCallback<T>) -> NetjobRequest
    
    func requestPublisher<T: Decodable>(endpoint: Endpoint) -> AnyPublisher<T, NetjobError>
    
    func cancelAll()
    var sslPinningEnabled: Bool { get }
    var configuration: URLSessionConfiguration { get }
}

extension Network {
    public var sslPinningEnabled: Bool { false }
    public var configuration: URLSessionConfiguration {
        sslPinningEnabled ? .ephemeral : .default
    }
}

public class Netjob: NSObject, Network {
    
    public static let shared = Netjob()
    
    private override init() {}
    
    private var pendingRequests = SyncArray<NetjobRequest>()
    
    @discardableResult public func request<T: Decodable>(endpoint: Endpoint,
                                                         completion: @escaping NetjobCallback<T>) -> NetjobRequest {
        
        return requestData(endpoint: endpoint) { response in
            switch response {
            case .success(let data):
                do {
                    if data.isEmpty {
                        let object = try endpoint.codingStrategy.decoder.decode(T.self, from: [:].data)
                        completion(.success(object))
                        return
                    }
                    
                    let object = try endpoint.codingStrategy.decoder.decode(T.self, from: data)
                    completion(.success(object))
                } catch let e {
                    completion(.failure(NetjobError.decodingFailed(error: e)))
                }
                break
            case .failure(let error):
                debugPrint("********************************  decoding error start  ***************************************")
                log(error)
                debugPrint("********************************  decoding error finish  ***************************************")
                completion(.failure(NetjobError.decodingFailed(error: error)))
            }
        }
    }
    
    public func requestPublisher<T: Decodable>(endpoint: Endpoint) -> AnyPublisher<T, NetjobError> {
        return requestDataPublisher(endpoint: endpoint)
            .tryMap { data in
                return try endpoint.codingStrategy.decoder.decode(T.self, from: data)
            }.mapError { error in
                return NetjobError.decodingFailed(error: error)
            }
        .eraseToAnyPublisher()
    }
    
    @discardableResult public func requestData(endpoint: Endpoint, completion:@escaping NetjobDataCallback) -> NetjobRequest {
        
        let request = endpoint.httpRequest
        self.configuration.timeoutIntervalForRequest = endpoint.timeout
        let session = URLSession(configuration: endpoint.configuration ?? configuration,
                                 delegate:  endpoint.sslPinningEnabled ? self : nil,
                                 delegateQueue: nil)
        
        log(request.description)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            endpoint.callbackQueue.async {
                
                guard let response = response as? HTTPURLResponse else {
                    completion(.failure(NetjobError.requestFailed(nil)))
                    return
                }
                
                if let e = error { // cancelled
                    completion(.failure(NetjobError(statusCode: response.statusCode, error: e)))
                    return
                }
                
                log(response.description)
                
                switch response.statusCode {
                    case 200...299: completion(.success(data ?? Data()))
                    default: completion(.failure(NetjobError.requestFailed(URLError(.badServerResponse))))
                }
            }
        }
        
        let object = NetjobRequestImpl(task: task)
        self.pendingRequests.append(newElement: object)
        task.resume()
        
        return object
    }
    
    @discardableResult public func requestDataPublisher(endpoint: Endpoint) -> AnyPublisher<Data, NetjobError> {
        
        self.configuration.timeoutIntervalForRequest = endpoint.timeout
        let session = URLSession(configuration: endpoint.configuration ?? configuration,
                                 delegate:  endpoint.sslPinningEnabled ? self : nil,
                                 delegateQueue: nil)
       
        let publisher = session.dataTaskPublisher(for: endpoint.httpRequest)
            .receive(on: endpoint.callbackQueue)
            .tryMap { element in
                guard let response = element.response as? HTTPURLResponse else {
                    throw NetjobError.requestFailed(nil)
                }
                
                switch response.statusCode {
                    case 200...299: return element.data
                    default: throw NetjobError.requestFailed(nil)
                }
            }
            .mapError { error in return NetjobError.requestFailed(error) }
            .eraseToAnyPublisher()
            
        return publisher
    }
    
    public func cancelAll() {
        self.pendingRequests.forEach({ s in
            s.cancel()
        })
        self.pendingRequests.removeAll()
    }
}

extension Netjob: URLSessionDelegate {
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                
                var isTrusted = false
                if #available(iOS 12.0, *) {
                    isTrusted = SecTrustEvaluateWithError(serverTrust, nil)
                } else {
                    var secresult = SecTrustResultType.invalid
                    let status = SecTrustEvaluate(serverTrust, &secresult)
                    isTrusted = errSecSuccess == status
                }
                
                if (isTrusted) {
                    if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
                        let serverCertificateData = SecCertificateCopyData(serverCertificate)
                        let data = CFDataGetBytePtr(serverCertificateData);
                        let size = CFDataGetLength(serverCertificateData);
                        let cert1 = NSData(bytes: data, length: size)
                        let file_der = Bundle.main.path(forResource: "netjobssl", ofType: "der")
                        
                        if let file = file_der {
                            if let cert2 = NSData(contentsOfFile: file) {
                                if cert1.isEqual(to: cert2 as Data) {
                                    completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust:serverTrust))
                                    return
                                }
                            }
                        } else {
                            completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
                        }
                    }
                }
            } else {
                // Pinning failed
                completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
            }
        } else {
            completionHandler(URLSession.AuthChallengeDisposition.performDefaultHandling, nil)
        }
    }
}
