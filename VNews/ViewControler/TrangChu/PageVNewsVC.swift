//
//  PageVNewsVC.swift
//  VNews
//
//  Created by dovietduy on 6/15/21.
//

import UIKit
import XLPagerTabStrip
import AVFoundation
import GoogleMobileAds

class PageVNewsVC: UIViewController, IndicatorInfoProvider {
    fileprivate let refreshControl = UIRefreshControl()
    fileprivate var svn = [ChildModel]()
    fileprivate var listLongForm = [ModelListNews]()
    fileprivate var ttxtc = [ChildModel]()
    fileprivate var listInfoGraphics = [ModelListNews]()
    fileprivate var home3Tin: CategoryModel!
    fileprivate var rowHeights = [CGFloat](repeating: 0.0, count: 9)
    fileprivate var count = 0
    fileprivate var homeCate = CategoryModel()
    var admobNativeAds: GADNativeAd?
    //
    fileprivate var sectionNews = -1
    fileprivate var sectionTTXVN = -1
    //
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.color = #colorLiteral(red: 0.159235239, green: 0.2396469116, blue: 0.5891875029, alpha: 1)
        aiv.startAnimating()
        return aiv
    }()
    
    //
    
    //
    func getSvn(){
        APIService.shared.getSVN { (data, error) in
            if let data = data as? [ChildModel]{
                self.svn = data
            }
        }
    }
    func getTtxtc(){
        APIService.shared.getTTXTC { (data, error) in
            if let data = data as? [ChildModel] {
                self.ttxtc = data
            }
        }
    }
    func setupPulltoRefresh(){
        refreshControl.tintColor = #colorLiteral(red: 0.159235239, green: 0.2396469116, blue: 0.5891875029, alpha: 1)
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        self.tblView.alwaysBounceVertical = true
        self.tblView.refreshControl = refreshControl // iOS 10+
    }
    var listNewsHome = [ModelListNews]()
    var checkListNewHome = false

    @objc private func didPullToRefresh(_ sender: Any) {
        count = 0
        homeCate = CategoryModel()
        homeScreen = []
        loadData()
    }
    func loadData(){
        APIService.shared.getHomeScreen { data, error in
            if error != nil {
                return
            }
            if let data = data as? CategoryModel {
                self.homeCate = data
                self.loadComponents()
            }
        }
    }
    func loadComponents(){
        if count < homeCate.components.count {
            let item = homeCate.components[count]
            APIService.shared.getHomeComponent(url: item.url, type: item.layout.type) {[self] data, error in
                if error != nil {
                    return
                }
                if let data = data{
                    homeScreen.append(data)
                    self.count += 1
                    if homeScreen.count == self.homeCate.components.count {
                        self.setHeight()
                        self.refreshControl.endRefreshing()
                        self.tblView.reloadData()
                        if let native = AdmobManager.shared.getAdmobNativeAds(){
                            admobNativeAds = native
                            tblView.reloadSections(IndexSet(integer: sectionNews), with: .automatic)
                        }
                    } else {
                        self.loadComponents()
                    }
                }
            }
        }
    }
    var count1 = 0
    func setHeight(){
        let data = (homeScreen[0] as! CategoryModel)
        for index in 0...8{
            let item = data.media[index]
            let img = UIImageView()
            if item.thumnail != "" {
                if let url = URL(string: item.image[0].cdn + item.thumnail.replacingOccurrences(of: "\\", with: "/" )){
                    img.kf.setImage(with: url){ [self]_ in
                        img.contentMode = .scaleAspectFill
                        img.clipsToBounds = true
                        let image = img.image ?? #imageLiteral(resourceName: "image_default")
                        img.image = image.resizeTopAlignedToFill(newWidth: 375 * scaleW)
                        images[index] = img
                        self.rowHeights[index] = (img.image?.size.height ?? 100) + 55 * scaleW
                        self.count1 += 1
                        if self.count1 == 9 {
                            tblView.reloadData()
                            tblView.isHidden = false
                            activityIndicatorView.stopAnimating()
                        }
                    }
                }
            } else {
                img.contentMode = .scaleAspectFill
                img.clipsToBounds = true
                let image = #imageLiteral(resourceName: "image_default")
                img.image = image.resizeTopAlignedToFill(newWidth: 375 * scaleW)
                images[index] = img
                self.rowHeights[index] = (img.image?.size.height ?? 100) + 55 * scaleW
                self.count1 += 1
                if self.count1 == 9 {
                    tblView.reloadData()
                    tblView.isHidden = false
                    activityIndicatorView.stopAnimating()
                }
            }
            
        }
    }
    var images = [UIImageView](repeating: UIImageView(), count: 9)
    var name:String = ""

    var isPlaying = false
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: name)
    }
    
    @IBOutlet weak var tblView: UITableView!
    
    var beforeIndexPath = IndexPath(row: -1, section: 0)
    var indexVideo = IndexPath(row: -1, section: 0)
    var isAutoNextVideo = false
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPulltoRefresh()
        getSvn()
        getTtxtc()
        setHeight()
        tblView.delegate = self
        tblView.dataSource = self
        tblView.register(UINib(nibName: Home2Cell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: Home2Cell.reuseIdentifier)
        tblView.register(UINib(nibName: SlideShowCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: SlideShowCell.reuseIdentifier)
        tblView.register(UINib(nibName: SlideShow3Cell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: SlideShow3Cell.reuseIdentifier)
        tblView.register(UINib(nibName: WeatherCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: WeatherCell.reuseIdentifier)
        tblView.register(UINib(nibName: ManyReadCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: ManyReadCell.reuseIdentifier)
        tblView.register(UINib(nibName: PlaylistCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: PlaylistCell.reuseIdentifier)
        tblView.register(UINib(nibName: NativeAdsCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: NativeAdsCell.reuseIdentifier)
        view.addSubview(activityIndicatorView)
        activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        //
        NotificationCenter.default.addObserver(self, selector: #selector(scrollToTop(_:)), name: NSNotification.Name("scrollView.scrollToTop"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopVOD(_:)), name: NSNotification.Name("vod.stop"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showAdmob), name: NSNotification.Name("Admob.loaded"), object: nil)

        //AdmobManager.shared.loadAdmobNativeAds()
        AdmobManager.shared.loadAdmobNativeAds()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func showAdmob(){
        if let native = AdmobManager.shared.getAdmobNativeAds(){
            admobNativeAds = native
            tblView.reloadSections(IndexSet(integer: sectionNews), with: .automatic)
//                tblView.reloadSections(IndexSet(integer: sectionTTXVN), with: .automatic)
            
            //tblView.reloadRows(at: [ IndexPath(row: 0, section: sectionNews)], with: .automatic)
        }
    }
    
    @objc func scrollToTop(_ notification: Notification){
        tblView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default
            .post(name: NSNotification.Name("pauseVideo"),
                  object: nil)
    }
    @objc func stopVOD(_ sender: Any){
        if let ceLL = cellForRowAt(indexPath: beforeIndexPath) {
            ceLL.isPlaying = false
            ceLL.viewPlayer.player?.pause()
            ceLL.isFirstTap = false
            ceLL.img.isHidden = false
            ceLL.hidePlayerController()
            ceLL.imgShadow.isHidden = false
            ceLL.lblTitle.isHidden = false
            ceLL.imgIconPlay.isHidden = false
            ceLL.report()
        }
    }
}
extension PageVNewsVC: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section < homeScreen.count else {
            return 0
        }
        let item = homeScreen[section]
        var type: Type = .news
        if item is CategoryModel {
            if let temp = Type(rawValue: (item as! CategoryModel).layout.type) {
                type = temp
            }
        } else if item is [WeatherModel]{
            type = .weather
        }
        
        switch type {
        case .video:
            return 9
        case .news:
            return 1
        case .weather:
            return 1
        case .infoLongForm:
            return 1
        case .horizontal:
            return 1
        case .slider:
            return 1
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.section < homeScreen.count else {return 0}
        let item = homeScreen[indexPath.section]
        var type: Type = .news
        if item is CategoryModel {
            if let temp = Type(rawValue: (item as! CategoryModel).layout.type) {
                type = temp
            }
        } else if item is [WeatherModel]{
            type = .weather
        }
        
        switch type {
        case .video:
            return UITableView.automaticDimension
        case .news:
            sectionNews = indexPath.section
            if self.admobNativeAds != nil {
                return scaleW * CGFloat((110 * 6)) + scaleW * 30 + 400 * scaleW
            }
            return scaleW * CGFloat((110 * 6)) + scaleW * 15
        case .weather:
            return scaleW * 263 + scaleW * 15
        case .infoLongForm:
            return scaleW * 610 + scaleW * 15
        case .horizontal:
            return scaleW * (52 + 131 + 20) + scaleW * 15
        case .slider:
            if item is CategoryModel {
                if self.admobNativeAds != nil, (item as! CategoryModel).name.contains("TTXVN") {
                    sectionTTXVN = indexPath.section
                    return scaleW * 300 + scaleW * 30 + 400 * scaleW
                } else {
                    return scaleW * 300 + scaleW * 15
                }
            }
            
            return scaleW * 300 + scaleW * 15
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return homeScreen.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.section < homeScreen.count else {
            let cell = tableView.dequeueReusableCell(withIdentifier: NativeAdsCell.reuseIdentifier, for: indexPath) as! NativeAdsCell
            return cell
        }
        let data = homeScreen[indexPath.section]
        var type: Type = .news
        if data is CategoryModel {
            if let temp = Type(rawValue: (data as! CategoryModel).layout.type) {
                type = temp
            }
        } else if data is [WeatherModel]{
            type = .weather
        }
        switch type {
        case .video:
            let cell = tableView.dequeueReusableCell(withIdentifier: Home2Cell.reuseIdentifier) as! Home2Cell
            let item = (data as! CategoryModel).media[indexPath.row]
            cell.img2.image = images[indexPath.row].image
            cell.img.image = images[indexPath.row].image
            cell.lblTitle.text = item.name.trimmingCharacters(in: .whitespacesAndNewlines)
            cell.lblPublished.text = item.getTimePass()
            cell.lblCategory.text = (item.category == "") ? "VNEWS" : item.category
            //print(item.category)
            cell.delegate = self
            cell.item = item
            cell.indexPath = indexPath
            cell.setup()
            cell.isSetup = true
            return cell
        case .news:
            let cell = tableView.dequeueReusableCell(withIdentifier: ManyReadCell.reuseIdentifier, for: indexPath) as! ManyReadCell
            cell.delegate = self
            let item = (data as! CategoryModel).media
//            if let native = self.admobNativeAds {
//                cell.setupHeader(nativeAd: native)
//                cell.topCollView.constant = 430 * scaleW
//            } else {
//                cell.topCollView.constant = 0
//            }
            if item.count != 0 {
                cell.listData = item
            }
            
            if let native = self.admobNativeAds {
                cell.setupHeader(nativeAd: native)
                cell.topCollView.constant = 415 * scaleW
            } else {
                cell.topCollView.constant = 0
            }
            
            return cell
        case .weather:
            let cell = tableView.dequeueReusableCell(withIdentifier: WeatherCell.reuseIdentifier, for: indexPath) as! WeatherCell
            let item = (data as! [WeatherModel])
            cell.listW = item
            return cell
        case .infoLongForm:
            let cell = tableView.dequeueReusableCell(withIdentifier: SlideShow3Cell.reuseIdentifier, for: indexPath) as! SlideShow3Cell
            let item = (data as! CategoryModel)
            cell.delegate = self
            cell.lblNamePlaylist.text = item.name
            cell.data = item
            return cell
        case .horizontal:
            let cell = tableView.dequeueReusableCell(withIdentifier: PlaylistCell.reuseIdentifier, for: indexPath) as! PlaylistCell
            cell.delegate = self
            let item = (data as! CategoryModel)
            cell.lblTitle.text = item.name
            cell.data = item
            return cell
        case .slider:
            let cell = tableView.dequeueReusableCell(withIdentifier: SlideShowCell.reuseIdentifier, for: indexPath) as! SlideShowCell
            let data = (data as! CategoryModel)
            cell.delegate = self
            if data.name.contains("TTXVN") {
                if let native = self.admobNativeAds {
                    cell.setupHeader(nativeAd: native)
                    cell.topCollView.constant = 415 * scaleW
                } else {
                    cell.topCollView.constant = 0
                }
            } else {
                cell.topCollView.constant = 0
            }
            cell.lblNamePlaylist.text = data.name
            cell.data = data
            cell.indexPath = IndexPath(row: 0, section: 5)
            return cell
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var isHaving = false

        for cell in tblView.visibleCells{
            let id = tblView.indexPath(for: cell)
            if id == beforeIndexPath {
                isHaving = true
            }
        }
        if isHaving == false && isPlaying == true{
            if let ceLL = cellForRowAt(indexPath: beforeIndexPath) {
                ceLL.isPlaying = false
                ceLL.viewPlayer.player?.pause()
                ceLL.isFirstTap = false
                ceLL.img.isHidden = false
                ceLL.hidePlayerController()
                ceLL.imgShadow.isHidden = false
                ceLL.lblTitle.isHidden = false
                ceLL.imgIconPlay.isHidden = false
                isPlaying = false
                ceLL.report()
            }
        }
        if isAutoNextVideo == true {
            isAutoNextVideo = false
            beforeIndexPath = indexVideo
        }
    }
}
extension PageVNewsVC: Home2CellDelegate{
    func didLike(_ cell: CellNews) {
        if cell.isMedia {
            APIService.shared.like(id: cell.itemMedia.id, title: cell.itemMedia.name) { _, _ in
                 
            }
        } else {
            APIService.shared.like(id: cell.item.id, title: cell.item.title) { _, _ in
                 
            }
        }
    }
    func didLike(_ cell: Home2Cell) {
        APIService.shared.like(id: cell.item.id, title: cell.item.name) { _, _ in
             
        }
    }
    func didShare(_ cell: Home2Cell) {
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
    
    func didFinish() {
        indexVideo = beforeIndexPath
        if indexVideo.row < 8{
            indexVideo.row += 1
            tblView.selectRow(at: indexVideo, animated: true, scrollPosition: .middle)
            if let ceLL = cellForRowAt(indexPath: indexVideo) {
                ceLL.isPlaying = true
                isPlaying = true
                ceLL.viewPlayer.player?.play()
                ceLL.reportStart = Date()
                ceLL.isFirstTap = true
                ceLL.img.isHidden = true
                ceLL.hidePlayerController()
                ceLL.imgShadow.isHidden = true
                ceLL.lblTitle.isHidden = true
                ceLL.imgIconPlay.isHidden = true
                ceLL.btnPlay.setBackgroundImage(#imageLiteral(resourceName: "ic_play"), for: .normal)
            }
            isAutoNextVideo = true
        }
        if let ceLL = cellForRowAt(indexPath: beforeIndexPath) {
            ceLL.isPlaying = false
            ceLL.viewPlayer.player?.pause()
            ceLL.isFirstTap = false
            ceLL.img.isHidden = false
            ceLL.hidePlayerController()
            ceLL.imgShadow.isHidden = false
            ceLL.lblTitle.isHidden = false
            ceLL.imgIconPlay.isHidden = false
            ceLL.btnPlay.setBackgroundImage(#imageLiteral(resourceName: "ic_pause"), for: .normal)
            ceLL.report()
        }
    }
    func didSelectViewSetting(_ cell: Home2Cell) {
        let vc = storyboard?.instantiateViewController(withIdentifier: PopUp3Controller.className) as! PopUp3Controller
        vc.listResolution = cell.listResolution
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false, completion: nil)
        vc.onComplete = { list in
            cell.listResolution = list
            cell.setBitRate()
        }
    }
    
    func didSelectViewFullScreen(_ cell: Home2Cell, _ newPlayer: AVPlayer) {
        if #available(iOS 13.0, *) {
            let vc = storyboard?.instantiateViewController(withIdentifier: FullScreenController.className) as! FullScreenController
            vc.player = newPlayer
            vc.listResolution = cell.listResolution
            vc.onDismiss = { () in
                cell.viewPlayer.player = vc.viewPlayer.player
                vc.player.replaceCurrentItem(with: nil)
                cell.btnPlay.setBackgroundImage(#imageLiteral(resourceName: "ic_play"), for: .normal)
                cell.isPlaying = true
                cell.viewPlayer.player?.play()
                cell.img.isHidden = true
                cell.hidePlayerController()
                cell.lblTitle.isHidden = true
                cell.imgIconPlay.isHidden = true
            }
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
        } else {
            let vc = PlayerViewController()
            vc.player = newPlayer
            vc.videoGravity = .resizeAspect
            vc.onDismiss = { () in
                cell.viewPlayer.player = vc.player
                vc.player!.replaceCurrentItem(with: nil)
                cell.viewPlayer.player?.play()
                cell.isPlaying = true
                cell.btnPlay.setBackgroundImage(#imageLiteral(resourceName: "ic_play"), for: .normal)
            }
            present(vc, animated: true) {
                vc.player?.play()
                vc.addObserver(self, forKeyPath: #keyPath(UIViewController.view.frame), options: [.old, .new], context: nil)
            }
        }
    }
    
    func didSelectViewPlayer(_ cell: Home2Cell) {
        tblView.scrollToRow(at: cell.indexPath, at: .middle, animated: true)
        if cell.indexPath != beforeIndexPath {
            if let ceLL = cellForRowAt(indexPath: beforeIndexPath) {
                ceLL.isPlaying = false
                ceLL.viewPlayer.player?.pause()
                ceLL.isFirstTap = false
                ceLL.img.isHidden = false
                ceLL.hidePlayerController()
                ceLL.imgShadow.isHidden = false
                ceLL.lblTitle.isHidden = false
                ceLL.imgIconPlay.isHidden = false
                ceLL.report()
            }
            
        } else{
            
        }
        beforeIndexPath = cell.indexPath
        isPlaying = true
    }
    func cellForRowAt(indexPath: IndexPath) -> Home2Cell? {
        guard let cell = tblView.cellForRow(at: indexPath) as? Home2Cell else {
            return tblView.dequeueReusableCell(withIdentifier: Home2Cell.className) as? Home2Cell
        }
        return cell
    }
}
extension PageVNewsVC: PlaylistCellDelegate{
    func didSelectItemAt(_ data: CategoryModel, _ indexPath: IndexPath) {
        if data.media.count != 0 {
            let vc = storyboard?.instantiateViewController(withIdentifier: VideoDetailVC.className) as! VideoDetailVC
            vc.listData = data.media
            vc.data = data.media[indexPath.row]
//            vc.index = indexPath.row
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
        }
    }
}
extension PageVNewsVC: ManyReadCellDelegate{
    func didShare(_ cell: CellNews) {
        var link = ""
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
        //print(link)
        guard let url = URL(string: link) else {
            return
        }
        let itemsToShare = [url]
        let ac = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        ac.popoverPresentationController?.sourceView = self.view
        self.present(ac, animated: true)
        
        APIService.shared.reportShare(id: cell.itemMedia.id, title: cell.itemMedia.name) { _, _ in
            
        }
    }
    
    func didSelectItemAt(_ data: [MediaModel], _ indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewsDetailVC") as! NewsDetailVC
        vc.id = data[indexPath.row].id
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension PageVNewsVC: SlideShow3CellDelegate{
    func didSelectItemSlideShow(data: MediaModel) {
        pushToNewsDetail(data: data)
    }
    func didSelectFirst(data: MediaModel) {
        pushToNewsDetail(data: data)
    }
    func pushToNewsDetail(data: MediaModel){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewsDetailVC") as! NewsDetailVC
        vc.id = data.id
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension PageVNewsVC: SlideShowCellDelegate{
    func slideShowDetail(data: [MediaModel], index: Int){
        let vc = storyboard?.instantiateViewController(withIdentifier: VideoDetailVC.className) as! VideoDetailVC
        vc.listData = data
        vc.data = data[index]
//        vc.index = index
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    func clickFirstSlideShow(index: Int, data: [MediaModel]) {
        slideShowDetail(data: data, index: index)
    }
    
    func didSelectItemSlideShow(index: Int, data: [MediaModel]) {
        slideShowDetail(data: data, index: index)
    }
    
    func didSelectViewHeader(_ cell: SlideShowCell) {
        let vc = storyboard?.instantiateViewController(withIdentifier: ChildVC.className) as! ChildVC
        if cell.data.name.contains("TTXVN") {
            if ttxtc.count != 0 {
                vc.data = ttxtc
                vc.name = cell.data.name
                navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = NotFoundVC(nibName: "NotFoundVC", bundle: nil)
                self.present(vc, animated: true, completion: nil)
            }
        } else if cell.data.name.contains("S Việt Nam") {
            if svn.count != 0 {
                vc.data = svn
                vc.name = cell.data.name
                navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = NotFoundVC(nibName: "NotFoundVC", bundle: nil)
                self.present(vc, animated: true, completion: nil)
            }
        } else{
            if cell.data.media.count != 0 {
                let vc = storyboard?.instantiateViewController(withIdentifier: VideoDetailVC.className) as! VideoDetailVC
                vc.listData = cell.data.media
                vc.data = cell.data.media[cell.indexPath.row]
//                vc.index = cell.indexPath.row
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true, completion: nil)
            }
        }
    }
}
enum Type: String {
    case video = "1"
    case news = "2"
    case weather = "3"
    case infoLongForm = "4"
    case horizontal = "5"
    case slider = "6"
}
