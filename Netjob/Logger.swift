//
//  Logger.swift
//  Netjob
//
//  Created by Qutaibah Essa on 01/06/2020.
//  Copyright © 2020 MRSOOL. All rights reserved.
//

import Foundation

func logger(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    debugPrint(items, separator: separator, terminator: terminator)
}
