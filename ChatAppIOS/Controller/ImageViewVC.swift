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
    
    override func viewWillAppear(_ animated: Bool) {
        Util.lockOrientation(.all)
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
        
        let attributedTitle = NSAttributedString(string: "See more",
                                                 attributes: [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0, green: 0.5157059431, blue: 0.8492991328, alpha: 1), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 19)])
        
        rightItemBtn.setAttributedTitle(attributedTitle, for: .normal)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightItemBtn)
        
        rightItemBtn.addTarget(self, action: #selector(savePictureToPhone), for: .touchUpInside)
    }
    
    @objc func savePictureToPhone() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let actionSave = UIAlertAction(title: "Save picture", style: .default) { ac in
            UIImageWriteToSavedPhotosAlbum(self.mediaView.image!, self, nil, nil)
            self.view.makeToast("Save image successfully")
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(actionSave)
        alert.addAction(actionCancel)
        present(alert, animated: true)

    }

}

extension ImageViewVC : UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return mediaView
    }
}
