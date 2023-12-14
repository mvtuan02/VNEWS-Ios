//
//  PlaylistCell.swift
//  VNews
//
//  Created by Apple on 28/06/2021.
//

import UIKit

class PlaylistCell: UITableViewCell {
    static let reuseIdentifier = "PlaylistCell"
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var clv: UICollectionView!
    var data = CategoryModel()
    var delegate: PlaylistCellDelegate!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        clv.delegate = self
        clv.dataSource = self
        clv.register(UINib(nibName: CellPlaylistHorizol.className, bundle: nil), forCellWithReuseIdentifier: CellPlaylistHorizol.className)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: 131 * scaleW, height: 131 * scaleW)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20 * scaleW, bottom: 20 * scaleW, right: 0)
        clv.collectionViewLayout = layout
    }

}
extension PlaylistCell: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        data.media.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellPlaylistHorizol.className, for: indexPath) as! CellPlaylistHorizol
        let item = data.media[indexPath.row]
        if let url = URL(string: data.cdn.imageDomain + item.thumnail.replacingOccurrences(of: "\\", with: "/" )){
            cell.img.kf.setImage(with: url ,placeholder: #imageLiteral(resourceName: "image_default"), options:[.cacheOriginalImage,.transition(.fade(1))])
        }
        cell.lblTitle.text = item.name
        cell.lblTime.text = item.getTimePass()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectItemAt(data, indexPath)
    }
}
protocol PlaylistCellDelegate: PageVNewsVC {
    func didSelectItemAt(_ data: CategoryModel, _ indexPath: IndexPath)
}

