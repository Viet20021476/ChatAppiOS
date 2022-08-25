//
//  SendFriendRequestAlert.swift
//  ChatAppIOS
//
//  Created by Nguyễn Duy Việt on 24/08/2022.
//

import UIKit

class SendFriendRequestAlert: BaseViewController {
    
    var viewAlert = UIView()
    var tfEmail = UITextField()
    var btnSend = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupViews()
    }
    
    func setupViews() {
        
        ivBack.isHidden = true
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
        
        viewAlert.addSubview(tfEmail)
        tfEmail.translatesAutoresizingMaskIntoConstraints = false
        
        tfEmail.topAnchor.constraint(equalTo: viewAlert.topAnchor, constant: 20).isActive = true
        tfEmail.leadingAnchor.constraint(equalTo: viewAlert.leadingAnchor, constant: 20).isActive = true
        tfEmail.trailingAnchor.constraint(equalTo: viewAlert.trailingAnchor, constant: -20).isActive = true
        tfEmail.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        tfEmail.font = .systemFont(ofSize: 18)
        tfEmail.textColor = .black
        tfEmail.setLeftPaddingPoints(25)
        tfEmail.backgroundColor = .lightGray.withAlphaComponent(0.3)
        
        tfEmail.layer.cornerRadius = 20
        tfEmail.layer.masksToBounds = true
        tfEmail.layer.borderWidth = 1
        tfEmail.layer.borderColor = #colorLiteral(red: 0.910294354, green: 0.910294354, blue: 0.910294354, alpha: 1)
        
        tfEmail.placeholder = "Enter email"
        
        
        tfEmail.disableAutoFill()
        tfEmail.autocapitalizationType = .none
        
        viewAlert.addSubview(btnSend)
        btnSend.translatesAutoresizingMaskIntoConstraints = false
        
        btnSend.topAnchor.constraint(equalTo: tfEmail.bottomAnchor, constant: 20).isActive = true
        btnSend.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        btnSend.widthAnchor.constraint(equalToConstant: 200).isActive = true
        btnSend.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btnSend.bottomAnchor.constraint(equalTo: viewAlert.bottomAnchor, constant: -20).isActive = true
        
        btnSend.setTitle("Send", for: .normal)
        btnSend.setTitleColor(UIColor.white, for: .normal)
        btnSend.titleLabel?.font = .boldSystemFont(ofSize: 18)
        
        btnSend.backgroundColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        roundCorner(views: [btnSend], radius: 20)
        
        btnSend.addTarget(self, action: #selector(tapOnSend), for: .touchUpInside)
        
        roundCorner(views: [viewAlert], radius: 10)
        
    }
    
    @objc func tapOnSend() {
        if tfEmail.text!.isEmpty {
            popupAlert(alertTitle: "Information must not be empty", acTitle: "OK")
            return
        }
        
        if let user = globalArrUser.first(where: {$0.email == tfEmail.text!}) {
            let value = ["avatar": globalCurrUser?.avatar, "name": globalCurrUser?.displayName, "senderId": globalCurrUser?.senderId] as [String : Any]
            dbRef.child("Users").child(user.senderId).child("friendsRequest").child(globalCurrUser!.senderId).setValue(value)
            dismiss(animated: true)

        } else {
            popupAlert(alertTitle: "Account does not exist", acTitle: "OK")

        }
    }
    
    @objc func tapOnDismiss() {
        dismiss(animated: true)
    }
    
}
