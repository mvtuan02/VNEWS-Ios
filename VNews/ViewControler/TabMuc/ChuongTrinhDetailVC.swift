//
//  ChuongTrinhDetailVC.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 6/12/21.
//

import UIKit
import AVFoundation
import MarqueeLabel
class ChuongTrinhDetailVC: UIViewController {
    @IBOutlet weak var tbl: UITableView!
    var indexSelect = -1
    // video
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
    var timeObserver: Any?
    lazy var isPlaying = false
    lazy var isEnded = false
    lazy var timer = Timer()
    lazy var listResolution: [StreamResolution] = []
    lazy var data = MediaModel()
    lazy var heightTbl: CGFloat = 0
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        return aiv
    }()
    
    @IBOutlet weak var imgBack: UIImageView!
    @IBOutlet weak var lblTitleVc: UILabel!
    
    var privateKey:String = ""
    var page = 0
    var titleChuongTrinh:String = ""
    var listVideo = CategoryModel()
    
    
    //Color Status Bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            // Fallback on earlier versions
            return .default
        }
    }
    
    private var reportStart: Date?
    private var reportEnd: Date?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.viewPlayer.player?.pause()
        self.report()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        tbl.backgroundColor = .white
        swipeBack()
        nhanData()
        onclickImg()
        tbl.delegate = self
        tbl.dataSource = self
        tbl.register(UINib(nibName: "CellHeaderChuongTrinhDetail", bundle: nil), forCellReuseIdentifier: "CellHeaderChuongTrinhDetail")
        tbl.register(UINib(nibName: "TblCellListChuongTrinhDetail", bundle: nil), forCellReuseIdentifier: "TblCellListChuongTrinhDetail")
        tbl.estimatedRowHeight = 10 * scale
        setVideo()
        self.data = self.listVideo.media[0]
        self.openVideoAudio()
    }
    
    var checkLoadMore = true
    func getDataMore(page: Int){
        APIService.shared.getVideoLoadMore(page: page, privateKey: privateKey) { (data, error) in
            if let data = data as? [MediaModel]{
                self.listVideo.media += data
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
    func setVideo(){
        hidePlayerController()
        slider.addTarget(self, action: #selector(sliderDidEndSliding), for: [.touchUpInside, .touchUpOutside])
        viewSetting.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectViewSetting(_:))))
        viewFullScreen.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectBtnFullScreen(_:))))
        viewPlayer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectViewPlayer(_:))))
        viewForward.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectBtnForward5s(_:))))
        viewReplay.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectBtnReplay5s(_:))))
        viewPlayer.addSubview(activityIndicatorView)
        activityIndicatorView.centerXAnchor.constraint(equalTo: viewPlayer.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: viewPlayer.centerYAnchor).isActive = true
    }
    func swipeBack(){
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func onclickImg(){
        imgBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goBack)))
    }
    
    @objc func goBack() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func nhanData(){
        lblTitleVc.text = titleChuongTrinh
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
    var isTapping = false
    @objc func playerDidFinishPlaying(note: NSNotification){
        btnPlay.setBackgroundImage(#imageLiteral(resourceName: "ic_pause"), for: .normal)
        viewPlayer.player?.pause()
        isEnded = true
        isPlaying = false
        //
        UserDefaults.standard.removeObject(forKey: data.id)
        UserDefaults.standard.synchronize()
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
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
            reportStart = Date()
            viewPlayer.player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
            viewPlayer.player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
            
            isPlaying = true
            btnPlay.setBackgroundImage(#imageLiteral(resourceName: "ic_play"), for: .normal)
            addTimeObserver()
            if let temp = UserDefaults.standard.value(forKey: data.id) as? Double, temp > 0.0{
                let time: CMTime = CMTimeMake(value: Int64(temp * 1000), timescale: 1000)
                viewPlayer.player?.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: .zero)
            }
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


extension ChuongTrinhDetailVC:UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension ChuongTrinhDetailVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellHeaderChuongTrinhDetail", for: indexPath) as! CellHeaderChuongTrinhDetail
            cell.delegate = self
            if indexSelect == -1 {
                if listVideo.media.count != 0 {
                    cell.lblTitle.text = listVideo.media[0].name
                    cell.lblTime.text = "•  \(listVideo.media[0].getTimePass())"
                    cell.lblCategory.text = listVideo.name
                    cell.item = listVideo.media[0]
                }
            } else {
                cell.lblTitle.text = listVideo.media[indexSelect].name
                cell.lblTime.text = "•  \(listVideo.media[indexSelect].getTimePass())"
                cell.lblCategory.text = listVideo.name
                cell.item = listVideo.media[indexSelect]
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TblCellListChuongTrinhDetail", for: indexPath) as! TblCellListChuongTrinhDetail
            cell.listVideo = self.listVideo
            cell.delegate = self
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        heightTbl = 0
        if indexPath.section == 0 {
            heightTbl += UITableView.automaticDimension
            return UITableView.automaticDimension
        } else {
            if listVideo.media.count != 0 {
                let count1 = listVideo.media.count
                let row1: Double = Double(count1) / 2.0
                let row2: Double = Double(count1 / 2)
                if row1 > row2{
                    heightTbl += scaleW * 137 * CGFloat(row2 + 1) + scaleW * 10 * (CGFloat(row2 + 1) - 1) + scaleW * 10
                    return scaleW * 137 * CGFloat(row2 + 1) + scaleW * 10 * (CGFloat(row2 + 1) - 1) + scaleW * 10
                } else{
                    heightTbl += scaleW * 137 * CGFloat(row2) + scaleW * 10 * (CGFloat(row1) - 1) + scaleW * 10
                    return scaleW * 137 * CGFloat(row2) + scaleW * 10 * (CGFloat(row1) - 1) + scaleW * 10
                }
            } else {
                return 0
            }
            
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("1: \(Int(tbl.contentOffset.y + tbl.bounds.height))")
//        print("2: \(Int(tbl.contentSize.height))")
        if Int(tbl.contentOffset.y + tbl.bounds.height) == Int(tbl.contentSize.height+1) {
            if checkLoadMore {
                page = page + 1
                getDataMore(page: page)
            }
        }
    }
}

extension ChuongTrinhDetailVC: TblCellListChuongTrinhDetailDelegate, CellHeaderChuongTringDetailDelegate {
    func didLike(_ cell: CellHeaderChuongTrinhDetail) {
        
        APIService.shared.like(id: cell.item.id, title: cell.item.name) { _, _ in
             
        }
    }
    func didShare(_ cell: CellHeaderChuongTrinhDetail) {
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
        print(link)
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
    func report() {
        reportEnd = Date()
        if reportStart != nil {
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
            reportEnd = nil
            reportStart = nil
        }
        
    }
    
    func didSelectItem(_ data: [MediaModel], _ index: Int) {
        self.report()
        self.data = data[index]
        if let cell = cellForRowAt(IndexPath(row: 0, section: 0)) {
            cell.lblTitle.text = self.data.name
            cell.lblTime.text = "•  \(self.data.getTimePass())"
            self.indexSelect = index
        }
        
        self.openVideoAudio()
        tbl.reloadData()
    }
    
    func cellForRowAt(_ indexPath: IndexPath) -> CellHeaderChuongTrinhDetail? {
        guard let cell = tbl.cellForRow(at: indexPath) as? CellHeaderChuongTrinhDetail else{
            return tbl.dequeueReusableCell(withIdentifier: CellHeaderChuongTrinhDetail.className, for: indexPath) as? CellHeaderChuongTrinhDetail
        }
        return cell
    }
}
