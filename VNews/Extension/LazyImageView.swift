//
//  LazyImageView.swift
//  VTVNew
//
//  Created by Nguyễn Văn Chiến on 1/28/21.
//

import Foundation
import UIKit
class LazyImageView : UIImageView{
    private let imgCache = NSCache<AnyObject, UIImage>()
    
    func loadImage(fromURL imageURL: URL){
        self.image = #imageLiteral(resourceName: "imgPlaceHolder")
        
        if let cacheImg = self.imgCache.object(forKey: imageURL as AnyObject){
            self.image = cacheImg
            return
        }
        
        DispatchQueue.global().async {
            [weak self] in
            if let imageData = try? Data(contentsOf: imageURL){
                if let image = UIImage(data: imageData){
                    DispatchQueue.main.async {
                        self?.imgCache.setObject(image, forKey: imageURL as AnyObject)
                        self?.image = image
                    }
                }
            }
        }
        
    }
}
