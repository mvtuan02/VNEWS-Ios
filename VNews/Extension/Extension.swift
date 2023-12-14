//
//  Extension.swift
//  VTVNew
//
//  Created by Nguyễn Văn Chiến on 1/26/21.
//

import Foundation
import UIKit
import ImageSlideshow

extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }
    class var className: String {
        return String(describing: self)
    }
}
extension Date {
    static func -(recent: Date, previous: Date) -> (month: Int?, day: Int?, hour: Int?, minute: Int?, second: Int?) {
        let day = Calendar.current.dateComponents([.day], from: previous, to: recent).day
        let month = Calendar.current.dateComponents([.month], from: previous, to: recent).month
        let hour = Calendar.current.dateComponents([.hour], from: previous, to: recent).hour
        let minute = Calendar.current.dateComponents([.minute], from: previous, to: recent).minute
        let second = Calendar.current.dateComponents([.second], from: previous, to: recent).second
        
        return (month: month, day: day, hour: hour, minute: minute, second: second)
    }
    
    func getDay() -> Int {
        return Calendar.current.dateComponents([.day], from: self).day ?? 0
    }
    
    func dayBefore() -> Date{
        return Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }
    func dayAfter() -> Date{
        return Calendar.current.date(byAdding: .day, value: 1, to: self)!
    }
    func getTimeString() -> String {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        let timeString = components.month!.description.add0() + "_" + components.day!.description.add0() + "_" + components.year!.description
        return timeString
    }
    func getTimeString2() -> String {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        let timeString = components.day!.description.add0() + "." + components.month!.description.add0() + "." + components.year!.description
        return timeString
    }
    
    func getTimeString3() -> String {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        let timeString = components.day!.description.add0() + "/" + components.month!.description.add0() + "/" + components.year!.description + ", " + components.hour!.description + ":" + components.minute!.description
        return timeString
    }
    func getTimeString4() -> String {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        let timeString = components.day!.description.add0() + "_" + components.month!.description.add0() + "_" + components.year!.description
        return timeString
    }
    func getTimeString5() -> String {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: self)
        let timeString = components.year!.description.add0() + "-" + components.month!.description.add0() + "-" + components.day!.description.add0() + "T" + components.hour!.description.add0() + ":" + components.minute!.description.add0() + ":" + components.second!.description.add0() + ":" + components.nanosecond!.description.add0()
        return timeString
    }
    func getTimeString6() -> String {
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: self)
        let timeString = components.hour!.description.add0() + ":" + components.minute!.description.add0() + ":" + components.second!.description.add0()
        return timeString
    }
}
extension String {
    func toDate() -> Date?{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss"
        if let date = dateFormatter.date(from: self){
            return date
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS"
            if let date = dateFormatter.date(from: self){
                return date
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZZZZZ"
                if let date = dateFormatter.date(from: self){
                    return date
                } else {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZZZ"
                    return dateFormatter.date(from: self)
                }
            }
            
        }
    }

    func toJsonArray() -> [[String: Any]]{
        let data = self.data(using: .utf8)!
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [[String: Any]]{
                return jsonArray
            } else {
                return []
            }
        } catch let error as NSError {
            print(error)
        }
        return []
    }
    func toJson() -> [String: Any]{
        let data = self.data(using: .utf8)!
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String: Any]{
                return jsonArray
            } else {
                return ["":""]
            }
        } catch let error as NSError {
            print(error)
        }
        return ["":""]
    }
    func getTimeString() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss"
        if let date = dateFormatter.date(from: self){
            let components = Calendar.current.dateComponents([.hour, .minute], from: date)
            let timeString = components.hour!.description.add0() + ":" + components.minute!.description.add0()
            return timeString
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS"
            if let date = dateFormatter.date(from: self){
                let components = Calendar.current.dateComponents([.hour, .minute], from: date)
                let timeString = components.hour!.description.add0() + ":" + components.minute!.description.add0()
                return timeString
            }
        }
        return ""
    }
    func add0() -> String {
        if self.count == 1 {
            return "0" + self
        } else{
            return self
        }
    }
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
}

