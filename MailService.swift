//
//  File.swift
//  FlickrDemoApp
//
//  Created by Piotr Stępień on 15/02/2017.
//  Copyright © 2017 Piotr Stepien. All rights reserved.
//

import Foundation
import MessageUI


class MailService: NSObject, MFMailComposeViewControllerDelegate {
    
    
    func sendMail(subject: String, recipients: [String], image: UIImage, imageTitle: String) -> MFMailComposeViewController? {  
        if MFMailComposeViewController.canSendMail() {
            let mailController = MFMailComposeViewController()
            mailController.mailComposeDelegate = self
            mailController.setSubject(subject)
            mailController.setToRecipients(recipients)
            if let dataImage = UIImageJPEGRepresentation(image, 0.8) {
                mailController.addAttachmentData(dataImage, mimeType: mimeType, fileName: imageTitle)
            }
            
            return mailController
        }
        
        return nil
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

