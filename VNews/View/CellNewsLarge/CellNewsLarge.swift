//
//  CellNewsLarge.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 6/21/21.
//

import UIKit
import GoogleMobileAds

class CellNewsLarge: UICollectionViewCell {
    @IBOutlet weak var nativeAdView: GADNativeAdView!
    @IBOutlet weak var line: UIView!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var viewShare: UIView!
    @IBOutlet weak var viewLike: UIView!
    @IBOutlet weak var imgLike: UIImageView!
    var delegate: CellNewLargeDelegate!
    var item: MediaModel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        viewShare.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didShare(_:))))
        viewLike.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didLike)))
    }
    @objc func didShare(_ sender: Any){
        self.delegate?.didShare(self)
    }
    @objc func didLike(){
        self.imgLike.image = #imageLiteral(resourceName: "icons8-facebook-like-64 (1)")
        self.delegate?.didLike(self)
    }
    override func prepareForReuse() {
        self.imgLike.image = #imageLiteral(resourceName: "icons8-facebook-like-64")
    }
    func setupHeader(nativeAd: GADNativeAd) {
        nativeAdView.nativeAd = nativeAd
        //
        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
        
        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        nativeAdView.bodyView?.isHidden = nativeAd.body == nil

        (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction?.lowercased().capitalizingFirstLetter(), for: .normal)

        nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil
        nativeAdView.callToActionView?.isUserInteractionEnabled = false
        nativeAdView.callToActionView?.backgroundColor = #colorLiteral(red: 0.159235239, green: 0.2396469116, blue: 0.5891875029, alpha: 1)
        nativeAdView.callToActionView?.tintColor = .white
        (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        nativeAdView.iconView?.isHidden = nativeAd.icon == nil

        (nativeAdView.starRatingView as? UIImageView)?.image = imageOfStars(from: nativeAd.starRating)
        nativeAdView.starRatingView?.isHidden = nativeAd.starRating == nil

        (nativeAdView.storeView as? UILabel)?.text = nativeAd.store
        nativeAdView.storeView?.isHidden = nativeAd.store == nil

        (nativeAdView.priceView as? UILabel)?.text = nativeAd.price
        nativeAdView.priceView?.isHidden = nativeAd.price == nil

        (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
        nativeAdView.advertiserView?.isHidden = nativeAd.advertiser == nil
    }
    func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
      guard let rating = starRating?.doubleValue else {
        return nil
      }
      if rating >= 5 {
        return UIImage(named: "stars_5")
      } else if rating >= 4.5 {
        return UIImage(named: "stars_4_5")
      } else if rating >= 4 {
        return UIImage(named: "stars_4")
      } else if rating >= 3.5 {
        return UIImage(named: "stars_3_5")
      } else {
        return nil
      }
    }
}
protocol CellNewLargeDelegate{
    func didShare(_ cell: CellNewsLarge)
    func didLike(_ cell: CellNewsLarge)
}
