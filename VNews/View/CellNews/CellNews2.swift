//
//  CellNews.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 5/11/21.
//

import UIKit
import SwiftyGif


class CellNews2: UICollectionViewCell {
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblPublished: UILabel!
    @IBOutlet weak var dotView: UIView!
    @IBOutlet weak var line: UIView!
    @IBOutlet weak var lblCountDown: UILabel!
    @IBOutlet weak var viewRec: UIView!
    @IBOutlet weak var viewCountDown: UIView!
    
    @IBOutlet weak var viewShare: UIView!
    @IBOutlet weak var viewLike: UIView!
    @IBOutlet weak var imgLike: UIImageView!
    var delegate: CellNews2Delegate!
    var isMedia = false
    var item: MostViewedModel!
    //var itemMedia: MediaModel!
    fileprivate var futureDate: Date? = nil
    var timer: Timer?
    var itemMedia = MediaModel(){
        didSet{
            futureDate = itemMedia.schedule.toDate()
            if isDayAgo() {
                viewCountDown.isHidden = true
                return
            }
            if isOnLive(){
                viewCountDown.isHidden = false
            } else{
                viewCountDown.isHidden = false
                timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {(timer) in
                    self.countDown()
                })
//                NotificationCenter.default.addObserver(self, selector: #selector(countDown(_:)),name: NSNotification.Name ("countDownTimer"), object: nil)
            }
        }
    }
    deinit {
        timer?.invalidate()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        dotView.layer.cornerRadius = scale * 1
        viewShare.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didShare(_:))))
        viewLike.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didLike(_:))))
        do {
            let gif = try UIImage(gifName: "rec.gif")
            let imageview = UIImageView(gifImage: gif)
            imageview.frame = viewRec.bounds
            viewRec.addSubview(imageview)
            viewRec.isHidden = true
        } catch {
            print(error)
        }
    }
    @objc func didShare(_ sender: Any){
        self.delegate?.didShare(self)
    }
    @objc func didLike(_ sender: Any){
        self.imgLike.image = #imageLiteral(resourceName: "icons8-facebook-like-64 (1)")
        self.delegate?.didLike(self)
    }
    override func prepareForReuse() {
        self.imgLike.image = #imageLiteral(resourceName: "icons8-facebook-like-64")
    }
    func isOnLive() -> Bool{
        if let futureDate = futureDate{
            let interval = futureDate - Date()
            if let hour = interval.hour, let minute = interval.minute, let second = interval.second{
                let timeStr = String(format: "%02d:%02d:%02d", hour, minute % 60, second % 60)
                
                if hour <= 0 && minute <= 0 && second <= 0{
                    if itemMedia.name.contains("Trực tiếp"){
                        itemMedia.timePass = "Trực tiếp"
                    } else {
                        itemMedia.timePass = "Đang phát"
                    }
                    viewRec.isHidden = false
                    lblPublished.text = itemMedia.timePass
                    lblCountDown.text = itemMedia.timePass
                    //lblTime.textColor = .white
                    return true
                } else{
                    itemMedia.timePass = "\(timeStr)"
                    //lblTime.textColor = .white
                    return false
                }
            }
        }
        return false
    }
    @objc func countDown(){
        if let futureDate = futureDate{
            let interval = futureDate - Date()
            if let hour = interval.hour, let minute = interval.minute, let second = interval.second{
                let timeStr = String(format: "%02d:%02d:%02d", hour, minute % 60, second % 60)
                
                if hour <= 0 && minute <= 0 && second <= 0{
                    if itemMedia.name.contains("Trực tiếp"){
                        itemMedia.timePass = "Trực tiếp"
                    } else {
                        itemMedia.timePass = "Đang phát"
                    }
                    viewRec.isHidden = false
                    lblPublished.text = itemMedia.timePass
                    timer?.invalidate()
                    //lblTime.textColor = .white
                    //NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init("countDownTimer"), object: nil)
//                    timer.invalidate()
                } else{
                    itemMedia.timePass = "\(timeStr)"
                    //lblTime.textColor = .white
                }
            }
            lblPublished.text = itemMedia.timePass
            lblCountDown.text = itemMedia.timePass
        }
    }

    func isDayAgo() -> Bool{
        let day1 = futureDate?.getDay()
        let day2 = Date().getDay()
        if day1 != day2 {
            lblPublished.text = itemMedia.timePass
            viewCountDown.isHidden = true
            return true
        } else {
            return false
        }
    }
}
protocol CellNews2Delegate{
    func didShare(_ cell: CellNews2)
    func didLike(_ cell: CellNews2)
}
