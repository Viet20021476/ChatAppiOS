//
//  ForgotPasswordVC.swift
//  ChatAppIOS
//
//  Created by Nguyễn Duy Việt on 11/08/2022.
//

import UIKit

class ForgotPasswordVC: BaseViewController {
    
    var emailInput = InputView()
    var btnConfirm = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }
    
    func setupViews() {
        ivBack.isHidden = false
        setupEmailInput()
        setupBtnConfirm()
    }
    
    func setupEmailInput() {
        emailInput = InputView(parentView: view)
            
        emailInput.lbInput.text = "YOUR EMAIL:"
        
        emailInput.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emailInput.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60).isActive = true
        
    }
    
    func setupBtnConfirm() {
        view.addSubview(btnConfirm)
        btnConfirm.translatesAutoresizingMaskIntoConstraints = false
        
        btnConfirm.topAnchor.constraint(equalTo: emailInput.bottomAnchor, constant: 20).isActive = true
        btnConfirm.leadingAnchor.constraint(equalTo: emailInput.leadingAnchor).isActive = true
        btnConfirm.trailingAnchor.constraint(equalTo: emailInput.trailingAnchor).isActive = true
        
        btnConfirm.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        btnConfirm.setTitle("Confirm", for: .normal)
        btnConfirm.setTitleColor(UIColor.white, for: .normal)
        btnConfirm.titleLabel?.font = .boldSystemFont(ofSize: 18)
        
        btnConfirm.backgroundColor = .purple
        
        roundCorner(views: [btnConfirm], radius: 30)
        
        btnConfirm.addTarget(self, action: #selector(confirmResetPassword), for: .touchUpInside)
        
        view.bringSubviewToFront(viewIndicator)
    }
    
    @objc func confirmResetPassword() {
        startAnimating()
        let email = emailInput.tfInput.text!
        if email.isEmpty {
            self.view.makeToast("Information must not be empty")
            stopAnimating()
            return
        }
        
        auth.sendPasswordReset(withEmail: email) { err in
            if err != nil {
                self.view.makeToast(err?.localizedDescription)
                self.stopAnimating()
                return
            }
            self.stopAnimating()
            let alert = UIAlertController(title: "We've send a link to \(email) to reset your password", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { ac in
                self.navigationController?.popViewController(animated: true)
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
}
