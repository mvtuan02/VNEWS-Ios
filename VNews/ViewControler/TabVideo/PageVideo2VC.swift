//
//  TabTinTucVC.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 6/19/21.
//

import UIKit
import GoogleMobileAds
import XLPagerTabStrip

class PageVideo2VC: UIViewController, IndicatorInfoProvider {
    var listSlideShow = [MediaModel]()
    var listTinMoi = [MediaModel]()
    var listTinDocNhieu = [MostViewedModel]()
    var checkLoadMore = true
    var checkAPIVideo = false
    @IBOutlet weak var clv: UICollectionView!
    
    var listData = CategoryModel()
    var listRelated: [MediaModel] = []
    fileprivate var newsCate = CategoryModel()
    var page = 0
    var privateKey:String = ""
    var name:String = ""
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: name)
    }
    
    func getData(){
        APIService.shared.getPlaylistForApp(privateKey: privateKey) { data, error, status in
            if let data = data as? CategoryModel{
                self.listData = data
                if self.listData.media.count != 0{
                    DispatchQueue.main.async {
                        self.clv.reloadData()
                        self.checkAPIVideo = true
                        self.viewLoading.stopAnimating()
                        self.clv.isHidden = false
                    }
                }
            }
        }
    }
    
    func getVideoMore(page: Int){
        APIService.shared.getVideoLoadMore(page: page, privateKey: privateKey) { (data, error) in
            if let data = data as? [MediaModel]{
                self.listData.media += data
                if data.count == 0 {
                    self.checkLoadMore = false
                } else {
                    DispatchQueue.main.async {
                        self.clv.reloadData()
                    }
                }
            }
        }
    }
    private let refreshControl = UIRefreshControl()
    fileprivate var isRefresh = false
    func setupPulltoRefresh(){
        refreshControl.tintColor = #colorLiteral(red: 0.159235239, green: 0.2396469116, blue: 0.5891875029, alpha: 1)
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        self.clv.alwaysBounceVertical = true
        self.clv.refreshControl = refreshControl // iOS 10+
    }
    @objc
    private func didPullToRefresh(_ sender: Any) {
        checkLoadMore = true
        page = 0
        APIService.shared.getContentPlaylist(privateKey: listData.privateKey) { (data, error) in
            if let data = data as? CategoryModel{
                self.listData = data
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.clv.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    let viewLoading: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.color = #colorLiteral(red: 0.1618125439, green: 0.2373211086, blue: 0.588183701, alpha: 1)
        aiv.startAnimating()
        return aiv
    }()
    func startViewLoading(){
        self.view.addSubview(viewLoading)
        viewLoading.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        viewLoading.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.clv.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startViewLoading()
        setupPulltoRefresh()
        getData()
        clv.backgroundColor = .white
        clv.delegate = self
        clv.dataSource = self
        registerCell()
        let layout = UICollectionViewFlowLayout()
        clv.collectionViewLayout = layout

        NotificationCenter.default.addObserver(self, selector: #selector(scrollToTop(_ :)), name: NSNotification.Name("news.refresh"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showAdmob), name: NSNotification.Name("Admob.loaded"), object: nil)
        AdmobManager.shared.loadAllNativeAds()
    }
    
    var admobNativeAds: GADNativeAd?
    @objc func showAdmob(){
        if let native = AdmobManager.shared.getAdmobNativeAds(){
            admobNativeAds = native
            self.clv.reloadSections(IndexSet(integer: 3))
        }
    }
    
    @objc func scrollToTop(_ noti: Notification){
        self.clv.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    func registerCell(){
        clv.register(UINib(nibName: "CellSlideShow", bundle: nil), forCellWithReuseIdentifier: "CellSlideShow")
        clv.register(UINib(nibName: "CellNews", bundle: nil), forCellWithReuseIdentifier: "CellNews")
        clv.register(UINib(nibName: "CellPlaylistHorizol", bundle: nil), forCellWithReuseIdentifier: "CellPlaylistHorizol")
        clv.register(UINib(nibName: "CellTextHeaderSection", bundle: nil), forCellWithReuseIdentifier: "CellTextHeaderSection")
        clv.register(UINib(nibName: "CellNewsLarge", bundle: nil), forCellWithReuseIdentifier: "CellNewsLarge")
        clv.register(UINib(nibName: "CellLoading", bundle: nil), forCellWithReuseIdentifier: "CellLoading")
        
    }
    
}

extension PageVideo2VC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            print("")
        case 1:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewsDetailVC") as! NewsDetailVC
            vc.id = listData.media[indexPath.row + 6].id
            self.navigationController?.pushViewController(vc, animated: true)
        case 2:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewsDetailVC") as! NewsDetailVC
            vc.id = listData.media[indexPath.row + 8].id
            self.navigationController?.pushViewController(vc, animated: true)
        case 3:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewsDetailVC") as! NewsDetailVC
            vc.id = listData.media[16].id
            self.navigationController?.pushViewController(vc, animated: true)
        case 4 :
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewsDetailVC") as! NewsDetailVC
            vc.id = listData.media[indexPath.row + 17].id
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            print("")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: clv.bounds.width, height: scaleW * 350)
        } else if indexPath.section == 1 {
            return CGSize(width: (clv.bounds.width - 20 * scaleW)/2.01  , height: scaleW * 150)
        } else if indexPath.section == 2 {
            return CGSize(width: UIScreen.main.bounds.width, height: scaleW * 109)
        } else if indexPath.section == 3 {
            if let _ = admobNativeAds {
                return CGSize(width: clv.bounds.width, height: scaleW * (340 + 414))
            }
            return CGSize(width: clv.bounds.width, height: scaleW * 340)
        } else if indexPath.section == 4 {
            return CGSize(width: UIScreen.main.bounds.width, height: scaleW * 109)
        } else {
            return CGSize(width: UIScreen.main.bounds.width, height: scale * 50)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 1 {
            return UIEdgeInsets(top: 10 * scaleW, left: 20 * scaleW, bottom: 0, right: 0)
        }
        return UIEdgeInsets(top: 0, left: 0 , bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            if checkAPIVideo {
                return 1
            } else {
                return 0
            }
        } else if section == 1 {
            if checkAPIVideo {
                return 2
            } else {
                return 0
            }
        } else if section == 2 {
            return 8
        } else if section == 3 {
            return 1
        } else if section == 4 {
            return listData.media.count - 17
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = clv.dequeueReusableCell(withReuseIdentifier: "CellSlideShow", for: indexPath) as! CellSlideShow
            if listData.media.count != 0 {
                if listData.media.count > 6 {
                    var data = [MediaModel]()
                    for (index,item) in listData.media.enumerated(){
                        if index < 8 {
                            data.append(item)
                        }
                    }
                    cell.listData = data
                } else {
                    var data = [MediaModel]()
                    for (index,item) in listData.media.enumerated(){
                        if index < listData.media.count - 2 {
                            data.append(item)
                        }
                    }
                    cell.listData = data
                }
            }
            cell.delegate = self
            cell.line.isHidden = true
            return cell
        } else if indexPath.section == 1 {
            let cell = clv.dequeueReusableCell(withReuseIdentifier: "CellPlaylistHorizol", for: indexPath) as! CellPlaylistHorizol
            if checkAPIVideo {
                if listData.media.count != 0 {
                    if listData.media.count > 8 {
                        let item = listData.media[indexPath.row + 6]
                        if item.thumnail != ""{
                            if let url = URL(string: item.image[0].cdn + item.thumnail.replacingOccurrences(of: "\\", with: "/")){
                                cell.img.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "image_default"))
                            }
                        } else {
                            cell.img.image = #imageLiteral(resourceName: "image_default")
                        }
                        cell.lblTitle.text = item.name
                        let schedule = item.schedule
                        let timePass = publishedDate(schedule: schedule)
                        cell.lblTime.text = timePass
                    }
                } else {
                    cell.isHidden = true
                }
            }
            return cell
        } else if indexPath.section == 2 {
            let cell = clv.dequeueReusableCell(withReuseIdentifier: "CellNews", for: indexPath) as! CellNews
            if listData.media.count > 15{
                let item = listData.media[indexPath.row + 8]
                cell.delegate = self
                cell.isMedia = true
                cell.itemMedia = item
                cell.lblTitle.text = item.name
                if item.thumnail != ""{
                    
                    if let url = URL(string: item.image[0].cdn + item.thumnail.replacingOccurrences(of: "\\", with: "/")){
                        cell.img.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "image_default"))
                    }
                } else {
                    cell.img.image = #imageLiteral(resourceName: "image_default")
                }
                cell.lblCategory.text = (item.category == "") ? "VNEWS" : item.category
                let schedule = item.schedule
                let timePass = publishedDate(schedule: schedule)
                cell.lblPublished.text = timePass
                if indexPath.row == listTinDocNhieu.count - 1 {
                    cell.line.isHidden = true
                }
            }
            return cell
        } else if indexPath.section == 3 {
            let cell = clv.dequeueReusableCell(withReuseIdentifier: "CellNewsLarge", for: indexPath) as! CellNewsLarge
            if listData.media.count > 16{
                let item = listData.media[16]
                cell.delegate = self
                cell.item = item
                cell.lblTitle.text = item.name
                if item.thumnail != ""{
                    if let url = URL(string: item.image[0].cdn + item.thumnail.replacingOccurrences(of: "\\", with: "/")){
                        cell.img.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "image_default"))
                    }
                } else {
                    cell.img.image = #imageLiteral(resourceName: "image_default")
                }
                cell.lblCategory.text = (item.category == "") ? "VNEWS" : item.category
                let schedule = item.schedule
                let timePass = publishedDate(schedule: schedule)
                cell.lblTime.text = "•  \(timePass)"
                
                if let abmob = admobNativeAds {
                    cell.setupHeader(nativeAd: abmob)
                    cell.nativeAdView.isHidden = false
                }
            }
            cell.line.isHidden = true
            return cell
        } else if indexPath.section == 4 {
            let cell = clv.dequeueReusableCell(withReuseIdentifier: "CellNews", for: indexPath) as! CellNews
            if listData.media.count > 17{
                let item = listData.media[indexPath.row + 17]
                cell.delegate = self
                cell.isMedia = true
                cell.itemMedia = item
                cell.lblTitle.text = item.name
                cell.line.isHidden = false
                if item.thumnail != "" {
                    if let url = URL(string: item.image[0].cdn + item.thumnail.replacingOccurrences(of: "\\", with: "/")){
                        cell.img.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "image_default"))
                    }
                } else {
                    cell.img.image = #imageLiteral(resourceName: "image_default")
                }
                cell.lblCategory.text = (item.category == "") ? "VNEWS" : item.category
                let schedule = item.schedule
                let timePass = publishedDate(schedule: schedule)
                cell.lblPublished.text = timePass
            }
            return cell
        } else {
            let cell = clv.dequeueReusableCell(withReuseIdentifier: "CellLoading", for: indexPath) as! CellLoading
            cell.activitiIndicator.startAnimating()
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.section == 4 {
            if indexPath.row == listData.media.count - 20 {
                if checkLoadMore {
                    APIService.shared.getMoreTinMoi(page: page.description){ response, error in
                        if let listMedia = response as? [MediaModel]{
                            if listMedia.count == 0 {
                                self.checkLoadMore = false
                            } else {
                                self.page += 1
                                self.listData.media += listMedia
                                DispatchQueue.main.async {
                                    self.clv.reloadSections(IndexSet(integer: 4))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

extension PageVideo2VC: CellSlideShowDelegate, CellNewsDelegate, CellNewLargeDelegate{
    func didLike(_ index: Int) {
        let item = listData.media[index]
        APIService.shared.like(id: item.id, title: item.name) { _, _ in
            
        }
    }
    func didLike(_ cell: CellNews) {
        if cell.isMedia{
            APIService.shared.like(id: cell.itemMedia.id, title: cell.itemMedia.name) { _, _ in
                
            }
        } else {
            APIService.shared.like(id: cell.item.id, title: cell.item.title) { _, _ in
                
            }
        }
        
    }
    func didLike(_ cell: CellNewsLarge) {
        APIService.shared.like(id: cell.item.id, title: cell.item.name) { _, _ in
            
        }
    }
    func didShare(_ cell: CellNewsLarge) {
        var link = ""
        switch cell.item.contentType {
        case "0":
            link = domainShare + "video/" + cell.item.slug
        case "1", "6":
            link = domainShare + "news/" + cell.item.slug
        case "2":
            link = domainShare + "magazine/" + cell.item.slug
        case "3":
            link = domainShare + "inforgraphic/" + cell.item.slug
        case "4":
            link = domainShare + "longform/" + cell.item.slug
        case "5":
            link = domainShare + "live/" + cell.item.slug
        default:
            link = domainShare
        }
        //print(link)
        guard let url = URL(string: link) else {
            return
        }
        let itemsToShare = [url]
        let ac = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        ac.popoverPresentationController?.sourceView = self.view
        self.present(ac, animated: true)
        
        APIService.shared.reportShare(id: cell.item.id, title: cell.item.name) { _, _ in
            
        }
    }
    
    func didShare(_ cell: CellNews) {
        var link = ""
        if cell.isMedia{
            switch cell.itemMedia.contentType {
            case "0":
                link = domainShare + "video/" + cell.itemMedia.slug
            case "1", "6":
                link = domainShare + "news/" + cell.itemMedia.slug
            case "2":
                link = domainShare + "magazine/" + cell.itemMedia.slug
            case "3":
                link = domainShare + "inforgraphic/" + cell.itemMedia.slug
            case "4":
                link = domainShare + "longform/" + cell.itemMedia.slug
            case "5":
                link = domainShare + "live/" + cell.itemMedia.slug
            default:
                link = domainShare
            }
            APIService.shared.reportShare(id: cell.itemMedia.id, title: cell.itemMedia.name) { _, _ in
                
            }
        } else {
            switch cell.item.contentType {
            case "0":
                link = domainShare + "video/" + cell.item.slug
            case "1", "6":
                link = domainShare + "news/" + cell.item.slug
            case "2":
                link = domainShare + "magazine/" + cell.item.slug
            case "3":
                link = domainShare + "inforgraphic/" + cell.item.slug
            case "4":
                link = domainShare + "longform/" + cell.item.slug
            case "5":
                link = domainShare + "live/" + cell.item.slug
            default:
                link = domainShare
            }
            APIService.shared.reportShare(id: cell.item.id, title: cell.item.title) { _, _ in
                
            }
        }
        
        //print(link)
        guard let url = URL(string: link) else {
            return
        }
        let itemsToShare = [url]
        let ac = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        ac.popoverPresentationController?.sourceView = self.view
        self.present(ac, animated: true)
    }
    
    func didShare(_ index: Int) {
        let item = listData.media[index]
        var link = ""
        switch item.contentType {
        case "0":
            link = domainShare + "video/" + item.slug
        case "1", "6":
            link = domainShare + "news/" + item.slug
        case "2":
            link = domainShare + "magazine/" + item.slug
        case "3":
            link = domainShare + "inforgraphic/" + item.slug
        case "4":
            link = domainShare + "longform/" + item.slug
        case "5":
            link = domainShare + "live/" + item.slug
        default:
            link = domainShare
        }
        //print(link)
        guard let url = URL(string: link) else {
            return
        }
        let itemsToShare = [url]
        let ac = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        ac.popoverPresentationController?.sourceView = self.view
        self.present(ac, animated: true)
        
        APIService.shared.reportShare(id: item.id, title: item.name) { _, _ in
            
        }
    }
    
    func didSelectItemSlideShow(index: Int) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewsDetailVC") as! NewsDetailVC
        vc.id = listData.media[index].id.description
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
