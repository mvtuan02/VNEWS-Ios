//
//  ModelSugestion.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 6/15/21.
//

import Foundation

class ModelSugestion{
    var name = ""
    var score = ""
    var payload = ""
    
    func initLoad(_ json: [String:Any]) -> ModelSugestion{
        if let temp = json["String"] as? String { name = temp}
        if let temp = json["score"] as? String { score = temp}
        if let temp = json["payload"] as? String { payload = temp}
        return self
    }
}
