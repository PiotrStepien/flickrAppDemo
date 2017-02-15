//
//  NetworkingSrvice.swift
//  EnumsTest
//
//  Created by Piotr Stepien on 19.12.2016.
//  Copyright © 2016 Piotr Stepien. All rights reserved.
//

import Foundation

enum RESTMethods: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum NetworkEndpoint {
    case publicPhotosAll
    case publicPhotosWithTag(tag: String)
    
    
    var mainURL: String { return "https://api.flickr.com/services" }
    var path: String {
        switch self {
        case .publicPhotosAll, .publicPhotosWithTag(tag: _):
            return mainURL + "/feeds/photos_public.gne"

        }
    }
    
    var method: RESTMethods {
        switch self {
        case .publicPhotosAll, .publicPhotosWithTag(tag: _):
            return .get
        }
    }
    
    var param: [String: Any]? {
        switch self {
        case .publicPhotosAll:
            let param = ["format" : "json", "nojsoncallback" : 1] as [String: Any]
            return param
            
        case .publicPhotosWithTag(let tag):
            let param = ["format" : "json", "nojsoncallback" : 1, "tagmode" : "All", "tag" : tag] as [String: Any]
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
    
    
    func requestJSON(endpoint: NetworkEndpoint, completion: @escaping ([String: AnyObject]?, URLResponse?, Error?) -> Void) {
        if isConnectedToNetwork() == true {
            if let url = URL(string: endpoint.path) {
                var request = URLRequest(url: url)
                switch endpoint.method {
                case .get:
                    if let parametersString = endpoint.param?.createStringDict() {
                        if let getURL = URL(string: endpoint.path + "?" + parametersString) {
                            request = URLRequest(url: getURL)
                        }
                    }
                    request.httpMethod = endpoint.method.rawValue
                    
                case .post, .put, .delete:
                    request.httpMethod = endpoint.method.rawValue
                    if let params = endpoint.param {
                        do {
                            let body = try JSONSerialization.data(withJSONObject: params as Any, options: .prettyPrinted)
                            request.httpBody = body
                        } catch let error {
                            completion(nil, nil, error)
                            return
                        }
                    }
                    
                    if let header = endpoint.headers {
                        request.allHTTPHeaderFields = header
                    }
                    request.allowsCellularAccess = true
                }
                
                taskHandler(request: request, completion: completion)
            }
        } else {
            completion(nil, nil, NetworkingServiceErrors.noInternetConnection)
        }
    }
    
    fileprivate func taskHandler(request: URLRequest, completion: @escaping ([String: AnyObject]?, URLResponse?, Error?) -> Void ) {
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if error == nil {
                do {
                    let session = try JSONSerialization.jsonObject(with: data!, options: [.mutableContainers, .allowFragments]) as? [String: AnyObject]
                    completion(session, response, error)
                } catch let error {
                    completion(nil, response, error)
                }
            } else {
                completion(nil, nil, error)
            }
        }
        task.resume()
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












