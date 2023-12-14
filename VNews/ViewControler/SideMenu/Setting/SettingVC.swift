//
//  SettingVC.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 5/17/21.
//

import UIKit

class SettingVC: UIViewController {
    @IBOutlet weak var myNavi: UINavigationItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        actionBar()

    }
    

    func actionBar(){
        navigationController?.navigationBar.barTintColor = UIColor(hexString: "#ffffff")
        navigationController?.navigationBar.isTranslucent = false
        self.myNavi.title = "Cài đặt";
        
        //settup leftBarbutton item
        let menuBtnLeft = UIButton(type: .custom)
        menuBtnLeft.frame = CGRect(x: 0.0, y: 0.0, width: 30, height: 30)
        menuBtnLeft.setImage(UIImage(named:"icClose"), for: .normal)
        menuBtnLeft.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectViewBack(_:))))
        //            menuBtn.addTarget(self, action: #selector(vc.onMenuButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        let menuBarItemLeft = UIBarButtonItem(customView: menuBtnLeft)
        menuBarItemLeft.customView?.widthAnchor.constraint(equalToConstant: 24).isActive = true
        menuBarItemLeft.customView?.heightAnchor.constraint(equalToConstant: 24).isActive = true
        self.myNavi.leftBarButtonItem = menuBarItemLeft
    
    }
    @objc func didSelectViewBack(_ sender: Any){
        self.navigationController?.popViewController(animated: true)
    }

}
