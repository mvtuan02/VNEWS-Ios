//
//  OpenMoreApp.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 6/9/21.
//

import Foundation
import UIKit

extension UIViewController{
    @objc func openFacbookApp(){
        let fbURL = URL(string: "fb://page/?id=324818237703136")
        if (UIApplication.shared.canOpenURL(fbURL!)){
            UIApplication.shared.open(fbURL!)
        } else {
            UIApplication.shared.open(URL(string: "https://www.facebook.com/vnews.gov.vn/?ref=page_internal")!)
        }
    }
    
    @objc func openYoutobeApp(){
        var youtubeUrl = NSURL(string:"youtube://channel/UCmBT5CqUxf3-K5_IU9tVtBg")!
        if UIApplication.shared.canOpenURL(youtubeUrl as URL){
            UIApplication.shared.open(youtubeUrl as URL)
        } else{
            youtubeUrl = NSURL(string:"https://www.youtube.com/channel/UCmBT5CqUxf3-K5_IU9tVtBg")!
            UIApplication.shared.open(youtubeUrl as URL)
        }
    }
    
    @objc func openTiktokApp(){
        var youtubeUrl = NSURL(string:"https://www.tiktok.com/@vnews360?lang=vi-VN")!
        if UIApplication.shared.canOpenURL(youtubeUrl as URL){
            UIApplication.shared.open(youtubeUrl as URL)
        } else{
            youtubeUrl = NSURL(string:"https://www.tiktok.com/@vnews360?lang=vi-VN")!
            UIApplication.shared.open(youtubeUrl as URL)
        }
    }
    
    @objc func openPhoneCall(){
        if let url = URL(string: "tel://0888161161") {
            UIApplication.shared.open(url)
        }
    }
    
    @objc func openViewSearch(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SearchVC") as! SearchVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func openViewAccount(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AccountVC") as! AccountVC
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func back(){
        isMessaging = false
        self.navigationController?.popViewController(animated: true)
    }
    @objc func goToHomePage(){
        NotificationCenter.default.post(name: NSNotification.Name("goHome"), object: nil)
    }
}
