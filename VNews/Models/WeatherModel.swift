//
//  WeatherModel.swift
//  VNews
//
//  Created by dovietduy on 6/12/21.
//

import Foundation
class TodayModel{
    var time = 0
    var icon = ""
    var humidity = 0.0
    var windSpeed = 0.0
    var temperature = 0.0
    func initLoad(_ json:  [String: Any]) -> TodayModel{
        if let temp = json["time"] as? Int { time = temp }
        if let temp = json["icon"] as? String { icon = temp }
        if let temp = json["temperature"] as? Double { temperature = temp }
        if let temp = json["humidity"] as? Double { humidity = temp }
        if let temp = json["windSpeed"] as? Double { windSpeed = temp}
        return self
    }
    func getHumidity() -> String {
        return Int(humidity * 100).description + "%"
    }
}
class WeatherModel {
    var name = ""
    var lat = ""
    var long = ""
    var data = TodayModel()
    var daily: [DailyModel] = []
    init(){}
    init(_ name: String, lat: String, long: String) {
        self.name = name
        self.lat = lat
        self.long = long
    }
    func initLoad(_ json: [String: Any]) -> WeatherModel{
            if let temp = json["Name"] as? String { name = temp }
            if let temp = json["Data"] as? [String: Any]{
                if let currently = temp["currently"] as?  [String: Any]{
                    data = data.initLoad(currently)
                }
                if let list = temp["daily"] as?  [[String: Any]]{
                    for item in list{
                        let day = DailyModel().initLoad(item)
                        daily.append(day)
                    }
                }
            }
            return self
        }
}
class DailyModel: Codable{
    var time = 0
    var icon = ""
    var temperatureHigh = 0.0
    var temperatureLow = 0.0
    func initLoad(_ json:  [String: Any]) -> DailyModel{
        if let temp = json["time"] as? Int { time = temp }
        if let temp = json["icon"] as? String { icon = temp }
        if let temp = json["temperatureMax"] as? Double { temperatureHigh = temp }
        if let temp = json["temperatureMin"] as? Double { temperatureLow = temp }
        return self
    }
}
