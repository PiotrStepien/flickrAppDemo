//
//  DictionaryExtension.swift
//  FlickrDemoApp
//
//  Created by Piotr Stepien on 14.02.2017.
//  Copyright © 2017 Piotr Stepien. All rights reserved.
//

import Foundation


extension Dictionary {
    func createStringDict() -> String {
        var dictString: String = ""
        for (key, value) in self {
            let hash = "\(key)"
            let newValue = "\(value)"
            dictString = dictString + "&" + hash + "=" + newValue
        }
        dictString.remove(at: dictString.startIndex)
        return dictString
    }
}
