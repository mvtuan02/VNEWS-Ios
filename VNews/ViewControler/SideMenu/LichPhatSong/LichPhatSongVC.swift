//
//  LichPhatSongVC.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 5/13/21.
//

import UIKit

class LichPhatSongVC: UIViewController {
    @IBOutlet weak var viewLeft: UIView!
    @IBOutlet weak var viewRight: UIView!
    
    @IBOutlet weak var clv: UICollectionView!
    @IBOutlet weak var myNavi: UINavigationItem!
    @IBOutlet weak var lblTimePicker: UILabel!
    @IBOutlet weak var lblTimeLive: UILabel!
    @IBOutlet weak var lblTextLive: UILabel!
    @IBOutlet weak var heightConstaint: NSLayoutConstraint!
    @IBOutlet weak var heightConstaint2: NSLayoutConstraint!
    lazy var listData: [ScheduleModel] = []
    lazy var datePicker = Date()
    lazy var timer = Timer()
    override func viewDidLoad() {
        super.viewDidLoad()
        actionBar()
        clv.delegate = self
        clv.dataSource = self
        clv.register(UINib(nibName: "CellLichPhatSong", bundle: nil), forCellWithReuseIdentifier: "CellLichPhatSong")
        let layout = UICollectionViewFlowLayout()
        clv.collectionViewLayout = layout
        viewLeft.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectViewLeft(_:))))
        viewRight.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectViewRight(_:))))
        viewRight.isHidden = true
        //
        lblTimePicker.text = datePicker.getTimeString2()
        hideLiveView()
        //
        
        APIService.shared.getSchedule(day: datePicker.getTimeString()) {[weak self] (data, error) in
            if let data = data as? [ScheduleModel] {
                self?.listData = data
                self?.clv.reloadData()
                self?.checkLive()
            }
        }
        timerLoop()
    }
    func timerLoop(){
        if datePicker.getTimeString() == Date().getTimeString(){
            self.checkLive()
            timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: {[weak self] timer in
                self?.checkLive()
            })
        } else{
            timer.invalidate()
        }
    }
    func checkLive(){
        for (index, item) in self.listData.enumerated(){
            let date1 = Date()
            let date2 = item.startTime.toDate()
            let date3 = item.endTime.toDate()
            if date2! <= date1 && date1 <= date3! {
                showLiveView()
                lblTimeLive.text = item.getTime()
                lblTextLive.text = item.description
                clv.scrollToItem(at: IndexPath(row: index, section: 0), at: .top, animated: true)
            }
        }
    }
    func hideLiveView() {
        heightConstaint.constant = 0
        heightConstaint2.constant = 0
    }
    func showLiveView(){
        heightConstaint.constant = 115 * scaleH
        heightConstaint2.constant = 4 * scaleH
    }
    @objc func didSelectViewLeft(_ sender: Any){
        datePicker = datePicker.dayBefore()
        lblTimePicker.text = datePicker.getTimeString2()
        hideLiveView()
        viewRight.isHidden = false
        clv.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        APIService.shared.getSchedule(day: datePicker.getTimeString()) {[weak self] (data, error) in
            if let data = data as? [ScheduleModel] {
                self?.listData = data
                self?.clv.reloadData()
                self?.timerLoop()
            }
        }
    }
    @objc func didSelectViewRight(_ sender: Any){
        datePicker = datePicker.dayAfter()
        lblTimePicker.text = datePicker.getTimeString2()
        hideLiveView()
        clv.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        APIService.shared.getSchedule(day: datePicker.getTimeString()) {[weak self] (data, error) in
            if let data = data as? [ScheduleModel] {
                self?.listData = data
                self?.clv.reloadData()
                self?.timerLoop()
            }
        }
        //
        if datePicker.getTimeString() == Date().getTimeString(){
            viewRight.isHidden = true
        }
    }
    func actionBar(){
        navigationController?.navigationBar.barTintColor = UIColor(hexString: "#ffffff")
        navigationController?.navigationBar.isTranslucent = false
        self.myNavi.title = "Lịch phát sóng";
        
        //settup leftBarbutton item
        let menuBtnLeft = UIButton(type: .custom)
        menuBtnLeft.frame = CGRect(x: 0.0, y: 0.0, width: 30, height: 30)
        menuBtnLeft.setImage(UIImage(named:"icArrLeft"), for: .normal)
        menuBtnLeft.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectViewBack(_:))))
        //            menuBtn.addTarget(self, action: #selector(vc.onMenuButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        let menuBarItemLeft = UIBarButtonItem(customView: menuBtnLeft)
        menuBarItemLeft.customView?.widthAnchor.constraint(equalToConstant: 24).isActive = true
        menuBarItemLeft.customView?.heightAnchor.constraint(equalToConstant: 24).isActive = true
        self.myNavi.leftBarButtonItem = menuBarItemLeft
    
    }
    @objc func didSelectViewBack(_ sender: Any){
        self.navigationController?.popViewController(animated: true)
    }

}

extension LichPhatSongVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        listData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = clv.dequeueReusableCell(withReuseIdentifier: "CellLichPhatSong", for: indexPath) as! CellLichPhatSong
        let item = listData[indexPath.row]
        cell.lblTitle.text = item.name.trimmingCharacters(in: .whitespacesAndNewlines)//.lowercased().capitalizingFirstLetter()
        cell.lblTime.text = item.getTime()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 0.21 * UIScreen.main.bounds.width )
    }
    
}
