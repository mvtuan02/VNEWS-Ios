//
//  ListEventHot.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 6/16/21.
//

import UIKit

class ListEventHot: UIViewController {
    var listData = [ComponentModel]()

    @IBOutlet weak var clv: UICollectionView!
    @IBOutlet weak var imgBack: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        clv.delegate = self
        clv.dataSource = self
        clv.register(UINib(nibName: "CellNews", bundle: nil), forCellWithReuseIdentifier: "CellNews")
        let layout = UICollectionViewFlowLayout()
        clv.collectionViewLayout = layout
        imgBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(back)))
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
}

extension ListEventHot: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: scaleW * 109)

    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        listData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = clv.dequeueReusableCell(withReuseIdentifier: "CellNews", for: indexPath) as! CellNews
        let item = listData[indexPath.row]
        cell.lblTitle.text = item.name
        if let url = URL(string: item.icon.replacingOccurrences(of: "\\", with: "/")){
            cell.img.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "image_default"))
        }
        cell.lblCategory.isHidden = true
        cell.lblPublished.isHidden = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailListEvenHot") as! DetailListEvenHot
        let item = listData[indexPath.row]
        vc.id = item.privateKey
        vc.nameVC = item.name
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
extension ListEventHot:UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
