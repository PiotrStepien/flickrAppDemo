//
//  AlertService.swift
//  FlickrDemoApp
//
//  Created by Piotr Stępień on 15/02/2017.
//  Copyright © 2017 Piotr Stepien. All rights reserved.
//

import UIKit

class AlertService {
    
    static let shared = AlertService()
    fileprivate init(){}
    fileprivate var alertController: UIAlertController!
    
    func twoButtonAlert(title: String, message: String?, firstButtonTitle: String, secondButtonTitle: String, firstCompletionHandler: ((UIAlertAction) -> ())?, secondCompletionHandler: ((UIAlertAction) -> ())? ) -> UIAlertController {
        let firstAction = UIAlertAction(title: firstButtonTitle, style: .default, handler: firstCompletionHandler)
        let secondAction = UIAlertAction(title: secondButtonTitle, style: .default, handler: secondCompletionHandler)
        alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(firstAction)
        alertController.addAction(secondAction)
        return alertController
    }
    
}
