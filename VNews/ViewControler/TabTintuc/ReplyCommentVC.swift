//
//  ReplyCommentVC.swift
//  VTVNew
//
//  Created by Nguyễn Văn Chiến on 3/8/21.
//

import UIKit

class ReplyCommentVC: UIViewController {
    @IBOutlet weak var lblPublished: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblContent: UILabel!
    @IBOutlet weak var tf: UITextField!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var tbl: UITableView!
    @IBOutlet weak var tfHoTen: UITextField!
    
    var listCmt = [ModelComment]()
    var listCmtById = [ModelComment]()
    var contenType = ""
    var slug = ""
    var postName = ""
    var published = ""
    var name = ""
    var content = ""
    var countLike = ""
    var idCmt = 0
    var postId = 0
    
    @IBOutlet weak var viewBack: UIView!
    //    @objc func tapSearch(_ sender: UITapGestureRecognizer){
//        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebviewSearch") as! WebviewSearch
//        self.present(vc, animated: true, completion: nil)
//    }
    @objc func didSelectViewBack(_ sender: Any){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tfHoTen.delegate = self
        tfHoTen.attributedPlaceholder = NSAttributedString(string: "Họ và tên*", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        tf.delegate = self
        tf.attributedPlaceholder = NSAttributedString(string: "Viết bình luận của bạn", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        lblName.text = name
        lblContent.text = content
        lblPublished.text = published
        btnSend.layer.masksToBounds = true
        btnSend.layer.cornerRadius = scale * 10
        viewBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectViewBack(_ :))))
        tbl.delegate = self
        tbl.dataSource = self
        
        for i in listCmt {
            if i.parentId == self.idCmt{
                listCmtById.append(i)
            }
        }
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "icLogo")
        let contentView = UIView()
        self.navigationItem.titleView = contentView
        self.navigationItem.titleView?.addSubview(imageView)
        imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        //setup rightbarbutton item
        let menuBtnRight = UIButton(type: .custom)
        menuBtnRight.frame = CGRect(x: 0.0, y: 0.0, width: 20, height: 20)
        menuBtnRight.setImage(UIImage(named:"icSearch"), for: .normal)
        //            menuBtn.addTarget(self, action: #selector(vc.onMenuButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        let menuBarItemRight = UIBarButtonItem(customView: menuBtnRight)
        menuBarItemRight.customView?.widthAnchor.constraint(equalToConstant: 24).isActive = true
        menuBarItemRight.customView?.heightAnchor.constraint(equalToConstant: 24).isActive = true
        self.navigationItem.rightBarButtonItem = menuBarItemRight
        
        //settup leftBarbutton item
        let menuBtnLeft = UIButton(type: .custom)
        menuBtnLeft.frame = CGRect(x: 0.0, y: 0.0, width: 20, height: 20)
        menuBtnLeft.setImage(UIImage(named:"icBack"), for: .normal)
        menuBtnLeft.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(back)))
        let menuBarItemLeft = UIBarButtonItem(customView: menuBtnLeft)
        menuBarItemLeft.customView?.widthAnchor.constraint(equalToConstant: 28).isActive = true
        menuBarItemLeft.customView?.heightAnchor.constraint(equalToConstant: 24).isActive = true
        self.navigationItem.leftBarButtonItem = menuBarItemLeft
//        menuBtnRight.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapSearch(_:))))
        
        tbl.register(UINib(nibName: "CellContentComment", bundle: nil), forCellReuseIdentifier: "CellContentComment")
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    @IBOutlet weak var bottomConstant: NSLayoutConstraint!
    var isKeyboardShowed = false
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            if isKeyboardShowed {
                
            } else {
                bottomConstant.constant += keyboardHeight
                view.layoutIfNeeded()
            }
            isKeyboardShowed = true
        }
    }
    @IBAction func btnSend(_ sender: Any) {
        tf.endEditing(true)
        isKeyboardShowed = false
        bottomConstant.constant = 16
        view.layoutIfNeeded()
        if tfHoTen.text! == "" {
            let alert = UIAlertController(title: "", message: "Không bỏ trống họ và tên", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { action in
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        if tf.text! == "" {
            let alert = UIAlertController(title: "", message: "Không bỏ trống bình luận", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { action in
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        let item = ModelComment()
        item.postId = postId
        item.user = name
        item.message = content
        item.parentId = idCmt
        item.postName = postName
        item.createdDate = Date().getTimeString5()
        var link = ""
        switch contenType {
        case "0":
            link = domainShare + "video/" + slug
        case "1", "6":
            link = domainShare + "news/" + slug
        case "2":
            link = domainShare + "magazine/" + slug
        case "3":
            link = domainShare + "inforgraphic/" + slug
        case "4":
            link = domainShare + "longform/" + slug
        case "5":
            link = domainShare + "live/" + slug
        default:
            link = domainShare
        }
        item.urlPost = link
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

extension ReplyCommentVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        listCmtById.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellContentComment", for: indexPath) as! CellContentComment
     
        
        cell.lblName.text = listCmtById.count != 0 ? listCmtById[indexPath.row].user : ""
        cell.lblContent.text = listCmtById.count != 0 ? listCmtById[indexPath.row].message : ""
//        cell.countLike.setTitle(" \(listCmtById[indexPath.row].like) thích", for: .normal)
        
        let schedule = listCmtById.count != 0 ? listCmtById[indexPath.row].createdDate : ""
        let timePass = publishedDate(schedule: schedule)
        cell.lblPublished.text = timePass
        
        
            cell.lblMoreReply.isHidden = true
            cell.btnMoreReplyConstrainTop.constant = scale * -4
            cell.btnMoreReplyConstrainBottom.constant = scale * -4
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
extension ReplyCommentVC: UITextFieldDelegate, UITextViewDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        tf.endEditing(true)
        tfHoTen.endEditing(true)
        isKeyboardShowed = false
        bottomConstant.constant = 16
        view.layoutIfNeeded()
        return true
    }
}
