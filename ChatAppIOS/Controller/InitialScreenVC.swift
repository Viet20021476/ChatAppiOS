//
//  InitialScreenVC.swift
//  ChatAppIOS
//
//  Created by Nguyễn Duy Việt on 11/08/2022.
//

import UIKit

class InitialScreenVC: BaseViewController {
    
    var ivBackground = UIImageView()
    var viewColor = UIView()
    var viewLogo = UIView()
    var ivLogo = UIImageView()
    var lbLogo = UILabel()
    var lbSol = UILabel()
    var btnRegister = UIButton()
    var btnLogin = UIButton()
    var lbVer = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupViews()
    }
    
    func setupViews() {
        setupBackground()
        setupLogoView()
        setupButton()
        setupLabelVersion()
    }
    
    func setupBackground() {
        ivBack.isHidden = true
        view.addSubview(ivBackground)
        ivBackground.translatesAutoresizingMaskIntoConstraints = false

        ivBackground.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        ivBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        ivBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        ivBackground.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        ivBackground.image = UIImage(named: "img_bg")
                
        view.addSubview(viewColor)

        viewColor.translatesAutoresizingMaskIntoConstraints = false

        viewColor.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        viewColor.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        viewColor.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        viewColor.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        viewColor.backgroundColor = #colorLiteral(red: 0.963629663, green: 0.02967488207, blue: 0.4042446911, alpha: 1).withAlphaComponent(0.8)
        viewColor.alpha = 0.5
    }
    
    func setupLogoView() {
        view.addSubview(lbLogo)
      
        lbLogo.translatesAutoresizingMaskIntoConstraints = false
        
        lbLogo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: screenSize.height / 8).isActive = true
        lbLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        
        lbLogo.text = "Chatting app"
        lbLogo.font = .boldSystemFont(ofSize: view.frame.width / 9)
        lbLogo.textColor = .white
        
        lbLogo.sizeToFit()
    }
    
    func setupButton() {
        view.addSubview(btnRegister)
        btnRegister.translatesAutoresizingMaskIntoConstraints = false
        
        btnRegister.topAnchor.constraint(equalTo: lbLogo.bottomAnchor, constant: screenSize.height / 6).isActive = true
        btnRegister.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50).isActive = true
        btnRegister.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50).isActive = true
        btnRegister.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        btnRegister.setTitle("Register", for: .normal)
        btnRegister.setTitleColor(UIColor.red, for: .normal)
        btnRegister.backgroundColor = .white
        btnRegister.titleLabel?.font = .boldSystemFont(ofSize: 20)
        
        btnRegister.addTarget(self, action: #selector(getToRegister), for: .touchUpInside)
        
        view.addSubview(btnLogin)
        btnLogin.translatesAutoresizingMaskIntoConstraints = false
        
        btnLogin.topAnchor.constraint(equalTo: btnRegister.bottomAnchor, constant: 25).isActive = true
        btnLogin.leadingAnchor.constraint(equalTo: btnRegister.leadingAnchor).isActive = true
        btnLogin.trailingAnchor.constraint(equalTo: btnRegister.trailingAnchor).isActive = true
        btnLogin.heightAnchor.constraint(equalTo: btnRegister.heightAnchor).isActive = true
        
        btnLogin.setTitle("Login", for: .normal)
        btnLogin.setTitleColor(UIColor.red, for: .normal)
        btnLogin.backgroundColor = .white
        btnLogin.titleLabel?.font = .boldSystemFont(ofSize: 20)
        
        roundCorner(views: [btnLogin, btnRegister], radius: 30)
        
        btnLogin.addTarget(self, action: #selector(getToLogin), for: .touchUpInside)
        
    }
    
    func setupLabelVersion() {
        view.addSubview(lbVer)
        lbVer.translatesAutoresizingMaskIntoConstraints = false
        
        lbVer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        lbVer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5).isActive = true
        
        lbVer.text = "Vit's Chat Apps v1.0"
        lbVer.textColor = .black
        lbVer.textAlignment = .center
        lbVer.font = lbVer.font.withSize(15)
        lbVer.alpha = 0.7
    }
    
    @objc func getToLogin() {
        let loginVC = LoginVC()
        navigationController?.pushViewController(loginVC, animated: true)
    }

    @objc func getToRegister() {
        let registerVC = RegisterVC()
        navigationController?.pushViewController(registerVC, animated: true)

    }

}
