//
//  CellTblTest.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 6/26/21.
//

import UIKit

class CellTblTest: UITableViewCell {
    @IBOutlet weak var heightImg: NSLayoutConstraint!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }

    func setImage(){
//        img.contentMode = .top
        img.clipsToBounds = true
        
        let image = img.image!
        img.image = image.resizeTopAlignedToFill(newWidth: img.frame.width)
        heightImg.constant = img.image?.size.height ?? 100
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
