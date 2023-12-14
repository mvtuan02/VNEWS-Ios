//
//  WellcomeVC.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 5/10/21.
//

import UIKit

var tinMoi: CategoryModel!
var home1Tin: CategoryModel!
var live: CategoryModel!
var chuongTrinh: CategoryModel!
var categoryVideo: CategoryModel!
var homeScreen: [Any] = []
var domainShare: String = ""
class WellcomeVC: UIViewController {

    fileprivate var count = 0
    fileprivate var homeCate = CategoryModel()
    func loadData(){
        APIService.shared.getHomeScreen { data, error in
            if error != nil {
                return
            }
            if let data = data as? CategoryModel {
                self.homeCate = data
                self.loadComponents()
            }
        }
    }
    func loadComponents(){
        if count < homeCate.components.count {
            let item = homeCate.components[count]
            APIService.shared.getHomeComponent(url: item.url, type: item.layout.type) { data, error in
                if error != nil {
                    return
                }
                if let data = data{
                    homeScreen.append(data)
                    self.count += 1
                    if homeScreen.count == self.homeCate.components.count {

                                APIService.shared.getCategoryVideo { (data, error) in
                                    if let data = data as? CategoryModel{
                                        categoryVideo = data
                                    }
                                    APIService.shared.getHome1TinPlaylist { (data, error) in
                                        if let data = data as? CategoryModel{
                                            home1Tin = data
                                        }
//                                        print(homeScreen)
                                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "RootTabbar") as! RootTabbar
                                        self.navigationController?.pushViewController(vc, animated: true)
                                    }
                                }

                    } else {
                        self.loadComponents()
                    }
                }
            }
        }
    }
    var versionAppstore = ""
    var versionApp = ""
    func isUpdateAvailable() throws -> Bool {
        guard let info = Bundle.main.infoDictionary,
              let currentVersion = info["CFBundleShortVersionString"] as? String,
              let identifier = info["CFBundleIdentifier"] as? String,
              let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
            throw VersionError.invalidBundleInfo
        }
        let data = try Data(contentsOf: url)
        guard let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any] else {
            throw VersionError.invalidResponse
        }
        if let result = (json["results"] as? [Any])?.first as? [String: Any], let version = result["version"] as? String {
            //print("Version: \(version)")
            //print("CurrenVersion: \(currentVersion)")
            self.versionApp = currentVersion
            self.versionAppstore = version
            return version != currentVersion
        }
        throw VersionError.invalidResponse
    }
    
    enum VersionError: Error {
        case invalidResponse, invalidBundleInfo
    }
    
    var checkClickUpdate = false
    @objc func willResignActive(){
        if checkClickUpdate {
            loadData()
        }
    }
    func getCurrentVersion() throws {
        guard let info = Bundle.main.infoDictionary,
              let currentVersion = info["CFBundleShortVersionString"] as? String
        else {
            throw VersionError.invalidBundleInfo
        }
        self.versionApp = currentVersion
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        APIService.shared.getDomainShare { data, error in
            if let data = data as? String {
                domainShare = data
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //AdmobManager.shared.createBannerView(inVC: self)
        do {
            try getCurrentVersion()
        } catch {
            print(error)
        }
        self.navigationController?.isNavigationBarHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        if #available(iOS 12.0, *) {
            if NetworkMonitor.shared.isConnected {
                APIService.shared.getAppVersion { response, error in
                    if error != nil {
                        self.loadData()
                    } else {
                        if let data = response as? String {
                            if data != self.versionApp {
                                let alert = UIAlertController(title: "Phiên bản mới Vnews", message: "Chúng tôi vừa cập nhật phiên bản mới trên Store với những cải tiến đáng kể. Bạn có muốn cập nhật phiên bản mới không", preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: "Cập nhật", style: .cancel, handler: { action in
                                    self.checkClickUpdate = true
                                    if let url = URL(string: "itms-apps://itunes.apple.com/app/1340851623"),
                                       UIApplication.shared.canOpenURL(url){
                                        UIApplication.shared.open(url)
                                    }
                                }))
                                alert.addAction(UIAlertAction(title: "Bỏ qua", style: .destructive, handler: { action in
                                    self.loadData()
                                }))
                                self.present(alert, animated: true, completion: nil)
                            } else {
                                self.loadData()
                            }
                        } else {
                            self.loadData()
                        }
                    }
                }
            } else {
                let alert = UIAlertController(title: "Không có kết nối mạng", message: "Hãy kiểm tra lại kết nối mạng của bạn trong cài đặt", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Thoát", style: UIAlertAction.Style.default, handler: { action in
                    exit(0)}
                                             ))
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            // Fallback on earlier versions
            self.loadData()
        }
    }
}
