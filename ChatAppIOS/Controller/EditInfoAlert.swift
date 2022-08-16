//
//  EditInfoAlert.swift
//  ChatAppIOS
//
//  Created by Nguyễn Duy Việt on 16/08/2022.
//

import UIKit

protocol EditInfoAlertDelegate {
    func editName(name: String)
    func editEmail(email: String)
    func editPNumber(pNumber: String)
    func editFeeling(feeling: String)
}

enum Type {
    case name
    case email
    case phonenumber
    case feeling
}

class EditInfoAlert: BaseViewController {
    
    var delegate: EditInfoAlertDelegate?
    
    var viewAlert = UIView()
    var tfInfo = UITextField()
    var btnConfirm = UIButton()
    
    var type: Type?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }
    
    func setupViews() {
        
        view.isOpaque = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        view.isUserInteractionEnabled = true
        
        let tapOnDismissGes = UITapGestureRecognizer(target: self, action: #selector(tapOnDismiss))
        view.addGestureRecognizer(tapOnDismissGes)
        
        view.addSubview(viewAlert)
        viewAlert.translatesAutoresizingMaskIntoConstraints = false
        
        viewAlert.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        viewAlert.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        viewAlert.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        viewAlert.backgroundColor = .white
        
        viewAlert.addSubview(tfInfo)
        tfInfo.translatesAutoresizingMaskIntoConstraints = false
        
        tfInfo.topAnchor.constraint(equalTo: viewAlert.topAnchor, constant: 20).isActive = true
        tfInfo.leadingAnchor.constraint(equalTo: viewAlert.leadingAnchor, constant: 20).isActive = true
        tfInfo.trailingAnchor.constraint(equalTo: viewAlert.trailingAnchor, constant: -20).isActive = true
        tfInfo.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        tfInfo.font = .systemFont(ofSize: 18)
        tfInfo.textColor = .black
        tfInfo.setLeftPaddingPoints(25)
        tfInfo.backgroundColor = .lightGray.withAlphaComponent(0.3)

        tfInfo.layer.cornerRadius = 20
        tfInfo.layer.masksToBounds = true
        tfInfo.layer.borderWidth = 1
        tfInfo.layer.borderColor = #colorLiteral(red: 0.910294354, green: 0.910294354, blue: 0.910294354, alpha: 1)
        
                
        tfInfo.disableAutoFill()
        tfInfo.autocapitalizationType = .none
        
        viewAlert.addSubview(btnConfirm)
        btnConfirm.translatesAutoresizingMaskIntoConstraints = false
        
        btnConfirm.topAnchor.constraint(equalTo: tfInfo.bottomAnchor, constant: 20).isActive = true
        btnConfirm.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        btnConfirm.widthAnchor.constraint(equalToConstant: 200).isActive = true
        btnConfirm.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btnConfirm.bottomAnchor.constraint(equalTo: viewAlert.bottomAnchor, constant: -20).isActive = true

        btnConfirm.setTitle("Confirm", for: .normal)
        btnConfirm.setTitleColor(UIColor.white, for: .normal)
        btnConfirm.titleLabel?.font = .boldSystemFont(ofSize: 18)

        btnConfirm.backgroundColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        roundCorner(views: [btnConfirm], radius: 20)
        
        btnConfirm.addTarget(self, action: #selector(tapOnConfirm), for: .touchUpInside)
        
        roundCorner(views: [viewAlert], radius: 10)
        
    }
    
    @objc func tapOnConfirm() {
        if tfInfo.text!.isEmpty {
            popupAlert(alertTitle: "Information must not be empty", acTitle: "OK")
            return
        }
        
        if type == .name {
            delegate?.editName(name: tfInfo.text!)
        } else if type == .email {
            delegate?.editEmail(email: tfInfo.text!)
        } else if type == .phonenumber {
            delegate?.editPNumber(pNumber: tfInfo.text!)
        } else if type == .feeling {
            delegate?.editFeeling(feeling: tfInfo.text!)
        }
        dismiss(animated: true)
    }
    
    @objc func tapOnDismiss() {
        dismiss(animated: true)
    }

}
