//
//  NetworkRequest.swift
//  Netjob
//
//  Created by Irakli Vashakidze on 6/4/20.
//  Copyright © 2023 Irakli Vashakidze. All rights reserved.
//

import Foundation
/**
 A protocol representing a network request in the Netjob framework.
*/
public protocol NetjobRequest: class {
    
    /// A unique identifier for the network request.
    var id: Int { get }
    
    /// Returns true if the URLSessionDataTask status is .cancelling or .running, otherwise false
    var isAlive: Bool { get }
    
    /// Actual request task
    var task: URLSessionDataTask { get }
    
    /*
    Cancels the ongoing network request.

    Call this method to cancel the network request if it is still in progress.
    */
    func cancel()
}

class NetjobRequestImpl: NetjobRequest {
    
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
