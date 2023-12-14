//
//  CellPlaylistHorizol.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 6/10/21.
//

import UIKit
import SwiftyGif
class CellPlaylistHorizol2: UICollectionViewCell {
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var viewRec: UIView!
    @IBOutlet weak var viewCountDown: UIView!
    fileprivate var futureDate: Date? = nil
    var timer: Timer?
    var item = MediaModel(){
        didSet{
            futureDate = item.schedule.toDate()
            if isDayAgo() {
                viewCountDown.isHidden = true
                viewRec.isHidden = true
                lblTime.text = ""
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
    override func prepareForReuse() {
        lblTime.text = ""
        viewRec.isHidden = true
        viewCountDown.isHidden = true
    }
    @objc func countDown(){
        if let futureDate = futureDate{
            let interval = futureDate - Date()
            if let hour = interval.hour, let minute = interval.minute, let second = interval.second{
                let timeStr = String(format: "%02d:%02d:%02d", hour, minute % 60, second % 60)
                
                if hour <= 0 && minute <= 0 && second <= 0{
                    if item.name.contains("Trực tiếp"){
                        item.timePass = "Trực tiếp"
                    } else {
                        item.timePass = "Đang phát"
                    }
                    
                    viewRec.isHidden = false
                    lblTime.text = item.timePass
                    timer?.invalidate()
                    //lblTime.textColor = .white
                    //NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init("countDownTimer"), object: nil)
//                    timer.invalidate()
                } else{
                    item.timePass = "\(timeStr)"
                    lblTime.text = item.timePass
                    //lblTime.textColor = .white
                }
            }
            
        }
    }
    func isOnLive() -> Bool{
        if let futureDate = futureDate{
            let interval = futureDate - Date()
            if let hour = interval.hour, let minute = interval.minute, let second = interval.second{
                let timeStr = String(format: "%02d:%02d:%02d", hour, minute % 60, second % 60)

                if hour <= 0 && minute <= 0 && second <= 0{
                    if item.name.contains("Trực tiếp"){
                        item.timePass = "Trực tiếp"
                    } else {
                        item.timePass = "Đang phát"
                    }
                    viewRec.isHidden = false
                    lblTime.text = item.timePass
                    //lblTime.textColor = .white
                    return true
                } else{
                    item.timePass = "\(timeStr)"
                    //lblTime.textColor = .white
                    return false
                }
            }
        }
        return false
    }
    func isDayAgo() -> Bool{
        let day1 = futureDate?.getDay()
        let day2 = Date().getDay()
        if day1 != day2 {
            lblTime.text = ""
            viewRec.isHidden = true
            return true
        } else {
            return false
        }
    }
}

