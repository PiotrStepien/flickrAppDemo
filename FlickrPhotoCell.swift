//
//  FlickrPhotoCell.swift
//  FlickrDemoApp
//
//  Created by Piotr Stępień on 15/02/2017.
//  Copyright © 2017 Piotr Stepien. All rights reserved.
//

import UIKit



class FlickrPhotoCell: UICollectionViewCell {
    
    //MARK: - Outlets
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var publishDate: UILabel!
    
    //MARK: - Variables
    
    weak var viewControlerViewModel: ViewControllerViewModel?
    var photoJSONDict: FlickrPhoto? {
        didSet {
            if let info = photoJSONDict {
                if let imgURL = info.photoURL, let title = info.title, let author = info.author, let date = info.data?.convertDateToString(dateFormat: .medium) {
                    if let image = viewControlerViewModel?.imageCash.object(forKey: imgURL as AnyObject) {
                        imageView.image = image as? UIImage
                        hideIndicator()
                    } else {
                        viewControlerViewModel?.downloadImage(url: imgURL , dataHandler: { [unowned self] (imageData) in
                            DispatchQueue.main.async {
                                let image = UIImage(data: imageData)
                                self.viewControlerViewModel?.imageCash.setObject(image!, forKey: imgURL as AnyObject)
                                self.imageView.image = image
                                self.hideIndicator()
                            }
                            }, errorHandler: { (error: Error?) in
                                DispatchQueue.main.async {
                                    self.setErrorPhoto()
                                }
                        })
                    }
                    titleLabel.text = "Title: \(title)"
                    authorLabel.text = "Author: \(author)"
                    publishDate.text = "Published: \(date)"
                }
            } else {
                setErrorPhoto()
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        indicatorView.startAnimating()
    }
    
    func hideIndicator() {
        indicatorView.stopAnimating()
        indicatorView.isHidden = true
    }
    
    func setErrorPhoto() {
        self.imageView.image = #imageLiteral(resourceName: "noImageIcon")
        self.hideIndicator()
    }
}
