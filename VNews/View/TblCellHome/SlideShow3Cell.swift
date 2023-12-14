//
//  SlideShow3Cell.swift
//  VNews
//
//  Created by Apple on 28/06/2021.
//

import UIKit
import ImageSlideshow
class SlideShow3Cell: UITableViewCell {
    static let reuseIdentifier = "SlideShow3Cell"
    var clickFirstSlideShowNews = false
    var indexSlide = 0

    var data = CategoryModel(){
        didSet{
            viewLoading.isHidden = true
            self.contentView.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.setUpSlideShow()
            }
        }
    }
    let imgShadow: UIImageView = UIImageView()
    var delegate: SlideShow3CellDelegate!
    let label:UILabel = UILabel()
    @IBOutlet weak var lblNamePlaylist: UILabel!
    @IBOutlet weak var imgSlideshow: ImageSlideshow!
    
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
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        startViewLoading()
        
        self.imgSlideshow.addSubview(imgShadow)
        imgShadow.translatesAutoresizingMaskIntoConstraints = false
        imgShadow.leadingAnchor.constraint(equalTo: imgSlideshow.leadingAnchor, constant: 0).isActive = true
        imgShadow.trailingAnchor.constraint(equalTo: imgSlideshow.trailingAnchor, constant: 0).isActive = true
        imgShadow.bottomAnchor.constraint(equalTo: imgSlideshow.bottomAnchor, constant: 0).isActive = true
        imgShadow.heightAnchor.constraint(equalTo: imgSlideshow.heightAnchor, multiplier: 0.3).isActive = true
        imgShadow.image = UIImage(named: "bg_shadow2")
        
        self.imgSlideshow.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: imgSlideshow.leadingAnchor, constant: scaleW * 10).isActive = true
        label.trailingAnchor.constraint(equalTo: imgSlideshow.trailingAnchor, constant: -10 * scaleW).isActive = true
        label.bottomAnchor.constraint(equalTo: imgSlideshow.bottomAnchor, constant: -24 * scaleW).isActive = true
        label.textColor = .white
        label.numberOfLines = 0
        label.font = UIFont(name: "OpenSans-SemiBold", size: 16 * scaleW)

        imgSlideshow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickFirstSl)))
    }
    
    @objc func clickFirstSl(){
        if !clickFirstSlideShowNews{
            delegate.didSelectFirst(data: data.media[0])
        }
    }

    func setUpSlideShow(){
        //set up slideshow
        imgSlideshow.activityIndicator = DefaultActivityIndicator()
        let pageIndicator = UIPageControl()
        pageIndicator.currentPageIndicatorTintColor = #colorLiteral(red: 0.1607843137, green: 0.2352941176, blue: 0.5882352941, alpha: 1)
        pageIndicator.pageIndicatorTintColor = #colorLiteral(red: 0.768627451, green: 0.768627451, blue: 0.768627451, alpha: 1)
        imgSlideshow.pageIndicatorPosition = PageIndicatorPosition(horizontal: .center, vertical: .bottom)
        imgSlideshow.pageIndicator = pageIndicator
        imgSlideshow.slideshowInterval = 5.0
        imgSlideshow.contentScaleMode = UIViewContentMode.scaleAspectFit
        imgSlideshow.activityIndicator = DefaultActivityIndicator()
        imgSlideshow.delegate = self
        var kingfisherSource:[KingfisherSource] = []
        if data.media.count != 0 {
            for (index, i) in data.media.enumerated() {
                kingfisherSource.append(KingfisherSource(urlString: data.cdn.imageDomain + i.thumnail.replacingOccurrences(of: "\\", with: "/" ), placeholder: #imageLiteral(resourceName: "image_default"))!)
                if index >= 5 {
                    break
                }
            }
            label.text = data.media[0].name
            indexSlide = 0
        }
        imgSlideshow.setImageInputs(kingfisherSource)
    }
}
extension SlideShow3Cell: ImageSlideshowDelegate {
    
    @objc func didTap() {
        delegate.didSelectItemSlideShow(data: data.media[indexSlide])
    }
    
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        self.indexSlide = page
        imgSlideshow.addGestureRecognizer(recognizer)
        label.text = data.media[page].name
    }
    
}

protocol SlideShow3CellDelegate: PageVNewsVC {
    func didSelectItemSlideShow(data: MediaModel)
    func didSelectFirst(data: MediaModel)
}
