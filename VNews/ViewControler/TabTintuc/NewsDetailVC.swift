//
//  NewsDetailVC.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 6/7/21.
//

import UIKit
import WebKit
import MarqueeLabel
import GoogleMobileAds
import AVFoundation
class NewsDetailVC: UIViewController, WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.heightWebview.constant = webView.scrollView.contentSize.height
        }
    }
    
    //
    @IBOutlet weak var top: NSLayoutConstraint!
    @IBOutlet weak var nativeAdView: GADNativeAdView!
    var admobNativeAds: GADNativeAd?
    @objc func showAdmob(){
        if let native = AdmobManager.shared.getAdmobNativeAds(){
            admobNativeAds = native
            nativeAdView.isHidden = false
            setupHeader(nativeAd: native)
            top.constant = 430 * scaleW
        }
    }
    func setupHeader(nativeAd: GADNativeAd) {
        nativeAdView.nativeAd = nativeAd
        //
        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
        
        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        nativeAdView.bodyView?.isHidden = nativeAd.body == nil

        (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction?.lowercased().capitalizingFirstLetter(), for: .normal)

        nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil
        nativeAdView.callToActionView?.isUserInteractionEnabled = false
        nativeAdView.callToActionView?.backgroundColor = #colorLiteral(red: 0.159235239, green: 0.2396469116, blue: 0.5891875029, alpha: 1)
        nativeAdView.callToActionView?.tintColor = .white
        (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        nativeAdView.iconView?.isHidden = nativeAd.icon == nil

        (nativeAdView.starRatingView as? UIImageView)?.image = imageOfStars(from: nativeAd.starRating)
        nativeAdView.starRatingView?.isHidden = nativeAd.starRating == nil

        (nativeAdView.storeView as? UILabel)?.text = nativeAd.store
        nativeAdView.storeView?.isHidden = nativeAd.store == nil

        (nativeAdView.priceView as? UILabel)?.text = nativeAd.price
        nativeAdView.priceView?.isHidden = nativeAd.price == nil

        (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
        nativeAdView.advertiserView?.isHidden = nativeAd.advertiser == nil
    }
    
    func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
      guard let rating = starRating?.doubleValue else {
        return nil
      }
      if rating >= 5 {
        return UIImage(named: "stars_5")
      } else if rating >= 4.5 {
        return UIImage(named: "stars_4_5")
      } else if rating >= 4 {
        return UIImage(named: "stars_4")
      } else if rating >= 3.5 {
        return UIImage(named: "stars_3_5")
      } else {
        return nil
      }
    }

    
    @IBOutlet weak var viewLblTinLienQuan: UIView!
    @IBOutlet weak var viewShare: UIView!
    @IBOutlet weak var viewLike: UIView!
    @IBOutlet weak var imgLike: UIImageView!
    @IBOutlet weak var heightLbl: NSLayoutConstraint!
    @IBOutlet weak var imgBack: UIImageView!
    @IBOutlet weak var heightWebview: NSLayoutConstraint!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblTIme: UILabel!
    @IBOutlet weak var lblTacgia: UILabel!
    @IBOutlet weak var imgHeart: UIImageView!
    @IBOutlet weak var lblCountHeart: UILabel!
    @IBOutlet weak var imgCmt: UIImageView!
    @IBOutlet weak var lblCountCmt: UILabel!
    @IBOutlet weak var imgShare: UIImageView!
    @IBOutlet weak var lblDes: UILabel!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var clvTinLienQuan: UICollectionView!
    @IBOutlet weak var heightClv: NSLayoutConstraint!
    @IBOutlet weak var clvTinLienQuan1: UICollectionView!
    @IBOutlet weak var heightClv1: NSLayoutConstraint!
    
    @IBOutlet weak var viewPlayer: PlayerView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var lblCurrentTime: UILabel!
    @IBOutlet weak var slider: CustomSlider!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var viewFullScreen: UIView!
    @IBOutlet weak var viewSetting: UIView!
    @IBOutlet weak var imgShadow: UIImageView!
    @IBOutlet weak var viewReplay: UIView!
    @IBOutlet weak var viewForward: UIView!
    
    @IBOutlet weak var imgHeader: UIImageView!
    var timeObserver: Any?
    lazy var isPlaying = false
    lazy var isEnded = false
    lazy var timer = Timer()
    lazy var listResolution: [StreamResolution] = []
    lazy var data = MediaModel()
    lazy var listRelated = [MediaModel]()
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        return aiv
    }()
    var id = ""{
        didSet{
            getData(id: id)
        }
    }
    
    var chitiettin = MediaModel()
    var listCungCM = [MediaModel]()
    
    let viewLoading:UIActivityIndicatorView = UIActivityIndicatorView()
    func startViewLoading(){
        viewLoading.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(viewLoading)
        viewLoading.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        viewLoading.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        viewLoading.startAnimating()
        self.scrollview.isHidden = true
        viewLoading.isHidden = false
    }
    private var reportStart: Date?
    private var reportEnd: Date?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reportStart = Date()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewPlayer.player?.pause()
        viewPlayer.player?.replaceCurrentItem(with: nil)
        NotificationCenter.default.removeObserver(self)
