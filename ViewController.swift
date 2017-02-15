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
    lazy var searchBar = UISearchBar()
    var rightButton: UIBarButtonItem!
    var isSearchBarAdded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initCollectionView()
        initErrorHandler()
        getPicturesFromFlickr()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !isSearchBarAdded {
            addBarItems()
        }
    }

    func initCollectionView() {
        collectionView.register(UINib(nibName: cellNIBName, bundle: nil), forCellWithReuseIdentifier: cellID)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func initErrorHandler() {
        viewModelDelegate?.errorHandler = { [unowned self] error in
            self.rightButton.isEnabled = true
            self.collectionView.isUserInteractionEnabled = true
            print("Herror handler: \(error)")
        }
    }
    
    func getPicturesFromFlickr() {
        viewModelDelegate?.getPublicPhotosJSONFromFlickr(endpoint: .publicPhotosAll ,successHandler: { [unowned self] in
            self.collectionView.reloadData()
        })
    }
    
    func addBarItems() {
        searchBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width * 0.7, height: 20)
        searchBar.placeholder = "Add tag to search"
        let searchItem = UIBarButtonItem(customView: searchBar)
        searchBar.delegate = self
        self.navigationItem.leftBarButtonItem = searchItem
        rightButton = UIBarButtonItem(title: "Search", style: .done, target: self, action: #selector(searchTapped))
        self.navigationItem.rightBarButtonItem = rightButton
        isSearchBarAdded = true
    }
    
    //MARK: - Selectors
    
    func searchTapped() {
        if let searchText = searchBar.text {
            searchBar.text = ""
            searchBar.resignFirstResponder()
            rightButton.isEnabled = false
            collectionView.isUserInteractionEnabled = false
            viewModelDelegate?.getPhotosByTag(tag: searchText, successHandler: { [unowned self] in
                self.collectionView.reloadData()
                self.rightButton.isEnabled = true
                self.collectionView.isUserInteractionEnabled = true
            })
        }
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
        let alert = AlertService.shared.twoButtonAlert(title: "Saving photo", message: "Do you want to save photo in photo library?", firstButtonTitle: "Yes", secondButtonTitle: "No", firstCompletionHandler: { _ in
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }, secondCompletionHandler: nil)
        self.present(alert, animated: true, completion: nil)
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchTapped()
    }
}
