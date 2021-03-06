//
//  FlickrPhotoCell.swift
//  FlickrDemoApp
//
//  Created by Piotr Stępień on 15/02/2017.
//  Copyright © 2017 Piotr Stepien. All rights reserved.
//

import UIKit

protocol FlickrPhotoCellDelegate: class {
    func photoInfo(image: UIImage, imageURL: String)
}


class FlickrPhotoCell: UICollectionViewCell {
    
    //MARK: - Outlets
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var publishDate: UILabel!
    
    //MARK: - Variables
    
    var longPressGestureRecognizer = UILongPressGestureRecognizer()
    weak var delegate: FlickrPhotoCellDelegate?
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
                    titleLabel.text = "\(titleInfo) \(title)"
                    authorLabel.text = "\(authorInfo) \(author)"
                    publishDate.text = "\(published) \(date)"
                }
            } else {
                setErrorPhoto()
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        indicatorView.startAnimating()
        longPressGestureRecognizer.addTarget(self, action: #selector(longPress(_:)))
        self.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    func hideIndicator() {
        indicatorView.stopAnimating()
        indicatorView.isHidden = true
    }
    
    func setErrorPhoto() {
        self.imageView.image = #imageLiteral(resourceName: "noImageIcon")
        self.hideIndicator()
    }
    
    func longPress(_ gesture: UILongPressGestureRecognizer) {
        if let image = imageView.image, let url = photoJSONDict?.link {
            delegate?.photoInfo(image: image, imageURL: url)
        }
    }
}
