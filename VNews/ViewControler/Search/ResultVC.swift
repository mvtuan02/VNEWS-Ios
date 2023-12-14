//
//  ResultVC.swift
//  VNews
//
//  Created by dovietduy on 6/19/21.
//

import UIKit
import AVFoundation
class ResultVC: UIViewController {
    
    @IBOutlet weak var clv: UICollectionView!
    @IBOutlet weak var viewBack: UIView!
    @IBOutlet weak var lblTextSearch: UILabel!
    var textSearch = ""
    var beforeIndexPath = IndexPath(row: 0, section: 0)
    var listData: [MediaModel] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        clv.delegate = self
        clv.dataSource = self
        clv.register(UINib(nibName: CellHome.className, bundle: nil), forCellWithReuseIdentifier: CellHome.className)
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 15 * scaleW
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 15 * scaleW, right: 0)
        clv.collectionViewLayout = layout
        
        //
        viewBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(back)))
        lblTextSearch.text = textSearch
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}
extension ResultVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        listData.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = clv.dequeueReusableCell(withReuseIdentifier: CellHome.className, for: indexPath) as! CellHome
        let item = listData[indexPath.row]
        if item.thumnail != "" {
            if let url = URL(string: item.image[0].cdn + item.thumnail.replacingOccurrences(of: "\\", with: "/" )){
                cell.img.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "image_default"), options:[.cacheOriginalImage])
            }
        }
        cell.lblTitle.text = item.name
        cell.lblCategory.text = (item.category == "") ? "VNEWS" : item.category
        cell.lblPublished.text = item.getTimePass()
        
        //video
        cell.delegate = self
        cell.item = item
        cell.indexPath = indexPath
        cell.setup()
        return cell
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var isHaving = false
        
        for cell in clv.visibleCells{
            let id = clv.indexPath(for: cell)
            if id == beforeIndexPath {
                isHaving = true
            }
        }
        if isHaving == false{
            if let ceLL = cellForRowAt(indexPath: beforeIndexPath) {
                ceLL.isPlaying = false
                ceLL.viewPlayer.player?.pause()
                ceLL.isFirstTap = false
                ceLL.img.isHidden = false
                ceLL.hidePlayerController()
                ceLL.imgShadow.isHidden = false
                ceLL.lblTitle.isHidden = false
                ceLL.imgIconPlay.isHidden = false
            }
        }
        //
        NotificationCenter.default.post(name: NSNotification.Name("scrollView.didScroll"), object: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: scaleW * 375, height: scaleW * 305)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default
                    .post(name: NSNotification.Name("pauseVideo"),
                     object: nil)
    }
}

extension ResultVC: CellHomeDelegate{
    func didLike(_ cell: CellHome) {
        APIService.shared.like(id: cell.item.id, title: cell.item.name) { _, _ in
             
        }
    }
    func didShare(_ cell: CellHome) {
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
    func didSelectViewSetting(_ cell: CellHome) {
        let vc = storyboard?.instantiateViewController(withIdentifier: PopUp3Controller.className) as! PopUp3Controller
        vc.listResolution = cell.listResolution
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false, completion: nil)
        vc.onComplete = { list in
            cell.listResolution = list
            cell.setBitRate()
        }
    }
    
    func didSelectViewFullScreen(_ cell: CellHome, _ newPlayer: AVPlayer) {
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
                vc.player?.replaceCurrentItem(with: nil)
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
    
    
    func didSelectViewPlayer(_ cell: CellHome) {
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
            }
            
        } else{
            
        }
        beforeIndexPath = cell.indexPath
    }
    
    func cellForRowAt(indexPath: IndexPath) -> CellHome? {
        guard let cell = clv.cellForItem(at: indexPath) as? CellHome else {
            return clv.dequeueReusableCell(withReuseIdentifier: CellHome.className, for: indexPath) as? CellHome
        }
        return cell
    }
    
}
