//
//  ServerErrorView.swift
//  FlickrDemoApp
//
//  Created by Piotr Stepien on 15.02.2017.
//  Copyright © 2017 Piotr Stepien. All rights reserved.
//

import UIKit

class ServerErrorView: UIView {
    
    //MARK: - Variables
    
    var label: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        lbl.textColor = .white
        lbl.font = UIFont.boldSystemFont(ofSize: 25)
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    convenience init(errorTitle: String, frame: CGRect) {
        self.init(frame: frame)
        self.label.text = errorTitle
    }
    
    func setup() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .black
        self.addSubview(label)
        label.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
    }
    
}
