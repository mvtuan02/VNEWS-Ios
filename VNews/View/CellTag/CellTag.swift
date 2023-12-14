//
//  CellTag.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 5/11/21.
//

import UIKit

class CellTag: UICollectionViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewBg: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        viewBg.layer.cornerRadius = viewBg.bounds.height/2
    }
    
    override func prepareForReuse() {
        viewBg.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)
        lblTitle.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }

}
