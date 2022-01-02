//
//  JJLogFormat.swift
//  JJSwiftLog
//
//  Created by Jezz on 2022/1/2.
//  Copyright © 2022 JJSwiftLog. All rights reserved.
//

import Foundation


public protocol JJLogFormatterProtocol {
    
    func format(log: JJLogBody) -> String
    
}
