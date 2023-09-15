//
//  NetworkService.swift
//  Netjob
//
//  Created by Qutaibah Essa on 01/06/2020.
//  Copyright © 2020 MRSOOL. All rights reserved.
//

import Foundation

class AnyCodable: Codable {}

extension Dictionary {
    var data: Data {
        let data = try? JSONSerialization.data(withJSONObject: self, options: .fragmentsAllowed)
        return data ?? Data()
    }
}

public protocol Network {
    @discardableResult func request(endpoint: Endpoint,
                                    success: @escaping EmptyResponse,
                                    failure: @escaping ErrorResponse) -> NetworkRequest
    
    @discardableResult func request(endpoint: Endpoint,
                                    success: @escaping StringResponse,
                                    failure: @escaping ErrorResponse) -> NetworkRequest
    
    @discardableResult func request(endpoint: Endpoint,
                                    success: @escaping DataResponse,
                                    failure: @escaping ErrorResponse) -> NetworkRequest
    
    @discardableResult func request<T: Decodable>(endpoint: Endpoint,
                                                  decoder: JSONDecoder,
                                                  success: @escaping DecodableResponse<T>,
                                                  failure: @escaping ErrorResponse) -> NetworkRequest
    
    @discardableResult func request<T>(endpoint: Endpoint,
                                       decoder: JSONDecoder,
                                       success: @escaping ObjectResponse<T>,
                                       failure: @escaping ErrorResponse) -> NetworkRequest
    
    func cancelAll()
}

class NetworkService: NSObject, Network {
    
    static let shared = NetworkService()
    private override init() {}
    
    private var pendingRequests = [NetworkRequest]()
    
    @discardableResult func request(endpoint: Endpoint,
                 success: @escaping EmptyResponse,
                 failure: @escaping ErrorResponse) -> NetworkRequest {
        
        request(endpoint: endpoint, success: { (_: Data) in
            success()
        }, failure: failure)
    }
    
    @discardableResult func request(endpoint: Endpoint,
                                    success: @escaping StringResponse,
                                    failure: @escaping ErrorResponse) -> NetworkRequest {
        return request(endpoint: endpoint, success: { (data: Data) in
            guard let value = String(data: data, encoding: .utf8) else { return failure(NetjobError.decodingFailed(error: nil)) }
            success(value)
        }, failure: failure)
    }
    
    @discardableResult func request<T>(endpoint: Endpoint,
                                       decoder: JSONDecoder,
                                       success: @escaping ObjectResponse<T>,
                                       failure: @escaping ErrorResponse) -> NetworkRequest {
        return request(endpoint: endpoint, decoder: decoder, success: { (data: Data) in
            do {
                guard let object = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? T else { return failure(NetjobError.decodingFailed(error: nil)) }
                success(object)
            } catch let error {
                logger(error)
                failure(NetjobError.decodingFailed(error: error))
            }
        }, failure: failure)
    }
    
    @discardableResult func request<T: Decodable>(endpoint: Endpoint,
                                                  decoder: JSONDecoder,
                                                  success: @escaping DecodableResponse<T>,
                                                  failure: @escaping ErrorResponse) -> NetworkRequest {
        return request(endpoint: endpoint, success: { (data: Data) in
            do {
                if data.isEmpty {
                    let object = try decoder.decode(T.self, from: [:].data)
                    success(object)
                    return
                }
                
                let object = try decoder.decode(T.self, from: data)
                success(object)
            } catch let error {
                debugPrint("********************************  decoding error start  ***************************************")
                logger(error)
                debugPrint("********************************  decoding error finish  ***************************************")
                failure(NetjobError.decodingFailed(error: error))
            }
        }, failure: failure)
    }
    
    @discardableResult func request(endpoint: Endpoint,
                                    success: @escaping DataResponse,
                                    failure: @escaping ErrorResponse) -> NetworkRequest {

        // declaring the default headers that are common with all endpoints
        var request = URLRequest(url: urlWith(url: endpoint.url,
                                              query: (endpoint.method == .get || endpoint.method == .delete)
                                                ?
                                              endpoint.parameters as? [String: Any]
                                                :
                                                endpoint.urlParameters))
        request.httpMethod = endpoint.method.name
        request.allHTTPHeaderFields = endpoint.headers
        request.setValue(endpoint.requestContentType, forHTTPHeaderField: "Content-Type")
        request.httpShouldHandleCookies = false
        request.cachePolicy = endpoint.cachePolicy
        
        if endpoint.method == .post || endpoint.method == .patch {
            
            if (endpoint.requestContentType == "application/x-www-form-urlencoded") {
                
                var str = ""
                let params = (endpoint.parameters as? [String: Any] ?? [:])
                for (i, kv) in params.enumerated() {
                    if let v = kv.value as? String {
                        str.append("\(kv.key)=\(v)")
                        if i < params.count - 1 {
                            str.append("&")
                        }
                    }
                }
                
                request.httpBody = str.data(using: .utf8)
                request.setValue("\(request.httpBody?.count ?? 0)", forHTTPHeaderField: "Content-Length")
            } else {
                request.encodeParameters(parameters: endpoint.parameters ?? [:])
            }
        }
        
        let config: URLSessionConfiguration = Netjob.shared.activateSSlPinning ? .ephemeral : .default
        config.timeoutIntervalForRequest = endpoint.timeout
        let session = URLSession(configuration: config, delegate: nil, delegateQueue: nil)
        
        logger(request.description)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                URLCache.shared.removeCachedResponse(for: request)
            })
            
            DispatchQueue.main.async {
                
                if let e = error, (e as NSError).code == -999 { // cancelled
                    failure(NetjobError.cancelled)
                    return
                }
                
                // check for a response objcet
                guard let response = response as? HTTPURLResponse else {
                    failure(NetjobError.timeout)
                    return
                }
                
                logger(response.description)
                
                // check for no content response
                if response.statusCode == 204 {
                    success(Data())
                    return
                }
                
                // check for a successful status code
                guard response.statusCode >= 200, response.statusCode < 300 else {
                    
                    if response.statusCode == 401 {
                        NotificationCenter.default.post(name: NetjobConstants.Notifications.unauthorized, object: nil)
                    }
                    
                    failure(NetjobError(statusCode: response.statusCode, error: error))
                    return
                }
                
                // check for response body~
                guard let data = data else {
                    failure(NetjobError.nilData)
                    return
                }
                
                self.fireNotificationFor403Code(data: data)
                
                success(data)
            }
        }
        
        let object = NetworkRequestObj(task: task)
        self.pendingRequests.append(object)
        task.resume()
        
        return object
    }
    
    func urlWith(url: String, query: [String: Any]?) -> URL {
        // make sure the base url is valid
        guard let baseUrl = URL(string: url) else {
            fatalError("The BASE URL provided is not a valid url: \(url)")
        }
        // if there are any query items
        guard let query = query else { return baseUrl }
        
        // create the url query
        var components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true)
        components?.queryItems = query.map { element in URLQueryItem(name: element.key, value: String(describing: element.value)) }
        
        guard let url = components?.url else { return baseUrl }
        return url
    }
    
    func fireNotificationFor403Code(data:Data) {
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            let code = json["code"] as? Int ?? 0
            if code == 403 {
                let message = json["message"] as? String ?? ""
                NotificationCenter.default.post(name: NetjobConstants.Notifications.prohibited, object: message)
            }
        }
    }
    
    func cancelAll() {
        self.pendingRequests.forEach({ s in
            s.cancel()
        })
        self.pendingRequests.removeAll()
    }
}
