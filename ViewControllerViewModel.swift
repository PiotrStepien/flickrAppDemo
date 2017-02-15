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
    
    
    //MARK: - Methods
    
    func getPublicPhotosJSONFromFlickr(successHandler: @escaping () -> ()) {
        DispatchQueue.global(qos: .userInteractive).async {
            self.networkService.requestJSON(endpoint: .publicPhotosAll) { (request, response, error) in
                let resp = response as? HTTPURLResponse
                if resp?.statusCode == 200 || resp?.statusCode == 201 {
                    if let photosArray = request?[JSONChild.items.rawValue] as? [[String : Any]] {
                        if let photoObjects = Mapper<FlickrPhoto>().mapArray(JSONArray: photosArray) {
                            self.flickrPhotosArray = photoObjects
                            successHandler()
                        } else {
                            self.errorHandler?(JSONErrors.objectMapperError)
                        }
                    } else {
                        self.errorHandler?(JSONErrors.jsonArrayParsingError)
                    }
                } else {
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
    
    
}
