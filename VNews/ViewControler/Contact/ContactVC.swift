//
//  ContactVC.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 6/24/21.
//

import UIKit

class ContactVC: UIViewController {

    @IBOutlet weak var viewBack: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        viewBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(back)))
    }
}
