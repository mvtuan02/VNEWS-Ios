//
//  PageVideoVC.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 5/13/21.
//

import UIKit
import XLPagerTabStrip
import ImageSlideshow
import AVFoundation
import GoogleMobileAds
class PageVideoVC: UIViewController, IndicatorInfoProvider {
    @IBOutlet weak var lblTitleVideo: UILabel!
    private let refreshControl = UIRefreshControl()
    func setupPulltoRefresh(){
        refreshControl.tintColor = #colorLiteral(red: 0.2666666667, green: 0.2666666667, blue: 0.2666666667, alpha: 1)
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        self.tbl.alwaysBounceVertical = true
        self.tbl.refreshControl = refreshControl // iOS 10+
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
                self.tbl.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
        
        
    }
    
    
    @IBOutlet weak var tbl: UITableView!
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.color = #colorLiteral(red: 0.1618125439, green: 0.2373211086, blue: 0.588183701, alpha: 1)
        aiv.startAnimating()
        return aiv
    }()
    //slideshow
    
    
    
    var name:String = ""
    var privateKey:String = ""{
        didSet{
            //            print("privateKey: \(privateKey)")
        }
    }
    var listData = CategoryModel()
    var listRelated: [MediaModel] = []
    var isPushByHome = false
    var page = 0
    var checkLoadMore = true
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: name)
    }
    
    var kingfisherSource:[KingfisherSource] = []
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }

    func getVideoMore(page: Int){
        APIService.shared.getVideoLoadMore(page: page, privateKey: privateKey) { (data, error) in
            if let data = data as? [MediaModel]{
                self.listData.media += data
                if data.count == 0 {
                    self.checkLoadMore = false
                } else {
                    DispatchQueue.main.async {
                        self.tbl.reloadData()
                    }
                }
            }
        }
    }
    func setUpTbl(){
        tbl.delegate = self
        tbl.dataSource = self
        tbl.register(UINib(nibName: "CellVideoTbl", bundle: nil), forCellReuseIdentifier: "CellVideoTbl")
        tbl.register(UINib(nibName: "CellVideoRelated", bundle: nil), forCellReuseIdentifier: "CellVideoRelated")
        tbl.register(UINib(nibName: "CellLoadingTbl", bundle: nil), forCellReuseIdentifier: "CellLoadingTbl")
        tbl.estimatedRowHeight = 60 * scaleW
    }
    
    func startViewLoading(){
        //viewLoading.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        //viewLoading.startAnimating()
        self.tbl.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        tbl.backgroundColor = .white
        setUpTbl()
        setupPulltoRefresh()
        startViewLoading()
        if isPushByHome, listData.media.count != 0{
            activityIndicatorView.stopAnimating()
            tbl.isHidden = false
        } else{
            getData()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(scrollToTop(_:)), name: NSNotification.Name("video.refresh"), object: nil)
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    @objc func scrollToTop(_ noti: Notification){
        tbl.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    func getData(){
        APIService.shared.getPlaylistForApp(privateKey: privateKey) { data, error, status in
            if let data = data as? CategoryModel{
                self.listData = data
                if self.listData.media.count != 0{
                    DispatchQueue.main.async {
                        self.tbl.reloadData()
                        self.activityIndicatorView.stopAnimating()
                        self.tbl.isHidden = false
                    }
                }
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
}

extension PageVideoVC: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.media.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellVideoTbl", for: indexPath) as! CellVideoTbl
        let item = listData.media[indexPath.row]
        if item.thumnail != "" {
            if let url = URL(string: item.image[0].cdn + item.thumnail.replacingOccurrences(of: "\\", with: "/" )){
                cell.img.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "image_default"))
            }
        } else {
            cell.img.kf.setImage(with: URL(string: "https://static.mediacdn.vn/vnews/web_images/image_default.png"))
        }
        cell.item = item
        cell.lblCategory.text = (item.category == "") ? "VNEWS" : item.category
        cell.lblTime.text = item.getTimePass()
        cell.lblTitle.text = item.name
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == listData.media.count - 2 {
            if checkLoadMore {
                page = page + 1
                getVideoMore(page: page)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if listData.media[indexPath.row].contentType == "0"{
            let vc = storyboard?.instantiateViewController(withIdentifier: VideoDetailVC.className) as! VideoDetailVC
            vc.listData = listData.media
            vc.data = listData.media[indexPath.row]
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
        } else {
            let vc = storyboard?.instantiateViewController(withIdentifier: "NewsDetailVC") as! NewsDetailVC
            vc.id = listData.media[indexPath.row].id
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
}

extension PageVideoVC: CellVideoTblDelegate {
    func didShare(_ cell: CellVideoTbl) {
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
    
    func didLike(_ cell: CellVideoTbl) {
        APIService.shared.like(id: cell.item.id, title: cell.item.name) { _, _ in
             
        }
    }
    
    
}
