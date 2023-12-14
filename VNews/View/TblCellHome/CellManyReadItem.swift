//
//  CellManyReadItem.swift
//  VNews
//
//  Created by dovietduy on 6/12/21.
//

import UIKit

class CellManyReadItem: UICollectionViewCell {


    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewLine: UIView!
    @IBOutlet weak var viewShare: UIView!
    
    var delegate: CellManyReadItemDelegate!
    var item: MediaModel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        viewShare.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didShare(_:))))
    }
    @objc func didShare(_ sender: Any){
        self.delegate.didShare(self)
    }
    override func prepareForReuse(){
        viewLine.isHidden = false
    }
}
protocol CellManyReadItemDelegate: ManyReadCell {
    func didShare(_ cell: CellManyReadItem)
}
