//
//  AdmobManager.swift
//  MangaReader
//
//  Created by Nhuom Tang on 9/9/18.
//  Copyright © 2018 Nhuom Tang. All rights reserved.
//

import UIKit
import GoogleMobileAds
enum adType: Int {
    case facebook
    case admob
}

enum clickType: Int {
    case facebook
    case admob
    case none
    case all
}

let adSize = UIDevice.current.userInterfaceIdiom == .pad ? kGADAdSizeBanner: kGADAdSizeBanner

class AdmobManager: NSObject, GADNativeAdDelegate {
    
    static let shared = AdmobManager()
    

    
    var isShowAds = false
    var counter = 1
    
    var adType: adType = .admob
    var clickType: clickType = .none
    var fullErrorType: clickType = .none
    var nativeType: adType = .facebook
    
    var fullRootViewController: UIViewController!
    
    //Native ads
    private var adLoader: GADAdLoader!
    var admobNativeAds: [GADNativeAd] = []
    var loadErrorNativeAdmob = 0
    var loadErrorFullAdmob = 0
    
    var nativeFBIndex = 0
    var nativeAdmobIndex = 0
    
    var isTimer = true
    
    override init() {
        super.init()
        self.loadAllNativeAds()
        counter = numberToShowAd - 1
        if randomBool(){
            adType = .admob
            nativeType = .admob
        }else{
            adType = .admob
            nativeType = .admob
        }
    }
    
    func randomBool() -> Bool {
        return arc4random_uniform(2) == 0
    }
    
//    func createBannerView(inVC: UIViewController) -> UIView{
//        let witdh = DEVICE_WIDTH
//        let frame = CGRect.init(x: (witdh - adSize.size.width)/2 , y: 0, width: adSize.size.width, height: adSize.size.height)
//        let bannerView = GADBannerView.init(adSize: adSize)
//        bannerView.adUnitID = admobBanner
//        bannerView.rootViewController = inVC
//        bannerView.delegate = self
//        bannerView.frame = frame
//        inVC.view.addSubview(bannerView)
//        let request = GADRequest()
//        bannerView.load(request)
//
//        let tempView = UIView.init(frame: CGRect.init(x:0 , y: 0, width: DEVICE_WIDTH, height: adSize.size.height))
//        tempView.addSubview(bannerView)
//        return tempView
//    }
    func loadAllNativeAds(){
        if !isTimer {
            return
        }
        isTimer = false
        let _ = Timer.scheduledTimer(withTimeInterval: 70, repeats: false) { [weak self] (timer) in
            self?.isTimer = true
        }
        self.loadAdmobNativeAds()
    }

    func getAdmobNativeAds() -> GADNativeAd?{
        if admobNativeAds.count > nativeAdmobIndex{
            let item = admobNativeAds[nativeAdmobIndex]
            nativeAdmobIndex = nativeAdmobIndex + 1
            return item
        } else {
            nativeAdmobIndex = 0
            if nativeAdmobIndex < admobNativeAds.count {
                let item = admobNativeAds[nativeAdmobIndex]
                nativeAdmobIndex = nativeAdmobIndex + 1
                return item
            }
            return nil
        }
        //return admobNativeAds.last
    }
    
    func loadAdmobNativeAds(){
        if loadErrorNativeAdmob >= 1{
            return
        }
        if nativeAdmobIndex > 0{
            if admobNativeAds.count > (nativeAdmobIndex){
                return
            }
        }
        print("loadAdmobNativeAds")
        let multipleAdsOptions = GADMultipleAdsAdLoaderOptions()
        multipleAdsOptions.numberOfAds = 5
        adLoader = GADAdLoader(adUnitID: adNativeAd, rootViewController: fullRootViewController, adTypes: [GADAdLoaderAdType.native], options: [multipleAdsOptions])
        adLoader.delegate = self
        let request = GADRequest()
        adLoader.load(request)
    }
}

extension AdmobManager: GADVideoControllerDelegate {
    func videoControllerDidEndVideoPlayback(_ videoController: GADVideoController) {
    }
}

extension AdmobManager: GADAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        print("\(adLoader) failed with error: \(error.localizedDescription)")
    }
}
//extension AdmobManager: GADBannerViewDelegate {
//    func loadBannerView(inVC: UIViewController) {
//        let bannerView = GADBannerView.init(adSize: kGADAdSizeSmartBannerPortrait)
//        bannerView.translatesAutoresizingMaskIntoConstraints = false
//        inVC.view.addSubview(bannerView)
//        inVC.view.addConstraints(
//            [NSLayoutConstraint(item: bannerView,
//                                attribute: .bottom,
//                                relatedBy: .equal,
//                                toItem: inVC.bottomLayoutGuide,
//                                attribute: .top,
//                                multiplier: 1,
//                                constant: 0),
//             NSLayoutConstraint(item: bannerView,
//                                attribute: .centerX,
//                                relatedBy: .equal,
//                                toItem: inVC.view,
//                                attribute: .centerX,
//                                multiplier: 1,
//                                constant: 0)
//            ])
//        bannerView.adUnitID = admobBanner
//        bannerView.rootViewController = inVC
//        bannerView.delegate = self
//        let request = GADRequest()
//        bannerView.load(request)
//    }
//
//    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
//        bannerView.alpha = 0
//        UIView.animate(withDuration: 1, animations: {
//            bannerView.alpha = 1
//        })
//    }
//}
extension AdmobManager: GADNativeAdLoaderDelegate {
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        print("didReceive nativeAd")
        admobNativeAds.append(nativeAd)
        print(nativeAd.headline)
        NotificationCenter.default.post(name: NSNotification.Name("Admob.loaded"), object: nil)
    }

}
