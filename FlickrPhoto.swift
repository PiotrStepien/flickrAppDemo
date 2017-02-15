//
//  FlickrPhoto.swift
//  FlickrDemoApp
//
//  Created by Piotr Stepien on 14.02.2017.
//  Copyright © 2017 Piotr Stepien. All rights reserved.
//

import UIKit
import ObjectMapper

class FlickrPhoto: Mappable {
    
    //MARK: - Variables
    
    var title: String?
    var photoURL: String?
    var data: Date?
    var description: String?
    var author: String?
    
    
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        title <- map["title"]
        photoURL <- map["media.m"]
        data <- map["published"]
        description <- map["description"]
        author <- map["author"]
    }

}
