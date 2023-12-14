//
//  ChildVC.swift
//  VNews
//
//  Created by dovietduy on 6/16/21.
//

import UIKit

class ChildVC: UIViewController {

    @IBOutlet weak var imgBack: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var clv: UICollectionView!
    var data: [ChildModel] = []
    var name = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        clv.delegate = self
        clv.dataSource = self
        clv.register(UINib(nibName: CellChuongTrinh.className, bundle: nil), forCellWithReuseIdentifier: CellChuongTrinh.reuseIdentifier)
        let layout2 = UICollectionViewFlowLayout()
        layout2.minimumLineSpacing = 20 * scaleW
        layout2.minimumInteritemSpacing = 0
        layout2.sectionInset = UIEdgeInsets(top: 20 * scaleW, left: 20 * scaleW, bottom: 20 * scaleW, right: 20 * scaleW)
        layout2.itemSize = CGSize(width: (UIScreen.main.bounds.width - 60 * scaleW) / 2.01, height: scaleW * 107)
        clv.collectionViewLayout = layout2
        // Do any additional setup after loading the view.
        lblTitle.text = name
        imgBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(back)))
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
    }

}
extension ChildVC: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellChuongTrinh.className, for: indexPath) as! CellChuongTrinh
        let item = data[indexPath.row]
        cell.lblTitle.text = item.name.uppercased()
        if let url = URL(string: item.image){
            cell.img.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "image_default"), options:[.cacheOriginalImage,.transition(.fade(1))])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = data[indexPath.row]
        //print(item.privateKey)
        APIService.shared.searchWithTag(privateKey: item.privateKey, keySearch: "") {[weak self] (listData, error) in
            if let listData = listData as? [MediaModel]{
                if listData.count != 0 {
                    let vc = self?.storyboard?.instantiateViewController(withIdentifier: VideoDetailVC.className) as! VideoDetailVC
                    vc.data = listData[0]
                    vc.listData = listData
                    vc.modalPresentationStyle = .fullScreen
                    self?.present(vc, animated: true, completion: nil)
                } else {
                    let vc = NotFoundVC(nibName: NotFoundVC.className, bundle: nil)
                    vc.modalPresentationStyle = .fullScreen
                    self?.present(vc, animated: true, completion: nil)
                }
            }
        }
    }
}
extension ChildVC:UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
