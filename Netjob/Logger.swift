//
//  Logger.swift
//  Netjob
//
//  Created by Irakli Vashakidze on 01/06/2020.
//  Copyright © 2023 Irakli Vashakidze. All rights reserved.
//

import Foundation

func log(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    debugPrint(items, separator: separator, terminator: terminator)
}
