//
//  ModelContentCate.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 6/7/21.
//

import Foundation
import SwiftyJSON

class ModelListNews{
    var avatar : String = ""
    var catID : Int = 0
    var catName : String = ""
    var cssClass : String = ""
    var displayType : Int = 0
    var id : Int = 0
    var linkCategory : String = ""
    var publishedDate : String = ""
    var sapo : String = ""
    var showVideoAsAvatar : Int = 0
    var title : String = ""
    var total : Int = 0
    var url : String = ""
    var urlBase : String = ""
    var urlRedirect : String = ""
    var timePass = ""
    init(json: JSON!){
        avatar = json["avatar"].stringValue
        catID = json["catID"].intValue
        catName = json["catName"].stringValue
        cssClass = json["cssClass"].stringValue
        displayType = json["displayType"].intValue
        id = json["id"].intValue
        linkCategory = json["linkCategory"].stringValue
        publishedDate = json["publishedDate"].stringValue
        sapo = json["sapo"].stringValue
        showVideoAsAvatar = json["showVideoAsAvatar"].intValue
        title = json["title"].stringValue
        total = json["total"].intValue
        url = json["url"].stringValue
        urlBase = json["urlBase"].stringValue
        urlRedirect = json["urlRedirect"].stringValue
        
        if let previousDate = publishedDate.toDate(){
            let interval = Date() - previousDate
            if let month = interval.month, month != 0{
                if month > 0 {
                    timePass = "\(month) tháng trước"
                } else{
                    timePass = "Còn \(-month) tháng"
                }
            } else if let day = interval.day, day != 0{
                if day > 0{
                    timePass = "\(day) ngày trước"
                } else{
                    timePass = "Còn \(-day) ngày"
                }
            }else if let hour = interval.hour, hour != 0{
                if hour > 0{
                    timePass = "\(hour) giờ trước"
                }else{
                    timePass = "Còn \(-hour) giờ"
                }
            }else if let minute = interval.minute, minute != 0{
                if minute > 0{
                    timePass = "\(minute) phút trước"
                }else{
                    timePass = "Còn \(-minute) phút"
                }
            }else if let second = interval.second, second != 0{
                if second > 0{
                    timePass = "\(second) giây trước"
                }else{
                    timePass = "Còn \(-second) giây"
                }
            }else {
                timePass = "Đang phát"
            }
        }
    }
}
