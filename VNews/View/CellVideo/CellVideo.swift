//
//  CellVideo.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 5/11/21.
//

import UIKit

class CellVideo: UICollectionViewCell {
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblPublished: UILabel!
    @IBOutlet weak var dotView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        dotView.layer.cornerRadius = scale * 1
    }

}
