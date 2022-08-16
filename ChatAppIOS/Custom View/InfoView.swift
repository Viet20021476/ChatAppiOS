//
//  InfoView.swift
//  ChatAppIOS
//
//  Created by Nguyễn Duy Việt on 16/08/2022.
//

import Foundation
import UIKit

class InfoView: UIView {
    var lbTag = UILabel()
    var tfInfo = UITextField()
    var imgEdit = UIImageView()
    
    convenience init(parentView: UIView) {
        self.init()
        parentView.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.isUserInteractionEnabled = true
        
        self.addSubview(lbTag)
        self.addSubview(tfInfo)
        self.addSubview(imgEdit)
        
        lbTag.translatesAutoresizingMaskIntoConstraints = false
        
        lbTag.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        lbTag.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        lbTag.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
                
        lbTag.sizeToFit()
        
        lbTag.font = .systemFont(ofSize: 20, weight: .semibold)
        
        tfInfo.translatesAutoresizingMaskIntoConstraints = false
        tfInfo.isUserInteractionEnabled = false
        
        tfInfo.leadingAnchor.constraint(equalTo: lbTag.trailingAnchor, constant: 15).isActive = true
        tfInfo.centerYAnchor.constraint(equalTo: lbTag.centerYAnchor).isActive = true
        
        tfInfo.textAlignment = .left
        
        imgEdit.translatesAutoresizingMaskIntoConstraints = false
        
        imgEdit.image = UIImage(named: "img_edit")
        imgEdit.contentMode = .scaleAspectFill
        
        imgEdit.widthAnchor.constraint(equalToConstant: 25).isActive = true
        imgEdit.heightAnchor.constraint(equalToConstant: 25).isActive = true
        imgEdit.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        imgEdit.centerYAnchor.constraint(equalTo: tfInfo.centerYAnchor).isActive = true
        
        imgEdit.isUserInteractionEnabled = true
    }
}

