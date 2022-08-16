//
//  ProfileVC.swift
//  ChatAppIOS
//
//  Created by Nguyễn Duy Việt on 15/08/2022.
//

import UIKit
import FirebaseAuth

class ProfileVC: BaseViewController {
    
    var scrollView = UIScrollView()
    var contentView = UIView()
    var imgAvatar = UIImageView()
    var infoName = InfoView()
    var infoBirthDate = InfoView()
    var infoEmail = InfoView()
    var infoPhoneNumber = InfoView()
    var infoFeeling = InfoView()
    
    var btnEdit = UIButton()
    var btnLogout = UIButton()
    
    var imgPicker = UIImagePickerController()
    var changePic = false
    
    var isOtherUserProfile = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupViews()
        bindData()
    }
    
    func setupViews() {
        setupScrollView()
        setupIvBack()
        setupImgAvatar()
        setupInfoViews()
        setupBtnEdit()
        setupBtnLogout()
    }
    
    func bindData() {
        startAnimating()
        imgAvatar.sd_setImage(with: URL(string: currUser!.avatar))
        infoName.tfInfo.text = currUser?.displayName
        infoBirthDate.tfInfo.text = currUser?.birthDate
        infoEmail.tfInfo.text = currUser?.email
        infoPhoneNumber.tfInfo.text = currUser?.phoneNumber
        infoFeeling.tfInfo.text = currUser?.feeling
        stopAnimating()
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
        contentView.widthAnchor.constraint(equalToConstant: screenSize.width - 20).isActive = true
        contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        
        contentView.isUserInteractionEnabled = true
        let tapHideKeyboardGes = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        contentView.addGestureRecognizer(tapHideKeyboardGes)
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
    
    func setupImgAvatar() {
        contentView.addSubview(imgAvatar)
        imgAvatar.translatesAutoresizingMaskIntoConstraints = false
        
        imgAvatar.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 60).isActive = true
        imgAvatar.widthAnchor.constraint(equalToConstant: 100).isActive = true
        imgAvatar.heightAnchor.constraint(equalToConstant: 100).isActive = true
        imgAvatar.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        contentView.layoutIfNeeded()
        
        imgAvatar.layer.borderWidth = 1.0
        imgAvatar.layer.masksToBounds = false
        imgAvatar.layer.borderColor = UIColor.white.cgColor
        imgAvatar.layer.cornerRadius = imgAvatar.frame.size.width / 2
        imgAvatar.clipsToBounds = true
        
        imgAvatar.image = UIImage(named: "img_placeholder")
        imgAvatar.contentMode = .scaleToFill
        
        imgAvatar.backgroundColor = .red
        
        imgAvatar.isUserInteractionEnabled = true
        
        let tapPickImgGes = UITapGestureRecognizer(target: self, action: #selector(tapOnPickImg))
        imgAvatar.addGestureRecognizer(tapPickImgGes)
        
        imgPicker.delegate = self
        
        
    }
    
    func setupInfoViews() {
        infoName = InfoView(parentView: contentView)
        infoName.isUserInteractionEnabled = true
        infoName.topAnchor.constraint(equalTo: imgAvatar.bottomAnchor, constant: 30).isActive = true
        infoName.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        infoName.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        
        infoName.lbTag.text = "Name:"
        infoName.tfInfo.text = "Hehe"
        
        let tapEditNameGes = UITapGestureRecognizer(target: self, action: #selector(tapOnEditName))
        infoName.imgEdit.addGestureRecognizer(tapEditNameGes)
        
        infoBirthDate = InfoView(parentView: contentView)
        infoBirthDate.topAnchor.constraint(equalTo: infoName.bottomAnchor, constant: 45).isActive = true
        infoBirthDate.leadingAnchor.constraint(equalTo: infoName.leadingAnchor).isActive = true
        infoBirthDate.trailingAnchor.constraint(equalTo: infoName.trailingAnchor).isActive = true
        
        infoBirthDate.lbTag.text = "Birthday:"
        infoBirthDate.tfInfo.text = "Hehe"
        
        let tapEditBDGes = UITapGestureRecognizer(target: self, action: #selector(tapOnEditBD))
        infoBirthDate.imgEdit.addGestureRecognizer(tapEditBDGes)
        
        infoEmail = InfoView(parentView: contentView)
        infoEmail.topAnchor.constraint(equalTo: infoBirthDate.bottomAnchor, constant: 45).isActive = true
        infoEmail.leadingAnchor.constraint(equalTo: infoBirthDate.leadingAnchor).isActive = true
        infoEmail.trailingAnchor.constraint(equalTo: infoBirthDate.trailingAnchor).isActive = true
        
        infoEmail.lbTag.text = "Email:"
        infoEmail.tfInfo.text = "Hehe"
        
        let tapEditEmailGes = UITapGestureRecognizer(target: self, action: #selector(tapOnEditEmail))
        infoEmail.imgEdit.addGestureRecognizer(tapEditEmailGes)
        
        infoPhoneNumber = InfoView(parentView: contentView)
        infoPhoneNumber.topAnchor.constraint(equalTo: infoEmail.bottomAnchor, constant: 45).isActive = true
        infoPhoneNumber.leadingAnchor.constraint(equalTo: infoEmail.leadingAnchor).isActive = true
        infoPhoneNumber.trailingAnchor.constraint(equalTo: infoEmail.trailingAnchor).isActive = true
        
        infoPhoneNumber.lbTag.text = "Phone number:"
        infoPhoneNumber.tfInfo.text = "Hehe"
        
        let tapEditPNumberGes = UITapGestureRecognizer(target: self, action: #selector(tapOnEditPNumber))
        infoPhoneNumber.imgEdit.addGestureRecognizer(tapEditPNumberGes)
        
        infoFeeling = InfoView(parentView: contentView)
        infoFeeling.topAnchor.constraint(equalTo: infoPhoneNumber.bottomAnchor, constant: 45).isActive = true
        infoFeeling.leadingAnchor.constraint(equalTo: infoPhoneNumber.leadingAnchor).isActive = true
        infoFeeling.trailingAnchor.constraint(equalTo: infoPhoneNumber.trailingAnchor).isActive = true
        
        infoFeeling.lbTag.text = "Feeling:"
        infoFeeling.tfInfo.text = "Hehe"
        
        let tapEditFeelingGes = UITapGestureRecognizer(target: self, action: #selector(tapOnEditFeeling))
        infoFeeling.imgEdit.addGestureRecognizer(tapEditFeelingGes)
        
        if isOtherUserProfile {
            infoName.imgEdit.isHidden = true
            infoBirthDate.imgEdit.isHidden = true
            infoEmail.imgEdit.isHidden = true
            infoPhoneNumber.imgEdit.isHidden = true
            infoFeeling.imgEdit.isHidden = true
            btnEdit.isHidden = true
            btnLogout.isHidden = true
            ivBack.isHidden = true
        }
    }
    
    func setupBtnEdit() {
        contentView.addSubview(btnEdit)
        
        btnEdit.translatesAutoresizingMaskIntoConstraints = false
        
        btnEdit.topAnchor.constraint(equalTo: infoFeeling.bottomAnchor, constant: 50).isActive = true
        btnEdit.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        btnEdit.widthAnchor.constraint(equalToConstant: 200).isActive = true
        btnEdit.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        btnEdit.setTitle("Edit", for: .normal)
        btnEdit.setTitleColor(UIColor.white, for: .normal)
        btnEdit.titleLabel?.font = .boldSystemFont(ofSize: 20)
        
        btnEdit.backgroundColor = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
        
        btnEdit.addTarget(self, action: #selector(tapOnConfirmEdit), for: .touchUpInside)
    }
    
    func setupBtnLogout() {
        contentView.addSubview(btnLogout)
        
        btnLogout.translatesAutoresizingMaskIntoConstraints = false
        
        btnLogout.topAnchor.constraint(equalTo: btnEdit.bottomAnchor, constant: 20).isActive = true
        btnLogout.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        btnLogout.widthAnchor.constraint(equalToConstant: 200).isActive = true
        btnLogout.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btnLogout.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        
        btnLogout.setTitle("Log out", for: .normal)
        btnLogout.setTitleColor(UIColor.white, for: .normal)
        btnLogout.titleLabel?.font = .boldSystemFont(ofSize: 18)
        
        btnLogout.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        roundCorner(views: [btnLogout, btnEdit], radius: 20)
        
        btnLogout.addTarget(self, action: #selector(tapOnLogout), for: .touchUpInside)
    }
    
    @objc func tapOnConfirmEdit() {
        startAnimating()
        if changePic {
            storageRef.child("Profile picture").child(currUser!.senderId).delete { err in
                if err != nil {
                    self.popupAlert(alertTitle: "An error occurred", acTitle: "OK")
                }
            }
        }
        
        let imgName = currUser?.senderId
        
        // DUONG DAN CHO THU MUC CHUA AVATAR
        let imgFolder = storageRef.child("Profile picture").child(imgName!)
        
        let data = imgAvatar.image?.jpegData(compressionQuality: 0.3)
        
        imgFolder.putData(data!, metadata: nil) { meta, err in
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
                        let newName = self.infoName.tfInfo.text
                        let newBirthDate = self.infoBirthDate.tfInfo.text
                        let newEmail = self.infoEmail.tfInfo.text
                        let newPNumber = self.infoPhoneNumber.tfInfo.text
                        let newFeeling = self.infoFeeling.tfInfo.text
                        
                        self.dbRef.child("Users").child(self.currUser!.senderId).child("avatar").setValue("\(url!)")
                        self.dbRef.child("Users").child(self.currUser!.senderId).child("name").setValue(newName)
                        self.dbRef.child("Users").child(self.currUser!.senderId).child("birthDate").setValue(newBirthDate)
                        self.dbRef.child("Users").child(self.currUser!.senderId).child("email").setValue(newEmail)
                        self.dbRef.child("Users").child(self.currUser!.senderId).child("phoneNumber").setValue(newPNumber)
                        self.dbRef.child("Users").child(self.currUser!.senderId).child("feeling").setValue(newFeeling)
                        
                        self.navigationController?.popViewController(animated: true)
                        
                        self.stopAnimating()
                    }
                }
            }
        }
        
    }
    
    @objc func tapOnLogout(_ sender: Any) {
        let alert = UIAlertController(title: "Do you want to log out?", message: nil, preferredStyle: .alert)
        let actionYes = UIAlertAction(title: "Yes", style: .destructive) { ac in
            self.dbRef.child("Users").child(self.currUser!.senderId).child("isOnline").setValue(false)
            self.dbRef.child("Users").child(self.currUser!.senderId).child("lastOnline").setValue(self.getStringFromDate(format: "HH:mm:ss dd/MM/YYYY", date:Date()))
            self.navigationController?.popToViewController(ofClass: InitialScreenVC.self, animated: true)
        }
        
        let actionNo = UIAlertAction(title: "No", style: .default, handler: nil)
        
        alert.addAction(actionYes)
        alert.addAction(actionNo)
        
        present(alert, animated: true)
    }
    
    @objc func tapOnPickImg() {
        
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
    
    @objc func tapOnEditName() {
        let vc = EditInfoAlert()
        vc.tfInfo.text = infoName.tfInfo.text
        vc.type = .name
        vc.delegate = self
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    @objc func tapOnEditBD() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChange(sender:)), for: .valueChanged)
        datePicker.frame.size = CGSize(width: 0, height: 300)
        datePicker.preferredDatePickerStyle = .wheels
        infoBirthDate.tfInfo.isUserInteractionEnabled = true
        infoBirthDate.tfInfo.inputView = datePicker
        infoBirthDate.tfInfo.becomeFirstResponder()
        
    }
    
    @objc func tapOnEditEmail() {
        let vc = EditInfoAlert()
        vc.tfInfo.text = infoEmail.tfInfo.text
        vc.type = .email
        vc.delegate = self
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    @objc func tapOnEditPNumber() {
        let vc = EditInfoAlert()
        vc.tfInfo.text = infoPhoneNumber.tfInfo.text
        vc.type = .phonenumber
        vc.delegate = self
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    @objc func tapOnEditFeeling() {
        let vc = EditInfoAlert()
        vc.tfInfo.text = infoFeeling.tfInfo.text
        vc.type = .feeling
        vc.delegate = self
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    @objc func dateChange(sender: UIDatePicker) {
        infoBirthDate.tfInfo.text = getStringFromDate(format: "dd/MM/YYYY", date: sender.date)
    }
    
    override func hideKeyboard() {
        view.endEditing(true)
    }
    
}

extension ProfileVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imgAvatar.image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        changePic = true
        dismiss(animated: true)
    }
}

extension ProfileVC : EditInfoAlertDelegate {
    func editName(name: String) {
        infoName.tfInfo.text = name
    }
    
    func editEmail(email: String) {
        infoEmail.tfInfo.text = email
    }
    
    func editPNumber(pNumber: String) {
        infoPhoneNumber.tfInfo.text = pNumber
    }
    
    func editFeeling(feeling: String) {
        infoFeeling.tfInfo.text = feeling
    }
    
    
}
