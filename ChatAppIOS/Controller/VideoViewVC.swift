//
//  VideoViewVC.swift
//  ChatAppIOS
//
//  Created by Nguyễn Duy Việt on 18/08/2022.
//

import UIKit
import AVFoundation
import Photos

class VideoViewVC: BaseViewController {
    
    @IBOutlet weak var playerView: VideoPlayer!
    var videoURL = ""
    
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask? = nil

    
    // MARK: - Override Methods
    
    override func viewDidLoad() {
        ivBack.isHidden = true
        super.viewDidLoad()
        setupRightBarBtnItem()
        config()
        playerView.vc = self
        navigationItem.backButtonTitle = ""
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        Util.lockOrientation(.all)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        playerView.player.pause()
        playerView.playerLayer.removeFromSuperlayer()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerView.updateLayoutSubviews()
    }
    
    // MARK: - Private Methods
    
    private func config() {
        playerView.playVideo(with: videoURL)
        playerView.dismissClosure = { [weak self] in
            self?.dismiss(animated: true)
        }
    }
    
    func setupRightBarBtnItem() {
        let rightItemBtn = UIButton(type: .custom)
        rightItemBtn.translatesAutoresizingMaskIntoConstraints = false
        
        let attributedTitle = NSAttributedString(string: "See more",
                                                 attributes: [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0, green: 0.5157059431, blue: 0.8492991328, alpha: 1), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 19)])
        
        rightItemBtn.setAttributedTitle(attributedTitle, for: .normal)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightItemBtn)
        
        rightItemBtn.addTarget(self, action: #selector(saveVideoToPhone), for: .touchUpInside)
    }
    
    @objc func saveVideoToPhone() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let actionSave = UIAlertAction(title: "Save video", style: .default) { ac in
            self.downloadAndSaveVideoToGallery(videoURL: self.videoURL)
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(actionSave)
        alert.addAction(actionCancel)
        present(alert, animated: true)
        
    }
    

    func downloadAndSaveVideoToGallery(videoURL: String, id: String = "default") {
        DispatchQueue.global(qos: .background).async {
            if let url = URL(string: videoURL) {
                let filePath = FileManager.default.temporaryDirectory.appendingPathComponent("\(id).mp4")
                print("work started")
                self.dataTask = self.defaultSession.dataTask(with: url, completionHandler: { [weak self] data, res, err in
                    DispatchQueue.main.async {
                        do {
                            try data?.write(to: filePath)
                            PHPhotoLibrary.shared().performChanges({
                                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: filePath)
                            }) { completed, error in
                                if completed {
                                    print("Saved to gallery !")
                                } else if let error = error {
                                    print(error.localizedDescription)
                                }
                            }
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                    self?.dataTask = nil
                })
                self.dataTask?.resume()
            }
        }
    }
}
