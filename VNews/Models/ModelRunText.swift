//
//  ModelRunText.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 6/16/21.
//

import Foundation
import SwiftyJSON

class ModelRunText{
    var avatar : String = ""
    var descriptionField : String = ""
    var id : Int = 0
    var name : String = ""
    var type : Int = 0
    var url : String = ""
    
    init(json: JSON!){
        avatar = json["avatar"].stringValue
        descriptionField = json["description"].stringValue
        id = json["id"].intValue
        name = json["name"].stringValue
        type = json["type"].intValue
        url = json["url"].stringValue
    }
}
