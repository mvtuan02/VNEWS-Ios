//
//  CellCLVTest.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 6/28/21.
//

import UIKit

class CellCLVTest: UICollectionViewCell {

    @IBOutlet weak var heightImg: NSLayoutConstraint!
    @IBOutlet weak var lbl: UILabel!
    @IBOutlet weak var img: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        lbl.lineBreakMode = .byWordWrapping
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
            lbl.preferredMaxLayoutWidth = layoutAttributes.size.width - contentView.layoutMargins.left - contentView.layoutMargins.left
            layoutAttributes.bounds.size.height = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            return layoutAttributes
        }
    
    func setImage(){
//        img.contentMode = .top
        img.clipsToBounds = true
        
        let image = img.image!
        img.image = image.resizeTopAlignedToFill(newWidth: img.frame.width)
        heightImg.constant = img.image?.size.height ?? 100
    }
}
