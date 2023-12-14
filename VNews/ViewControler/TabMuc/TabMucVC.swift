//
//  TabHotVC.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 5/10/21.
//

import UIKit
import GoogleMobileAds

class TabMucVC: UIViewController {
    @IBOutlet weak var clickFacebook: UIView!
    @IBOutlet weak var clickYoutobe: UIView!
    @IBOutlet weak var clickTiktok: UIView!
    @IBOutlet weak var clickPhone: UIView!
    @IBOutlet weak var clickSearch: UIView!
    @IBOutlet weak var clickAccount: UIView!
    @IBOutlet weak var clickLogo: UIImageView!
    
    
    @IBOutlet weak var lblXemThem: UILabel!
    @IBOutlet weak var heighClvChuongtrinh: NSLayoutConstraint!
    @IBOutlet weak var clvChuongTrinh: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    var dataMore = CategoryModel()
    
    @objc func clickXemThem(){
//        196d0dee-39a4-4d9f-b5ac-fa54f3c371d1
        APIService.shared.getPlaylistForApp(privateKey: "196d0dee-39a4-4d9f-b5ac-fa54f3c371d1") { (data, error, statusCode) in
            if let data = data {
                self.dataMore = data as! CategoryModel
                DispatchQueue.main.async {
                    let count1 = chuongTrinh.components.count + self.dataMore.components.count
                    let row1: Double = Double(count1) / 2.0
                    if row1 == Double(Int(row1)) {
                        self.heighClvChuongtrinh.constant = scaleW * 107 * CGFloat(Int(row1)) + scale * 24
                    } else {
                        self.heighClvChuongtrinh.constant = scaleW * 107 * CGFloat(Int(row1) + 1) + scale * 24
                    }
                    self.clvChuongTrinh.reloadData()
                    self.lblXemThem.isHidden = true
                }
            }
            
            if statusCode == 400 {
                    let alert = UIAlertController(title: "Error", message: "Hệ thống đang lỗi, chúng tôi sẽ khắc phục lại sự cố sớm nhất", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Đóng", style: .cancel, handler: nil ))
                    self.present(alert, animated: true, completion: nil)
            }
            
            if error != nil {
                    let alert = UIAlertController(title: "Error", message: "Hệ thống đang lỗi, chúng tôi sẽ khắc phục lại sự cố sớm nhất", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Đóng", style: .cancel, handler: nil ))
                    self.present(alert, animated: true, completion: nil)
                
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Xemthem
        lblXemThem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickXemThem)))
        
        //open more app
        clickFacebook.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openFacbookApp)))
        clickYoutobe.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openYoutobeApp)))
        clickTiktok.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openTiktokApp)))
        clickPhone.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openPhoneCall)))
        clickSearch.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openViewSearch)))
        clickAccount.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openViewAccount)))
        clickLogo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToHomePage)))
        
        clvChuongTrinh.delegate = self
        clvChuongTrinh.dataSource = self
        clvChuongTrinh.register(UINib(nibName: "CellChuongTrinh", bundle: nil), forCellWithReuseIdentifier: "CellChuongTrinh")
        clvChuongTrinh.register(UINib(nibName: "AdmobCell", bundle: nil), forCellWithReuseIdentifier: "AdmobCell")
        let layout = UICollectionViewFlowLayout()
        clvChuongTrinh.collectionViewLayout = layout
        clvChuongTrinh.isScrollEnabled = false
        
        
        let count1 = chuongTrinh.components.count
        let row1: Double = Double(count1) / 2.0
        
        if row1 == Double(Int(row1)) {
            heighClvChuongtrinh.constant = scaleW * 107 * CGFloat(Int(row1)) + scale * 24
        } else{
            heighClvChuongtrinh.constant = scaleW * 107 * CGFloat(Int(row1) + 1) + scale * 24
        }
        AdmobManager.shared.loadAllNativeAds()
        NotificationCenter.default.addObserver(self, selector: #selector(showAdmob), name: NSNotification.Name("Admob.loaded"), object: nil)
    }
    var admobNativeAds: GADNativeAd?
    @objc func showAdmob(){
        if let native = AdmobManager.shared.getAdmobNativeAds(){
            admobNativeAds = native
            clvChuongTrinh.reloadSections(IndexSet(integer: 1))
            
        }
    }

    
    
}

