//
//  HWW8
//
//  Created by Nguyễn Duy Việt on 31/07/2022.
//

import UIKit
import Toast
import Firebase
class RegisterVC: BaseViewController {
    
    var scrollView = UIScrollView()
    var contentView = UIView()
    var lbRegisterHeading = UILabel()
    var imgAvatar = UIImageView()
    var fNameInput = InputView()
    var lNameInput = InputView()
    var registerEmailInput = InputView()
    var registerPasswordInput = InputView()
    var registerConfirmPasswordInput = InputView()
    var btnRegister = UIButton()
    var lbTerms = UILabel()
    var imgLine = UIImageView()
    var lbAl = UILabel()
    
    var imgPicker = UIImagePickerController()
    var chosenAvatar: UIImage?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        navigationController?.navigationBar.isHidden = true
        let tapGesture = UITapGestureRecognizer(target: self, action:#selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        setupViews()
        setupEvent()
    }
  
    func setupViews() {
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white
        
        setupScrollView()
        setupIvBack()
        setupBigLB()
        setupImgAvatar()
        setupLInputView()
        setupBtnRegister()
        setupLbTerms()
    }
    
    func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(ivBack)
        
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        scrollView.showsVerticalScrollIndicator = false
        
        scrollView.addSubview(contentView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.widthAnchor.constraint(equalToConstant: screenSize.width - 50).isActive = true
        contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 25).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
    }
    
    override func setupIvBack() {
        ivBack.removeFromSuperview()
        ivBack.isHidden = false
        
        scrollView.addSubview(ivBack)
        ivBack.translatesAutoresizingMaskIntoConstraints = false
        
        ivBack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10).isActive = true
        ivBack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20).isActive = true
        ivBack.widthAnchor.constraint(equalToConstant: 25).isActive = true
        ivBack.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        ivBack.image = UIImage(named: "ic_back")
        
        ivBack.isUserInteractionEnabled = true
        let backTapGesture = UITapGestureRecognizer(target: self, action: #selector(backScreen))
        ivBack.addGestureRecognizer(backTapGesture)
        
    }
    
    func setupBigLB() {
        contentView.addSubview(lbRegisterHeading)
        lbRegisterHeading.translatesAutoresizingMaskIntoConstraints = false
        
        lbRegisterHeading.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40).isActive = true
        lbRegisterHeading.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        lbRegisterHeading.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        lbRegisterHeading.text = "Register"
        lbRegisterHeading.textColor = .red
        lbRegisterHeading.font = .boldSystemFont(ofSize: 40)
        
        lbRegisterHeading.sizeToFit()
        lbRegisterHeading.numberOfLines = 0
        
    }
    
    func setupImgAvatar() {
        contentView.addSubview(imgAvatar)
        imgAvatar.translatesAutoresizingMaskIntoConstraints = false
        
        imgAvatar.topAnchor.constraint(equalTo: lbRegisterHeading.bottomAnchor, constant: 20).isActive = true
        imgAvatar.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imgAvatar.widthAnchor.constraint(equalToConstant: 100).isActive = true
        imgAvatar.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        contentView.layoutSubviews()
        
        imgAvatar.layer.borderWidth = 1.0
        imgAvatar.layer.masksToBounds = false
        imgAvatar.layer.borderColor = UIColor.white.cgColor
        imgAvatar.layer.cornerRadius = imgAvatar.frame.size.width / 2
        imgAvatar.clipsToBounds = true
        
        imgAvatar.image = UIImage(named: "img_placeholder")
                
        imgAvatar.isUserInteractionEnabled = true
        let pickImgTapGes = UITapGestureRecognizer(target: self, action: #selector(pickImg))
        imgAvatar.addGestureRecognizer(pickImgTapGes)
        
        
        imgPicker.delegate = self
    }
    
    func setupLInputView() {
        
        fNameInput = InputView(parentView: contentView)
        
        fNameInput.topAnchor.constraint(equalTo: imgAvatar.bottomAnchor, constant: 20).isActive = true
        fNameInput.leadingAnchor.constraint(equalTo: lbRegisterHeading.leadingAnchor).isActive = true
        
        fNameInput.lbInput.text = "FIRST NAME :"
        
        fNameInput.tfInput.widthAnchor.constraint(equalToConstant: screenSize.width / 2 - 50).isActive = true
        
        lNameInput = InputView(parentView: contentView)
        
        lNameInput.topAnchor.constraint(equalTo: fNameInput.topAnchor).isActive = true
        lNameInput.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        lNameInput.lbInput.text = "LAST NAME :"
        
        lNameInput.tfInput.widthAnchor.constraint(equalTo: fNameInput.tfInput.widthAnchor).isActive = true
        
        registerEmailInput = InputView(parentView: contentView)
        
        registerEmailInput.topAnchor.constraint(equalTo: lNameInput.bottomAnchor, constant: 12).isActive = true
        registerEmailInput.leadingAnchor.constraint(equalTo: lbRegisterHeading.leadingAnchor).isActive = true
        
        registerEmailInput.lbInput.text = "EMAIL :"
        
        
        registerPasswordInput = InputView(parentView: contentView)
        
        registerPasswordInput.topAnchor.constraint(equalTo: registerEmailInput.bottomAnchor, constant: 12).isActive = true
        registerPasswordInput.leadingAnchor.constraint(equalTo: registerEmailInput.leadingAnchor).isActive = true
        
        registerPasswordInput.lbInput.text = "PASSWORD :"
        registerPasswordInput.tfInput.isSecureTextEntry = true
        
        registerConfirmPasswordInput = InputView(parentView: contentView)
        
        registerConfirmPasswordInput.topAnchor.constraint(equalTo: registerPasswordInput.bottomAnchor, constant: 12).isActive = true
        registerConfirmPasswordInput.leadingAnchor.constraint(equalTo: registerPasswordInput.leadingAnchor).isActive = true
        
        registerConfirmPasswordInput.lbInput.text = "CONFIRM PASSWORD :"
        registerConfirmPasswordInput.tfInput.isSecureTextEntry = true
        
    }
    
    func setupBtnRegister() {
        contentView.addSubview(btnRegister)
        btnRegister.translatesAutoresizingMaskIntoConstraints = false
        
        btnRegister.topAnchor.constraint(equalTo: registerConfirmPasswordInput.bottomAnchor, constant: 35).isActive = true
        btnRegister.leadingAnchor.constraint(equalTo: registerConfirmPasswordInput.leadingAnchor).isActive = true
        btnRegister.trailingAnchor.constraint(equalTo: registerConfirmPasswordInput.trailingAnchor).isActive = true
        btnRegister.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        btnRegister.setTitle("Register", for: .normal)
        btnRegister.setTitleColor(UIColor.white, for: .normal)
        btnRegister.titleLabel?.font = .boldSystemFont(ofSize: 18)
        
        btnRegister.backgroundColor = .red
        
        roundCorner(views: [btnRegister], radius: 30)
        btnRegister.layer.borderColor = UIColor.red.cgColor
        
        btnRegister.addTarget(self, action: #selector(tapToRegister), for: .touchUpInside)
        
        view.bringSubviewToFront(viewIndicator)
    }
    
    func setupLbTerms() {
        contentView.addSubview(lbTerms)
        lbTerms.translatesAutoresizingMaskIntoConstraints = false
        
        lbTerms.topAnchor.constraint(equalTo: btnRegister.bottomAnchor, constant: 15).isActive = true
        lbTerms.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        lbTerms.text = "By Sign up, you agree our Terms and Conditions"
        
        lbTerms.attributedText = colorString(string: lbTerms.text!, startFrom: "Terms", normalFont: lightGrayFont!, anotherColorFont: redFont!)
        
        
        contentView.addSubview(imgLine)
        imgLine.translatesAutoresizingMaskIntoConstraints = false
        
        imgLine.topAnchor.constraint(equalTo: lbTerms.bottomAnchor, constant: 30).isActive = true
        imgLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        imgLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        imgLine.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        imgLine.image = UIImage(named: "line")
        imgLine.alpha = 0.8
        
        
        contentView.addSubview(lbAl)
        lbAl.translatesAutoresizingMaskIntoConstraints = false
        
        
        lbAl.topAnchor.constraint(equalTo: imgLine.bottomAnchor, constant: 10).isActive = true
        lbAl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        lbAl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: -5).isActive = true
        
        lbAl.text = "Already have an account? Login"
        lbAl.attributedText = colorString(string: lbAl.text!, startFrom: "Login", normalFont: lightGrayFont!, anotherColorFont: redFont!)
        
        // HANDLE LATER
        //        contentView.layoutIfNeeded()
        //        if contentView.frame.height > view.frame.height {
        //            imgLine.topAnchor.constraint(equalTo: lbTerms.bottomAnchor, constant: 20).isActive = true
        //
        //        }
    }
    
    func setupEvent() {
        lbTerms.isUserInteractionEnabled = true
        lbAl.isUserInteractionEnabled = true
        
        let lbTermsTapGesture = UITapGestureRecognizer(target: self, action: #selector(navToTerms))
        lbTerms.addGestureRecognizer(lbTermsTapGesture)
        
        let lbLoginTapGesture = UITapGestureRecognizer(target: self, action: #selector(navToLogin))
        lbAl.addGestureRecognizer(lbLoginTapGesture)
    }
    
    @objc func navToTerms() {
        print("Reading Terms and Conditions.....")
    }
    
    @objc func navToLogin() {
        
        if let viewControllers = self.navigationController?.viewControllers {
            for viewController in viewControllers {
                
                if viewController.isKind(of: LoginVC.self) {
                    navigationController?.popToViewController(ofClass: LoginVC.self, animated: true)
                    return
                }
            }
            let loginVC = LoginVC()
            navigationController?.pushViewController(loginVC, animated: true)
        }
    }
    
    @objc func pickImg() {
        let alert = UIAlertController(title: "Choose your profile picture", message: nil, preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "Photo Library", style: .default) { ac in
            self.imgPicker.sourceType = .photoLibrary
            self.present(self.imgPicker, animated: true)
        }
        let action2 = UIAlertAction(title: "Camera", style: .default) { ac in
            self.imgPicker.sourceType = .camera
            self.present(self.imgPicker, animated: true)
        }
        let action3 = UIAlertAction(title: "Cancel", style: .cancel,handler: nil)
        
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action3)
        
        present(alert, animated: true)
    }
    
    
    @objc func tapToRegister() {
        view.endEditing(true)
        startAnimating()
        
        if fNameInput.tfInput.text!.isEmpty || lNameInput.tfInput.text!.isEmpty || registerEmailInput.tfInput.text!.isEmpty || registerPasswordInput.tfInput.text!.isEmpty || registerConfirmPasswordInput.tfInput.text!.isEmpty {
            self.view.makeToast("Information must not be empty")
            stopAnimating()
            return
        }
        
        if registerPasswordInput.tfInput.text! != registerConfirmPasswordInput.tfInput.text! {
            self.view.makeToast("Password does not match")
            stopAnimating()
            return
        }
        
        if chosenAvatar == nil {
            self.view.makeToast("You have not chosen your profile picture yet")
            stopAnimating()
            return
        }
        
        auth.createUser(withEmail: registerEmailInput.tfInput.text!, password: registerPasswordInput.tfInput.text!) { res, err in
            if err != nil {
                self.view.makeToast(err?.localizedDescription)
                self.stopAnimating()
            } else {
                let userId = res?.user.uid
                let name = "\(self.fNameInput.tfInput.text!) \(self.lNameInput.tfInput.text!)"
                
                if let avatar = self.chosenAvatar, let data = avatar.jpegData(compressionQuality: 0.3) { // 1 la MAX
                    let imgName = userId
                    
                    // DUONG DAN CHO THU MUC CHUA AVATAR
                    let imgStorageRef = self.storageRef
                    let imgFolder = imgStorageRef.child("Profile picture").child(imgName!) //-> DUONG DAN LUU AVATAR
                    imgFolder.putData(data, metadata: nil) { meta, err in
                        if err != nil {
                            self.view.makeToast(err?.localizedDescription)
                            self.stopAnimating()
                            return
                        } else {
                            imgFolder.downloadURL { url, err in
                                if err != nil {
                                    self.view.makeToast(err?.localizedDescription)
                                    self.stopAnimating()
                                    return
                                } else {
                                    // POST DATA
                                    let value = ["id": userId, "email": res?.user.email, "avatar": "\(url!)", "name": name, "timeStamp": 0, "beingInRoom": "", "isOnline": false, "lastOnline": "", "birthDate": "", "phoneNumber": "", "feeling": ""] as [String : Any]
                                    self.dbRef.child("Users").child(userId!).setValue(value)
                                }
                            }
                            
                        }
                    }
                }
                
                self.view.makeToast("Sign up successfully")
                self.stopAnimating()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        
    }
    
}

extension RegisterVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imgAvatar.image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        chosenAvatar = imgAvatar.image
        dismiss(animated: true)
    }
}



