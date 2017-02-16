//
//  NetworkingSrvice.swift
//  EnumsTest
//
//  Created by Piotr Stepien on 19.12.2016.
//  Copyright © 2016 Piotr Stepien. All rights reserved.
//

import Foundation
import Alamofire


enum NetworkEndpoint {
    case publicPhotosAll
    case publicPhotosWithTag(tag: String)
    
    
    var mainURL: String { return serviceURL }
    var path: String {
        switch self {
        case .publicPhotosAll, .publicPhotosWithTag(tag: _):
            return mainURL + publicPhotosPath
            
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .publicPhotosAll, .publicPhotosWithTag(tag: _):
            return .get
        }
    }
    
    var param: [String: String]? {
        switch self {
        case .publicPhotosAll:
            let param = ["format" : "json", "nojsoncallback" : "1"]
            return param
            
        case .publicPhotosWithTag(let tag):
            let param = ["format" : "json", "nojsoncallback" : "1", "tagmode" : "All", "tag" : tag]
            return param
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .publicPhotosAll, .publicPhotosWithTag(tag: _):
            return nil
        }
    }
}

enum NetworkingServiceErrors: Error {
    case urlError
    case noInternetConnection
}


class NetworkingService {
    
    func requestJSON(endpoint: NetworkEndpoint, completion: @escaping (Any?, URLResponse?, Error?) -> Void) {
        if isConnectedToNetwork() == true {
            let backgroundQueue = DispatchQueue.global(qos: .userInteractive)
            if let url = URL(string: endpoint.path) {
                Alamofire.request(url, method: endpoint.method, parameters: endpoint.param, encoding: URLEncoding.default, headers: endpoint.headers).responseJSON(queue: backgroundQueue, options: .allowFragments, completionHandler: { (response: DataResponse<Any>) in
                    switch response.result {
                    case .success:
                        completion(response.result.value, response.response, response.error)
                        
                    case .failure(let error):
                        completion(nil, response.response, error)
                    }
                })
            }
        } else {
            completion(nil, nil, NetworkingServiceErrors.noInternetConnection)
        }
    }
    
    
    func downloadImageData(_ url: String, imageHandler: @escaping(Data) -> (), errorHandler: @escaping(Error?) -> ()) {
        if isConnectedToNetwork() {
            guard let url = URL(string: url) else { errorHandler(NetworkingServiceErrors.urlError); return }
            let task = URLSession.shared.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
                if error == nil {
                    guard let imageData = data else { return }
                    imageHandler(imageData)
                } else {
                    errorHandler(error)
                }
            }
            task.resume()
        } else {
            errorHandler(NetworkingServiceErrors.noInternetConnection)
        }
    }
}












