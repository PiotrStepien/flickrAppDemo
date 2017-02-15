//
//  ViewController.swift
//  FlickrDemoApp
//
//  Created by Piotr Stepien on 14.02.2017.
//  Copyright © 2017 Piotr Stepien. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    //MARK: - Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - Variables
    
    var viewModelDelegate: ViewControllerViewModel?
    var cellID: String = "cell"
    var cellNIBName: String = "FlickrPhotoCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initCollectionView()
        initErrorHandler()
        getPicturesFromFlickr()
    }

    func initCollectionView() {
        collectionView.register(UINib(nibName: cellNIBName, bundle: nil), forCellWithReuseIdentifier: cellID)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func initErrorHandler() {
        viewModelDelegate?.errorHandler = { error in
            print(error)
        }
    }
    
    func getPicturesFromFlickr() {
        viewModelDelegate?.getPublicPhotosJSONFromFlickr(successHandler: { 
            self.collectionView.reloadData()
        })
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let photosCount = viewModelDelegate?.flickrPhotosArray.count {
            return photosCount
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! FlickrPhotoCell
        cell.viewControlerViewModel = viewModelDelegate
        cell.delegate = self
        cell.photoJSONDict = viewModelDelegate?.flickrPhotosArray[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 10, height: 400)
    }
    
}

extension ViewController: FlickrPhotoCellDelegate {
    func saveImageInPhotoLiblary(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}
