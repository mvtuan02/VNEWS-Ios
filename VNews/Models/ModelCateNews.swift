//
//  ModelCateNews.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 6/7/21.
//

import Foundation
import SwiftyJSON

class ModelCateNews{
    var catID : Int = 0
    var id : Int = 0
    var name : String = ""
    var orderNumber : Int = 0
    var parent : Int = 0
    var position : Int = 0
    var redirect : String = ""
    var urlBase : String = ""
    init(json: JSON!){
        catID = json["catID"].intValue
        id = json["id"].intValue
        name = json["name"].stringValue
        orderNumber = json["orderNumber"].intValue
        parent = json["parent"].intValue
        position = json["position"].intValue
        redirect = json["redirect"].stringValue
        urlBase = json["urlBase"].stringValue
    }
}
