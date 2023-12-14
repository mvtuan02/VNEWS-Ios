//
//  CellSlideShow.swift
//  VNews
//
//  Created by Nguyễn  Chiến on 6/21/21.
//

import UIKit
import ImageSlideshow

class CellSlideShow: UICollectionViewCell {
    @IBOutlet weak var constrainBottom: NSLayoutConstraint!
    @IBOutlet weak var viewShare: UIView!
    @IBOutlet weak var vỉewLike: UIView!
    @IBOutlet weak var imgLike: UIImageView!
    var delegate: CellSlideShowDelegate!
    var indexSlide = 0{
        didSet{
            clvDot.reloadData()
        }
    }
    var listData = [MediaModel](){
        didSet{
            self.setUpSlideShow()
        }
    }
    @IBOutlet weak var widthClvDot: NSLayoutConstraint!
    @IBOutlet weak var clvDot: UICollectionView!
    @IBOutlet weak var line: UIView!
    @IBOutlet weak var imgShare: UIImageView!
    @IBOutlet weak var imgSave: UIImageView!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imageSlideShow: ImageSlideshow!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        clvDot.delegate = self
        clvDot.dataSource = self
        clvDot.register(UINib(nibName: CellDot.className, bundle: nil), forCellWithReuseIdentifier: CellDot.className)
        let layoutDot = UICollectionViewFlowLayout()
        layoutDot.scrollDirection = .horizontal
        clvDot.collectionViewLayout = layoutDot
        indexSlide = 0
        clvDot.backgroundColor = .clear
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectView)))
        viewShare.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didShare(_:))))
        vỉewLike.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didLike)))
    }
    @objc func didShare(_ sender: Any) {
        delegate.didShare(indexSlide)
    }
    @objc func didLike() {
        self.imgLike.image = #imageLiteral(resourceName: "icons8-facebook-like-64 (1)")
        delegate.didLike(indexSlide)
    }
    @objc func didSelectView(){
        delegate.didSelectItemSlideShow(index: indexSlide)
    }
    
    func setUpSlideShow(){
        //set up slideshow
        imageSlideShow.slideshowInterval = 5.0
        imageSlideShow.contentScaleMode = UIViewContentMode.scaleAspectFill
        imageSlideShow.activityIndicator = DefaultActivityIndicator()
        imageSlideShow.delegate = self
        imageSlideShow.pageIndicator = .none
        imageSlideShow.pageIndicatorPosition = PageIndicatorPosition(horizontal: .center, vertical: .bottom)
        var kingfisherSource:[KingfisherSource] = []
        if listData.count != 0 {
            for i in listData {
                var urlString = ""
                if i.thumnail != ""{
                    urlString = i.image[0].cdn + i.thumnail.replacingOccurrences(of: "\\", with: "/" )
                } else {
                    urlString = "https://static.mediacdn.vn/vnews/web_images/image_default.png"
                }
                kingfisherSource.append(KingfisherSource(urlString: urlString)!)
                if kingfisherSource.count == 6 {
                    break
                }
            }
            lblTitle.text = listData[0].name
            lblCategory.text = (listData[0].category == "") ? "VNEWS" : listData[0].category
            let schedule = listData[0].schedule
            let timePass = publishedDate(schedule: schedule)
            lblTime.text = "•  \(timePass)"
            let count = (listData.count > 6) ? 6 : (listData.count)
            widthClvDot.constant = 6 * scaleW * CGFloat(count) + 4 * scaleW * CGFloat(count - 1)
        }
        imageSlideShow.setImageInputs(kingfisherSource)
        
        //set first image slideshow
    }

}

extension CellSlideShow: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4 * scaleW
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 6 * scaleW, height: 6 * scaleW)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if listData.count > 6 {
            return 6
        }
        return listData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellDot.className, for: indexPath) as! CellDot
        if indexPath.row == indexSlide{
            cell.bigDot.isHidden = false
        } else{
            cell.bigDot.isHidden = true
        }
        return cell
    }


}


extension CellSlideShow: ImageSlideshowDelegate {
    
    @objc func didTap() {
        delegate.didSelectItemSlideShow(index: indexSlide)
    }
    
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        let item = listData[page]
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        imageSlideShow.addGestureRecognizer(recognizer)
        indexSlide = page
        lblTitle.text = listData[page].name
        lblCategory.text = (item.category == "") ? "VNEWS" : item.category
        let schedule = listData[page].schedule
        let timePass = publishedDate(schedule: schedule)
        lblTime.text = "•  \(timePass)"
    }
    
}

protocol CellSlideShowDelegate {
    func didSelectItemSlideShow(index: Int)
    func didShare(_ index: Int)
    func didLike(_ index: Int)
}
