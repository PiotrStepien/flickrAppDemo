//
//  DateExtension.swift
//  FlickrDemoApp
//
//  Created by Piotr Stępień on 15/02/2017.
//  Copyright © 2017 Piotr Stepien. All rights reserved.
//

import Foundation

extension String {
    func convertDateToString(dateFormat: DateFormatter.Style) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
        let date = dateFormatter.date(from: self.replacingCharacters(in: self.range(of: "T")!, with: " "))
        dateFormatter.dateStyle = dateFormat
        let stringDate = dateFormatter.string(from: date!)
        return stringDate
    }
    
    func convertToDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
        let date = dateFormatter.date(from: self.replacingCharacters(in: self.range(of: "T")!, with: " "))
        return date
    }
    
    func stringToTimeInterval() -> TimeInterval {
        let timeInterval = self.convertToDate()?.timeIntervalSinceNow
        return timeInterval!
    }
}


