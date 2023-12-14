//
//  ModelResultSearch.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 6/15/21.
//

import Foundation

class ModelResultSearch{
    var schedule = ""
    var privateID = ""
    var keyword = ""
    var title = ""
    var keySearch = ""
    var duration = ""
    var mediaProjectID = ""
    var metaData: [MetaData] = []
    var description = ""
    var id = ""
    var path = ""
    var createDate = ""
    
    func initLoad(_ json: [String:Any]) -> ModelResultSearch{
        if let temp = json["Schedule"] as? String { schedule = temp}
        if let temp = json["PrivateID"] as? String { privateID = temp}
        if let temp = json["Keyword"] as? String { keyword = temp}
        if let temp = json["Title"] as? String { title = temp}
        if let temp = json["KeySearch"] as? String { keySearch = temp}
        if let temp = json["Duration"] as? String { duration = temp}
        if let temp = json["MediaProjectID"] as? String { mediaProjectID = temp}
        if let temp = json["Metadata"] as? [[String:Any]] {
            for item in temp {
                let metadataAdd = MetaData().initLoad(item)
                metaData.append(metadataAdd)
            }
        }
        if let temp = json["Description"] as? String { description = temp}
        if let temp = json["ID"] as? String { id = temp}
        if let temp = json["Path"] as? String { path = temp}
        if let temp = json["CreateDate"] as? String { createDate = temp}
        return self
    }
}

class MetaData{
    var name = ""
    var value = ""
    
    func initLoad(_ json: [String: Any]) -> MetaData{
        if let temp = json["Name"] as? String { name = temp}
        if let temp = json["Value"] as? String { value = temp}
        return self
    }
}


