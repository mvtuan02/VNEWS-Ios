//
//  TestCLVVC.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 6/28/21.
//

import UIKit
// ghgfgfgjhkgh
class TestCLVVC: UIViewController {
    @IBOutlet weak var clv: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clv.delegate = self
        clv.dataSource = self
        clv.register(UINib(nibName: "CellCLVTest", bundle: nil), forCellWithReuseIdentifier: "CellCLVTest")
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        clv.collectionViewLayout = layout
            
    }

}
extension TestCLVVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        9
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellCLVTest", for: indexPath) as! CellCLVTest
        let item = home1Tin.components[0].category.media[indexPath.row]
        cell.lbl.text = item.name
        if let url = URL(string: tinMoi.cdn.imageDomain + item.thumnail.replacingOccurrences(of: "\\", with: "/" )){
            cell.img.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "image_default"), options:[.cacheOriginalImage,.transition(.fade(1))]){_ in
                cell.lbl.text = item.name
                cell.setImage()
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let referenceHeight: CGFloat = 100 // Approximate height of your cell
            let referenceWidth = collectionView.safeAreaLayoutGuide.layoutFrame.width
            return CGSize(width: referenceWidth, height: referenceHeight)
        }
}
