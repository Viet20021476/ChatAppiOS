//
//  VideoPlayer.swift
//  CustomVideoPlayer
//
//  Created by Nguyen Duc Huy B on 7/8/21.
//

import UIKit
import AVFoundation

final class VideoPlayer: UIView {
    // MARK: - Outlets
    
    @IBOutlet var videoView: UIView!
    @IBOutlet var playBackView: PlayBackView!
    
    // MARK: - Properties
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var isShowPlayBack: Bool = true
    var playerTimer: Timer?
    
    var dismissClosure: (() -> Void)?
    var vc: UIViewController?
    
    // MARK: - Override Methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        config()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
        config()
    }
    
    // MARK: - Public Methods
    
    func playVideo(with urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let playerItem = AVPlayerItem(url: url)
        player?.replaceCurrentItem(with: playerItem)
        playBackView.playVideo()
    }
    
    func updateLayoutSubviews() {
        layoutIfNeeded()
        playerLayer.frame = videoView.bounds
    }
    
    // MARK: - Private Methods
    
    private func commonInit() {
        guard let contentView = Bundle.main.loadNibNamed(String(describing: VideoPlayer.self), owner: self, options: nil)?.first as? UIView else { return }
        contentView.frame = self.bounds
        addSubview(contentView)
    }
    
    private func config() {
        // Tap gesture
        let controlTapGesture = UITapGestureRecognizer(target: self, action: #selector(playerViewHandleTap))
        self.addGestureRecognizer(controlTapGesture)
        
        setupPlayer()
        
        playBackView.config(with: player)
        playBackView.pauseAutoHidePlayBackClosure = { [weak self] in
            self?.resetTimer()
        }
        
        startTimer()
    }
    
    private func setupPlayer() {
        player = AVPlayer()
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoView.bounds
        playerLayer.videoGravity = .resizeAspect
        videoView.layer.addSublayer(playerLayer)
    }
    
    @objc private func playerViewHandleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.location(in: self)
        guard let contentView = self.getViewsByType(type: PlayBackView.self).first else { return }
        
        if contentView.frame.contains(location) && isShowPlayBack {
            return
        }
        
        showHidePlayBackView()
    }
}

// MARK: - Show / Hide PlayBack

private extension VideoPlayer {
    func startTimer() {
        playerTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(autoHidePlayBack), userInfo: nil, repeats: false)
    }
    
    func resetTimer() {
        playerTimer?.invalidate()
        startTimer()
    }
    
    @objc func autoHidePlayBack() {
        if isShowPlayBack {
            showHidePlayBackView()
        }
    }
    
    func showHidePlayBackView() {
        isShowPlayBack = !isShowPlayBack
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let self = self else { return }
            self.playBackView.alpha = !self.isShowPlayBack ? 0 : 1
            self.vc?.navigationController?.navigationBar.isHidden = !self.isShowPlayBack
        })
        if isShowPlayBack {
            resetTimer()
        }
    }
}
