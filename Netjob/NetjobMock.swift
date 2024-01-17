//
//  NetjobMock.swift
//  Netjob
//
//  Created by Irakli Vashakidze on 19.12.23.
//  Copyright © 2023 MRSOOL. All rights reserved.
//

import Foundation
import Combine

class NetjobMock: Network {
    func requestAsync<T>(type: T.Type, endpoint: Endpoint) async throws -> T where T : Decodable {
        let data = try await requestDataAsync(endpoint: endpoint)
        return try endpoint.codingStrategy.decoder.decode(T.self, from: data)
    }
    
    
    func requestDataAsync(endpoint: Endpoint) async throws -> Data {
        return self.jsonObject ?? Data()
    }
    
    func request<T>(endpoint: Endpoint, completion: @escaping NetjobCallback<T>) -> CancellableTask where T : Decodable {
        let data = self.jsonObject ?? Data()
        let decoded = try! endpoint.codingStrategy.decoder.decode(T.self, from: data)
        completion(.success(decoded))
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: URL(string: "https://www.netjob.com")!))
        return CancellableTaskImpl(task: task)
    }
    
    func requestPublisher<T>(endpoint: Endpoint) -> AnyPublisher<T, NetjobError> where T : Decodable {
        let data = self.jsonObject ?? Data()
        let decoded = try! endpoint.codingStrategy.decoder.decode(T.self, from: data)
        return Just(decoded)
            .setFailureType(to: NetjobError.self)
            .eraseToAnyPublisher()
    }
    
    func cancelAll() {
    }
    
    private var jsonObject: Data?
    private lazy var stringResponse = ""
    
    init(mockURL: URL) {
        if let data = try? Data(contentsOf: mockURL) {
            self.jsonObject = data
        }
    }
    
    init(file: String, ext: String = "json", fromBundle bundle: Bundle = Bundle.main) {
        if let url = bundle.url(forResource: file, withExtension: ext) {
           self.jsonObject = try? Data(contentsOf: url)
        }
    }
    
    init(stringResponse: String) {
        self.stringResponse = stringResponse
    }
}
