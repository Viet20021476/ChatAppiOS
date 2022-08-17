//
//  MediaViewVC.swift
//  ChatAppIOS
//
//  Created by Nguyễn Duy Việt on 17/08/2022.
//

import UIKit

class MediaViewVC: BaseViewController {
    
    var mediaView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupView()
        setupRightBarBtnItem()
    }
    
    func setupView() {
        ivBack.isHidden = true
        view.addSubview(mediaView)
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        
        mediaView.contentMode = .scaleAspectFit
        
        mediaView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        mediaView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mediaView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mediaView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
    }
    
    func setupRightBarBtnItem() {
        let rightItemBtn = UIButton(type: .custom)
        rightItemBtn.translatesAutoresizingMaskIntoConstraints = false
        rightItemBtn.setImage(UIImage(systemName: "square.and.arrow.down"), for: .normal)
        rightItemBtn.contentVerticalAlignment = .fill
        rightItemBtn.contentHorizontalAlignment = .fill
        rightItemBtn.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        rightItemBtn.widthAnchor.constraint(equalToConstant: 40).isActive = true
        rightItemBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightItemBtn)
        
        rightItemBtn.addTarget(self, action: #selector(saveToPhone), for: .touchUpInside)
    }
    
    @objc func saveToPhone() {
        UIImageWriteToSavedPhotosAlbum(mediaView.image!, self, nil, nil)
        view.makeToast("Save image successfully")
    }

}
