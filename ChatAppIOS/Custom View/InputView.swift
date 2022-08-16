//
//  InputView.swift
//  HWW8
//
//  Created by Nguyễn Duy Việt on 31/07/2022.
//

import UIKit

class InputView: UIView {
    
    let screenSize: CGRect = UIScreen.main.bounds

    var lbInput = UILabel()
    var tfInput = UITextField()
    
    convenience init (parentView: UIView) {
        self.init()
        parentView.addSubview(self)
        
        self.translatesAutoresizingMaskIntoConstraints = false
                
        self.addSubview(lbInput)
        self.addSubview(tfInput)
                
        lbInput.translatesAutoresizingMaskIntoConstraints = false
        
        lbInput.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        lbInput.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        
        lbInput.sizeToFit()
        
        lbInput.font = .boldSystemFont(ofSize: 16)
        lbInput.textColor = .black.withAlphaComponent(0.7)
        
        tfInput.translatesAutoresizingMaskIntoConstraints = false
        
        tfInput.topAnchor.constraint(equalTo: lbInput.bottomAnchor, constant: 8).isActive = true
        tfInput.leadingAnchor.constraint(equalTo: lbInput.leadingAnchor).isActive = true
        tfInput.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        tfInput.heightAnchor.constraint(equalToConstant: 60).isActive = true
        tfInput.widthAnchor.constraint(equalToConstant: screenSize.width - 50).isActive = true
        tfInput.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
                
        tfInput.attributedPlaceholder = NSAttributedString(
            string: "",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        
        tfInput.font = .systemFont(ofSize: 20)
        tfInput.textColor = .black
        tfInput.setLeftPaddingPoints(25)
        tfInput.backgroundColor = .lightGray.withAlphaComponent(0.3)

        tfInput.layer.cornerRadius = 20
        tfInput.layer.masksToBounds = true
        tfInput.layer.borderWidth = 1
        tfInput.layer.borderColor = #colorLiteral(red: 0.910294354, green: 0.910294354, blue: 0.910294354, alpha: 1)
        
                
        tfInput.disableAutoFill()
        tfInput.autocapitalizationType = .none
    }

}




