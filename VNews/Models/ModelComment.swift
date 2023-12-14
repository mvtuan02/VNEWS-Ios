//
//  ModelComment.swift
//  VTVNew
//
//  Created by Nguyễn Văn Chiến on 2/2/21.
//

import Foundation
import SwiftyJSON

class ModelComment{
    var id : Int = 0
    var message : String = ""
    var share : Int = 0
    var like : Int = 0
    var createdDate : String = ""
    var user : String = ""
    var postId : Int = 0
    var postName: String = ""
    var urlPost: String = ""
    var parentId : Int = 0
    var timePass = ""
    var countChild = 0
    init(json : JSON) {
        id = json["id"].intValue
        postId = json["postId"].intValue
        user = json["user"].stringValue
        message = json["message"].stringValue
        parentId = json["parentId"].intValue
        like = json["like"].intValue
        share = json["share"].intValue
        createdDate = json["createDate"].stringValue
    }
    init() {
        
    }
    func countReply(_ list: [ModelComment]) {
        for i in list {
            if i.parentId == self.id {
                countChild += 1
            }
        }
    }
    func getTimePass() -> String{
        if let previousDate = createdDate.toDate(){
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
        return timePass
    }
}
