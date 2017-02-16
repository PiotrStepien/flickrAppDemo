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
    var errorHandler: ((Error?) -> ())?
    fileprivate var networkService = NetworkingService()
    fileprivate var mailService = MailService()
    var imageCash = NSCache<AnyObject, AnyObject>()
    var image: UIImage?
    var imageLink: String?
    
    //MARK: - Methods
    
    func getPublicPhotosJSONFromFlickr(endpoint: NetworkEndpoint, successHandler: @escaping () -> ()) {
        self.networkService.requestJSON(endpoint: endpoint) { (data, response, error) in
            guard error == nil else {self.errorHandler?(error); return }
            if let dict = data as? NSDictionary {
                if let photosArray = dict[JSONChild.items.rawValue] as? [[String : Any]] {
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
                    self.errorHandler?(error)
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
    
    func presentAlertControlerWithOptions(controller: UIViewController) -> UIAlertController? {
        if let image = image, let link = imageLink {
            let alert = AlertService.shared.fourOptionsAllert(title: alertTitle, message: alertMessage, firstButtonTitle: firstTitle, secondButtonTitle: secondTitle, thirdButtonTitle: thirdTitle, fourthButtonTitle: cancelTitle, firstCompletionHandler: { (action) in
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }, secondCompletionHandler: { (action) in
                if let mailController = self.mailService.sendMail(subject: mailSubject, recipients: [""], image: image, imageTitle: mailImageTitle) {
                    controller.present(mailController, animated: true, completion: nil)
                }
            }, thirdCompletionHandler: { (action) in
                if let url = URL(string: link) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }, fourthCompletionHandler: nil)
            
            return alert
        }
        
        return nil
    }
    
    func sortPhotosByDate(success: @escaping() -> ()) {
        if !flickrPhotosArray.isEmpty {
            flickrPhotosArray.sort(by: { $0.data!.convertToDate()! < $1.data!.convertToDate()! })
            success()
        }
    }
    
}
