//
//  CellHeaderChuongTrinhDetail.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 6/19/21.
//

import UIKit

class CellHeaderChuongTrinhDetail: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var icShare: UIImageView!
    @IBOutlet weak var viewShare: UIView!
    @IBOutlet weak var icSave: UIImageView!
    @IBOutlet weak var viewLike: UIView!
    @IBOutlet weak var imgLike: UIImageView!
    
    var delegate: CellHeaderChuongTringDetailDelegate!
    var item: MediaModel!
    override func awakeFromNib() {
        super.awakeFromNib()
        viewShare.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didShare(_:))))
        viewLike.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didLike(_:))))
        
    }
    @objc func didShare(_ sender: Any){
        delegate?.didShare(self)
    }
    @objc func didLike(_ sender: Any){
        self.imgLike.image = #imageLiteral(resourceName: "icons8-facebook-like-64 (1)")
        delegate?.didLike(self)
    }
}
protocol CellHeaderChuongTringDetailDelegate: ChuongTrinhDetailVC{
    func didShare(_ cell: CellHeaderChuongTrinhDetail)
    func didLike(_ cell: CellHeaderChuongTrinhDetail)
}
