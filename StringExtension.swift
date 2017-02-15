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
        dateFormatter.dateStyle = .full
        let date = dateFormatter.date(from: self)
        dateFormatter.dateStyle = dateFormat
        let stringDate = dateFormatter.string(from: date!)
        return stringDate
    }
}
