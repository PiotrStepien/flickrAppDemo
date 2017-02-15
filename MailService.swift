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
    
    fileprivate var mailController: MFMailComposeViewController?
    
    func sendMail(subject: String, recipients: [String], image: UIImage, imageTitle: String) -> MFMailComposeViewController? {
        
        if MFMailComposeViewController.canSendMail() {
            mailController = MFMailComposeViewController()
            mailController?.setSubject(subject)
            mailController?.setToRecipients(recipients)
            if let dataImage = UIImageJPEGRepresentation(image, 0.8) {
                mailController?.addAttachmentData(dataImage, mimeType: "image/jpeg", fileName: imageTitle)
            }
        }
        
        return mailController
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
    }
    
    
}

