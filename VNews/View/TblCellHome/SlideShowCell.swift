//
//  SlideShowCell.swift
//  VNews
//
//  Created by Apple on 28/06/2021.
//

import UIKit
import ImageSlideshow
import GoogleMobileAds

class SlideShowCell: UITableViewCell {
    static let reuseIdentifier = "SlideShowCell"
    @IBOutlet weak var topCollView: NSLayoutConstraint!
    @IBOutlet weak var nativeAdView: GADNativeAdView!
    var clickFirstSlideShowVideo = false
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var icRight: UIImageView!
    var indexPath: IndexPath!
    var indexSlide = 0
    let imgShadow: UIImageView = UIImageView()
    var delegate: SlideShowCellDelegate!
    var data = CategoryModel(){
        didSet{
            self.contentView.isHidden = false
            viewLoading.isHidden = true
            setUpSlideShow()
        }
    }
    let label:UILabel = UILabel()
    let icPlayVideo:UIImageView = UIImageView()
    @IBOutlet weak var imgSlideShow: ImageSlideshow!
    @IBOutlet weak var lblNamePlaylist: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        startViewLoading()
        
        self.imgSlideShow.addSubview(imgShadow)
        imgShadow.translatesAutoresizingMaskIntoConstraints = false
        imgShadow.leadingAnchor.constraint(equalTo: imgSlideShow.leadingAnchor, constant: 0).isActive = true
        imgShadow.trailingAnchor.constraint(equalTo: imgSlideShow.trailingAnchor, constant: 0).isActive = true
        imgShadow.bottomAnchor.constraint(equalTo: imgSlideShow.bottomAnchor, constant: 0).isActive = true
        imgShadow.heightAnchor.constraint(equalTo: imgSlideShow.heightAnchor, multiplier: 0.5).isActive = true
        imgShadow.image = UIImage(named: "bg_shadow2")
        
        self.addSubview(icPlayVideo)
        icPlayVideo.translatesAutoresizingMaskIntoConstraints = false
        icPlayVideo.trailingAnchor.constraint(equalTo: imgSlideShow.trailingAnchor, constant: -16 * scaleW).isActive = true
        icPlayVideo.bottomAnchor.constraint(equalTo: imgSlideShow.bottomAnchor, constant: -16 * scaleW).isActive = true
        icPlayVideo.heightAnchor.constraint(equalToConstant: 25 * scaleW).isActive = true
        icPlayVideo.widthAnchor.constraint(equalToConstant: 25 * scaleW).isActive = true
        icPlayVideo.image = UIImage(named: "icPlayVideo")
        
        self.imgSlideShow.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: imgSlideShow.leadingAnchor, constant: scaleW * 10).isActive = true
        label.trailingAnchor.constraint(equalTo: icPlayVideo.trailingAnchor, constant: -10 * scaleW).isActive = true
        label.bottomAnchor.constraint(equalTo: imgSlideShow.bottomAnchor, constant: -24 * scaleW).isActive = true
        label.textColor = .white
        label.numberOfLines = 0
        label.font = UIFont(name: "OpenSans-SemiBold", size: 16 * scaleW)
        viewHeader.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectHeader)))
        imgSlideShow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectFirstSl)))
    }
    
    override func prepareForReuse() {
        self.topCollView.constant = 0
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
    
    @objc func didSelectHeader(){
        delegate.didSelectViewHeader(self)
    }
    @objc func didSelectFirstSl(){
        if !clickFirstSlideShowVideo {
            delegate.clickFirstSlideShow(index: 0, data: data.media)
        }
    }
    
    let viewLoading:UIActivityIndicatorView = UIActivityIndicatorView()
    func startViewLoading(){
        viewLoading.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(viewLoading)
        viewLoading.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        viewLoading.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        viewLoading.startAnimating()
        self.contentView.isHidden = true
        viewLoading.isHidden = false
    }
    
    func setUpSlideShow(){
        //set up slideshow
        imgSlideShow.activityIndicator = DefaultActivityIndicator()
        let pageIndicator = UIPageControl()
        pageIndicator.currentPageIndicatorTintColor = #colorLiteral(red: 0.1607843137, green: 0.2352941176, blue: 0.5882352941, alpha: 1)
        pageIndicator.pageIndicatorTintColor = #colorLiteral(red: 0.768627451, green: 0.768627451, blue: 0.768627451, alpha: 1)
        imgSlideShow.pageIndicatorPosition = PageIndicatorPosition(horizontal: .center, vertical: .bottom)
        imgSlideShow.pageIndicator = pageIndicator
        imgSlideShow.slideshowInterval = 5.0
        imgSlideShow.contentScaleMode = UIViewContentMode.scaleAspectFill
        imgSlideShow.activityIndicator = DefaultActivityIndicator()
        imgSlideShow.delegate = self
        var kingfisherSource:[KingfisherSource] = []
        if data.media.count != 0 {
            for i in data.media {
                var urlString = ""
                if i.thumnail != ""{
                    urlString = data.cdn.imageDomain + i.thumnail.replacingOccurrences(of: "\\", with: "/" )
                } else {
                    urlString = "https://static.mediacdn.vn/vnews/web_images/image_default.png"
                }
                kingfisherSource.append(KingfisherSource(urlString: urlString)!)
                if kingfisherSource.count == 6 {
                    break
                }
            }
            label.text = data.media[0].name
            indexSlide = 0
            
            
        }
        imgSlideShow.setImageInputs(kingfisherSource)
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        imgSlideShow.addGestureRecognizer(recognizer)
    }

}

extension SlideShowCell: ImageSlideshowDelegate {
    
    @objc func didTap(_ sender: Any) {
        delegate.didSelectItemSlideShow(index: indexSlide, data: data.media)
    }
    
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        clickFirstSlideShowVideo = true
        
        self.indexSlide = page
        
        label.text = data.media[page].name
    }
    
}


protocol SlideShowCellDelegate: PageVNewsVC {
    func didSelectItemSlideShow(index: Int, data: [MediaModel])
    func clickFirstSlideShow(index: Int, data: [MediaModel])
    func didSelectViewHeader(_ cell: SlideShowCell)
}
