//
//  PageLiveVC.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 5/13/21.
//

import UIKit
import AVFoundation
import XLPagerTabStrip
import GoogleMobileAds

class PageLiveVC: UIViewController {
    //
    @IBOutlet weak var top: NSLayoutConstraint!
    @IBOutlet weak var nativeAdView: GADNativeAdView!
    var admobNativeAds: GADNativeAd?
    @objc func showAdmob(){
        if let native = AdmobManager.shared.getAdmobNativeAds(){
            admobNativeAds = native
            nativeAdView.isHidden = false
            setupHeader(nativeAd: native)
            top.constant = 400 * scaleW
            isLoadedAdmob = true
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

    @IBOutlet weak var clickFacebook: UIView!
    @IBOutlet weak var clickYoutobe: UIView!
    @IBOutlet weak var clickTiktok: UIView!
    @IBOutlet weak var clickPhone: UIView!
    @IBOutlet weak var clickSearch: UIView!
    @IBOutlet weak var clickAccount: UIView!
    @IBOutlet weak var clickLogo: UIImageView!
    
    @IBOutlet weak var clvPlaylist: UICollectionView!
    @IBOutlet weak var heightPlayList: NSLayoutConstraint!
    @IBOutlet weak var tblLichPhatSong: UITableView!
    @IBOutlet weak var clvChuongTrinh: UICollectionView!
    @IBOutlet weak var heightChuongTrinh: NSLayoutConstraint!
    @IBOutlet weak var viewPlayer: PlayerView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var lblCurrentTime: UILabel!
    @IBOutlet weak var slider: CustomSlider!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var viewFullScreen: UIView!
    @IBOutlet weak var viewSetting: UIView!
    @IBOutlet weak var imgShadow: UIImageView!
    @IBOutlet weak var viewSchedule: UIView!
    @IBOutlet weak var viewForward: UIView!
    @IBOutlet weak var viewReplay: UIView!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTenChuongTrinh: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    var nameOnLive = ""
    
    var timeObserver: Any?
    var isPlaying = false
    var isEnded = false
    var timer = Timer()
    var timer2 = Timer()
    var listResolution: [StreamResolution] = []
    
    @IBOutlet weak var namePlaylist: UILabel!
    lazy var listLichPhatSong: [ScheduleModel] = []
    lazy var indexOnLive = IndexPath(row: -1, section: 0)
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        return aiv
    }()
    var isLoadedAdmob = false
    var playlistTivi: CategoryModel!
    var listChuongTrinh: CategoryModel!
    var checkPlaylistTivi = false
    func getListChuongTring(){
        APIService.shared.getChuongTrinh { data, error in
            if let data = data as? CategoryModel {
                self.listChuongTrinh = data
                self.heightChuongTrinh.constant = CGFloat(3 * 107) * scaleW + 2 * 20 * scaleW + 40 * scaleW
                self.clvChuongTrinh.reloadData()
            }
        }
    }
    func getPlaylistTivi(){
        APIService.shared.getPlaylistForApp(privateKey: "86efc499-9cc1-4f7b-a915-8f630c66bffe") { (data, error, statusCode) in
            if let data = data as? CategoryModel{
                self.playlistTivi = data
                self.checkPlaylistTivi = true
                DispatchQueue.main.async {
                    self.namePlaylist.text = "\(self.playlistTivi.name)"
                    self.clvPlaylist.reloadData()
                }
            }
            if error != nil {
                self.checkPlaylistTivi = false
                self.heightPlayList.constant = 0
                DispatchQueue.main.async {
                    self.clvPlaylist.reloadData()
                    self.namePlaylist.text = ""
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTime.text = ""
        hidePlayerController()
        getPlaylistTivi()
        getListChuongTring()
        //
        slider.addTarget(self, action: #selector(sliderDidEndSliding), for: [.touchUpInside, .touchUpOutside])
        viewSetting.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectViewSetting(_:))))
        viewFullScreen.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectBtnFullScreen(_:))))
        viewForward.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectBtnForward5s(_:))))
        viewReplay.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectBtnReplay5s(_:))))
        viewPlayer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectViewPlayer(_:))))
        viewPlayer.addSubview(activityIndicatorView)
        activityIndicatorView.centerXAnchor.constraint(equalTo: viewPlayer.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: viewPlayer.centerYAnchor).isActive = true
        viewSchedule.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectViewSchedule(_:))))
        //
        tblLichPhatSong.backgroundColor = .white
        tblLichPhatSong.delegate = self
        tblLichPhatSong.dataSource = self
        tblLichPhatSong.register(UINib(nibName: CellLich.className, bundle: nil), forCellReuseIdentifier: CellLich.className)
        tblLichPhatSong.estimatedRowHeight = 60 * scaleW
        //open more app
        clickFacebook.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openFacbookApp)))
        clickYoutobe.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openYoutobeApp)))
        clickTiktok.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openTiktokApp)))
        clickPhone.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openPhoneCall)))
        clickSearch.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openViewSearch)))
        clickAccount.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openViewAccount)))
        clickLogo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToHomePage)))
        
        lblTitle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectLblTenChuongTrinh(_:))))
        //
        APIService.shared.getSchedule(day: Date().getTimeString4()) {[weak self] (data, error) in
            if let data = data as? [ScheduleModel] {
                self?.listLichPhatSong = data
                self?.tblLichPhatSong.reloadData()
                self?.checkLive()
//                for item in self!.listLichPhatSong {
//                    print(item.startTime.getTimeString())
//                }
            }
        }
        timerLoop()
        //
        clvChuongTrinh.delegate = self
        clvChuongTrinh.dataSource = self
        clvChuongTrinh.register(UINib(nibName: CellChuongTrinh.className, bundle: nil), forCellWithReuseIdentifier: CellChuongTrinh.className)
        let layout2 = UICollectionViewFlowLayout()
        layout2.minimumLineSpacing = 20 * scaleW
        layout2.minimumInteritemSpacing = 0
        layout2.sectionInset = UIEdgeInsets(top: 20 * scaleW, left: 20 * scaleW, bottom: 20 * scaleW, right: 20 * scaleW)
        layout2.itemSize = CGSize(width: (UIScreen.main.bounds.width - 60 * scaleW) / 2.01, height: scaleW * 107)
        clvChuongTrinh.collectionViewLayout = layout2
        
        
        //clv Playlist
        clvPlaylist.delegate = self
        clvPlaylist.dataSource = self
        clvPlaylist.register(UINib(nibName: "CellPlaylistHorizol2", bundle: nil), forCellWithReuseIdentifier: "CellPlaylistHorizol2")
        let layout1 = UICollectionViewFlowLayout()
        layout1.scrollDirection = .horizontal
        layout1.itemSize = CGSize(width: scaleW * 131, height: scaleW * 131)
        layout1.sectionInset = UIEdgeInsets(top: 0, left: scale * 20, bottom: scale * 20, right: scale * 20)
        clvPlaylist.collectionViewLayout = layout1
        heightPlayList.constant = scaleW * 131 + scale * 20
        
        
        AdmobManager.shared.loadAdmobNativeAds()
        _ = Timer.scheduledTimer(withTimeInterval: 15, repeats: true, block: {[self] timer in
            if isLoadedAdmob == false {
                showAdmob()
            } else {
                timer.invalidate()
            }
            
        })
        NotificationCenter.default.addObserver(self, selector: #selector(showAdmob), name: NSNotification.Name("Admob.loaded"), object: nil)
    }
    
    @objc func orientationDidChange() {
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
            self.didSelectBtnFullScreen(Any.self)
        default:
            break
        }
    }
    
    @objc func didSelectLblTenChuongTrinh(_ sender: Any){
//        let item = listLichPhatSong[indexPath.row]
        lblTenChuongTrinh.text = nameOnLive
        lblTitle.text = nameOnLive
        checkLive()
        link = live.domain
        viewPlayer.player?.replaceCurrentItem(with: nil)
        openVideoAudio()
    }
    @objc func didSelectViewSchedule(_ sender: Any){
        let vc = storyboard?.instantiateViewController(withIdentifier: DatePickerController.className) as! DatePickerController
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false, completion: nil)
        vc.onComplete = {[weak self] (date) in
            APIService.shared.getSchedule(day: date.getTimeString4()) {[weak self] (data, error) in
                if let data = data as? [ScheduleModel] {
                    self?.listLichPhatSong = data
                    self?.tblLichPhatSong.reloadData()
                    self?.indexOnLive = IndexPath(row: -1, section: 0)
                    self?.checkLive()
                    if self?.indexOnLive == IndexPath(row: -1, section: 0) && self?.listLichPhatSong.count != 0{
                        self?.tblLichPhatSong.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                    }
                }
            }
            
        }
    }
    func timerLoop(){
        timer2 = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true, block: {[weak self] timer in
            self?.checkLive2()
        })
    }
    func checkLive(){
        for (index, item) in self.listLichPhatSong.enumerated(){
            let date1 = Date()
            let date2 = item.startTime.toDate()
            let date3 = item.endTime.toDate()
            if date2! <= date1 && date1 <= date3! {
                indexOnLive = IndexPath(row: index, section: 0)
                tblLichPhatSong.scrollToRow(at: IndexPath(row: index, section: 0), at: .middle, animated: true)
                tblLichPhatSong.reloadData()
            }
        }
    }
    func checkLive2(){
        for (index, item) in self.listLichPhatSong.enumerated(){
            let date1 = Date()
            let date2 = item.startTime.toDate()
            let date3 = item.endTime.toDate()
            if date2! <= date1 && date1 <= date3! {
                indexOnLive = IndexPath(row: index, section: 0)
                tblLichPhatSong.reloadData()
            }
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        openVideoAudio()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.viewPlayer.player?.pause()
        self.viewPlayer.player?.replaceCurrentItem(with: nil)
        timer.invalidate()
        timer2.invalidate()
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
    @IBAction func didSelectBtnPlay(_ sender: Any) {
        if isPlaying{
            viewPlayer.player?.pause()
            btnPlay.setBackgroundImage(#imageLiteral(resourceName: "ic_pause"), for: .normal)
        } else{
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
    
    var link = live.domain
    func openVideoAudio(){
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .default, options: [])
        }
        catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
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
            let playerItem = AVPlayerItem(url: url)
            let player = AVPlayer(playerItem: playerItem)
            viewPlayer.player = player
            viewPlayer.player?.play()
            viewPlayer.player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
            viewPlayer.player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
            
            isPlaying = true
            btnPlay.setBackgroundImage(#imageLiteral(resourceName: "ic_play"), for: .normal)
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
                vc.player?.replaceCurrentItem(with: nil)
                self?.viewPlayer.player?.play()
                self?.isPlaying = true
                self?.btnPlay.setBackgroundImage(#imageLiteral(resourceName: "ic_play"), for: .normal)
                self?.hidePlayerController()
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

extension PageLiveVC: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case clvChuongTrinh:
            if listChuongTrinh != nil {
                return 6
            } else {
                return 0
            }
            
        default:
            if playlistTivi != nil {
                return playlistTivi.media.count
            } else {
                return 0
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case clvPlaylist:
            let cell = clvPlaylist.dequeueReusableCell(withReuseIdentifier: "CellPlaylistHorizol2", for: indexPath) as! CellPlaylistHorizol2
            if playlistTivi != nil {
                let item = playlistTivi.media[indexPath.row]
                cell.item = item
                if item.thumnail != "" {
                    if let url = URL(string: playlistTivi.cdn.imageDomain + item.thumnail.replacingOccurrences(of: "\\", with: "/" )){
                        cell.img.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "image_default"))
                    } else {
                        cell.img.image = #imageLiteral(resourceName: "image_default")
                    }
                } else {
                    cell.img.image = #imageLiteral(resourceName: "image_default")

                }
                            
                cell.lblTitle.text = item.name
                //cell.lblTime.text = item.getTimePass()
            }
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellChuongTrinh.className
                                                          , for: indexPath) as! CellChuongTrinh
            let item = listChuongTrinh.components[indexPath.row]
            cell.lblTitle.text = item.name.uppercased()
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
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case clvChuongTrinh:
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
        default:
            let vc = storyboard?.instantiateViewController(withIdentifier: Video2VC.className) as! Video2VC
            vc.listData = playlistTivi.media
            vc.data = playlistTivi.media[indexPath.row]
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
        }
    }
}
extension PageLiveVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        listLichPhatSong.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellLich.className, for: indexPath) as! CellLich
        let item = listLichPhatSong[indexPath.row]
        cell.lblTitle.text = item.name.trimmingCharacters(in: .whitespacesAndNewlines)//.lowercased().capitalizingFirstLetter().trimmingCharacters(in: .whitespacesAndNewlines)
        cell.lblTime.text = item.getTime()
        cell.lblDescription.text = item.description
        if indexOnLive == IndexPath(row: -1, section: 0){
            cell.lblTitle.textColor = .black
            cell.imgDot.image = nil
            cell.isUserInteractionEnabled = true
        } else if indexOnLive == indexPath {
            cell.imgDot.image = #imageLiteral(resourceName: "Ellipse 3")
            nameOnLive = item.name.trimmingCharacters(in: .whitespacesAndNewlines)
            lblTenChuongTrinh.text = nameOnLive
            lblTitle.text = nameOnLive
            //lblTenChuongTrinh.text = item.name.lowercased().capitalizingFirstLetter()
            lblTime.text = item.getTime()
            cell.lblTitle.textColor = .black
            cell.isUserInteractionEnabled = true
        } else if indexPath > indexOnLive {
            cell.imgDot.image = nil
            cell.lblTitle.textColor = .lightGray
            cell.isUserInteractionEnabled = false
        } else {
            cell.lblTitle.textColor = .black
            cell.imgDot.image = nil
            cell.isUserInteractionEnabled = true
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = listLichPhatSong[indexPath.row]
        lblTenChuongTrinh.text = item.name.trimmingCharacters(in: .whitespacesAndNewlines)//.lowercased().capitalizingFirstLetter()
        //lblTime.text = item.getTime()
        
        
        if indexOnLive == indexPath {
            link = live.domain
        } else {
            link = item.url
        }
        viewPlayer.player?.replaceCurrentItem(with: nil)
        openVideoAudio()
    }
    
}
