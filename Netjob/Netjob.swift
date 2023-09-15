//
//  Netjob.swift
//  Netjob
//
//  Created by Qutaibah Essa on 01/06/2020.
//  Copyright © 2020 MRSOOL. All rights reserved.
//

import Foundation

public typealias EmptyResponse = () -> Void
public typealias StringResponse = (String) -> Void
public typealias DictionaryResponse = ([String:Any]) -> Void
public typealias ObjectResponse<T> = (T) -> Void
public typealias DecodableResponse<T: Decodable> = (T) -> Void
public typealias DataResponse = (Data) -> Void
public typealias ErrorResponse = (Error) -> Void

private struct MrsoolCodingKey : CodingKey {

  var stringValue: String
  var intValue: Int?

  init(_ base: CodingKey) {
    self.init(stringValue: base.stringValue, intValue: base.intValue)
  }

  init(stringValue: String) {
    self.stringValue = stringValue
  }

  init(intValue: Int) {
    self.stringValue = "\(intValue)"
    self.intValue = intValue
  }

  init(stringValue: String, intValue: Int?) {
    self.stringValue = stringValue
    self.intValue = intValue
  }
}

public class Netjob {
    public static var shared = Netjob()
    private init() {}
    
    public var activateSSlPinning: Bool = false
    public var keyDecodingStrategy = JSONDecoder.KeyDecodingStrategy.convertFromSnakeCase
    public var dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.iso8601
    public var keyEncodingStrategy = JSONEncoder.KeyEncodingStrategy.convertToSnakeCase
    public var dateEncodingStrategy = JSONEncoder.DateEncodingStrategy.iso8601
    public var nonConformingFloatDecodingStrategy = JSONDecoder.NonConformingFloatDecodingStrategy.convertFromString(
                                                                positiveInfinity: "inf",
                                                                negativeInfinity: "-inf",
                                                                nan: "nan")
    public var nonConformingFloatEncodingStrategy = JSONEncoder.NonConformingFloatEncodingStrategy.convertToString(
                                                                positiveInfinity: "inf",
                                                                negativeInfinity: "-inf",
                                                                nan: "nan")
    
    public var defaultNetworkService: Network = NetworkService.shared
}

// Not used
extension JSONDecoder.KeyDecodingStrategy {

  static var ncDecodingStrategy: JSONDecoder.KeyDecodingStrategy {
    return .custom { codingKeys in

        var key = MrsoolCodingKey(codingKeys.last!)

        var _key = ""
        var found = false
        for char in key.stringValue {
            var nextChar = String(char)
            
            if found {
                nextChar = nextChar.uppercased()
                found = false
            }
            
            if char == "_" {
                found = true
            } else {
                _key.append(nextChar)
            }
        }
        
        key.stringValue = _key
      
        return key
    }
  }
}
