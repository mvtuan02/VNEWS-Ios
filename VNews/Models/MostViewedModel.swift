//
//  MostViewedModel.swift
//  VNews
//
//  Created by Apple on 10/08/2021.
//

import Foundation

class MostViewedModel {
    var id = ""
    var image = ""
    var title = ""
    var schedule = ""
    var timePass = ""
    var category = ""
    var slug = ""
    var contentType = "0"
    func initLoad(_ json: [String: Any]) -> MostViewedModel{
        if let temp = json["postId"] as? Int { id = temp.description}
        if let temp = json["image"] as? String { image = temp}
        if let temp = json["schedule"] as? String { schedule = temp}
        
        if let previousDate = schedule.toDate(){
            let interval = Date() - previousDate
            if let month = interval.month, month != 0{
                if month > 0 {
                    timePass = "\(month) tháng trước"
                }
            } else if let day = interval.day, day != 0{
                if day > 0{
                    timePass = "\(day) ngày trước"
                }
            }else if let hour = interval.hour, hour != 0{
                if hour > 0{
                    timePass = "\(hour) giờ trước"
                }
            }else if let minute = interval.minute, minute != 0{
                if minute > 0{
                    timePass = "\(minute) phút trước"
                }
            }else if let second = interval.second, second != 0{
                if second > 0{
                    timePass = "\(second) giây trước"
                }
            }else {
                timePass = "Đang phát"
            }
        }
        if let temp = json["metadata"] as? [[String: Any]]{
            for item in temp{
                let metaDataAdd = MetaDataModel().initLoad(item)
    
                if metaDataAdd.name == "Title"{
                    title = metaDataAdd.value
                }
                if metaDataAdd.name == "Slug"{
                    slug = metaDataAdd.value
                }
                if metaDataAdd.name == "DVBCategories"{
                    category = metaDataAdd.value
                }
                if metaDataAdd.name == "ContentType"{
                    if metaDataAdd.value == "" {
                        
                    } else {
                        contentType = metaDataAdd.value
                    }
                }
            }
        }
        return self
    }
    
}
