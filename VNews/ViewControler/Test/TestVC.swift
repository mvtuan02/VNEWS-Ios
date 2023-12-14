//
//  TestVC.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 6/26/21.
//

import UIKit

class TestVC: UIViewController {
    
    let tbl:UITableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawView()
        tbl.delegate = self
        tbl.dataSource = self
        tbl.register(UINib(nibName: "CellTblTest", bundle: nil), forCellReuseIdentifier: "CellTblTest")
        
    }
    
    func drawView(){
        self.view.addSubview(tbl)
        tbl.translatesAutoresizingMaskIntoConstraints = false
        tbl.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        tbl.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        tbl.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        tbl.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
    }
}

extension TestVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellTblTest", for: indexPath) as! CellTblTest
        let item = home1Tin.components[0].category.media[indexPath.row]
        cell.title.text = item.name
        if let url = URL(string: tinMoi.cdn.imageDomain + item.thumnail.replacingOccurrences(of: "\\", with: "/" )){
            cell.img.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "image_default"), options:[.cacheOriginalImage,.transition(.fade(1))]){_ in
                cell.title.text = item.name
                cell.setImage()

            }
        }
        return cell

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
