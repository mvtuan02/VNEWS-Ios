//
//  NotFoundVC.swift
//  VNews
//
//  Created by dovietduy on 6/18/21.
//

import UIKit

class NotFoundVC: UIViewController {

    @IBOutlet weak var viewBack: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        // Do any additional setup after loading the view.
        viewBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectViewBack(_:))))
    }
    @objc func didSelectViewBack(_ sender: Any){
        dismiss(animated: true, completion: nil)
    }
}
