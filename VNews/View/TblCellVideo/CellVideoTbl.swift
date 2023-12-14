//
//  CellVideoTbl.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 6/18/21.
//

import UIKit

class CellVideoTbl: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var viewLike: UIView!
    @IBOutlet weak var viewShare: UIView!
    @IBOutlet weak var imgLike: UIImageView!
    var delegate: CellVideoTblDelegate?
    var item = MediaModel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        viewLike.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didLike)))
        viewShare.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didShare)))
    }
    @objc func didShare() {
        
        delegate?.didShare(self)
    }
    @objc func didLike() {
        self.imgLike.image = #imageLiteral(resourceName: "icons8-facebook-like-64 (1)")
        delegate?.didLike(self)
    }
    override func prepareForReuse() {
        self.imgLike.image = #imageLiteral(resourceName: "icons8-facebook-like-64")
    }
}
protocol CellVideoTblDelegate: PageVideoVC {
    func didShare(_ cell: CellVideoTbl)
    func didLike(_ cell: CellVideoTbl)
}
