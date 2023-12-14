//
//  CellComment.swift
//  VNews
//
//  Created by Apple on 07/09/2021.
//

import UIKit

class CellComment: UITableViewCell {
    @IBOutlet weak var lblUser: UILabel!
    @IBOutlet weak var lblMessage: UILabel!{
        didSet{
//            let attributedText = NSMutableAttributedString(attributedString: lblMessage.attributedText!)
//            let text = lblMessage.text! as NSString
//            let boldRange = text.range(of: lblMessage.text!)
//            attributedText.addAttribute(NSAttributedString.Key.backgroundColor, value: #colorLiteral(red: 0.9329736829, green: 0.9381117821, blue: 0.9446959496, alpha: 1), range: boldRange)
//            lblMessage.attributedText = attributedText
        }
    }
    @IBOutlet weak var lblTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
}
