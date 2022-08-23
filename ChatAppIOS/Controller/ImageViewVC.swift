//
//  MediaViewVC.swift
//  ChatAppIOS
//
//  Created by Nguyễn Duy Việt on 17/08/2022.
//

import UIKit

class ImageViewVC: BaseViewController {
    
    var scrollView = UIScrollView()
    var mediaView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupView()
        setupRightBarBtnItem()
    }
    
    func setupView() {
        ivBack.isHidden = true

        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        
        
        scrollView.addSubview(mediaView)
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        
        mediaView.contentMode = .scaleAspectFit
        
        mediaView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        mediaView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor).isActive = true
        mediaView.widthAnchor.constraint(equalToConstant: screenSize.width).isActive = true
        mediaView.clipsToBounds = false
        
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
                
        scrollView.delegate = self
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

extension ImageViewVC : UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return mediaView
    }
}
