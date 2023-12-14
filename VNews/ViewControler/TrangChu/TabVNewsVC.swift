//
//  TabVNewsVC.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 5/10/21.
//

import UIKit
import Kingfisher
import XLPagerTabStrip
class TabVNewsVC: ButtonBarPagerTabStripViewController {
    
    @IBOutlet weak var clickFacebook: UIView!
    @IBOutlet weak var clickYoutobe: UIView!
    @IBOutlet weak var clickTiktok: UIView!
    @IBOutlet weak var clickPhone: UIView!
    @IBOutlet weak var clickSearch: UIView!
    @IBOutlet weak var clickAccount: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDesign()
        buttonBarView.selectedBar.backgroundColor = settings.style.selectedBarBackgroundColor
        buttonBarView.backgroundColor = settings.style.buttonBarBackgroundColor
        
        //
//        containerView.isScrollEnabled = false
        //open more app
        clickFacebook.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openFacbookApp)))
        clickYoutobe.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openYoutobeApp)))
        clickTiktok.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openTiktokApp)))
        clickPhone.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openPhoneCall)))
        clickSearch.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openViewSearch)))
        clickAccount.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openViewAccount)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(scrollToTop(_:)), name: NSNotification.Name("scrollView.scrollToTop"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openVideo(_:)), name: NSNotification.Name("HomeOpenVideo"), object: nil)
        if isMessaging{
            NotificationCenter.default.post(name: NSNotification.Name("HomeOpenVideo"), object: nil)
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    @objc func openVideo(_ notification: Notification){
        switch typeNoti{
        case "video":
            let vc = storyboard?.instantiateViewController(withIdentifier: VideoDetailVC.className) as! VideoDetailVC
            vc.modalPresentationStyle = .fullScreen
            vc.data = mediaNoti
            vc.listData = listDataNoti
            present(vc, animated: true, completion: nil)
        case "article":
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewsDetailVC") as! NewsDetailVC
            vc.id = idNoti
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            let vc = storyboard?.instantiateViewController(withIdentifier: VideoDetailVC.className) as! VideoDetailVC
            vc.modalPresentationStyle = .fullScreen
            vc.data = mediaNoti
            vc.listData = listDataNoti
            present(vc, animated: true, completion: nil)
        }
        
        
    }
    @objc func scrollToTop(_ notification: Notification){
        self.moveToViewController(at: 0, animated: true)
    }
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        var child:[UIViewController] = []
        if homeScreen.count != 0 {
            let child_1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: PageVNewsVC.className) as! PageVNewsVC
            child_1.name = "Tin Nổi Bật"
            child.append(child_1)
        }
        if categoryVideo.components.count != 0 {
            for value in categoryVideo.components{
                let child_1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: PageVideoVC.className) as! PageVideoVC
                child_1.name = value.name
                child_1.listData = value.category
                child_1.isPushByHome = true
                child.append(child_1)
            }
            return child
        } else {
            return child
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: NSNotification.Name("vod.stop"), object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewDidAppear(_ animated: Bool) {
        let selectedBarHeight: CGFloat = 2
        
        buttonBarView.selectedBar.frame.origin.y = buttonBarView.frame.size.height - selectedBarHeight
        buttonBarView.selectedBar.frame.size.height = selectedBarHeight
    }
    func loadDesign(){
        settings.style.buttonBarBackgroundColor = #colorLiteral(red: 0.1607843137, green: 0.2352941176, blue: 0.5882352941, alpha: 1)
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor = #colorLiteral(red: 0.1607843137, green: 0.2352941176, blue: 0.5882352941, alpha: 1)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .green
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        changeCurrentIndexProgressive = {(oldCell: ButtonBarViewCell?,newCell:ButtonBarViewCell?,progressPercentage:CGFloat,changeCurrentIndex:Bool,animated:Bool) -> Void in
            guard changeCurrentIndex == true else {return}
            newCell?.transform = CGAffineTransform(scaleX: 1, y: 1)
            oldCell?.transform = CGAffineTransform(scaleX: 1, y: 1)
            oldCell?.label.textColor = #colorLiteral(red: 0.768627451, green: 0.768627451, blue: 0.768627451, alpha: 1)
            newCell?.label.textColor = .white
            oldCell?.label.font = .systemFont(ofSize: 14)
            newCell?.label.font = .boldSystemFont(ofSize: 14)
        }
    }
    
}


