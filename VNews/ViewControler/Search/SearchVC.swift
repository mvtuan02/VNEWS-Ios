//
//  SearchVC.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 5/18/21.
//

import UIKit

class SearchVC: UIViewController {
    var listResultData = [ModelResultSearch]()
    var listSuggestion = [ModelSugestion]()
    @IBOutlet weak var clvResutl: UICollectionView!
    @IBOutlet weak var tfInput: UITextField!
    @IBOutlet weak var viewBack: UIView!
    @IBOutlet weak var viewMicrophone: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.navigationController?.isNavigationBarHidden = true
        let attributes = [
            NSAttributedString.Key.font : UIFont(name: "OpenSans-SemiBold", size: 16)!
        ]
        tfInput.attributedPlaceholder = NSAttributedString(string: "Nhập nội dung tìm kiếm", attributes:attributes)
        
        viewBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(back)))
        viewMicrophone.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectViewMicrophone(_:))))
        tfInput.delegate = self
        tfInput.addTarget(self, action: #selector(textFieldDidChange(_:)),
                                                         for: .editingChanged)
        setupClv()
        registerCell()
        setUpLayout()
        
        // Change place holder tf
        tfInput.attributedPlaceholder = NSAttributedString(string: "Nhập nội dung tìm kiếm",
                                                           attributes: [NSAttributedString.Key.foregroundColor: UIColor(hexString: "#888888")])

    }
    //Color Status Bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            // Fallback on earlier versions
            return .default
        }
    }
    func setupClv(){
        clvResutl.delegate = self
        clvResutl.dataSource = self
    }
    
    func registerCell(){
        clvResutl.register(UINib(nibName: "CellResultSuggestionSearch", bundle: nil), forCellWithReuseIdentifier: CellResultSuggestionSearch.reuseIdentifier)
    }
    
    func setUpLayout(){
        let layoutSuggestion = UICollectionViewFlowLayout()
        layoutSuggestion.itemSize = CGSize(width: clvResutl.bounds.width, height: scaleW * 56)
        clvResutl.collectionViewLayout = layoutSuggestion
    }
    
    @objc func didSelectViewMicrophone(_ sender: Any){
        let vc = SpeechToTextVC(nibName: SpeechToTextVC.className, bundle: nil)
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false, completion: nil)
        vc.onComplete = { textSearch in
            APIService.shared.getDataSearch(keySearch: textSearch) { (data, error) in
                if let data = data as? [MediaModel]{
                    let vc = ResultVC(nibName: ResultVC.className, bundle: nil)
                    vc.listData = data
                    vc.textSearch = textSearch
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                }
            }
        }
    }
    
}
extension SearchVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        tfInput.endEditing(true)
        APIService.shared.getDataSearch(keySearch: textField.text ?? "") { (data, error) in
            if let data = data as? [MediaModel]{
                let vc = ResultVC(nibName: ResultVC.className, bundle: nil)
                vc.listData = data
                vc.textSearch = textField.text ?? ""
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
        }
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        APIService.shared.getSugestionSearch(keySearch: textField.text!) { (data, error) in
            if let data = data as? [ModelSugestion]{
                self.listSuggestion = data
                DispatchQueue.main.async {
                    self.clvResutl.reloadData()
                }
            }
        }
    }
}

extension SearchVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listSuggestion.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = clvResutl.dequeueReusableCell(withReuseIdentifier: "CellResultSuggestionSearch", for: indexPath) as! CellResultSuggestionSearch
        cell.lblName.text = listSuggestion[indexPath.row].name
        print(listSuggestion[indexPath.row].name);
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = listSuggestion[indexPath.row]
//        print(item.payload)
        APIService.shared.getVideoRelated(privateKey: item.payload) { (data, error) in
            if let data = data as? MediaModel {
                APIService.shared.getContentPlaylist(privateKey: data.keyword) { (listData, error) in
                    if let listData = listData as? CategoryModel{
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: VideoDetailVC.className) as! VideoDetailVC
                        vc.data = data
                        vc.listData = listData.media
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                    } else {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: VideoDetailVC.className) as! VideoDetailVC
                        vc.data = data
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}
