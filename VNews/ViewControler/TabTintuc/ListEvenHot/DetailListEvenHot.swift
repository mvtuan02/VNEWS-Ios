//
//  DetailListEvenHot.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 6/16/21.
//

import UIKit

class DetailListEvenHot: UIViewController {
    var listData = [MediaModel]()
    var id = "" {
        didSet{
            getData()
        }
    }
    var page = 1
    var nameVC = ""
    
    @IBOutlet weak var lblNameVC: UILabel!
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
        
        lblNameVC.text = nameVC
    }
    
    func getData(){
        APIService.shared.getPlayList(privateId: id){ (data, error) in
            if let data = data as? CategoryModel{
                for i in data.media {
                    self.listData.append(i)
                }
                DispatchQueue.main.async {
                    self.clv.reloadData()
                }
            }
        }
    }
    
}
extension DetailListEvenHot: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
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
        
        if item.thumnail != "" {
            if let url = URL(string: item.image[0].cdn + item.thumnail.replacingOccurrences(of: "\\", with: "/")){
                cell.img.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "image_default"))
            }
        } else {
            cell.img.kf.setImage(with: URL(string: "https://static.mediacdn.vn/vnews/web_images/image_default.png"))
        }
        cell.lblCategory.text = (item.category == "") ? "VNEWS" : item.category
        let schedule = item.schedule
        let timePass = publishedDate(schedule: schedule)
        cell.lblPublished.text = timePass
        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if indexPath.row == listData.count - 2 {
//            page = page + 1
//            getData(page: page, id: id)
//        }
//    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewsDetailVC") as! NewsDetailVC
        vc.id = listData[indexPath.row].id
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension DetailListEvenHot:UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
