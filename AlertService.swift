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
    
    func fourOptionsAllert(title: String, message: String?, firstButtonTitle: String, secondButtonTitle: String, thirdButtonTitle: String, fourthButtonTitle: String, firstCompletionHandler: ((UIAlertAction) -> ())?, secondCompletionHandler: ((UIAlertAction) -> ())?, thirdCompletionHandler: ((UIAlertAction) -> ())?, fourthCompletionHandler: ((UIAlertAction) -> ())? ) -> UIAlertController {
        let firstAction = UIAlertAction(title: firstButtonTitle, style: .default, handler: firstCompletionHandler)
        let secondAction = UIAlertAction(title: secondButtonTitle, style: .default, handler: secondCompletionHandler)
        let thirdAction = UIAlertAction(title: thirdButtonTitle, style: .default, handler: thirdCompletionHandler)
        let fourthAction = UIAlertAction(title: fourthButtonTitle, style: .cancel, handler: fourthCompletionHandler)
        alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alertController.addAction(firstAction)
        alertController.addAction(secondAction)
        alertController.addAction(thirdAction)
        alertController.addAction(fourthAction)
        return alertController
    }
}

