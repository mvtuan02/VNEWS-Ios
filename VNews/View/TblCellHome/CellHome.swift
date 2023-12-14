//
//  CellHome.swift
//  VNews
//
//  Created by dovietduy on 6/12/21.
//

import UIKit
import AVFoundation
class CellHome: UICollectionViewCell {
    static let reuseIdentifier = "CellHome"

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblPublished: UILabel!
    @IBOutlet weak var imgIconPlay: UIImageView!
    @IBOutlet weak var viewReplay: UIView!
    @IBOutlet weak var viewForward: UIView!
    @IBOutlet weak var imgLike: UIImageView!
    
    //video
    @IBOutlet weak var viewPlayer: PlayerView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var lblCurrentTime: UILabel!
    @IBOutlet weak var slider: CustomSlider!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var viewFullScreen: UIView!
    @IBOutlet weak var viewSetting: UIView!
    @IBOutlet weak var imgShadow: UIImageView!
    
    @IBOutlet weak var viewLike: UIView!
    @IBOutlet weak var viewShare: UIView!
    var delegate: CellHomeDelegate!
    var indexPath: IndexPath!
    var item: MediaModel!
    var timeObserver: Any?
    var isPlaying = false
    var isEnded = false
    var timer = Timer()
    var listResolution: [StreamResolution] = []
    var height: CGFloat = 0.0
    func setImage(){
//        img.contentMode = .top
        img.clipsToBounds = true

            let image = img.image!
            img.image = image.resizeTopAlignedToFill(newWidth: img.frame.width)
            height = (img.image?.size.height ?? 100) + 55 * scaleW

        
    }
//    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//            lblCategory.preferredMaxLayoutWidth = layoutAttributes.size.width - contentView.layoutMargins.left - contentView.layoutMargins.left
//            layoutAttributes.bounds.size.height = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
//            return layoutAttributes
//        }
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        //aiv.startAnimating()
        return aiv
    }()
    
    @objc func didShare(){
        delegate?.didShare(self)
    }
    @objc func didLike(){
        imgLike.image = #imageLiteral(resourceName: "icons8-facebook-like-64 (1)")
        delegate?.didLike(self)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        viewPlayer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectViewPlayer(_:))))
        viewSetting.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectViewSetting(_:))))
        viewFullScreen.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectBtnFullScreen(_:))))
        viewForward.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectBtnForward5s(_:))))
        viewReplay.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectBtnReplay5s(_:))))
        slider.addTarget(self, action: #selector(sliderDidEndSliding), for: [.touchUpInside, .touchUpOutside])
        viewShare.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didShare)))
        viewLike.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didLike)))
        lblCategory.lineBreakMode = .byWordWrapping

        
        hidePlayerController()
        imgShadow.isHidden = false
        //
        viewPlayer.addSubview(activityIndicatorView)
        activityIndicatorView.centerXAnchor.constraint(equalTo: viewPlayer.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: viewPlayer.centerYAnchor).isActive = true
        
        NotificationCenter.default
                          .addObserver(self,
                                       selector: #selector(pauseVideo),
                         name: NSNotification.Name ("pauseVideo"), object: nil)
        NotificationCenter.default
                          .addObserver(self,
                                       selector: #selector(pauseVideo),
                         name: NSNotification.Name ("pauseVideo"), object: nil)
    }
    
    @objc func pauseVideo(){
        isPlaying = false
        self.viewPlayer.player?.pause()
        btnPlay.setBackgroundImage(#imageLiteral(resourceName: "ic_pause"), for: .normal)
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
    @objc func playerDidFinishPlaying(note: NSNotification){
        btnPlay.setBackgroundImage(#imageLiteral(resourceName: "ic_pause"), for: .normal)
        viewPlayer.player?.pause()
        isEnded = true
        isPlaying = false
//        delegate?.didFinish()
    }
    var isTapping = false
    var isFirstTap = false
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
        if isFirstTap == false{
            lblTitle.isHidden = true
            imgIconPlay.isHidden = true
            img.isHidden = true
            didSelectBtnPlay(Any.self)
            isFirstTap = true
        }
        delegate?.didSelectViewPlayer(self)
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {[weak self] in
            if self?.isSliderChanging == false{
                self?.hidePlayerController()
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
            UserDefaults.standard.setValue(currentItem.currentTime().seconds, forKey: self!.item.privateID)
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
    override func prepareForReuse() {
        imgLike.image = #imageLiteral(resourceName: "icons8-facebook-like-64")
        viewPlayer.player?.pause()
        img.isHidden = false
        lblTitle.isHidden = false
        imgIconPlay.isHidden = false
        hidePlayerController()
        imgShadow.isHidden = false
    }
   
    func setup(){
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .default, options: [])
        }
        catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        listResolution = []
        var link = ""
        if item.path != "" {
            link = item.path
            if Array(link)[link.count - 1] == "/" {
                link = item.fileCode
            }
        }else{
            link = item.fileCode
        }
        if let url = URL(string: link){
            if item.fileCode != "" || item.path.contains(".m3u8"){
                StreamHelper.shared.getPlaylist(from: url) { [weak self] (result) in
                    switch result {
                    case .success(let playlist):
                        self?.listResolution = StreamHelper.shared.getStreamResolutions(from: playlist)
                        self?.listResolution.insert(StreamResolution(maxBandwidth: 0, averageBandwidth: 0, resolution: CGSize(width: 854.0, height: 480.0)), at: 0)
                        self?.listResolution[0].isTicked = true
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
            viewPlayer.player = AVPlayer(url: url)
        }
        viewPlayer.player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
        viewPlayer.player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        addTimeObserver()
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
    @objc func didSelectViewSetting(_ sender: Any) {
        delegate?.didSelectViewSetting(self)
    }
    @objc func didSelectBtnFullScreen(_ sender: Any) {
        self.viewPlayer.player?.pause()
        self.btnPlay.setBackgroundImage(#imageLiteral(resourceName: "ic_pause"), for: .normal)
        self.isPlaying = false
        let newPlayer = self.viewPlayer.player
        self.viewPlayer.player = nil
        
        delegate?.didSelectViewFullScreen(self, newPlayer!)
    }
}
protocol CellHomeDelegate {
    func didSelectViewSetting(_ cell: CellHome)
    func didSelectViewFullScreen(_ cell: CellHome, _ newPlayer: AVPlayer)
    func didSelectViewPlayer(_ cell: CellHome)
    func didShare(_ cell: CellHome)
    func didLike(_ cell: CellHome)
}
