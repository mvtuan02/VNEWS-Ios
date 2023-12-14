//
//  CellContentComment.swift
//  VTVNew
//
//  Created by Nguyễn Văn Chiến on 2/2/21.
//

import UIKit

class CellContentComment: UITableViewCell {

    @IBOutlet weak var lblMoreReply: UILabel!
    @IBOutlet weak var btnMoreReplyConstrainBottom: NSLayoutConstraint!
    @IBOutlet weak var btnMoreReplyConstrainTop: NSLayoutConstraint!
    @IBOutlet weak var line: UIView!
    @IBOutlet weak var reply: UIButton!
    @IBOutlet weak var lblContent: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPublished: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}

