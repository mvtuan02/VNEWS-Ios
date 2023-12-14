//
//  WebViewVC.swift
//  VNews
//
//  Created by Apple on 20/09/2021.
//

import UIKit
import WebKit
class WebViewVC: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = URL(string: "https://ovp.vnews.tek4tv.vn/MediaPublish"){
            webView.load(URLRequest(url: url))
        }
        
        // Do any additional setup after loading the view.
    }

}
