//
//  CellVideoRelated.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 6/18/21.
//

import UIKit

class CellVideoRelated: UITableViewCell {
    
    var listRelated: [MediaModel] = []{
        didSet{
            clvPlaylist.reloadData()
        }
    }
    var delegate: CellVideoRelatedDelegate!
    @IBOutlet weak var bottomTinLienQuan: NSLayoutConstraint!
    @IBOutlet weak var clvPlaylist: UICollectionView!
    @IBOutlet weak var lblCountPlaylist: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpClv()
        registerCell()
        setupLayout()
        
        
    }
    func setup(){
//        print(listRelated.count)
        var listData: [MediaModel] = []
        for (index, item) in listRelated.enumerated(){
            APIService.shared.getVideoRelated(privateKey: item.privateID) { (data, error) in
                if let data = data as? MediaModel {
                    listData.append(data)
                    if index == self.listRelated.count - 1 {
                        self.listRelated = listData
                        
                        DispatchQueue.main.async {
                            self.clvPlaylist.reloadData()
                        }
                    }
                }
            }
        }
    }
    func setUpClv(){
        clvPlaylist.delegate = self
        clvPlaylist.dataSource = self
    }
    func registerCell(){
        clvPlaylist.register(UINib(nibName: "CellPlaylistHorizol", bundle: nil), forCellWithReuseIdentifier: "CellPlaylistHorizol")
    }
    func setupLayout(){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        clvPlaylist.collectionViewLayout = layout
    }
    
}

extension CellVideoRelated: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listRelated.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: scale * 20, bottom: scale * 20, right: scale * 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: scaleW * 131, height: scaleW * 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = clvPlaylist.dequeueReusableCell(withReuseIdentifier: "CellPlaylistHorizol", for: indexPath) as! CellPlaylistHorizol
        let item = listRelated[indexPath.row]
        if item.thumnail != "" {
            if let url = URL(string: chuongTrinh.cdn.imageDomain + item.thumnail.replacingOccurrences(of: "\\", with: "/" )){
                cell.img.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "image_default"))
            }
        } else {
            cell.img.kf.setImage(with: URL(string: "https://static.mediacdn.vn/vnews/web_images/image_default.png"))
        }
        
        cell.lblTitle.text = item.name
        cell.lblTime.text = item.getTimePass()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        APIService.shared.getVideoRelated(privateKey: listRelated[indexPath.row].id) { (data, error) in
            if let data = data as? MediaModel {
                self.delegate?.didSelectItem(self, data)
            }
        }
    }
}

protocol CellVideoRelatedDelegate {
    func didSelectItem(_ cell: CellVideoRelated, _ data: MediaModel)
}
