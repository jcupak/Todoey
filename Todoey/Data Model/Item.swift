//
//  Item.swift
//  Todoey
//
//  Created by John Cupak on 1/2/18.
//  Copyright © 2018 John Cupak. All rights reserved.
//

import Foundation

// Identify class as able to be encoded/decoded as plist
// Replace Encodable, Decodable with Codable
// NOTE: All properties must be standard types
class Item: Codable {
    
    var title: String = ""
    var done:  Bool   = false
}
