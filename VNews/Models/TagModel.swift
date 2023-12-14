//
//  TagModel.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 5/27/21.
//

import Foundation
import SwiftyJSON
class TagModel{
    
    var keyWord : String = ""
    var name : String = ""
    var orderBy : String = ""
    var privateKey : String = ""
    init(json: JSON!){
        keyWord = json["KeyWord"].stringValue
        name = json["Name"].stringValue
        orderBy = json["OrderBy"].stringValue
        privateKey = json["PrivateKey"].stringValue
    }
}
