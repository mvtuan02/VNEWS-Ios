//
//  APIService.swift
//  VTCNow
//
//  Created by dovietduy on 1/25/21.
//

import Foundation
import Alamofire
import SwiftyJSON

class APIService{
    static let shared = APIService()
    func getDomainShare(closure: @escaping (_ response: Any?, _ error: Error?) -> Void) {
        AF.request("https://caching2.mediahub.vn/api/Playlist/json/DomainShare", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).responseString(completionHandler: { (response) in
            switch response.result {
            case .success(let data):
                closure(data, nil)
            case .failure(let error):
                closure(nil, error)
            }
        })
    }
    func getAppVersion(closure: @escaping (_ response: Any?, _ error: Error?) -> Void) {
        AF.request("https://caching2.mediahub.vn/api/Playlist/json/app_ios_version", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).responseString(completionHandler: { (response) in
            switch response.result {
            case .success(let data):
                closure(data, nil)
            case .failure(let error):
                closure(nil, error)
            }
        })
    }
    func getAdmobNativeKey(closure: @escaping (_ response: Any?, _ error: Error?) -> Void) {
        AF.request("https://caching2.mediahub.vn/api/Playlist/json/ads", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).responseString(completionHandler: { (response) in
            switch response.result {
            case .success(let data):
                closure(data, nil)
            case .failure(let error):
                closure(nil, error)
            }
        })
    }
    func getHomeScreen( closure: @escaping (_ response: Any?, _ error: Error?) -> Void) {
        AF.request("https://caching2.mediahub.vn/api/Playlist/json/60fe2710-4c9f-48e3-9f5a-ec4d3f3c9e26", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let data):
                var category = CategoryModel()
                if let data = data as? [String: Any]{
                    category = category.initLoad(data)
                }
                closure(category, nil)
            case .failure(let error):
                print(error)
                closure(nil, error)
            }
        })
    }
    func getHomeComponent(url: String, type: String = "", closure: @escaping (_ response: Any?, _ error: Error?) -> Void) {
        AF.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let data):
                var category = CategoryModel()
                if let data = data as? [String: Any]{
                    category = category.initLoad(data)
                    closure(category, nil)
                    return
                }
                if type == "3" {
                    var listWeather: [WeatherModel] = []
                    if let data = data as? [[String: Any]]{
                        for item in data{
                            let weather = WeatherModel().initLoad(item)
                            listWeather.append(weather)
                        }
                        closure(listWeather, nil)
                        return
                    }
                } else {
                    if let data = data as? [[String: Any]]{
                        for json in data{
                            let item = MediaModel().initLoad(json)
                            category.media.append(item)
                        }
                        category.layout.type = type
                        closure(category, nil)
                        return
                    }
                }
                
            case .failure(let error):
                print(error)
                closure(nil, error)
            }
        })
    }

    func getTabNews( closure: @escaping (_ response: Any?, _ error: Error?) -> Void) {
        AF.request("https://caching2.mediahub.vn/api/Playlist/json/ef40eab0-bd12-4904-804f-8d7007757b47", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let data):
                var category = CategoryModel()
                if let data = data as? [String: Any]{
                    category = category.initLoad(data)
                }
                closure(category, nil)
            case .failure(let error):
                print(error)
                closure(nil, error)
            }
        })
    }
    func getComponentListMedia(url: String, closure: @escaping (_ response: Any?, _ error: Error?) -> Void) {
        AF.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let data):
                var list: [MediaModel] = []
                if let data = data as? [[String: Any]]{
                    for json in data{
                        let item = MediaModel().initLoad(json)
                        list.append(item)
                    }
                    closure(list, nil)
                }
            case .failure(let error):
                print(error)
                closure(nil, error)
            }
        })
    }
    func getComponentListMostViewed(url: String, closure: @escaping (_ response: Any?, _ error: Error?) -> Void) {
        AF.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let value):
                var list: [MostViewedModel] = []
                if let value = value as? [String: Any]{
                    if let data = value["data"] as? [[String: Any]]{
                        for json in data{
                            let item = MostViewedModel().initLoad(json)
                            list.append(item)
                        }
                    }
                }
                closure(list, nil)
            case .failure(let error):
                print(error)
                closure(nil, error)
            }
        })
    }

    func getChuongTrinh( closure: @escaping (_ response: Any?, _ error: Error?) -> Void) {
        //https://api.caching.tek4tv.vn/api/playlist/json/949fa752-80e3-4d96-a45b-cb7af1a11dec
        AF.request("https://caching2.mediahub.vn/api/Playlist/json/949fa752-80e3-4d96-a45b-cb7af1a11dec", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let data):
                var category = CategoryModel()
                if let data = data as? [String: Any]{
                    category = category.initLoad(data)
                }
                closure(category, nil)
            case .failure(let error):
                print(error)
            }
        })
    }
    func getChuongTrinh2( closure: @escaping (_ response: Any?, _ error: Error?) -> Void) {
        //https://api.caching.tek4tv.vn/api/playlist/json/949fa752-80e3-4d96-a45b-cb7af1a11dec
        AF.request("https://caching2.mediahub.vn/api/Playlist/json/922f655c-0317-45a4-af2f-55db78184e93", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let data):
                var category = CategoryModel()
                if let data = data as? [String: Any]{
                    category = category.initLoad(data)
                }
                closure(category, nil)
            case .failure(let error):
                print(error)
            }
        })
    }

    func getHome1TinPlaylist( closure: @escaping (_ response: Any?, _ error: Error?) -> Void) {
        //https://api.caching.tek4tv.vn/api/playlist/json/26f280ee-5ece-477e-a556-2c9ef41d9b7c
        AF.request("https://caching2.mediahub.vn/api/Playlist/json/7ae75372-5f90-4e01-a2de-f938cf43d593", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let data):
                var category = CategoryModel()
                if let data = data as? [String: Any]{
                    category = category.initLoad(data)
                    var count = 0
                    for component in category.components{
                        self.getPlaylistForApp(privateKey: component.privateKey) { (data1, error, statusCode) in
                            if let data1 = data1 as? CategoryModel{
                                component.category = data1
//                                print(category.components[0].category.name)
                                count += 1
                            }
                            if count == category.components.count {
                                closure(category, nil)
                            }
                        }
                    }
                }
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func getSchedule(day: String, closure: @escaping (_ response: Any?, _ error: Error?) -> Void) {
        //https://api.caching.tek4tv.vn/api/playlist/json/vnews_epg_
        print("https://caching2.mediahub.vn/api/playlist/json/vnews_epg_" + day)
        AF.request("https://caching2.mediahub.vn/api/playlist/json/vnews_epg_" + day, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let data):
                var list: [ScheduleModel] = []
                if let data = data as? [[String: Any]]{
                    for json in data {
                        var item = ScheduleModel()
                        item = item.initLoad(json)
                        list.append(item)
                    }
                }
                closure(list, nil)
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func getContentPlaylist(privateKey: String ,closure: @escaping (_ response: Any?, _ error: Error?) -> Void) {
        AF.request("https://caching2.mediahub.vn/api/playlist/json/\(privateKey)", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let data):
                var category = CategoryModel()
                if let data = data as? [String: Any]{
                    category = category.initLoad(data)
                }
                closure(category, nil)
            case .failure(let error):
                print(error)
            }
        })
    }
    func getLive(closure: @escaping (_ response: Any?, _ error: Error?) -> Void) {
//        https://caching.mediahub.vn/api/playlist/json/live
        AF.request("https://caching2.mediahub.vn/api/Playlist/json/3fb791c4-077e-403e-a5b6-99052143a644", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let data):
                var category = CategoryModel()
                if let data = data as? [String: Any]{
                    category = category.initLoad(data)
                }
                closure(category, nil)
            case .failure(let error):
                print(error)
            }
        })
    }

    func getChitiettin(id: String,closure: @escaping (_ response: MediaModel?, _ error: Error?) -> Void) {
            AF.request("https://caching2.mediahub.vn/api/Video/json/\(id)", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let value):
                if let data = value as? [String:Any]{
                    let chitiettin = MediaModel().initLoad(data)
                    closure(chitiettin,nil)
                }
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func getCategoryVideo( closure: @escaping (_ response: Any?, _ error: Error?) -> Void) {
        AF.request("https://caching2.mediahub.vn/api/Playlist/json/25a27da9-34d4-4ef8-bb14-7b3bd8aa1ea5", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let data):
                var category = CategoryModel()
                if let data = data as? [String: Any]{
                    category = category.initLoad(data)
                    var count = 0
                    for component in category.components{
                        self.getPlaylistForApp(privateKey: component.privateKey) { (data1, error, statusCode) in
                            if let data1 = data1 as? CategoryModel{
                                component.category = data1
                                count += 1
                            }
                            if count == category.components.count {
                                closure(category, nil)
                            }
                        }
                    }
                }
                //closure(category, nil)
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func getVideoRelated(privateKey:String ,closure: @escaping (_ response: Any?, _ error: Error?) -> Void) {
        AF.request("https://caching2.mediahub.vn/api/Video/\(privateKey)", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let data):
                var category = MediaModel()
                if let data = data as? [String: Any]{
                        category = category.initLoad(data)
                }
                closure(category, nil)
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func getVideoLoadMore(page:Int,privateKey:String ,closure: @escaping (_ response: Any?, _ error: Error?) -> Void) {
        AF.request("https://caching2.mediahub.vn/api/Video/\(privateKey)/\(page)/20", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let data):
                var category = [MediaModel]()
                if let data = data as? [[String: Any]]{
                    for i in data {
                        let item = MediaModel().initLoad(i)
                        category.append(item)
                    }
                }
                closure(category, nil)
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func getTinMoi(closure: @escaping (_ response: CategoryModel?, _ error: Error?) -> Void) {
        AF.request("https://api.caching.tek4tv.vn/api/Playlist/json/a9a4f6cc-3d33-4d5a-8938-7f5d6780d9bf", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let data):
                var cate = CategoryModel()
                if let data = data as? [String: Any]{
                    cate = cate.initLoad(data)
                }
                closure(cate, nil)
            case .failure(let error):
                print(error)
            }
        })
    }
    func getEvenhot(closure: @escaping (_ response: Any?, _ error: Error?) -> Void) {
        AF.request("https://caching2.mediahub.vn/api/Playlist/json/fe4814ab-dce0-4d74-84e8-3a198f08dee9", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let data):
                var cate = CategoryModel()
                if let data = data as? [String: Any] {
                    cate = cate.initLoad(data)
                }
                closure(cate, nil)
            case .failure(let error):
                print(error)
            }
        })
    }

    func getPlayList(privateId: String,closure: @escaping (_ response: Any?, _ error: Error?) -> Void) {
        AF.request("https://caching2.mediahub.vn/api/Playlist/json/" + privateId, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let data):
                var cate = CategoryModel()
                if let data = data as? [String: Any] {
                    cate = cate.initLoad(data)
                }
                closure(cate, nil)
            case .failure(let error):
                print(error)
            }
        })
    }
    func getPlaylistForApp(privateKey: String ,closure: @escaping (_ response: Any?, _ error: Error?, _ statusCode: Int) -> Void) {
        AF.request("https://caching2.mediahub.vn/api/Playlist/json/\(privateKey)", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let data):
                var category = CategoryModel()
                if let data = data as? [String: Any] {
                    category = category.initLoad(data)
                }
                closure(category, nil, response.response!.statusCode)
            case .failure(let error):
                print(error)
            }
        })
    }
    func getTTXTC(closure: @escaping (_ response: Any?, _ error: Error?) -> Void) {
//        https://caching.mediahub.vn/api/playlist/json/ttxtc
        AF.request("https://caching2.mediahub.vn/api/playlist/json/ttxtc", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let data):
                var category: [ChildModel] = []
                if let data = data as? [[String: Any]]{
                    for json in data {
                        let item = ChildModel().initLoad(json)
                        category.append(item)
                    }
                }
                closure(category, nil)
            case .failure(let error):
                print(error)
            }
        })
    }
    func getSVN(closure: @escaping (_ response: Any?, _ error: Error?) -> Void) {
//        https://caching.mediahub.vn/api/playlist/json/svn
        AF.request("https://caching2.mediahub.vn/api/playlist/json/svn", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let data):
                var category: [ChildModel] = []
                if let data = data as? [[String: Any]]{
                    for json in data {
                        let item = ChildModel().initLoad(json)
                        category.append(item)
                    }
                }
                closure(category, nil)
            case .failure(let error):
                print(error)
            }
        })
    }
    
    
    func getDataSearch(keySearch:String ,closure: @escaping (_ response: Any?, _ error: Error?) -> Void) {
        AF.request("https://caching2.mediahub.vn/api/Video/Search", method: .post, parameters: ["KeySearch":"\"\(keySearch)\"","Tag":"","Page":0,"Size":50], encoding: JSONEncoding.default, headers: nil, interceptor: nil).responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let data):
                var modelResultSearch: [MediaModel] = []
                if let data = data as? [[String: Any]]{
                    for json in data {
                        var item = MediaModel()
                        item = item.initLoad(json)
                        modelResultSearch.append(item)
                    }
                }
                closure(modelResultSearch, nil)
            case .failure(let error):
                print(error)
            }
        })
    }
    func getMoreTinMoi(page: String,closure: @escaping (_ response: Any?, _ error: Error?) -> Void) {
        let json = [
            "KeySearch": "-vnewnewest",
            "Page": page,
            "Size": "20"
        ]
        AF.request("https://caching2.mediahub.vn/api/Video/Search", method: .post, parameters: json, encoding: JSONEncoding.default, headers: nil, interceptor: nil).responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let data):
                var modelResultSearch: [MediaModel] = []
                if let data = data as? [[String: Any]]{
                    for json in data {
                        var item = MediaModel()
                        item = item.initLoad(json)
                        modelResultSearch.append(item)
                    }
                }
                closure(modelResultSearch, nil)
            case .failure(let error):
                print(error)
            }
        })
    }
    func getSugestionSearch(keySearch:String ,closure: @escaping (_ response: Any?, _ error: Error?) -> Void) {
        AF.request("https://caching2.mediahub.vn/api/Video/suggestion/search", method: .post, parameters: ["KeySearch":keySearch,"Size":30], encoding: JSONEncoding.default, headers: nil, interceptor: nil).responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let data):
                var modelResultSearch: [ModelSugestion] = []
                if let data = data as? [[String: Any]]{
                    for json in data {
                        var item = ModelSugestion()
                        item = item.initLoad(json)
                        modelResultSearch.append(item)
                    }
                }
                closure(modelResultSearch, nil)
            case .failure(let error):
                print(error)
            }
        })
    }
    func searchWithTag(privateKey: String, keySearch: String, closure: @escaping (_ response: Any?, _ error: Error?) -> Void) {
        let json: [String : Any] = [
            "KeySearch": keySearch,
            "Tag": privateKey,
            "Page":0,
            "Size":20
        ]
        AF.request("https://caching2.mediahub.vn/api/Video/Search/tag", method: .post, parameters: json, encoding: JSONEncoding.default).responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let data):
                var listMedia: [MediaModel] = []
                if let data = data as? [[String: Any]]{
                    for item in data{
                        var mediaAdd = MediaModel()
                        mediaAdd = mediaAdd.initLoad(item)
                        listMedia.append(mediaAdd)
                    }
                }
                closure(listMedia, nil)
            case .failure(let error):
                print(error)
            }
        })
    }
    func getComment(postId: String , closure: @escaping (_ response: [ModelComment]?, _ error: Error?) -> Void) {
        AF.request("https://report.mediahub.vn/api/comment/c/\(postId)/1/100", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let value):
                if let data = value as? [String:Any] {
                    var listComment = [ModelComment]()
                    let jsonTag = JSON(data["data"]!).arrayValue
                    for i in jsonTag {
                        let c = ModelComment(json: i)
                        listComment.append(c)
                    }
                    closure(listComment, nil)
                }
            case .failure(let error):
                closure(nil, error)
            }
        })
    }
    func addNewComment(item: ModelComment,closure: @escaping (_ response: Any?, _ error: Error?) -> Void) {
        let json = [
            "PostId": item.postId.description,
            "User": item.user,
            "Message": item.message,
            "ParentId": "0",
            "PostName": item.postName,
            "UrlPost": item.urlPost
            
        ]
        AF.request("https://report.mediahub.vn/api/comment/add", method: .post, parameters: json, encoding: JSONEncoding.default, headers: nil, interceptor: nil).responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let data):
                if let data = data as? String{
                    closure(data, nil)
                }
                closure("false", nil)
            case .failure(_):
                closure("false", nil)
            }
        })
    }
    func replyComment(item: ModelComment,closure: @escaping (_ response: Any?, _ error: Error?) -> Void) {
        let json = [
            "PostId": item.postId.description,
            "User": item.user,
            "Message": item.message,
            "ParentId": item.parentId.description,
            "PostName": item.postName,
            "UrlPost": item.urlPost
            
        ]
        AF.request("https://report.mediahub.vn/api/comment/reply", method: .post, parameters: json, encoding: JSONEncoding.default, headers: nil, interceptor: nil).responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let data):
                if let data = data as? String{
                    closure(data, nil)
                }
                closure("false", nil)
            case .failure(_):
                closure("false", nil)
            }
        })
    }
    func report(id: String, title: String, path: String, contentType: String, duration: String, device: String, network: String, location: String, ip: String, closure: @escaping (_ response: Any?, _ error: Error?) -> Void) {
        let json: [String : Any] = [
            "id": id,
            "path": path,
            "type": "ios",
            "title": title,
            "contentType": contentType,
            "duration": duration,
            "device": device,
            "network": network,
            "location": location,
            "ip": ip
        ]
        AF.request("https://report2.mediahub.vn/api/Video/add/payload", method: .post, parameters: json, encoding: JSONEncoding.default).responseString(completionHandler: { (response) in
            switch response.result {
            case .success(let data):
                print(data)
            case .failure(let error):
                print(error)
            }
        })
    }
    func like(id: String, title: String, closure: @escaping (_ response: Any?, _ error: Error?) -> Void) {
        let json: [String : Any] = [
            "ID": id,
            "Title": title,
            "Like": 0,
            "Share": 0
        ]
        AF.request("https://report2.mediahub.vn/api/Social/add/like", method: .post, parameters: json, encoding: JSONEncoding.default).responseString(completionHandler: { (response) in
            switch response.result {
            case .success(let data):
                print(data)
            case .failure(let error):
                print(error)
            }
        })
    }
    func reportShare(id: String, title: String, closure: @escaping (_ response: Any?, _ error: Error?) -> Void) {
        let json: [String : Any] = [
            "ID": id,
            "Title": title,
            "Like": 0,
            "Share": 0
        ]
        AF.request("https://report2.mediahub.vn/api/Social/add/share", method: .post, parameters: json, encoding: JSONEncoding.default).responseString(completionHandler: { (response) in
            switch response.result {
            case .success(let data):
                print(data)
            case .failure(let error):
                print(error)
            }
        })
    }
}
