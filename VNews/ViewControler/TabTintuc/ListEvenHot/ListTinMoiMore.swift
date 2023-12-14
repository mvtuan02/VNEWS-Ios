//
//  ListTinMoiMore.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 6/17/21.
//

import UIKit

class ListTinMoiMore: UIViewController {
    
    private let refreshControl = UIRefreshControl()
    func setupPulltoRefresh(){
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
            self.clv.alwaysBounceVertical = true
            self.clv.refreshControl = refreshControl // iOS 10+
    }
    @objc
    private func didPullToRefresh(_ sender: Any) {
        page = 2
        getData(page: page)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.refreshControl.endRefreshing()
        }
    }
    
    var page = 2
    var listTinMoi = [MediaModel]()

    @IBOutlet weak var clv: UICollectionView!
    @IBOutlet weak var imgback: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPulltoRefresh()
        clv.delegate = self
        clv.dataSource = self
        clv.register(UINib(nibName: "CellNews", bundle: nil), forCellWithReuseIdentifier: "CellNews")
        let layout = UICollectionViewFlowLayout()
        clv.collectionViewLayout = layout
        getData(page: page)
        imgback.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(back)))
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func getData(page: Int){
        APIService.shared.getTinMoi() { (data, error) in
            if let listData = data {
                for i in listData.media{
                    self.listTinMoi.append(i)
                }
                DispatchQueue.main.async {
                    self.clv.reloadData()
                }
            }
        }
    }

}
extension ListTinMoiMore: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: scaleW * 109)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listTinMoi.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = clv.dequeueReusableCell(withReuseIdentifier: "CellNews", for: indexPath) as! CellNews
        let item = listTinMoi[indexPath.row]
        cell.lblTitle.text = item.name
        if item.thumnail != ""{
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == listTinMoi.count - 3 {
            page = page + 1
            getData(page: page)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewsDetailVC") as! NewsDetailVC
        vc.id = listTinMoi[indexPath.row].id
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
extension ListTinMoiMore:UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
