//
//  ManyReadCell.swift
//  VNews
//
//  Created by Apple on 28/06/2021.
//

import UIKit
import GoogleMobileAds
//
//var isLoadedFirstAdmod = false
//

class ManyReadCell: UITableViewCell {
    static let reuseIdentifier = "ManyReadCell"
    @IBOutlet weak var topCollView: NSLayoutConstraint!
    @IBOutlet weak var nativeAdView: GADNativeAdView!
    var delegate: ManyReadCellDelegate!
    var listData = [MediaModel](){
        didSet{
            clv.reloadData()
        }
    }
    @IBOutlet weak var clv: UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        clv.delegate = self
        clv.dataSource = self
        clv.register(UINib(nibName: CellNews.className, bundle: nil), forCellWithReuseIdentifier: CellNews.className)
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: 375 * scaleW, height: 110 * scaleW)
        clv.collectionViewLayout = layout
        
        //
        
        nativeAdView.backgroundColor = UIColor.clear
        //

       // loadAdmobNativeAds()
    }

    var fullRootViewController: UIViewController!
    var adLoader: GADAdLoader!
//    func loadAdmobNativeAds(){
//        let multipleAdsOptions = GADMultipleAdsAdLoaderOptions()
//        multipleAdsOptions.numberOfAds = 5
//        adLoader = GADAdLoader(adUnitID: "ca-app-pub-4070508565123234/7623572716", rootViewController: nil,
//                               adTypes: [.native],
//                               options: [multipleAdsOptions])
//        adLoader.delegate = self
//        adLoader.load(GADRequest())
//    }
    
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

//extension ManyReadCell: GADNativeAdLoaderDelegate{
//    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
//        print("didFailToReceiveAdWithError")
//        print(error.localizedDescription)
//    }
//
//    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
//        print(nativeAd.headline)
//        nativeAdView.nativeAd = nativeAd
//        //
//        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
//        nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
//
//        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
//        nativeAdView.bodyView?.isHidden = nativeAd.body == nil
//
//        (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
//        nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil
//        nativeAdView.callToActionView?.isUserInteractionEnabled = true
//        nativeAdView.callToActionView?.backgroundColor = #colorLiteral(red: 0.159235239, green: 0.2396469116, blue: 0.5891875029, alpha: 1)
//        nativeAdView.callToActionView?.tintColor = .white
//        (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
//        nativeAdView.iconView?.isHidden = nativeAd.icon == nil
//
//        (nativeAdView.starRatingView as? UIImageView)?.image = imageOfStars(from: nativeAd.starRating)
//        nativeAdView.starRatingView?.isHidden = nativeAd.starRating == nil
//
//        (nativeAdView.storeView as? UILabel)?.text = nativeAd.store
//        nativeAdView.storeView?.isHidden = nativeAd.store == nil
//
//        (nativeAdView.priceView as? UILabel)?.text = nativeAd.price
//        nativeAdView.priceView?.isHidden = nativeAd.price == nil
//
//        (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
//        nativeAdView.advertiserView?.isHidden = nativeAd.advertiser == nil
//
//        if isLoadedFirstAdmod == false {
//            isLoadedFirstAdmod = true
//            NotificationCenter.default.post(name: NSNotification.Name("Admob.loaded.first"), object: nil)
//        }
        
        //
//    }
//
//}

extension ManyReadCell: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellNews.className, for: indexPath) as! CellNews
        if listData.count != 0, indexPath.row < listData.count {
            let item = listData[indexPath.row]
            cell.isMedia = true
            cell.itemMedia = item
            cell.lblTitle.text = item.name
            cell.line.isHidden = false
            if item.thumnail != "" {
                if let url = URL(string: item.image[0].cdn + item.thumnail.replacingOccurrences(of: "\\", with: "/")){
                    cell.img.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "image_default"))
                }
            } else {
                cell.img.image = #imageLiteral(resourceName: "image_default")
            }
            cell.lblCategory.text = (item.category == "") ? "VNEWS" : item.category
            let schedule = item.schedule
            let timePass = publishedDate(schedule: schedule)
            cell.lblPublished.text = timePass
        }
        
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectItemAt(listData, indexPath)
    }
    
    
}
extension ManyReadCell: CellNewsDelegate{
    func didLike(_ cell: CellNews) {
        
        delegate?.didLike(cell)
    }
    
    func didShare(_ cell: CellNews) {
        delegate?.didShare(cell)
    }
}
protocol ManyReadCellDelegate: PageVNewsVC {
    func didSelectItemAt(_ data: [MediaModel], _ indexPath: IndexPath)
    func didShare(_ cell: CellNews)
    func didLike(_ cell: CellNews)
}
