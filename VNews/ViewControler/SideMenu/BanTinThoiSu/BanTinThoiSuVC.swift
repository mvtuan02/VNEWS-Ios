//
//  BanTinThoiSuVC.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 5/13/21.
//

import UIKit

class BanTinThoiSuVC: UIViewController {
    @IBOutlet weak var clv: UICollectionView!
    @IBOutlet weak var myNavi: UINavigationItem!
    override func viewDidLoad() {
        super.viewDidLoad()

        actionBar()

        clv.delegate = self
        clv.dataSource = self
        clv.register(UINib(nibName: "CellNews", bundle: nil), forCellWithReuseIdentifier: "CellNews")
        let layout = UICollectionViewFlowLayout()
               clv.collectionViewLayout = layout
        
    }
    

    func actionBar(){
        navigationController?.navigationBar.barTintColor = UIColor(hexString: "#ffffff")
        navigationController?.navigationBar.isTranslucent = false
        self.myNavi.title = "Bản tin Thời sự";
        
        //settup leftBarbutton item
        let menuBtnLeft = UIButton(type: .custom)
        menuBtnLeft.frame = CGRect(x: 0.0, y: 0.0, width: 30, height: 30)
        menuBtnLeft.setImage(UIImage(named:"icArrLeft"), for: .normal)
        menuBtnLeft.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectViewBack(_:))))
        //            menuBtn.addTarget(self, action: #selector(vc.onMenuButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        let menuBarItemLeft = UIBarButtonItem(customView: menuBtnLeft)
        menuBarItemLeft.customView?.widthAnchor.constraint(equalToConstant: 24).isActive = true
        menuBarItemLeft.customView?.heightAnchor.constraint(equalToConstant: 24).isActive = true
        self.myNavi.leftBarButtonItem = menuBarItemLeft
    
    }
    @objc func didSelectViewBack(_ sender: Any){
        self.navigationController?.popViewController(animated: true)
    }

}

extension BanTinThoiSuVC: UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = clv.dequeueReusableCell(withReuseIdentifier: "CellNews", for: indexPath) as! CellNews
        cell.img.kf.setImage(with: URL(string: "https://imgcomfort.com/Userfiles/Upload/images/illustration-geiranger.jpg"))
        cell.lblTitle.text = "Bộ Công Thương triển khai các quyết định của Đảng và Nhà nước về công tác cán bộ"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 0.245)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
