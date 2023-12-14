//
//  RootTabbar.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 5/10/21.
//

import UIKit
import AVFoundation
class RootTabbar: UITabBarController, UITabBarControllerDelegate {
    var tabBarIteam = UITabBarItem()
    override func viewDidLoad() {
        super.viewDidLoad()
        let selectedImage0 = UIImage(named: "icHomeSelected")?.withRenderingMode(.alwaysOriginal)
        let deSelectedImage0 = UIImage(named: "icHomeUnSelected")?.withRenderingMode(.alwaysOriginal)
        tabBarIteam = self.tabBar.items![0]
        tabBarIteam.image = deSelectedImage0
        tabBarIteam.selectedImage = selectedImage0

        let selectedImage1 = UIImage(named: "icVideoSelected")?.withRenderingMode(.alwaysOriginal)
        let deSelectedImage1 = UIImage(named: "icVideoUnSelected")?.withRenderingMode(.alwaysOriginal)
        tabBarIteam = self.tabBar.items![1]
        tabBarIteam.image = deSelectedImage1
        tabBarIteam.selectedImage = selectedImage1

        let selectedImage2 = UIImage(named: "icNewsSelected")?.withRenderingMode(.alwaysOriginal)
        let deSelectedImage2 = UIImage(named: "icNewsUnSelected")?.withRenderingMode(.alwaysOriginal)
        tabBarIteam = self.tabBar.items![2]
        tabBarIteam.image = deSelectedImage2
        tabBarIteam.selectedImage = selectedImage2

        let selectedImage3 = UIImage(named: "icTiviSelected")?.withRenderingMode(.alwaysOriginal)
        let deSelectedImage3 = UIImage(named: "icTiviUnSelected")?.withRenderingMode(.alwaysOriginal)
        tabBarIteam = self.tabBar.items![3]
        tabBarIteam.image = deSelectedImage3
        tabBarIteam.selectedImage = selectedImage3

        let selectedImage4 = UIImage(named: "icMucSelected")?.withRenderingMode(.alwaysOriginal)
        let deSelectedImage4 = UIImage(named: "icMucUnSelected")?.withRenderingMode(.alwaysOriginal)
        tabBarIteam = self.tabBar.items![4]
        tabBarIteam.image = deSelectedImage4
        tabBarIteam.selectedImage = selectedImage4
        
        self.selectedIndex = 0
        //Change Text color selected
        self.tabBar.tintColor = UIColor(hexString: "#3A53A4")
        
        //Shadow
        tabBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        tabBar.layer.shadowRadius = 2
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.2
        
        //Change line top tabbar
        UITabBar.appearance().backgroundImage = UIImage.colorForNavBar(color: .white)
        UITabBar.appearance().shadowImage = UIImage.colorForNavBar(color: .white)
        
        //
        NotificationCenter.default.addObserver(self, selector: #selector(goHome(_:)), name: NSNotification.Name("goHome"), object: nil)
        self.delegate = self
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let items = tabBar.items else { return }
        guard let index = items.firstIndex(of: item) else{return}
        if index == 1{
            NotificationCenter.default.post(name: NSNotification.Name("video.refresh"), object: nil)
        }
        if index == 2{
            NotificationCenter.default.post(name: NSNotification.Name("news.refresh"), object: nil)
        }
 
    }

    @objc func goHome(_ sender: Any){
        guard let tabbarController = UIApplication.shared.tabbarController() as? RootTabbar else { return }
        tabbarController.selectedIndex = 0  // Will redirect to first tab ( index = 0 )
        NotificationCenter.default.post(name: NSNotification.Name("scrollView.scrollToTop"), object: nil)
    }
}