extension TabMucVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 6
        } else if section == 1 {
            if let _ = self.admobNativeAds {
                return 1
            }
            return 0
        } else if section == 2 {
            return chuongTrinh.components.count - 6
        } else {
            return dataMore.components.count
        }
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellChuongTrinh", for: indexPath) as! CellChuongTrinh
            let item = chuongTrinh.components[indexPath.row]
            cell.lblTitle.text = item.name.uppercased()
            //let imgDomain = "https://lsnk4ojchwvod.vcdn.cloud/"
            if item.icon.contains("https") == false{
                item.icon = chuongTrinh.cdn.imageDomain + item.icon
            }
            if item.icon != "" {
                
                if let url = URL(string: item.icon.replacingOccurrences(of: "\\", with: "/" )){
                    cell.img.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "image_default"))
                }
            } else {
                cell.img.kf.setImage(with: URL(string: "https://static.mediacdn.vn/vnews/web_images/image_default.png"))
            }
            return cell
        } else if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AdmobCell", for: indexPath) as! AdmobCell
            if let admob = admobNativeAds {
                cell.setupHeader(nativeAd: admob)
            }
            return cell
        } else if indexPath.section == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellChuongTrinh", for: indexPath) as! CellChuongTrinh
            let item = chuongTrinh.components[indexPath.row + 6]
            cell.lblTitle.text = item.name.uppercased()
            //let imgDomain = "https://lsnk4ojchwvod.vcdn.cloud/"
            if item.icon.contains("https") == false{
                item.icon = chuongTrinh.cdn.imageDomain + item.icon
            }
            if item.icon != "" {
                
                if let url = URL(string: item.icon.replacingOccurrences(of: "\\", with: "/" )){
                    cell.img.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "image_default"))
                }
            } else {
                cell.img.kf.setImage(with: URL(string: "https://static.mediacdn.vn/vnews/web_images/image_default.png"))
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellChuongTrinh", for: indexPath) as! CellChuongTrinh
            let item = dataMore.components[indexPath.row]
            cell.lblTitle.text = item.name.uppercased()
            //let imgDomain = "https://lsnk4ojchwvod.vcdn.cloud/"
            //print(chuongTrinh.cdn.imageDomain + item.icon)
            if item.icon.contains("https") == false{
                item.icon = chuongTrinh.cdn.imageDomain + item.icon
            }
            if let url = URL(string: item.icon.replacingOccurrences(of: "\\", with: "/" )){
                cell.img.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "image_default"))
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChuongTrinhDetailVC") as! ChuongTrinhDetailVC
            APIService.shared.getPlaylistForApp(privateKey: chuongTrinh.components[indexPath.row].privateKey) { (data, error, statusCode) in
                if let data = data as? CategoryModel{
//                    print("key: \(chuongTrinh.components[indexPath.row].privateKey)")
                    if data.media.count != 0 {
                        vc.titleChuongTrinh = chuongTrinh.components[indexPath.row].name.uppercased()
                        vc.listVideo = data
                        vc.privateKey = chuongTrinh.components[indexPath.row].privateKey
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        let vc = NotFoundVC(nibName: "NotFoundVC", bundle: nil)
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            }
        } else if indexPath.section == 1 {
            
        } else if indexPath.section == 2 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChuongTrinhDetailVC") as! ChuongTrinhDetailVC
            APIService.shared.getPlaylistForApp(privateKey: chuongTrinh.components[indexPath.row + 6].privateKey) { (data, error, statusCode) in
                if let data = data as? CategoryModel{
//                    print("key: \(chuongTrinh.components[indexPath.row].privateKey)")
                    if data.media.count != 0 {
                        vc.titleChuongTrinh = chuongTrinh.components[indexPath.row + 6].name.uppercased()
                        vc.listVideo = data
                        vc.privateKey = chuongTrinh.components[indexPath.row + 6].privateKey
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        let vc = NotFoundVC(nibName: "NotFoundVC", bundle: nil)
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            }
        } else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChuongTrinhDetailVC") as! ChuongTrinhDetailVC
            APIService.shared.getPlaylistForApp(privateKey: dataMore.components[indexPath.row].privateKey) { (data, error, statusCode) in
                if let data = data as? CategoryModel{
                    if data.media.count != 0 {
                        vc.titleChuongTrinh = self.dataMore.components[indexPath.row].name.uppercased()
                        vc.listVideo = data
                        vc.privateKey = self.dataMore.components[indexPath.row].privateKey
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        let vc = NotFoundVC(nibName: "NotFoundVC", bundle: nil)
                        self.present(vc, animated: true, completion: nil)
                    }
                    
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0{
            return CGSize(width: scaleW * 160, height: scaleW * 107)
        } else if indexPath.section == 1 {
            return CGSize(width: collectionView.bounds.width, height: scaleW * 400)
        } else if indexPath.section == 2 {
            return CGSize(width: scaleW * 160, height: scaleW * 107)
        } else {
            return CGSize(width: scaleW * 160, height: scaleW * 107)
        }
        
        
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0{
            return UIEdgeInsets(top: scale * 16, left: scale * 20, bottom: 0, right: scale * 20)
        } else if section == 1 {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else if section == 2 {
            return UIEdgeInsets(top: 0, left: scale * 20, bottom: 0, right: scale * 20)
        } else {
            return UIEdgeInsets(top: scale * 16, left: scale * 20, bottom: 0, right: scale * 20)
        }
        
        
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
}



