//
//  LoginViewController.swift
//  HWW8
//
//  Created by Nguyễn Duy Việt on 31/07/2022.
//

import UIKit
import LTHRadioButton

class LoginVC: BaseViewController {
    
    var lbLoginHeading = UILabel()
    var loginEmailInput = InputView()
    var loginPasswordInput = InputView()
    var btnLogin = UIButton()
    var lbForgot = UILabel()
    var imgLine = UIImageView()
    var lbRegister = UILabel()
    var lbSave = UILabel()
    var radiBtnSave = LTHRadioButton(diameter: 30, selectedColor: .red)
    var saveSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupViews()
        setupEvent()
    }
    
    func setupViews() {
        ivBack.isHidden = false
        navigationController?.navigationBar.isHidden = true
        
        setupBigLB()
        setupLInputView()
        setupCheckbox()
        setupBtnLogin()
        setupLbForgotNRegister()
    }
    
    func setupBigLB() {
        view.addSubview(lbLoginHeading)
        lbLoginHeading.translatesAutoresizingMaskIntoConstraints = false
        
        lbLoginHeading.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40).isActive = true
        lbLoginHeading.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25).isActive = true
        lbLoginHeading.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        lbLoginHeading.text = "Login"
        lbLoginHeading.textColor = .red
        lbLoginHeading.font = .boldSystemFont(ofSize: 40)
        
        lbLoginHeading.sizeToFit()
        lbLoginHeading.numberOfLines = 0
    }
    
    func setupLInputView() {
        loginEmailInput = InputView(parentView: view)
        
        loginEmailInput.topAnchor.constraint(equalTo: lbLoginHeading.bottomAnchor, constant: 40).isActive = true
        loginEmailInput.leadingAnchor.constraint(equalTo: lbLoginHeading.leadingAnchor).isActive = true
        
        loginEmailInput.lbInput.text = "EMAIL :"
        
        loginPasswordInput = InputView(parentView: view)
        
        loginPasswordInput.topAnchor.constraint(equalTo: loginEmailInput.bottomAnchor, constant: 12).isActive = true
        loginPasswordInput.leadingAnchor.constraint(equalTo: loginEmailInput.leadingAnchor).isActive = true
        
        loginPasswordInput.lbInput.text = "PASSWORD :"
        loginPasswordInput.tfInput.isSecureTextEntry = true
        
        if let info = userDefault.object(forKey: ACCOUNT) as? String {
            let arrInfo = info.split(separator: " ")
            loginEmailInput.tfInput.text = String(arrInfo[0])
            loginPasswordInput.tfInput.text = String(arrInfo[1])
        }
    }
    
    func setupCheckbox() {
        view.addSubview(lbSave)
        lbSave.translatesAutoresizingMaskIntoConstraints = false
        
        lbSave.topAnchor.constraint(equalTo: loginPasswordInput.bottomAnchor, constant: 20).isActive = true
        lbSave.leadingAnchor.constraint(equalTo: loginPasswordInput.leadingAnchor).isActive = true
        
        lbSave.text = "Save"
        lbSave.textColor = .black.withAlphaComponent(0.7)
        lbSave.font = .boldSystemFont(ofSize: view.frame.width / 23)
        
        
        view.addSubview(radiBtnSave)
        radiBtnSave.translatesAutoresizingMaskIntoConstraints = false
        
        radiBtnSave.centerYAnchor.constraint(equalTo: lbSave.centerYAnchor).isActive = true
        radiBtnSave.leadingAnchor.constraint(equalTo: lbSave.trailingAnchor, constant: 10).isActive = true
        radiBtnSave.widthAnchor.constraint(equalToConstant: 30).isActive = true
        radiBtnSave.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        radiBtnSave.onSelect {
            self.saveSelected = true
        }
        radiBtnSave.onDeselect {
            self.saveSelected = false
        }
    }
    
    func setupBtnLogin() {
        view.addSubview(btnLogin)
        btnLogin.translatesAutoresizingMaskIntoConstraints = false
        
        btnLogin.topAnchor.constraint(equalTo: lbSave.bottomAnchor, constant: 35).isActive = true
        btnLogin.leadingAnchor.constraint(equalTo: loginPasswordInput.leadingAnchor).isActive = true
        btnLogin.trailingAnchor.constraint(equalTo: loginPasswordInput.trailingAnchor).isActive = true
        btnLogin.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        btnLogin.setTitle("Login", for: .normal)
        btnLogin.setTitleColor(UIColor.white, for: .normal)
        btnLogin.titleLabel?.font = .boldSystemFont(ofSize: 18)
        
        btnLogin.backgroundColor = .red
        
        btnLogin.layer.cornerRadius = 30
        btnLogin.layer.masksToBounds = true
        btnLogin.layer.borderWidth = 1
        btnLogin.layer.borderColor = UIColor.red.cgColor
        
        btnLogin.addTarget(self, action: #selector(tapToLogin), for: .touchUpInside)
        
        view.bringSubviewToFront(viewIndicator)

    }
    
    func setupLbForgotNRegister() {
        view.addSubview(lbForgot)
        lbForgot.translatesAutoresizingMaskIntoConstraints = false
        
        lbForgot.topAnchor.constraint(equalTo: btnLogin.bottomAnchor, constant: 20).isActive = true
        lbForgot.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        lbForgot.text = "Cant't login? Forgot Password"
        
        lbForgot.attributedText = colorString(string: lbForgot.text!, startFrom: "Forgot", normalFont: lightGrayFont!, anotherColorFont: redFont!)
        
        
        view.addSubview(imgLine)
        imgLine.translatesAutoresizingMaskIntoConstraints = false
        
        imgLine.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imgLine.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        imgLine.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive = true
        imgLine.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        imgLine.image = UIImage(named: "line")
        imgLine.alpha = 0.8
        
        
        view.addSubview(lbRegister)
        lbRegister.translatesAutoresizingMaskIntoConstraints = false
        
        lbRegister.topAnchor.constraint(equalTo: imgLine.bottomAnchor, constant: 20).isActive = true
        lbRegister.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        lbRegister.text = "Don't have an account? Register"
        
        lbRegister.attributedText = colorString(string: lbRegister.text!, startFrom: "Register", normalFont: lightGrayFont!, anotherColorFont: redFont!)
    }
    
    func setupEvent() {
        lbForgot.isUserInteractionEnabled = true
        lbRegister.isUserInteractionEnabled = true
        
        let lbForgotTapGesture = UITapGestureRecognizer(target: self, action: #selector(navToForgotPassword))
        lbForgot.addGestureRecognizer(lbForgotTapGesture)
        
        let lbRegisterTapGesture = UITapGestureRecognizer(target: self, action: #selector(navToRegister))
        lbRegister.addGestureRecognizer(lbRegisterTapGesture)
        
    }
    
    @objc func navToForgotPassword() {
        let forgotPasswordVC = ForgotPasswordVC()
        navigationController?.pushViewController(forgotPasswordVC, animated: true)
        
    }
    
    @objc func navToRegister() {
        
        if let viewControllers = self.navigationController?.viewControllers {
            for viewController in viewControllers {
                
                if viewController.isKind(of: RegisterVC.self) {
                    navigationController?.popToViewController(ofClass: RegisterVC.self, animated: true)
                    return
                }
            }
            let registerVC = RegisterVC()
            navigationController?.pushViewController(registerVC, animated: true)
        }
    }

    @objc func tapToLogin() {
        view.endEditing(true)
        startAnimating()
        
        let email = loginEmailInput.tfInput.text!
        let password = loginPasswordInput.tfInput.text!
        
        if email.isEmpty || password.isEmpty {
            self.view.makeToast("Information must not be empty")
            stopAnimating()
            return
        }
        
        auth.signIn(withEmail: email, password: password) { res, err in
            if err != nil {
                self.view.makeToast(err?.localizedDescription)
                self.stopAnimating()
                return
            }
            
            if self.saveSelected == true {
                self.userDefault.set("\(email) \(password)", forKey: ACCOUNT)
            }
            
            self.view.makeToast("Login successfully")
            self.stopAnimating()
            
            self.loginEmailInput.tfInput.text = ""
            self.loginPasswordInput.tfInput.text = ""
            
            let vc = HomeVC(nibName: "HomeVC", bundle: nil)
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
    
    
}



