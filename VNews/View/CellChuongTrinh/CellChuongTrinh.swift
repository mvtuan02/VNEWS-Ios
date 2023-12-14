//
//  CellChuongTrinh.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 5/17/21.
//

import UIKit

class CellChuongTrinh: UICollectionViewCell {
    static let reuseIdentifier = "CellChuongTrinh"

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var img: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
