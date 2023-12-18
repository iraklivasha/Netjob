//
//  URLRequest+Logger.swift
//  Netjob
//
//  Created by Irakli Vashakidze on 01/06/2020.
//  Copyright © 2023 Irakli Vashakidze. All rights reserved.
//

import Foundation

extension URLRequest {
    
    var description: String {
        """
        <\(httpMethod ?? "")> <\(url?.absoluteString ?? "")>
        \(httpBody == nil ? "With No Data." : "Data: <\(httpBody?.string(encoding: .utf8) ?? "empty")>")
        """
    }
}

extension HTTPURLResponse {
    
    override open var description: String {
        """
        <\(statusCode)> <\(url?.absoluteString ?? "")>
        """
    }
}
