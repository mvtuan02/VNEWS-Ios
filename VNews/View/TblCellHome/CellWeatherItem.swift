//
//  CellWeatherItem.swift
//  VNews
//
//  Created by dovietduy on 6/12/21.
//

import UIKit

class CellWeatherItem: UICollectionViewCell {
    static let reuseIdentifier = "CellWeatherItem"
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lblThu: UILabel!
    @IBOutlet weak var lblLow: UILabel!
    @IBOutlet weak var lblHigh: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
