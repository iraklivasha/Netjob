//
//  URLRequest+Logger.swift
//  Netjob
//
//  Created by Qutaibah Essa on 01/06/2020.
//  Copyright © 2020 MRSOOL. All rights reserved.
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
