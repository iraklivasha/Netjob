//
//  CodingStrategy.swift
//  Netjob
//
//  Created by Irakli Vashakidze on 06.12.23.
//

import Foundation

public class CodingStrategy {
    
    public static let instance = CodingStrategy()
    
    public var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy { .convertFromSnakeCase }
    public var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy { .iso8601 }
    public var keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy { .convertToSnakeCase }
    public var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy { .iso8601 }
    public var nonConformingFloatDecodingStrategy: JSONDecoder.NonConformingFloatDecodingStrategy {
        .convertFromString(
            positiveInfinity: "inf",
            negativeInfinity: "-inf",
            nan: "nan")
    }
    public var nonConformingFloatEncodingStrategy: JSONEncoder.NonConformingFloatEncodingStrategy {
        .convertToString(
            positiveInfinity: "inf",
            negativeInfinity: "-inf",
            nan: "nan")
    }
    
    public private(set) lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = self.keyDecodingStrategy
        decoder.dateDecodingStrategy = self.dateDecodingStrategy
        decoder.nonConformingFloatDecodingStrategy = self.nonConformingFloatDecodingStrategy
        return decoder
    }()
    
    public private(set) lazy var encoder: JSONEncoder = {
        let decoder = JSONEncoder()
        decoder.keyEncodingStrategy = self.keyEncodingStrategy
        decoder.dateEncodingStrategy = self.dateEncodingStrategy
        decoder.nonConformingFloatEncodingStrategy = self.nonConformingFloatEncodingStrategy
        return decoder
    }()
}
