//
//  NativeAdsCell.swift
//  VNews
//
//  Created by Apple on 05/11/2021.
//

import UIKit
import GoogleMobileAds

//
var isLoadedThreeAdmod = false
//

class NativeAdsCell: UITableViewCell {
    static let reuseIdentifier = "NativeAdsCell"
      
    @IBOutlet weak var nativeAdView: GADNativeAdView!
    @IBOutlet weak var colorView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        colorView.backgroundColor = UIColor.white
        nativeAdView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        //loadAdmobNativeAds()
    }
    
    // Admob //
    var fullRootViewController: UIViewController!
    private var adLoader: GADAdLoader!
    func loadAdmobNativeAds(){
        let multipleAdsOptions = GADMultipleAdsAdLoaderOptions()
        multipleAdsOptions.numberOfAds = 5


        adLoader = GADAdLoader(adUnitID: "", rootViewController: fullRootViewController,
                               adTypes: [.native],
                               options: [multipleAdsOptions])
        adLoader.delegate = self
        adLoader.load(GADRequest())
    }
    //
}


extension NativeAdsCell: GADNativeAdLoaderDelegate{
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        print("didFailToReceiveAdWithError")
        print(error.localizedDescription)
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {

        nativeAdView.nativeAd = nativeAd
        nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
        //
        (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        nativeAdView.iconView?.isHidden = nativeAd.icon == nil
        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil
        nativeAdView.callToActionView?.isUserInteractionEnabled = false
        if isLoadedThreeAdmod == false {
            isLoadedThreeAdmod = true
                //NotificationCenter.default.post(name: NSNotification.Name("Admob.loaded.three"), object: nil)
        }
    }
}
