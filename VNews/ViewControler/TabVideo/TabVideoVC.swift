//
//  TabVideoVC.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 5/10/21.
//

import UIKit
import XLPagerTabStrip
class TabVideoVC: ButtonBarPagerTabStripViewController {
    @IBOutlet weak var clickFacebook: UIView!
    @IBOutlet weak var clickYoutobe: UIView!
    @IBOutlet weak var clickTiktok: UIView!
    @IBOutlet weak var clickPhone: UIView!
    @IBOutlet weak var clickSearch: UIView!
    @IBOutlet weak var clickAccount: UIView!
    @IBOutlet weak var clickLogo: UIImageView!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDesign()
        buttonBarView.selectedBar.backgroundColor = settings.style.selectedBarBackgroundColor
        buttonBarView.backgroundColor = settings.style.buttonBarBackgroundColor
        
        //open more app
        clickFacebook.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openFacbookApp)))
        clickYoutobe.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openYoutobeApp)))
        clickTiktok.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openTiktokApp)))
        clickPhone.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openPhoneCall)))
        clickSearch.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openViewSearch)))
        clickAccount.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openViewAccount)))
        clickLogo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToHomePage)))

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
        
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        var child:[UIViewController] = []
        if home1Tin.components.count != 0 {
            for (_, i) in home1Tin.components.enumerated() {
//                if index == 0 {
//
//                } else{
                    let child_1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PageVideo2VC") as! PageVideo2VC
                    child_1.name = i.name
                    child_1.privateKey = i.privateKey
                    child.append(child_1)
//                }
            }
            return child
        } else {
            let child_1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PageVideo2VC") as! PageVideo2VC
            return [child_1]
        }
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
