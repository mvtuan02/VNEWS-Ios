import Foundation
import AVKit
let scale = UIScreen.main.bounds.height / 812
let scaleH = UIScreen.main.bounds.height / 812
let scaleW = UIScreen.main.bounds.width / 375
extension NSLayoutConstraint{
    @IBInspectable var autoConstrains: Bool {
        get { return true }
        set {
            let attribute = self.firstAttribute
            if attribute == .top || attribute == .bottom {
                self.constant = self.constant * scaleH
            } else if attribute == .leading || attribute == .trailing {
                self.constant = self.constant * scaleW
            }
            
            if attribute == .width {
                self.constant = self.constant * scaleW
            } else if attribute == .height {
                self.constant = self.constant * scaleH
            }
        }
    }
    @IBInspectable var myConstainWidth: Bool {
        get { return true }
        set {
            let attribute = self.firstAttribute
            if attribute == .top || attribute == .bottom {
                self.constant = self.constant * scaleW
            } else if attribute == .leading || attribute == .trailing {
                self.constant = self.constant * scaleW
            } else if attribute == .width{
                self.constant = self.constant * scaleW
            } else if attribute == .height{
                self.constant = self.constant * scaleW
            }
        }
    }
}
var scaleFont = (UIScreen.main.bounds.width * UIScreen.main.bounds.height) / (812 * 375)
extension UILabel{
    @IBInspectable var myAutoFontSize: Bool{
        get{ true }
        set {
            self.font = self.font.withSize(self.font.pointSize * scaleFont)
        }
    }
}
extension UITextView{
    @IBInspectable var myAutoFontSize: Bool{
        get{ true }
        set {
            self.font = self.font?.withSize(self.font!.pointSize * scale)
        }
    }
}
extension UITextField{
    @IBInspectable var myAutoFontSize: Bool{
        get{ true }
        set {
            self.font = self.font?.withSize(self.font!.pointSize * scale)
        }
    }
}

@IBDesignable
class BorderTextField: UITextField {
 @IBInspectable var borderColor: UIColor? {
    didSet {
        layer.borderColor = borderColor?.cgColor
    }
 }
 @IBInspectable var borderWidth: CGFloat = 0 {
    didSet {
        layer.borderWidth = borderWidth
    }
 }
}
