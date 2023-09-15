//
//  NetworkRequest.swift
//  Netjob
//
//  Created by Irakli Vashakidze on 6/4/20.
//  Copyright © 2020 MRSOOL. All rights reserved.
//

import Foundation

public protocol NetworkRequest: class {
    func cancel()
    var id: Int { get }
    var task: URLSessionDataTask { get }
    var isAlive: Bool { get }
}

class NetworkRequestObj: NetworkRequest {
    
    private(set) var task: URLSessionDataTask
    
    init(task: URLSessionDataTask) {
        self.task = task
    }
    
    func cancel() {
        task.cancel()
    }
    
    var id: Int {
        return task.taskIdentifier
    }
    
    var isAlive: Bool {
        return self.task.state == .canceling || self.task.state == .running
    }
}
