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
    var sortButton: UIBarButtonItem!
    var isSearchBarAdded: Bool = false
    var responseError: ServerErrorView!
    
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
            if error.localizedDescription == JSONErrors.jsonArrayParsingError.localizedDescription {
                self.addFlickrResponseErrorView()
            }
            self.rightButton.isEnabled = true
            self.collectionView.isUserInteractionEnabled = true
        }
    }
    
    func getPicturesFromFlickr() {
        viewModelDelegate?.getPublicPhotosJSONFromFlickr(endpoint: .publicPhotosAll ,successHandler: { [unowned self] in
            self.removeFlickrErrorView()
            self.collectionView.reloadData()
        })
    }
    
    func addBarItems() {
        searchBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width * 0.6, height: 20)
        searchBar.placeholder = "Add tag to search"
        let searchItem = UIBarButtonItem(customView: searchBar)
        searchBar.delegate = self
        self.navigationItem.leftBarButtonItem = searchItem
        rightButton = UIBarButtonItem(title: "Search", style: .done, target: self, action: #selector(searchTapped))
        sortButton = UIBarButtonItem(title: "Sort", style: .plain, target: self, action: #selector(sortTapped))
        self.navigationItem.rightBarButtonItems = [sortButton, rightButton]
        isSearchBarAdded = true
    }
    
    func addFlickrResponseErrorView() {
        responseError = ServerErrorView()
        self.view.addSubview(responseError)
        responseError.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        responseError.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        responseError.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        responseError.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
    }
    
    func removeFlickrErrorView() {
        if responseError != nil {
            responseError.removeFromSuperview()
        }
    }
    
    //MARK: - Selectors
    
    func searchTapped() {
        if let searchText = searchBar.text {
            searchBar.text = ""
            searchBar.resignFirstResponder()
            rightButton.isEnabled = false
            collectionView.isUserInteractionEnabled = false
            viewModelDelegate?.getPhotosByTag(tag: searchText, successHandler: { [unowned self] in
                self.removeFlickrErrorView()
                self.collectionView.reloadData()
                self.rightButton.isEnabled = true
                self.collectionView.isUserInteractionEnabled = true
            })
        }
    }
    
    func sortTapped() {
        viewModelDelegate?.sortPhotosByDate { [unowned self] in
            self.collectionView.reloadData()
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
    func photoInfo(image: UIImage, imageURL: String) {
        viewModelDelegate?.image = image
        viewModelDelegate?.imageLink = imageURL
        if !(self.navigationController?.visibleViewController?.isKind(of: UIAlertController.self))! {
            if let controller = viewModelDelegate?.presentAlertControlerWithOptions(controller: self) {
                present(controller, animated: true, completion: nil)
            }
        }
        
    }
 }
 
 extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchTapped()
    }
 }
