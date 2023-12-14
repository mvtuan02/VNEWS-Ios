//
//  CategoryModel.swift
//  NOW
//
//  Created by dovietduy on 1/29/21.
//

import Foundation
class CategoryModel{
    var privateKey = ""
    var name = ""
    var icon = ""
    var cdn = CDNModel()
    var layout = LayoutModel()
    var media: [MediaModel] = []
    var components: [ComponentModel] = []
    var components2: [ComponentModel2] = []
    var domain = ""
    var index = 0
    func initLoad(_ json: [String: Any]) -> CategoryModel{
        if let temp = json["PrivateKey"] as? String { privateKey = temp}
        if let temp = json["Name"] as? String { name = temp}
        if let temp = json["Icon"] as? String { icon = temp}
        if let temp = json["Domain"] as? String { domain = temp}
        if let temp = json["Media"] as? [[String: Any]] {
            for item in temp {
                let mediaAdd = MediaModel().initLoad(item)
                media.append(mediaAdd)
            }
        }
        if let temp = json["CDN"] as? String  {
            cdn = CDNModel().initLoad(temp.toJson())
        }
        if let temp = json["CDN"] as? [String: Any]  {
            cdn = CDNModel().initLoad(temp)
        }
        if let temp = json["LayoutType"] as? String {
            layout = LayoutModel().initLoad(temp.toJson())
        }
        if let temp = json["LayoutType"] as? [String: Any] {
            layout = LayoutModel().initLoad(temp)
        }
        if let temp = json["Components"] as? String {
            for item in temp.toJsonArray(){
                let componentAdd = ComponentModel().initLoad(item)
                components.append(componentAdd)
            }
        }
        if let temp = json["Components"] as? [[String: Any]]{
            for item in temp{
                let componentAdd = ComponentModel().initLoad(item)
                components.append(componentAdd)
            }
        }
        return self
    }
    func copy() -> CategoryModel{
        let copy = CategoryModel()
        copy.privateKey = self.privateKey
        copy.name = self.name
        copy.cdn = self.cdn
        copy.layout = self.layout
        copy.media = self.media
        copy.components = self.components
        return copy
    }
}
class MediaModel{
    var id = ""
    var privateID = ""
    var descripTion = ""
    var image: [ImageModel] = []
    var name = ""
    var path = ""
    var schedule = ""
    var timePass = ""
    var duration = ""
    var metaData: [MetaDataModel] = []
    var thumnail = ""
    var portrait = ""
    var fileCode = ""
    var contentType = "0"
    var slug = ""
    var square = ""
    var category = ""
    var keyword = ""
    var body = ""
    var related: [MediaModel] = []
    func initLoad(_ json: [String: Any]) -> MediaModel{
        if let temp = json["ID"] as? Int { id = temp.description}
        if let temp = json["ID"] as? String { id = temp}
        if let temp = json["PrivateID"] as? String { privateID = temp}
        if let temp = json["Description"] as? String { descripTion = temp}
        if let temp = json["Body"] as? String { body = temp}
        if let temp = json["Image"] as? [[String:Any]] {
            for item in temp{
                let imageAdd = ImageModel().initLoad(item)
                if imageAdd.type == "Thumbnail"{
                    thumnail = imageAdd.url
                }
                if imageAdd.type == "Portrait"{
                    portrait = imageAdd.url
                }
                if imageAdd.type == "Square"{
                    square = imageAdd.url
                }
                image.append(imageAdd)
            }
        }
        if let temp = json["Keyword"] as? String {
            if temp != "" {
                let arraySplit = temp.split(separator: ",")
                if arraySplit.count >= 1 {
                    keyword = arraySplit[0].description
                }
            }
        }
        if let temp = json["Image"] as? [String: Any]{
            let imageAdd = ImageModel().initLoad(temp)
            if imageAdd.type == "Thumbnail"{
                thumnail = imageAdd.url
            }
        }
        if let temp = json["Image"] as? String {
            for item in temp.toJsonArray(){
                let imageAdd = ImageModel().initLoad(item)
                if imageAdd.type == "Thumbnail"{
                    thumnail = imageAdd.url
                }
                if imageAdd.type == "Portrait"{
                    portrait = imageAdd.url
                }
                if imageAdd.type == "Square"{
                    square = imageAdd.url
                }
                image.append(imageAdd)
            }
        }
        if let temp = json["Name"] as? String { name = temp}
        if let temp = json["Title"] as? String { name = temp}
        if let temp = json["Path"] as? String { path = temp}
        if let temp = json["Schedule"] as? String { schedule = temp}
        if let temp = json["Duration"] as? String {
            duration = temp
        }
        if let previousDate = schedule.toDate(){
            let interval = Date() - previousDate
            if let month = interval.month, month != 0{
                if month > 0 {
                    timePass = ""
                } else{
                    timePass = "Còn \(-month) tháng"
                }
            } else if let day = interval.day, day != 0{
                if day > 0{
                    timePass = "\(day) ngày trước"
//                    if day >= 6 {
//                        timePass = ""
//                    }
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
        if let temp = json["Metadata"] as? [[String: Any]]{
            for item in temp{
                let metaDataAdd = MetaDataModel().initLoad(item)
    
                if metaDataAdd.name == "FileCode"{
                    //path = metaDataAdd.value
                    fileCode = metaDataAdd.value
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
                if metaDataAdd.name == "Slug"{
                    slug = metaDataAdd.value
                }
                if metaDataAdd.name == "Related"{
                    for json in metaDataAdd.value.toJsonArray(){
                        let item = MediaModel().initLoad(json)
                        related.append(item)
                    }
                }
                metaData.append(metaDataAdd)
            }
        }
        if let data = json["Metadata"] as? [String: Any]{
            if let temp = data["FileCode"] as? String {
                fileCode = temp
            }
        }
        if let data0 = json["Metadata"] as? String{
            let data = data0.toJson()

            if let temp = data["FileCode"] as? String {
                fileCode = temp
            }
        }
        return self
    }
    func getTimePass() -> String{
        if let previousDate = schedule.toDate(){
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
class ImageModel{
    var type = ""
    var url = ""
    var cdn = ""
    func initLoad(_ json: [String: Any]) -> ImageModel{
        if let temp = json["Url"] as? String { url = temp}
        if let temp = json["Type"] as? String { type = temp}
        if let temp = json["Cdn"] as? String { cdn = temp}
        if categoryVideo != nil, cdn == "" {
            cdn = categoryVideo.cdn.imageDomain
        }
        return self
    }
}
class MetaDataModel{
    var name = ""
    var value = ""
    
    func initLoad(_ json: [String: Any]) -> MetaDataModel{
        if let temp = json["Name"] as? String { name = temp}
        if let temp = json["Value"] as? String { value = temp}
        if let temp = json["Value"] as? Int { value = temp.description}
        return self
    }
}

class LayoutModel{
    var type = "1"
    var subType = "1"
    func initLoad(_ json: [String: Any]) -> LayoutModel{
        if let temp = json["Type"] as? String { type = temp}
        if let temp = json["Type"] as? Int { type = temp.description}
        if let temp = json["SubType"] as? String { subType = temp}
        return self
    }
}
class CDNModel{
    var liveDomain = ""
    var videoDomain = ""
    var imageDomain = ""
    func initLoad(_ json: [String: Any]) -> CDNModel{
        if let temp = json["LiveDomain"] as? String { liveDomain = temp}
        if let temp = json["VideoDomain"] as? String { liveDomain = temp}
        if let temp = json["ImageDomain"] as? String { imageDomain = temp}
        return self
    }
}
class ComponentModel{
    var id = ""
    var privateKey = ""
    var name = ""
    var url = ""
    var icon = ""
    var layout = LayoutModel()
    var descripTion = ""
    var category = CategoryModel()
    var components2: [ComponentModel2] = []
    func initLoad(_ json: [String: Any]) -> ComponentModel{
        if let temp = json["ID"] as? Int { id = temp.description}
        if let temp = json["PrivateKey"] as? String { privateKey = temp}
        if let temp = json["Name"] as? String { name = temp}
        if let temp = json["Icon"] as? String { icon = temp}
        if let temp = json["Url"] as? String { url = temp}
        if let temp = json["Description"] as? String { descripTion = temp}
        if let temp = json["Components"] as? String {
            for item in temp.toJsonArray(){
                let componentAdd = ComponentModel2().initLoad(item)
                components2.append(componentAdd)
            }
        }
        if let temp = json["LayoutType"] as? String {
            layout = LayoutModel().initLoad(temp.toJson())
        }
        if let temp = json["LayoutType"] as? [String: Any] {
            layout = LayoutModel().initLoad(temp)
        }
        return self
    }
    
}

class ComponentModel2{
    var privateKey = ""
    var name = ""
    var icon = ""
    var descripTion = ""
    var category = CategoryModel()
    func initLoad(_ json: [String: Any]) -> ComponentModel2{
        if let temp = json["PrivateKey"] as? String { privateKey = temp}
        if let temp = json["Name"] as? String { name = temp}
        if let temp = json["Icon"] as? String { icon = temp}
        if let temp = json["Description"] as? String { descripTion = temp}
        return self
    }
}
