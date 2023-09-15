//
//  Data+String.swift
//  Netjob
//
//  Created by Qutaibah Essa on 01/06/2020.
//  Copyright © 2020 MRSOOL. All rights reserved.
//

import Foundation

extension Data {
    
    func string(encoding: String.Encoding) -> String? {
        return String(data: self, encoding: encoding)
    }
}