//        viewPlayer.player?.removeObserver(self, forKeyPath: "currentItem.loadedTimeRanges", context: nil)
//        viewPlayer.player?.removeObserver(self, forKeyPath: "timeControlStatus", context: nil)
        timer.invalidate()
        if let timeObserver = timeObserver {
            viewPlayer.player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        reportEnd = Date()
        let reportTime = reportEnd! - reportStart!
        let duration = reportTime.hour!.description.add0() + ":" + reportTime.minute!.description.add0() + ":" + reportTime.second!.description.add0()
        var link = ""
        switch chitiettin.contentType {
        case "0":
            link = domainShare + "video/" + chitiettin.slug
        case "1", "6":
            link = domainShare + "news/" + chitiettin.slug
        case "2":
            link = domainShare + "magazine/" + chitiettin.slug
        case "3":
            link = domainShare + "inforgraphic/" + chitiettin.slug
        case "4":
            link = domainShare + "longform/" + chitiettin.slug
        case "5":
            link = domainShare + "live/" + chitiettin.slug
        default:
            link = domainShare
        }
        APIService.shared.report(id: self.chitiettin.id, title: self.chitiettin.name, path: link, contentType: "article", duration: duration, device: device, network: network, location: "", ip: ip) { data, error in
            
        }
    }
    @objc func goBack() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBOutlet weak var scrollview: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        startViewLoading()
        
        heightWebview.constant = UIScreen.main.bounds.height
        webView.navigationDelegate = self
        webView.scrollView.isScrollEnabled = true

        imgBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goBack)))
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        let layout = UICollectionViewFlowLayout()
        clvTinLienQuan.collectionViewLayout = layout
        clvTinLienQuan.delegate = self
        clvTinLienQuan.dataSource = self
        clvTinLienQuan.register(UINib(nibName: "CellNews", bundle: nil), forCellWithReuseIdentifier: "CellNews")

        
        clvTinLienQuan1.delegate = self
        clvTinLienQuan1.dataSource = self
        clvTinLienQuan1.register(UINib(nibName: "CellNews", bundle: nil), forCellWithReuseIdentifier: "CellNews")
        let layout1 = UICollectionViewFlowLayout()
        clvTinLienQuan1.collectionViewLayout = layout1
        hidePlayerController()
        //
        slider.addTarget(self, action: #selector(sliderDidEndSliding), for: [.touchUpInside, .touchUpOutside])
        viewSetting.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectViewSetting(_:))))
        viewFullScreen.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectBtnFullScreen(_:))))
        viewPlayer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectViewPlayer(_:))))
        viewForward.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectBtnForward5s(_:))))
        viewReplay.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectBtnReplay5s(_:))))
        viewShare.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didShare1(_:))))
        viewLike.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(like)))
        viewPlayer.addSubview(activityIndicatorView)
        activityIndicatorView.centerXAnchor.constraint(equalTo: viewPlayer.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: viewPlayer.centerYAnchor).isActive = true
        lblTacgia.text = ""
        
       
    }
    @objc func like() {
        self.imgLike.image = #imageLiteral(resourceName: "icons8-facebook-like-64 (1)")
        APIService.shared.like(id: chitiettin.id, title: chitiettin.name) { _, _ in
             
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            // Fallback on earlier versions
            return .default
        }
    }
    @objc func didShare1(_ sender: Any) {
        let item = chitiettin
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
        
        APIService.shared.reportShare(id: chitiettin.id, title: chitiettin.name) { _, _ in
            
        }
    }
    
    func getData(id: String){
        //print(id)
        APIService.shared.getChitiettin(id: id) { (response, error) in
            if let data = response{
                self.chitiettin = data
                if data.related.count == 0 {
                    self.viewLblTinLienQuan.isHidden = true
                    self.heightLbl.constant = 0
                    self.heightClv1.constant = 0
                } else {
                    for item in self.chitiettin.related {
                        APIService.shared.getVideoRelated(privateKey: item.id) { data, error in
                            if let data = data as? MediaModel {
                                self.listRelated.append(data)
                                if self.listRelated.count == self.chitiettin.related.count {
                                    self.heightClv1.constant = CGFloat(self.chitiettin.related.count) * scaleW * 109
                                    self.clvTinLienQuan1.reloadData()
                                }
                            }
                        }
                    }
                    
                }
                APIService.shared.getContentPlaylist(privateKey: data.keyword) { (cate, error) in
                    if let cate = cate as? CategoryModel {
                        self.listCungCM = cate.media
                        self.heightClv.constant = CGFloat(self.listCungCM.count) * scaleW * 109
                        self.clvTinLienQuan.reloadData()
                    }
                }
                self.scrollview.isHidden = false
                self.viewLoading.isHidden = true
                
                if data.path != ""{
                    if Array(data.path)[data.path.count - 1] == "/" {
                        self.viewPlayer.isHidden = true
                    } else{
                        self.openVideoAudio()
                        if self.data.body == "" {
                            self.heightWebview.constant = 1.0
                        }
                    }
                } else {
                    self.viewPlayer.isHidden = true
                }
                if data.thumnail != ""{
                    if let url = URL(string: data.image[0].cdn + data.thumnail.replacingOccurrences(of: "\\", with: "/")){
                        self.imgHeader.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "image_default"))
                    }
                } else {
                    self.imgHeader.kf.setImage(with: URL(string: "https://static.mediacdn.vn/vnews/web_images/image_default.png"))
                }
                DispatchQueue.main.async {
                    //self.heightClv.constant = CGFloat(self.chitiettin.related.count) * scaleW * 109
                    //self.clvTinLienQuan.reloadData()
                    let schedule = self.chitiettin.schedule
                    let timePass = publishedDate(schedule: schedule)
                    self.lblTIme.text = timePass
                    self.lblTitle.text = self.chitiettin.name
                    self.lblDes.text = self.chitiettin.descripTion
                    self.lblCategory.text = (self.chitiettin.category == "") ? "VNEWS" : self.chitiettin.category
                    let html = """
                    <!DOCTYPE html>
                    <html lang="en">
                    <head>
                        <meta charset="UTF-8">
                        <meta http-equiv="X-UA-Compatible" content="IE=edge">
                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
                        <title>Document</title>
                    </head>
                    <body>

                        \(self.chitiettin.body)
                     <style>
                             body{
                                 padding-left:10px;
                                 padding-right:10px
                             }
                             .entry-body{
                                 font-size:14px;
                                 text-align: justify;
                             }
                             h3{
                                 font-size: 14px;
                             }
                             .VCSortableInPreviewMode div{
                                 position: relative;
                                margin-left: -10px; margin-right: -10px
                             }
                             p{
                                 text-align: justify;
                             }
                             .name-n-quote p{
                                 padding-left:10px;
                                 padding-right:10px
                             }
                             td p{
                                 padding-left:10px;
                                 padding-right:10px
                             }
                         </style>
                       
                        <script src="https://code.jquery.com/jquery-3.2.1.slim.min.js" integrity="sha384-KJ3o2DKtIkvYIK3UENzmM7KCkRr/rE9/Qpg6aAZGJwFDMVNA/GpGFF93hXpG5KkN" crossorigin="anonymous"></script>
                    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js" integrity="sha384-ApNbgh9B+Y1QKtv3Rn7W3mgPxhU9K/ScQsAP7hUibX39j7fakFPskvXusvfa0b4Q" crossorigin="anonymous"></script>
                    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js" integrity="sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl" crossorigin="anonymous"></script>
                    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
                    <script>
                        $(document).ready(function(){
                            $( "img" ).addClass( "img-fluid" );
                            });
                        
                    </script>
                    </body>
                    </html>
                    """
                    self.webView.loadHTMLString(html, baseURL: nil)
                }
            }
        }
    }
    @objc func didSelectBtnReplay5s(_ sender: Any) {
        let currentTime = CMTimeGetSeconds(viewPlayer.player!.currentTime())
        var newTime = currentTime - 5.0
        
        if newTime < 0 {
            newTime = 0
        }
        let time: CMTime = CMTimeMake(value: Int64(newTime * 1000), timescale: 1000)
        viewPlayer.player?.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    }
    @objc func didSelectBtnForward5s(_ sender: Any) {
        guard let duration = viewPlayer.player?.currentItem?.duration else { return }
        let currentTime = CMTimeGetSeconds(viewPlayer.player!.currentTime())
        let newTime = currentTime + 5.0
        
        if newTime < (CMTimeGetSeconds(duration) - 5.0) {
            let time: CMTime = CMTimeMake(value: Int64(newTime * 1000), timescale: 1000)
            viewPlayer.player?.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        }
    }
    var index = 0
    @objc func playerDidFinishPlaying(note: NSNotification){
        btnPlay.setBackgroundImage(#imageLiteral(resourceName: "ic_pause"), for: .normal)
        viewPlayer.player?.pause()
        isEnded = true
        isPlaying = false
        
    }
    var isTapping = false
    
    @objc func didSelectViewPlayer(_ sender: Any){
        if isTapping{
            hidePlayerController()
            timer.invalidate()
        } else{
            showPlayerController()
            timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false, block: {[weak self] timer in
                if self?.isSliderChanging == false{
                    self?.hidePlayerController()
                    self?.isTapping = false
                    timer.invalidate()
                }
                
            })
        }
        isTapping = !isTapping
    }
    var isSliderChanging = false
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        viewPlayer.player?.pause()
        isPlaying = false
        if let timeObserver = timeObserver {
            viewPlayer.player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        
        isSliderChanging = true
        isEnded = false
        viewPlayer.player?.seek(to: CMTimeMake(value: Int64(sender.value) * 1000, timescale: 1000), toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        guard let currentItem = self.viewPlayer.player?.currentItem, currentItem.duration >= CMTime.zero else {return}
        self.lblCurrentTime.text = self.getTimeString(from: currentItem.currentTime())
    }
    @objc func sliderDidEndSliding(){
        addTimeObserver()
        viewPlayer.player?.play()
        isPlaying = true
        isSliderChanging = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            if self.isSliderChanging == false{
                self.hidePlayerController()
            }
        }
    }
    @IBAction func didSelectBtnPlay(_ sender: Any) {
        if isPlaying{
            viewPlayer.player?.pause()
            btnPlay.setBackgroundImage(#imageLiteral(resourceName: "ic_pause"), for: .normal)
        } else{
            if isEnded{
                viewPlayer.player?.seek(to: CMTime.zero)
                isEnded = false
            }
            viewPlayer.player?.play()
            btnPlay.setBackgroundImage(#imageLiteral(resourceName: "ic_play"), for: .normal)
        }
        isPlaying = !isPlaying
    }
    func hidePlayerController(){
        self.imgShadow.isHidden = true
        self.viewFullScreen.isHidden = true
        self.viewSetting.isHidden = true
        self.lblCurrentTime.isHidden = true
        self.lblDuration.isHidden = true
        self.slider.isHidden = true
        self.btnPlay.isHidden = true
        self.viewReplay.isHidden = true
        self.viewForward.isHidden = true
    }
    func showPlayerController(){
        self.imgShadow.isHidden = false
        self.viewFullScreen.isHidden = false
        self.viewSetting.isHidden = false
        self.lblCurrentTime.isHidden = false
        self.lblDuration.isHidden = false
        self.slider.isHidden = false
        self.btnPlay.isHidden = false
        self.viewReplay.isHidden = false
        self.viewForward.isHidden = false
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "currentItem.loadedTimeRanges", viewPlayer != nil, let duration = viewPlayer.player?.currentItem?.duration.seconds, duration > 0.0{
            self.lblDuration.text = getTimeString(from: (viewPlayer.player?.currentItem!.duration)!)
            activityIndicatorView.stopAnimating()
        }
        if keyPath == "timeControlStatus"{
            if (viewPlayer.player?.timeControlStatus == .playing) {
                activityIndicatorView.stopAnimating()
                //player is playing
            }
            else if (viewPlayer.player?.timeControlStatus == .paused) {
                //player is pause
            }
            else if (viewPlayer.player?.timeControlStatus == .waitingToPlayAtSpecifiedRate) {
                //player is waiting to play
                activityIndicatorView.startAnimating()
                
            }
        }
    }
    func addTimeObserver(){
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let mainQueue = DispatchQueue.main
        timeObserver = viewPlayer.player?.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue, using: {[weak self] (time) in
            guard let currentItem = self?.viewPlayer.player?.currentItem, currentItem.duration >= CMTime.zero else {return}
            guard currentItem.status.rawValue == AVPlayerItem.Status.readyToPlay.rawValue else {return}
            self?.slider.maximumValue =  (Float(currentItem.duration.seconds) > 0) ? Float(currentItem.duration.seconds) : 0
            self?.slider.minimumValue = 0
            self?.slider.value = Float(currentItem.currentTime().seconds)
            self?.lblCurrentTime.text = self?.getTimeString(from: currentItem.currentTime())
            UserDefaults.standard.setValue(currentItem.currentTime().seconds, forKey: self!.chitiettin.id)
        })
    }
    func getTimeString(from time: CMTime) -> String{
        let totalSeconds = CMTimeGetSeconds(time)
        let hours = Int(totalSeconds / 3600)
        let minutes = Int(totalSeconds / 60) % 60
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        if hours > 0{
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else{
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    func openVideoAudio(){
        var link = ""
        if chitiettin.path != "" {
            link = chitiettin.path
            if Array(link)[link.count - 1] == "/" {
                link = chitiettin.fileCode
            }
        }else{
            link = chitiettin.fileCode
        }
        if link.contains("http") == false {
            link = "https://lsnk4ojchwvod.vcdn.cloud/" + link
        }
        if let url = URL(string: link){
            listResolution = []
            if link.contains("m3u8"){
                StreamHelper.shared.getPlaylist(from: url) { [weak self] (result) in
                    switch result {
                    case .success(let playlist):
                        self?.listResolution = StreamHelper.shared.getStreamResolutions(from: playlist)
                        let resol1 = StreamResolution(maxBandwidth: 0, averageBandwidth: 0, resolution: CGSize(width: 854.0, height: 480.0))
                        resol1.isTicked = true
                        self?.listResolution.insert(resol1, at: 0)
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .default, options: [])
            }
            catch {
                print("Setting category to AVAudioSessionCategoryPlayback failed.")
            }
            
            viewPlayer.player  = AVPlayer(url: url)
            viewPlayer.player?.currentItem?.preferredPeakBitRate = 1.0
            viewPlayer.player?.play()
            viewPlayer.player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
            viewPlayer.player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
            NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            
            isPlaying = true
            btnPlay.setBackgroundImage(#imageLiteral(resourceName: "ic_play"), for: .normal)
            if let temp = UserDefaults.standard.value(forKey: chitiettin.id) as? Double, temp > 0.0{
                let time: CMTime = CMTimeMake(value: Int64(temp * 1000), timescale: 1000)
                viewPlayer.player?.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: .zero)
            }
            addTimeObserver()
        }
    }
    func setBitRate(){
        for (index, temp) in listResolution.enumerated(){
            if index == 0, temp.isTicked {
                viewPlayer.player?.currentItem?.preferredPeakBitRate = 0
            } else if index != 0, temp.isTicked {
                viewPlayer.player?.currentItem?.preferredPeakBitRate = temp.maxBandwidth
            }
        }
    }
    @objc func didSelectBtnFullScreen(_ sender: Any) {
        self.viewPlayer.player?.pause()
        self.btnPlay.setBackgroundImage(#imageLiteral(resourceName: "ic_pause"), for: .normal)
        self.isPlaying = false
        let newPlayer = self.viewPlayer.player
        self.viewPlayer.player = nil
        if #available(iOS 13.0, *) {
            let vc = storyboard?.instantiateViewController(withIdentifier: FullScreenController.className) as! FullScreenController
            vc.player = newPlayer
            vc.listResolution = self.listResolution
            vc.onDismiss = {[weak self] in
                self?.viewPlayer.player = vc.player
                vc.player.replaceCurrentItem(with: nil)
                self?.viewPlayer.player?.play()
                self?.isPlaying = true
                self?.btnPlay.setBackgroundImage(#imageLiteral(resourceName: "ic_play"), for: .normal)
            }
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
        } else {
            let vc = PlayerViewController()
            vc.player = newPlayer
            vc.onDismiss = {[weak self] in
                self?.viewPlayer.player = vc.player
                vc.player?.replaceCurrentItem(with: nil)
                self?.viewPlayer.player?.play()
                self?.isPlaying = true
                self?.btnPlay.setBackgroundImage(#imageLiteral(resourceName: "ic_play"), for: .normal)
            }
            present(vc, animated: true) {
                vc.player?.play()
                vc.addObserver(self, forKeyPath: #keyPath(UIViewController.view.frame), options: [.old, .new], context: nil)
            }
        }
        
    }
    @objc func didSelectViewSetting(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: PopUp3Controller.className) as! PopUp3Controller
        vc.listResolution = listResolution
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false, completion: nil)
        vc.onComplete = {[weak self] list in
            self?.listResolution = list
            self?.setBitRate()
        }
    }
}

extension NewsDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case clvTinLienQuan1:
            return listRelated.count
        default:
            return listCungCM.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case clvTinLienQuan1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellNews", for: indexPath) as! CellNews
            if listRelated.count != 0 {
                let item = listRelated[indexPath.row]
                cell.isMedia = true
                cell.itemMedia = item
                cell.lblTitle.text = item.name
                cell.line.isHidden = false
                if item.thumnail != "", chitiettin.image.count > 0 {
                    if let url = URL(string: chuongTrinh.cdn.imageDomain + item.thumnail.replacingOccurrences(of: "\\", with: "/")){
                        cell.img.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "image_default"))
                    }
                } else {
                    cell.img.kf.setImage(with: URL(string: "https://static.mediacdn.vn/vnews/web_images/image_default.png"))
                }
                cell.lblCategory.text = (item.category == "") ? "VNEWS" : item.category
                let schedule = item.schedule
                let timePass = publishedDate(schedule: schedule)
                cell.lblPublished.text = timePass
                cell.delegate = self
                if indexPath.row == chitiettin.related.count - 1 {
                    cell.line.isHidden = true
                }
            }
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellNews", for: indexPath) as! CellNews
            if listCungCM.count != 0, indexPath.row < listCungCM.count{
                let item = listCungCM[indexPath.row]
                cell.lblTitle.text = item.name
                cell.line.isHidden = false
                if item.thumnail != "", item.image.count > 0 {
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
                cell.delegate = self
                cell.isMedia = true
                cell.itemMedia = item
            }
            return cell
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: scaleW * 109)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case clvTinLienQuan1:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewsDetailVC") as! NewsDetailVC
            vc.id = listRelated[indexPath.row].id
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewsDetailVC") as! NewsDetailVC
            vc.id = listCungCM[indexPath.row].id
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }

}
extension NewsDetailVC: CellNewsDelegate {
    func didLike(_ cell: CellNews) {
        APIService.shared.like(id: cell.itemMedia.id, title: cell.itemMedia.name) { _, _ in
             
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
    
    
}


extension NewsDetailVC:UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

