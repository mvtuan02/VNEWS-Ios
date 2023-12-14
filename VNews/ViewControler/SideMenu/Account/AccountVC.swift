//
//  AccountVC.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 5/17/21.
//

import UIKit

class AccountVC: UIViewController {

    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var imgClose: UIImageView!
    @IBOutlet weak var lblChangeAvatar: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
      
        self.hideKeyboardWhenTappedAround()
        textUnderLine()
        clickView()
        imgAvatar.layer.masksToBounds = false
        imgAvatar.layer.cornerRadius = imgAvatar.frame.size.width / 2
        imgAvatar.clipsToBounds = true
        
        
    }
    
    func clickView(){
        imgAvatar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickAvatar)))
        lblChangeAvatar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickAvatar)))
    }
    
    @objc func pickAvatar(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func textUnderLine(){
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue]
        let underlineAttributedString = NSAttributedString(string: "Thay ảnh đại diện", attributes: underlineAttribute)
        lblChangeAvatar.attributedText = underlineAttributedString
        imgClose.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(close)))
    }
    
    @objc func close(){
        dismiss(animated: true, completion: nil)
    }

}

extension AccountVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image  = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage{
            imgAvatar.image = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
