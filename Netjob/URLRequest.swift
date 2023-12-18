//
//  URLRequest.swift
//  Netjob
//
//  Created by Irakli Vashakidze on 6/17/20.
//  Copyright © 2023 Irakli Vashakidze. All rights reserved.
//

import Foundation

extension URLRequest {
    
  private func percentEscapeString(_ string: String) -> String {
    var characterSet = CharacterSet.alphanumerics
    characterSet.insert(charactersIn: "-._* ")
    
    return string
      .addingPercentEncoding(withAllowedCharacters: characterSet)!
      .replacingOccurrences(of: " ", with: "+")
      .replacingOccurrences(of: " ", with: "+", options: [], range: nil)
  }
    
    mutating func encodeParameters(parameters: Any) {
        httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
    }
}
