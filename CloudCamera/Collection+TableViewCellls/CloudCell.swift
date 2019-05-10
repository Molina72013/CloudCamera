//
//  CloudCell.swift
//  CloudCamera
//
//  Created by Cristian Molina on 10/15/18.
//  Copyright © 2018 Cristian Molina. All rights reserved.
//

import Foundation
import  UIKit
import FirebaseAuth

class CloudCell: UICollectionViewCell {
    @IBOutlet weak var imageView: CloudImage!

    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
}


class CloudImage: UIImageView {
    static let imageCache = NSCache<AnyObject, AnyObject>()
    
    var currentURL: URL? {
        didSet {
            self.previosURL = oldValue
        }
    }
    
    var previosURL: URL?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func loadImageFromURL(url: URL) {
        
        let urlString = "\(url)"
        
        
        
        image = nil
        
        
        if let imageFromCache = CloudImage.imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = imageFromCache
            return
        }
        
        print("download.........................")
        
        URLSession.shared.dataTask(with: url) { (data, respone, error) in
            if let data = data {
                
//                let filePath = NSTemporaryDirectory() + "/" + RfcP7r)
//                eBsv81o0tuX7xHPoESOkKzVWy8E2
//
                DispatchQueue.main.async { [weak self] in
                    guard let imageToCache = UIImage(data: data) else {return}
                    CloudImage.imageCache.setObject(imageToCache, forKey: urlString as AnyObject)
                    guard let this = self else {return}
                    this.image = imageToCache
                }
            }
            }.resume()
    }
}
