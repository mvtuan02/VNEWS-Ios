//
//  VideoDetailVC.swift
//  VNews
//
//  Created by dovietduy on 5/26/21.
//

import UIKit
import AVFoundation
import GoogleMobileAds
var sharedPlayer: AVPlayer!

class VideoDetailVC: UIViewController {
    //
    @IBOutlet weak var top: NSLayoutConstraint!
    @IBOutlet weak var nativeAdView: GADNativeAdView!
    //
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewLbl: UIView!
    @IBOutlet weak var heightLbl: NSLayoutConstraint!
    @IBOutlet weak var viewShare: UIView!
    @IBOutlet weak var viewLike: UIView!
    @IBOutlet weak var imgLike: UIImageView!
    
    @IBOutlet weak var imgClose: UIImageView!
    @IBOutlet weak var viewPlayer: PlayerView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var lblCurrentTime: UILabel!
    @IBOutlet weak var slider: CustomSlider!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var viewFullScreen: UIView!
    @IBOutlet weak var viewSetting: UIView!
    @IBOutlet weak var imgShadow: UIImageView!
    @IBOutlet weak var viewExpand: UIView!
    @IBOutlet weak var viewReplay: UIView!
    @IBOutlet weak var viewForward: UIView!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblTHUGON: UILabel!
    @IBOutlet weak var collView: UICollectionView!
    @IBOutlet weak var collView2: UICollectionView!
    @IBOutlet weak var switcher: CustomSwitch!

    
    var timeObserver: Any?
    lazy var isPlaying = false
    lazy var isEnded = false
    lazy var timer = Timer()
    lazy var listResolution: [StreamResolution] = []
    lazy var data = MediaModel()
    lazy var listData = [MediaModel]()
    lazy var listRelated = [MediaModel]()
    @IBOutlet weak var heightClv: NSLayoutConstraint!
    @IBOutlet weak var heightClv2: NSLayoutConstraint!
    lazy var isMiniViewPush = false
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        return aiv
    }()
    
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
    
    @objc func dismissView(){
        NotificationCenter.default.removeObserver(self)
        viewPlayer.player?.removeObserver(self, forKeyPath: "currentItem.loadedTimeRanges", context: nil)
        viewPlayer.player?.removeObserver(self, forKeyPath: "timeControlStatus", context: nil)
        if let timeObserver = timeObserver {
            viewPlayer.player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        self.viewPlayer.player?.pause()
        self.viewPlayer.player?.replaceCurrentItem(with: nil)
//        self.viewPlayer.player = nil
//        dismiss(animated: true, completion: nil)
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    @objc func didShare1(_ sender: Any){
        let item = data
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
        AdmobManager.shared.loadAdmobNativeAds()
        NotificationCenter.default.addObserver(self, selector: #selector(showAdmob), name: NSNotification.Name("Admob.loaded"), object: nil)
    }
    var admobNativeAds: GADNativeAd?
    @objc func showAdmob(){
        if let native = AdmobManager.shared.getAdmobNativeAds(){
            admobNativeAds = native
            nativeAdView.isHidden = false
            setupHeader(nativeAd: native)
            top.constant = 430 * scaleW
        }
    }
    func closeViewController(){
        imgClose.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissView)))
    }
    
    //Color Status Bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            // Fallback on earlier versionse
            return .default
        }
    }
    func stopVOD() {
        NotificationCenter.default.removeObserver(self)
        viewPlayer.player?.removeObserver(self, forKeyPath: "currentItem.loadedTimeRanges", context: nil)
        viewPlayer.player?.removeObserver(self, forKeyPath: "timeControlStatus", context: nil)
        if let timeObserver = timeObserver {
            viewPlayer.player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        self.viewPlayer.player?.pause()
        self.viewPlayer.player?.replaceCurrentItem(with: nil)
        self.viewPlayer.player = nil
    }
    @objc func like() {
        self.imgLike.image = #imageLiteral(resourceName: "icons8-facebook-like-64 (1)")
        APIService.shared.like(id: data.id, title: data.name) { _, _ in
             
        }
    }
    @objc func orientationDidChange() {
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
            self.didSelectBtnFullScreen(Any.self)
        default:
            break
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        closeViewController()
        hidePlayerController()
        navigationController?.isNavigationBarHidden = true
        //
        
       
        slider.addTarget(self, action: #selector(sliderDidEndSliding), for: [.touchUpInside, .touchUpOutside])
        viewSetting.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectViewSetting(_:))))
        viewFullScreen.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectBtnFullScreen(_:))))
