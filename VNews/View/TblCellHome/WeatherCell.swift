//
//  WeatherCell.swift
//  VNews
//
//  Created by Apple on 28/06/2021.
//

import UIKit
import GoogleMobileAds


class WeatherCell: UITableViewCell {
    static let reuseIdentifier = "WeatherCell"
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var lblC: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var clv: UICollectionView!
    @IBOutlet weak var lblWindSpeed: UILabel!
    @IBOutlet weak var lblHumidity: UILabel!
    @IBOutlet weak var nativeAdView: GADNativeAdView!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var topWeather: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        clv.delegate = self
        clv.dataSource = self
        clv.register(UINib(nibName: CellWeatherItem.className, bundle: nil), forCellWithReuseIdentifier: CellWeatherItem.className)
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (375 - 40 - 25 * 4) / 5.01 * scaleW, height: 100 * scaleW)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 25 * scaleW
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20 * scaleW, bottom: 0, right: 20 * scaleW)
        clv.collectionViewLayout = layout
    }
    let thu: [String: String] = [
        "Mon": "Th 2",
        "Tue": "Th 3",
        "Wed": "Th 4",
        "Thu": "Th 5",
        "Fri": "Th 6",
        "Sat": "Th 7",
        "Sun": "CN"
    ]
    var timer = Timer()
    var index = 0
    var listW: [WeatherModel] = [] {
        didSet{
            clv.reloadData()
            lblCity.text = "Thời tiết " + listW[0].name
            lblC.text = Int(listW[0].data.temperature.rounded(.toNearestOrEven)).description + "°"
            icon.image = UIImage(named: listW[0].data.icon)
            lblWindSpeed.text = listW[0].data.windSpeed.description + " Km/h"
            lblHumidity.text = listW[0].data.getHumidity()
            if timer.isValid == false {
                timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: {[self] (timer) in
                    
                    if index < 4 {
                        index += 1
                    } else{
                        index = 0
                    }
                    
                    if index < listW.count{
                        lblCity.text = "Thời tiết " + listW[index].name
                        lblC.text = Int(listW[index].data.temperature.rounded(.toNearestOrEven)).description + "°"
                        icon.image = UIImage(named: listW[index].data.icon)
                        lblWindSpeed.text = listW[index].data.windSpeed.description + " Km/h"
                        lblHumidity.text = listW[index].data.getHumidity()
                        clv.reloadData()
                    }
                    
                })
            }
        }
    }
   
}
extension WeatherCell: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellWeatherItem.reuseIdentifier, for: indexPath) as! CellWeatherItem
        if index < listW.count, listW[index].daily.isEmpty == false {
            let item = listW[index].daily[indexPath.row + 1]
            cell.lblThu.text = thu[getDayOfDate(Date(timeIntervalSince1970: Double(item.time)))]
            cell.img.image = UIImage(named: item.icon)
            cell.lblLow.text = Int(item.temperatureLow.rounded(.toNearestOrEven)).description + "°"
            cell.lblHigh.text = Int(item.temperatureHigh.rounded(.toNearestOrEven)).description + "°"
        }
        return cell
    }
    func getDayOfDate(_ date: Date?) -> String{
        guard let inputDate = date else {
            return ""
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: inputDate)
    }
    
}

