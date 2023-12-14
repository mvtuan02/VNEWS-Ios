//
//  ModelChitiettin.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 6/7/21.
//

import Foundation

class ModelChitiettin{
    var id:Int = 0
    var title:String = ""
    var sapo:String = ""
    var catName:String = ""
    var avatar:String = ""
    var publishedDate:String = ""
    var content:String = ""
    var sameCategory:[SameListNews] = []
    
    func initLoad(_ json: [String: Any]) -> ModelChitiettin{
        if let temp = json["avatar"] as? String { self.avatar = temp}
        
        if let temp = json["title"] as? String { self.title = temp}

        if let temp = json["id"] as? Int { self.id = temp}

        if let temp = json["catName"] as? String { self.catName = temp}

        if let temp = json["content"] as? String { self.content = temp}

        if let temp = json["sapo"] as? String { self.sapo = temp}

        if let temp = json["publishedDate"] as? String { self.publishedDate = temp}

        if let temp = json["sameCategory"] as? [[String:Any]] {
            for item in temp {
                let data = SameListNews().initLoad(item)
                sameCategory.append(data)
            }
        }
        
        return self
    }
    
}

class SameListNews{
    var id: Int = 0
    var title:String = ""
    var avartar:String = ""
    var publishedDate: String = ""
    
    func initLoad(_ json: [String:Any]) -> SameListNews{
        if let temp = json["id"] as? Int { self.id = temp }
        if let temp = json["title"] as? String { self.title = temp }
        if let temp = json["avatar"] as? String { self.avartar = temp }
        if let temp = json["publishedDate"] as? String { self.publishedDate = temp }
        return self
    }
}
