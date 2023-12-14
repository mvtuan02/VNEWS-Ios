//
//  SideMenuVC.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 5/13/21.
//

import UIKit

class SideMenuVC: UIViewController {

    @IBOutlet weak var imgSetting: UIImageView!
    @IBOutlet weak var viewAccount: UIView!
    @IBOutlet weak var viewXemLai: UIView!
    @IBOutlet weak var viewChuongTrinh: UIView!
    @IBOutlet weak var viewThoiSu: UIView!
    @IBOutlet weak var viewLichPhatSong: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        viewXemLai.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectViewXemLai)))
        viewChuongTrinh.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectViewChuongTrinh)))
        viewThoiSu.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectViewThoiSu)))
        viewLichPhatSong.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectViewLichPhatSong)))
        viewAccount.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectViewAccount)))
        imgSetting.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectImgSetting)))

    }
    
    @objc func didSelectViewXemLai(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "XemLaiVNewsVC") as! XemLaiVNewsVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didSelectViewChuongTrinh(){
    }
    
    @objc func didSelectViewThoiSu(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "BanTinThoiSuVC") as! BanTinThoiSuVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didSelectViewLichPhatSong(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LichPhatSongVC") as! LichPhatSongVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didSelectViewAccount(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AccountVC") as! AccountVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func didSelectImgSetting(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SettingVC") as! SettingVC
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