func publishedDate(schedule: String) -> String{
    if let previousDate = schedule.toDate(){
        let interval = Date() - previousDate
        if let month = interval.month, month != 0{
            return "\(month) tháng trước"
        } else if let day = interval.day, day != 0{
            return  "\(day) ngày trước"
        }else if let hour = interval.hour, hour != 0{
            return  "\(hour) giờ trước"
        }else if let minute = interval.minute, minute != 0{
            return  "\(minute) phút trước"
        }else {
            return  "trực tiếp"
        }
    } else {
        return ""
    }
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}


extension UIImage {
    func imageWithColor(tintColor: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        let context = UIGraphicsGetCurrentContext() as CGContext?
        context!.translateBy(x: 0, y: self.size.height)
        context!.scaleBy(x: 1.0, y: -1.0);
        context!.setBlendMode(CGBlendMode.normal)
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height) as CGRect
        context!.clip(to: rect, mask: self.cgImage!)
        tintColor.setFill()
        context!.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func makeImageWithColorAndSize(color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 100, height: 100))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
}
func multilColorLabel(string: String, color: UIColor, location: Int, lenght: Int) -> NSMutableAttributedString{
    var myMytableString = NSMutableAttributedString()
    myMytableString = NSMutableAttributedString(string: string)
    myMytableString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSRange(location: location, length: lenght))
    return myMytableString
}
extension UIView {
    func createDottedLine(width: CGFloat, color: CGColor) {
        let caShapeLayer = CAShapeLayer()
        caShapeLayer.strokeColor = color
        caShapeLayer.lineWidth = width
        caShapeLayer.lineDashPattern = [2,3]
        let cgPath = CGMutablePath()
        let cgPoint = [CGPoint(x: 0, y: 0), CGPoint(x: self.bounds.width, y: 0)]
        cgPath.addLines(between: cgPoint)
        caShapeLayer.path = cgPath
        layer.addSublayer(caShapeLayer)
    }
    func dropShadow(){
        layer.shadowColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        layer.shadowOffset = CGSize(width: 0, height: 7)
        layer.shadowOpacity = 0.7
        layer.shadowRadius = 7 * scaleW
        layer.masksToBounds = false
    }
    @IBInspectable var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set {
            
            layer.cornerRadius = newValue * scaleW
            layer.masksToBounds = newValue > 0
        }
    }
    @IBInspectable var bWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable var bColor: UIColor? {
        get {
            let color = UIColor.init(cgColor: layer.borderColor!)
            return color
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}

extension UIImage {
    class func colorForNavBar(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        //    Or if you need a thinner border :
        //    let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 0.5)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()

        context!.setFillColor(color.cgColor)
        context!.fill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image!
    }
}
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
func isUpdateAvailable() throws -> Bool {
    guard let info = Bundle.main.infoDictionary,
        let currentVersion = info["CFBundleShortVersionString"] as? String,
        let identifier = info["CFBundleIdentifier"] as? String,
        let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
        throw VersionError.invalidBundleInfo
    }
    let data = try Data(contentsOf: url)
    guard let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any] else {
        throw VersionError.invalidResponse
    }
    if let result = (json["results"] as? [Any])?.first as? [String: Any], let version = result["version"] as? String {
        return version != currentVersion
    }
    throw VersionError.invalidResponse
}

enum VersionError: Error {
    case invalidResponse, invalidBundleInfo
}
extension UIImage {
    func resizeTopAlignedToFill(newWidth: CGFloat) -> UIImage? {
        let newHeight = size.height * newWidth / size.width

        let newSize = CGSize(width: newWidth, height: newHeight)

        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
        draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}

extension ImageSlideshow {
    func topAlignmentAndAspectFit(to view: UIView) {
        self.contentMode = .scaleAspectFill
        self.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        
        self.addConstraints(
            [NSLayoutConstraint(item: self,
                                attribute: .height,
                                relatedBy: .equal,
                                toItem: self,
                                attribute: .width,
                                multiplier: self.frame.size.height / self.frame.size.width,
                                constant: 0.0)])
        view.addConstraints(
            [NSLayoutConstraint(item: self,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1.0,
                                constant: 0.0)])
        view.addConstraints(
            [NSLayoutConstraint(item: self,
                                attribute: .width,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .width,
                                multiplier: 1.0,
                                constant: 0.0)])
        view.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]",
                                           options: .alignAllTop,
                                           metrics: nil,
                                           views: ["imageView": self]))
    }
}
