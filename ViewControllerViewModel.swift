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
    fileprivate var mailService = MailService()
    var imageCash = NSCache<AnyObject, AnyObject>()
    var image: UIImage?
    var imageLink: String?
    
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
    
    func presentAlertControlerWithOptions(controller: UIViewController) -> UIAlertController? {
        if let image = image, let link = imageLink {
            let alert = AlertService.shared.fourOptionsAllert(title: "Extras", message: "Special Option", firstButtonTitle: "Save Photo", secondButtonTitle: "Send via mail", thirdButtonTitle: "See in web browser", fourthButtonTitle: "Cancel", firstCompletionHandler: { (action) in
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }, secondCompletionHandler: { (action) in
                let emailAlert = UIAlertController(title: "Add your email", message: nil, preferredStyle: .alert)
                emailAlert.addTextField(configurationHandler: { (textfield) in
                    textfield.placeholder = "Add you email"
                })
                let send = UIAlertAction(title: "Send", style: .default, handler: { (action) in
                    let email = emailAlert.textFields?.first?.text
                    if let mailController = self.mailService.sendMail(subject: "Flickr Photo", recipients: [email!], image: image, imageTitle: "Flickr Photo") {
                        controller.present(mailController, animated: true, completion: nil)
                    }
                })
                let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                emailAlert.addAction(send)
                emailAlert.addAction(cancel)
                controller.present(emailAlert, animated: true, completion: nil)
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
    
}
