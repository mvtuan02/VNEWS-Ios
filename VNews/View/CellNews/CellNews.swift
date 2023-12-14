//
//  CellNews.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 5/11/21.
//

import UIKit

class CellNews: UICollectionViewCell {
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblPublished: UILabel!
    @IBOutlet weak var dotView: UIView!
    @IBOutlet weak var line: UIView!
    
    @IBOutlet weak var viewShare: UIView!
    @IBOutlet weak var viewLike: UIView!
    @IBOutlet weak var imgLike: UIImageView!
    var delegate: CellNewsDelegate!
    var isMedia = false
    var item: MostViewedModel!
    var itemMedia: MediaModel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        dotView.layer.cornerRadius = scale * 1
        viewShare.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didShare(_:))))
        viewLike.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didLike(_:))))
    }
    @objc func didShare(_ sender: Any){
        self.delegate?.didShare(self)
    }
    @objc func didLike(_ sender: Any){
        self.imgLike.image = #imageLiteral(resourceName: "icons8-facebook-like-64 (1)")
        self.delegate?.didLike(self)
    }
    override func prepareForReuse() {
        self.imgLike.image = #imageLiteral(resourceName: "icons8-facebook-like-64")
    }
    
}
protocol CellNewsDelegate{
    func didShare(_ cell: CellNews)
    func didLike(_ cell: CellNews)
}
