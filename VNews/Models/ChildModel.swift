//
//  ChildModel.swift
//  VNews
//
//  Created by dovietduy on 6/16/21.
//

import Foundation

class ChildModel{
    var privateKey = ""
    var name = ""
    var orderBy = ""
    var image = ""
    
    func initLoad(_ json: [String: Any]) -> ChildModel{
        if let temp = json["PrivateKey"] as? String { privateKey = temp}
        if let temp = json["Name"] as? String { name = temp}
        if let temp = json["OrderBy"] as? String { orderBy = temp}
        if let temp = json["Image"] as? String { image = temp}
        return self
    }
}
