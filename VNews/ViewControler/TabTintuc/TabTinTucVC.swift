//
//  TabTinTucVC.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 6/19/21.
//

import UIKit
import MarqueeLabel
import GoogleMobileAds

class TabTinTucVC: UIViewController {
    var listSlideShow = [MediaModel]()
    var listTinMoi = [MediaModel]()
    var listTinDocNhieu = [MostViewedModel]()
    var checkLoadMore = true
    var checkAPISlideshow = false
    @IBOutlet weak var clv: UICollectionView!
    @IBOutlet weak var lblTextMove: MarqueeLabel!
    @IBOutlet weak var viewTextMove: UIView!
    @IBOutlet weak var clickFacebook: UIView!
    @IBOutlet weak var clickYoutobe: UIView!
    @IBOutlet weak var clickTiktok: UIView!
    @IBOutlet weak var clickPhone: UIView!
    @IBOutlet weak var clickSearch: UIView!
    @IBOutlet weak var clickAccount: UIView!
    @IBOutlet weak var clickLogo: UIImageView!
    
    fileprivate var newsCate = CategoryModel()
    fileprivate var count = 0 {
        didSet {
            if count == 3 {
                viewLoading.stopAnimating()
                clv.reloadData()
                clv.isHidden = false
                if isRefresh {
                    refreshControl.endRefreshing()
                } else {
                    isRefresh = false
                }
            }
        }
    }
    func getTabNews(){
        count = 0
        APIService.shared.getTabNews { response, error in
            if let cate = response as? CategoryModel{
                self.newsCate = cate
                for component in cate.components {
                    switch component.layout.type{
                    case "0":
                        APIService.shared.getComponentListMostViewed(url: component.url) { response, error in
                            if let data = response as? [MostViewedModel] {
                                self.listTinDocNhieu = data
                                self.count += 1
                            }
                        }
                        break
                    case "1":
                        APIService.shared.getHomeComponent(url: component.url) { response, error in
                            if let data = response as? CategoryModel {
                                self.listSlideShow = data.media
                                self.checkAPISlideshow = true
                                self.count += 1
                            }
                        }
                    case "2":
                        APIService.shared.getComponentListMedia(url: component.url) { response, error in
                            if let data = response as? [MediaModel] {
                                self.listTinMoi = data
                                self.count += 1
                            }
                        }
                    default:
                        break
                    }
                }
            }
        }
    }

