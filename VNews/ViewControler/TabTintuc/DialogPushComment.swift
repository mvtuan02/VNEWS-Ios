//
//  DialogPushComment.swift
//  VTVNew
//
//  Created by Nguyễn Văn Chiến on 2/24/21.
//

import UIKit
import Alamofire

class DialogPushComment: UIViewController {
    var content = ""
    var idArticle = 0
    var idComment = 0
    
    @IBOutlet weak var viewPushCmt: UIView!
    @IBOutlet weak var tfname: UITextField!
    @IBOutlet weak var btnSend: UIButton!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tfname.delegate = self
        tfname.attributedPlaceholder = NSAttributedString(string: "Họ tên*", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])

        btnSend.layer.cornerRadius = scale * 10
        
        viewPushCmt.layer.masksToBounds = true
        viewPushCmt.layer.cornerRadius = scale * 15
        
    }
    @IBAction func btnSend(_ sender: Any) {
        tfname.endEditing(true)
        let userName = tfname.text!
            
        if userName == ""{
            let alert = UIAlertController(title: "", message: "Không bỏ trống họ và tên", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { action in
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            let item = ModelComment()
            item.postId = idArticle
            item.user = userName
            item.message = content
            item.parentId = idComment
            item.createdDate = Date().getTimeString5()
//            item.postName = data.name
//            item.urlPost = data.slug
            APIService.shared.replyComment(item: item) { data, error in
                if let data = data as? String {
                    if data == "true" {
                        let alert = UIAlertController(title: "", message: "Gửi thành công!", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { action in
                            self.dismiss(animated: true, completion: nil)
                        }))
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        let alert = UIAlertController(title: "", message: "Gửi thất bại!", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { action in
                            self.dismiss(animated: true, completion: nil)
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    @IBAction func btnCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
}
extension DialogPushComment: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        tfname.endEditing(true)
        
        return true
    }
}