//        viewExpand.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectViewExpand(_:))))
        viewPlayer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectViewPlayer(_:))))
        viewForward.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectBtnForward5s(_:))))
        viewReplay.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectBtnReplay5s(_:))))
        viewShare.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didShare1(_:))))
        viewLike.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(like)))
        viewPlayer.addSubview(activityIndicatorView)
        activityIndicatorView.centerXAnchor.constraint(equalTo: viewPlayer.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: viewPlayer.centerYAnchor).isActive = true
        
        //
        lblTitle.text = data.name.uppercased()
        lblCategory.text = data.category != "" ? data.category : "VNEWS"
        lblTime.text = data.getTimePass()
        lblDescription.text = data.descripTion
        
        //
        lblDescription.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectThuGon(_:))))
        lblTHUGON.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectThuGon(_:))))
        
        collView.delegate = self
        collView.dataSource = self
        collView.register(UINib(nibName: "CellNews", bundle: nil), forCellWithReuseIdentifier: "CellNews")
        let layout = UICollectionViewFlowLayout()
        collView.collectionViewLayout = layout
        
        collView2.delegate = self
        collView2.dataSource = self
        collView2.register(UINib(nibName: "CellNews", bundle: nil), forCellWithReuseIdentifier: "CellNews")
        let layout2 = UICollectionViewFlowLayout()
        collView2.collectionViewLayout = layout2
        //
        if data.related.count == 0 {
            heightClv.constant = 0
            viewLbl.isHidden = true
            heightLbl.constant = 0
        } else {
            for item in data.related {
                APIService.shared.getVideoRelated(privateKey: item.id) { data, error in
                    if let data = data as? MediaModel {
                        self.listRelated.append(data)
                        if self.listRelated.count == self.data.related.count {
                            self.heightClv.constant = UIScreen.main.bounds.width * 0.245 * CGFloat(data.related.count)
                            self.collView.reloadData()
                        }
                    }
                }
            }
        }
        heightClv2.constant = UIScreen.main.bounds.width * 0.245 * CGFloat(listData.count)
        //
        let mode = UserDefaults.standard.integer(forKey: "switcher")
        switcher.isOn = (mode == 0) ? true : false
        switcher.thumbView.backgroundColor = switcher.isOn ? switcher.thumbTintColor : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    private var reportStart: Date?
    private var reportEnd: Date?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        openVideoAudio()
        reportStart = Date()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.viewPlayer.player?.pause()

        reportEnd = Date()
        let reportTime = reportEnd! - reportStart!
        let duration = reportTime.hour!.description.add0() + ":" + reportTime.minute!.description.add0() + ":" + reportTime.second!.description.add0()
        var link = ""
        switch data.contentType {
        case "0":
            link = domainShare + "video/" + data.slug
        case "1", "6":
            link = domainShare + "news/" + data.slug
        case "2":
            link = domainShare + "magazine/" + data.slug
        case "3":
            link = domainShare + "inforgraphic/" + data.slug
        case "4":
            link = domainShare + "longform/" + data.slug
        case "5":
            link = domainShare + "live/" + data.slug
        default:
            link = domainShare
        }
        APIService.shared.report(id: self.data.id, title: self.data.name, path: link, contentType: "video", duration: duration, device: device, network: network, location: "", ip: ip) { data, error in
        }
    }
    lazy var isThuGon = true
    @objc func didSelectThuGon(_ sender: Any){
        if isThuGon {
            lblTHUGON.text = "THU GỌN"
            lblDescription.numberOfLines = 0
        }else{
            lblTHUGON.text = "XEM THÊM"
            lblDescription.numberOfLines = 3
        }
        isThuGon = !isThuGon
    }
    @IBAction func valueChanged(_ sender: CustomSwitch) {
        UserDefaults.standard.setValue((sender.isOn == true ? 0 : 1) , forKey: "switcher")
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
        //
        UserDefaults.standard.removeObject(forKey: data.id)
        UserDefaults.standard.synchronize()
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
//        //
//        let mode = UserDefaults.standard.integer(forKey: "switcher")
//        if mode == 0 {
////            if index >= data.related.count - 1 {
////                index = 0
//                if data.related.count != 0 {
//                    APIService.shared.getVideoRelated(privateKey: data.related[0].id) { data, error in
//                        if let data = data as? MediaModel {
//                            self.data = data
//                            self.updateRelated()
//                            self.lblTitle.text = data.name.uppercased()
//                            self.lblTime.text = data.getTimePass()
//                            self.lblDescription.text = data.descripTion
//                            self.viewPlayer.player?.replaceCurrentItem(with: nil)
//                            self.openVideoAudio()
//                            self.scrollView.setContentOffset(CGPoint.zero, animated: true)
//                        }
//                    }
//                }
//        }
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
        self.viewExpand.isHidden = true
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
        self.viewExpand.isHidden = false
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
            UserDefaults.standard.setValue(currentItem.currentTime().seconds, forKey: self!.data.id)
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
        if data.path != "" {
            link = data.path
            if Array(link)[link.count - 1] == "/" {
                link = data.fileCode
            }
        }else{
            link = data.fileCode
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
            viewPlayer.player?.play()
            viewPlayer.player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
            viewPlayer.player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
            NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            
            isPlaying = true
            btnPlay.setBackgroundImage(#imageLiteral(resourceName: "ic_play"), for: .normal)
            
            
            //
            if isMiniViewPush {
                if let temp = UserDefaults.standard.value(forKey: "TimeSave") as? Double, temp > 0.0{
                    let time: CMTime = CMTimeMake(value: Int64(temp * 1000), timescale: 1000)
                    viewPlayer.player?.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: .zero)
                }
            }
            if let temp = UserDefaults.standard.value(forKey: data.id) as? Double, temp > 0.0{
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
extension VideoDetailVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension VideoDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case collView:
            return listRelated.count
        default:
            return self.listData.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case collView:
            let cell = collView.dequeueReusableCell(withReuseIdentifier: "CellNews", for: indexPath) as! CellNews
            let item = listRelated[indexPath.row]
            cell.delegate = self
            cell.isMedia = true
            cell.itemMedia = item
            if item.thumnail != "" {
                //(item.image[0].cdn + item.thumnail.replacingOccurrences(of: "\\", with: "/"))
                if let url = URL(string: item.image[0].cdn + item.thumnail.replacingOccurrences(of: "\\", with: "/" )){
                    cell.img.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "image_default"))
                }
            } else {
                cell.img.image = #imageLiteral(resourceName: "image_default")
            }
            cell.lblTitle.text = item.name
            cell.lblPublished.text = item.getTimePass()
            cell.lblCategory.text = (item.category == "") ? "VNEWS" : item.category
            return cell
        default:
            let cell = collView.dequeueReusableCell(withReuseIdentifier: "CellNews", for: indexPath) as! CellNews
            let item = listData[indexPath.row]
            if item.thumnail != "" {
                if let url = URL(string: item.image[0].cdn + item.thumnail.replacingOccurrences(of: "\\", with: "/" )){
                    cell.img.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "image_default"))
                }
            }
            else {
                cell.img.image = #imageLiteral(resourceName: "image_default")
            }
            cell.lblTitle.text = item.name
            cell.lblPublished.text = item.getTimePass()
            cell.lblCategory.text = (item.category == "") ? "VNEWS" : item.category
            cell.delegate = self
            cell.isMedia = true
            cell.itemMedia = item
    //        print(item.category)
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 0.245)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        NotificationCenter.default.removeObserver(self)
        viewPlayer.player?.removeObserver(self, forKeyPath: "currentItem.loadedTimeRanges", context: nil)
        viewPlayer.player?.removeObserver(self, forKeyPath: "timeControlStatus", context: nil)
        if let timeObserver = timeObserver {
            viewPlayer.player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        self.viewPlayer.player?.pause()
        self.viewPlayer.player?.replaceCurrentItem(with: nil)
        self.viewPlayer.player = nil
        let vc = storyboard?.instantiateViewController(withIdentifier: VideoDetailVC.className) as! VideoDetailVC
        switch collectionView {
        case collView:
            vc.listData = listData
            vc.data = listRelated[indexPath.row]
        default:
            vc.listData = listData
            vc.data = listData[indexPath.row]
        }
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
}
extension VideoDetailVC: CellNewsDelegate{
    func didLike(_ cell: CellNews) {
        if cell.isMedia {
            APIService.shared.like(id: cell.itemMedia.id, title: cell.itemMedia.name) { _, _ in
                 
            }
        } else {
            APIService.shared.like(id: cell.item.id, title: cell.item.title) { _, _ in
                 
            }
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
        
        guard let url = URL(string: link) else {
            return
        }
        let itemsToShare = [url]
        let ac = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        ac.popoverPresentationController?.sourceView = self.view
        self.present(ac, animated: true)
    }
}
