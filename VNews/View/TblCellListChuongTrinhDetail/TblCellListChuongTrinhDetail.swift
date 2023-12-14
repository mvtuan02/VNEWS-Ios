//
//  TblCellListChuongTrinhDetail.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 6/19/21.
//

import UIKit

class TblCellListChuongTrinhDetail: UITableViewCell {
    var delegate: TblCellListChuongTrinhDetailDelegate!
    var listVideo = CategoryModel(){
        didSet{
            self.clv.reloadData()
        }
    }
    @IBOutlet weak var clv: UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()
        clv.delegate = self
        clv.dataSource = self
        clv.register(UINib(nibName: "CellPlaylistHorizol", bundle: nil), forCellWithReuseIdentifier: "CellPlaylistHorizol")
        let layoutChuongTrinh = UICollectionViewFlowLayout()
                layoutChuongTrinh.itemSize = CGSize(width: (375 * scaleW - 20 * scaleW)/2.01  , height: scaleW * 150)
                layoutChuongTrinh.minimumInteritemSpacing = 0
                layoutChuongTrinh.sectionInset = UIEdgeInsets(top: 0, left: 20 * scaleW, bottom: 10 * scaleW, right: 0)
        layoutChuongTrinh.minimumLineSpacing = scaleW * 10
                clv.collectionViewLayout = layoutChuongTrinh
        // Initialization code
    }
    
    func setUp(){
        clv.reloadData()
    }
}

extension TblCellListChuongTrinhDetail: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listVideo.media.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellPlaylistHorizol", for: indexPath) as! CellPlaylistHorizol
        if listVideo.media.count != 0 {
            let item = listVideo.media[indexPath.row]
            if item.thumnail == "" {
                cell.img.kf.setImage(with: URL(string: "https://static.mediacdn.vn/vnews/web_images/image_default.png"))
            } else {
                if item.thumnail != "", let url = URL(string: item.image[0].cdn + item.thumnail.replacingOccurrences(of: "\\", with: "/" )){
                    cell.img.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "image_default"))
                }
            }
            cell.lblTitle.text = item.name
            cell.lblTime.text = item.getTimePass()
        } else {
            cell.img.kf.setImage(with: URL(string: "https://static.mediacdn.vn/vnews/web_images/image_default.png"))
            cell.lblTitle.text = ""
            cell.lblTime.text = ""
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate.didSelectItem(listVideo.media, indexPath.row)
    }
}

protocol TblCellListChuongTrinhDetailDelegate {
    func didSelectItem(_ data: [MediaModel], _ index: Int)
}