    var page = 0

    
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
        listTinMoi.removeAll()
        listTinDocNhieu.removeAll()
        listSlideShow.removeAll()
        isRefresh = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.getTabNews()
//            self.getTinDocNhieu {
//                self.refreshControl.endRefreshing()
//            }
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
        //viewLoading.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(viewLoading)
        viewLoading.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        viewLoading.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        //viewLoading.startAnimating()
        self.clv.isHidden = true
    }
    
    //let viewLoading:UIActivityIndicatorView = UIActivityIndicatorView()
    override func viewDidLoad() {
        super.viewDidLoad()
        startViewLoading()
        getTabNews()
        setupPulltoRefresh()
        getTextEvenHot()
        
        clv.backgroundColor = .white
        clv.delegate = self
        clv.dataSource = self
        registerCell()
        let layout = UICollectionViewFlowLayout()
        clv.collectionViewLayout = layout
        
        //open more app
        clickFacebook.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openFacbookApp)))
        clickYoutobe.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openYoutobeApp)))
        clickTiktok.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openTiktokApp)))
        clickPhone.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openPhoneCall)))
        clickSearch.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openViewSearch)))
        clickAccount.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openViewAccount)))
        clickLogo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToHomePage)))
        lblTextMove.font = UIFont(name: "OpenSans-Bold", size: 14 * scaleW)
        
        lblTextMove.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(moveDetail)))
        viewTextMove.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(moveDetail)))
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(scrollToTop(_ :)), name: NSNotification.Name("news.refresh"), object: nil)
        //
        NotificationCenter.default.addObserver(self, selector: #selector(showAdmob), name: NSNotification.Name("Admob.loaded"), object: nil)
        AdmobManager.shared.loadAdmobNativeAds()
    }
    
    var admobNativeAds: GADNativeAd?
    @objc func showAdmob(){
        if let native = AdmobManager.shared.getAdmobNativeAds(){
            admobNativeAds = native
            self.clv.reloadSections(IndexSet(integer: 4))
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
    
    @objc func moveDetail(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ListEventHot") as! ListEventHot
        vc.listData = self.listEvenHot
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    var listEvenHot = [ComponentModel]()
    
    func getTextEvenHot(){
        APIService.shared.getEvenhot { (response, error) in
            if let data = response as? CategoryModel{
                var text = ""
                //var textArray = [String]()
                for i in data.components{
                    self.listEvenHot.append(i)
                    text = text + "        " + i.name
                    //textArray.append("        " + i.name)
                }
                DispatchQueue.main.async {
                    self.lblTextMove.text = text
                }
            }
        }
    }
    
}

extension TabTinTucVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            print("")
        case 1:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewsDetailVC") as! NewsDetailVC
            var id = ""
            if listSlideShow.count > 8 {
                var data = [MediaModel]()
                for (index, item) in listSlideShow.enumerated() {
                    if index < 8 {
                        data.append(item)
                    }
                }
                id = data[(data.count - 2) + indexPath.row].id
            } else {
                id = listSlideShow[(listSlideShow.count - 2) + indexPath.row].id
            }
            vc.id = id
            self.navigationController?.pushViewController(vc, animated: true)
        case 2:
            print("")
        case 3:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewsDetailVC") as! NewsDetailVC
            vc.id = listTinDocNhieu[indexPath.row].id
            self.navigationController?.pushViewController(vc, animated: true)
        case 4:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewsDetailVC") as! NewsDetailVC
            vc.id = listTinMoi[indexPath.row].id
            self.navigationController?.pushViewController(vc, animated: true)
        case 5:
            print("")
        case 6 :
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewsDetailVC") as! NewsDetailVC
            vc.id = listTinMoi[indexPath.row+1].id
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
            let cell = clv.dequeueReusableCell(withReuseIdentifier: "CellTextHeaderSection", for: indexPath) as! CellTextHeaderSection
            return CGSize(width: clv.bounds.width, height: cell.lblTitle.bounds.height + 1 * (scaleW * 16))
        } else if indexPath.section == 3 {
            return CGSize(width: UIScreen.main.bounds.width, height: scaleW * 109)
        } else if indexPath.section == 4 {
            if let _ = admobNativeAds {
                return CGSize(width: clv.bounds.width, height: scaleW * (340 + 414))
            }
            return CGSize(width: clv.bounds.width, height: scaleW * 340)
        } else if indexPath.section == 5 {
            let cell = clv.dequeueReusableCell(withReuseIdentifier: "CellTextHeaderSection", for: indexPath) as! CellTextHeaderSection
            return CGSize(width: clv.bounds.width, height: cell.lblTitle.bounds.height + 1 * (scaleW * 16))
        } else if indexPath.section == 6 {
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
        } else if section == 2 {
            return UIEdgeInsets(top: scaleW * 20, left: 0, bottom: 0, right: 0)
        } else if section == 5 {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        return UIEdgeInsets(top: 0, left: 0 , bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            if checkAPISlideshow {
                return 1
            } else {
                return 0
            }
        } else if section == 1 {
            if checkAPISlideshow {
                return 2
            } else {
                return 0
            }
        } else if section == 2 {
            return 1
        } else if section == 3 {
            return listTinDocNhieu.count
        } else if section == 4 {
            return 1
        } else if section == 5 {
            return 1
        } else if section == 6 {
            return listTinMoi.count - 1
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = clv.dequeueReusableCell(withReuseIdentifier: "CellSlideShow", for: indexPath) as! CellSlideShow
            if listSlideShow.count != 0 {
                if listSlideShow.count > 8 {
                    var data = [MediaModel]()
                    for (index,item) in listSlideShow.enumerated(){
                        if index < 8 {
                            data.append(item)
                        }
                    }
                    cell.listData = data
                } else {
                    var data = [MediaModel]()
                    for (index,item) in listSlideShow.enumerated(){
                        if index < listSlideShow.count - 2 {
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
            if checkAPISlideshow {
                if listSlideShow.count != 0 {
                    if listSlideShow.count > 8 {
                        var data = [MediaModel]()
                        for (index, item) in listSlideShow.enumerated() {
                            if index < 8 {
                                data.append(item)
                            }
                        }
                        let item = data[(data.count - 2) - indexPath.row]
                        if item.thumnail != ""{
                            if let url = URL(string: item.image[0].cdn + item.thumnail.replacingOccurrences(of: "\\", with: "/")){
                                cell.img.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "image_default"))
                            }
                        } else {
                            cell.img.kf.setImage(with: URL(string: "https://static.mediacdn.vn/vnews/web_images/image_default.png"))
                        }
//                        cell.img.kf.setImage(with: URL(string: "https://media.vnews.gov.vn/images/upload/\(data[(data.count - 2) - indexPath.row].avatar)"), placeholder: #imageLiteral(resourceName: "image_default"))
                        cell.lblTitle.text = data[(data.count - 2) - indexPath.row].name
                        let schedule = data[(data.count - 2) - indexPath.row].schedule
                        let timePass = publishedDate(schedule: schedule)
                        cell.lblTime.text = timePass
                    } else {
                        let item = listSlideShow[ indexPath.row + (listSlideShow.count - 2)]
                        if item.thumnail != ""{
                            if let url = URL(string: item.image[0].cdn + item.thumnail.replacingOccurrences(of: "\\", with: "/")){
                                cell.img.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "image_default"))
                            }
                        } else {
                            cell.img.kf.setImage(with: URL(string: "https://static.mediacdn.vn/vnews/web_images/image_default.png"))
                        }
//                        cell.img.kf.setImage(with: URL(string: "https://media.vnews.gov.vn/images/upload/\(listSlideShow[ indexPath.row + (listSlideShow.count - 2)].avatar)"))
                        cell.lblTitle.text = listSlideShow[ indexPath.row + (listSlideShow.count - 2)].name
                        let schedule = listSlideShow[ indexPath.row + (listSlideShow.count - 2)].schedule
                        let timePass = publishedDate(schedule: schedule)
                        cell.lblTime.text = timePass
                    }
                }
            } else {
                cell.isHidden = true
            }
            return cell
        } else if indexPath.section == 2 {
            let cell = clv.dequeueReusableCell(withReuseIdentifier: "CellTextHeaderSection", for: indexPath) as! CellTextHeaderSection
            cell.lblTitle.text = "Tin đọc nhiều"
            return cell
        } else if indexPath.section == 3 {
            let cell = clv.dequeueReusableCell(withReuseIdentifier: "CellNews", for: indexPath) as! CellNews
            if listTinDocNhieu.count != 0 , indexPath.row < listTinDocNhieu.count{
                let item = listTinDocNhieu[indexPath.row]
                cell.delegate = self
                cell.item = item
                cell.lblTitle.text = item.title
                if item.image != ""{
                    if let url = URL(string: item.image){
                        cell.img.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "image_default"))
                    }
                } else {
                    cell.img.kf.setImage(with: URL(string: "https://static.mediacdn.vn/vnews/web_images/image_default.png"))
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
        } else if indexPath.section == 4 {
            let cell = clv.dequeueReusableCell(withReuseIdentifier: "CellNewsLarge", for: indexPath) as! CellNewsLarge
            if listTinMoi.count != 0 {
                let item = listTinMoi[indexPath.row]
                cell.delegate = self
                cell.item = item
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
                cell.lblTime.text = "•  \(timePass)"
                
                if let abmob = admobNativeAds {
                    cell.setupHeader(nativeAd: abmob)
                    cell.nativeAdView.isHidden = false
                }
            }
            cell.line.isHidden = true
            
            return cell
        } else if indexPath.section == 5 {
            let cell = clv.dequeueReusableCell(withReuseIdentifier: "CellTextHeaderSection", for: indexPath) as! CellTextHeaderSection
            cell.lblTitle.text = "Tin mới"
            return cell
        } else if indexPath.section == 6 {
            let cell = clv.dequeueReusableCell(withReuseIdentifier: "CellNews", for: indexPath) as! CellNews
            if listTinMoi.count != 0 {
                let item = listTinMoi[indexPath.row + 1]
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
                    cell.img.kf.setImage(with: URL(string: "https://static.mediacdn.vn/vnews/web_images/image_default.png"))
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
            if !checkLoadMore {
                cell.activitiIndicator.stopAnimating()
                cell.activitiIndicator.isHidden = true
                collectionView.deleteSections(NSIndexSet(index: 7) as IndexSet)
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.section == 6 {
            if indexPath.row == listTinMoi.count - 2 {
                if checkLoadMore {
                    
//                    getData(page: page)
                    APIService.shared.getMoreTinMoi(page: page.description){ response, error in
                        if let listMedia = response as? [MediaModel]{
                            if listMedia.count == 0 {
                                self.checkLoadMore = false
                            } else {
                                self.page += 1
                                self.listTinMoi += listMedia
                                DispatchQueue.main.async {
                                    self.clv.reloadSections(IndexSet(integer: 6))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
}

extension TabTinTucVC: CellSlideShowDelegate, CellNewsDelegate, CellNewLargeDelegate{
    func didLike(_ index: Int) {
        let item = listSlideShow[index]
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
        let item = listSlideShow[index]
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
        vc.id = listSlideShow[index].id.description
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
