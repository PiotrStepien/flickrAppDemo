//
//  ViewControllerViewModel.swift
//  FlickrDemoApp
//
//  Created by Piotr Stepien on 14.02.2017.
//  Copyright © 2017 Piotr Stepien. All rights reserved.
//

import Foundation
import ObjectMapper

fileprivate enum JSONChild: String {
    case items
}

enum JSONErrors: Error {
    case responseStatusError
    case jsonArrayParsingError
    case objectMapperError
}


class ViewControllerViewModel {
    
    //MARK: - Variables
    
    var flickrPhotosArray = [FlickrPhoto]()
    var errorHandler: ((Error) -> ())?
    fileprivate var networkService = NetworkingService()
    var imageCash = NSCache<AnyObject, AnyObject>()
    
    //MARK: - Methods
    
    func getPublicPhotosJSONFromFlickr(endpoint: NetworkEndpoint, successHandler: @escaping () -> ()) {
        self.networkService.requestJSON(endpoint: endpoint) { (request, response, error) in
            let resp = response as? HTTPURLResponse
            if resp?.statusCode == 200 || resp?.statusCode == 201 {
                if let photosArray = request?[JSONChild.items.rawValue] as? [[String : Any]] {
                    if let photoObjects = Mapper<FlickrPhoto>().mapArray(JSONArray: photosArray) {
                        self.flickrPhotosArray = photoObjects
                        DispatchQueue.main.async {
                            successHandler()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.errorHandler?(JSONErrors.objectMapperError)
                        }
                        
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorHandler?(JSONErrors.jsonArrayParsingError)
                    }
                    
                }
            } else {
                DispatchQueue.main.async {
                    self.errorHandler?(JSONErrors.responseStatusError)
                }
                
            }
        }
    }
    
    
    func downloadImage(url: String, dataHandler: @escaping(Data) -> (), errorHandler: @escaping(Error?) -> ()) {
        networkService.downloadImageData(url, imageHandler: { (data: Data) in
            
            dataHandler(data)
        }) { (error) in
            errorHandler(error)
        }
    }
    
    func getPhotosByTag(tag: String, successHandler: @escaping () -> ()) {
        getPublicPhotosJSONFromFlickr(endpoint: .publicPhotosWithTag(tag: tag)) {
            DispatchQueue.main.async {
                successHandler()
            }
        }
    }
    
}
