//
//  PlayBackView.swift
//  CustomVideoPlayer
//
//  Created by Huy Nguyen on 5/14/21.
//

import AVFoundation
import UIKit

private struct Constant {
    static let icTrack = UIImage(named: "ic-track")
    static let icPlay = UIImage(named: "ic-play")
    static let icPause = UIImage(named: "ic-pause")
    static let icReplay = UIImage(named: "ic-replay")
    static let icAudio = UIImage(named: "ic-audio")
    static let icNoAudio = UIImage(named: "ic-no-audio")
}

final class PlayBackView: UIView {
    // MARK: - Outlets
    
    @IBOutlet private var playPauseButton: UIButton!
    @IBOutlet private var audioButton: UIButton!
    @IBOutlet private var timeSlider: UISlider!
    @IBOutlet private var timeRemainingLabel: UILabel!
    
    // MARK: - Controls & Properties
    
    var pauseAutoHidePlayBackClosure: (() -> Void)?
    private var player: AVPlayer?
    private var isMuted: Bool = false
    private var isVideoFinished: Bool = false
    
    private var statusObserver: NSKeyValueObservation?
    
    // MARK: - Override Methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromNib()
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadFromNib()
        setup()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "outputVolume" {
            pauseAutoHidePlayBackClosure?()
        }
    }
    
    // MARK: - Deinit
    
    deinit {
        statusObserver?.invalidate()
        AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: "outputVolume")
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public Methods
    
    func config(with player: AVPlayer) {
        self.player = player
        addObservers()
    }
    
    // MARK: - Private Methods
    
    private func setup() {
        timeSlider.setThumbImage(Constant.icTrack, for: .normal)
        timeSlider.addTarget(self, action: #selector(timeSliderValueChanged(_:event:)), for: .valueChanged)
    }
    
    @objc private func timeSliderValueChanged(_ sender: UISlider, event: UIEvent) {
        guard let duration = player?.currentItem?.duration else { return }
        let totalSeconds = CMTimeGetSeconds(duration)
        guard !(totalSeconds.isNaN || totalSeconds.isInfinite) else { return }
        let value = Float64(sender.value) * totalSeconds
        let seekTime = CMTime(value: CMTimeValue(value), timescale: 1)
        
        // Seek and scrub video
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                pauseVideo()
            case .moved:
                player?.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero)
            case .ended:
                playVideo()
                isVideoFinished = false
            default:
                break
            }
        }
        
        // Update time remaining label
        let timeRemaining = duration - seekTime
        guard let timeRemainingString = timeRemaining.getTimeString() else { return }
        timeRemainingLabel.text = timeRemainingString
        
        // Delay auto hide playback
        pauseAutoHidePlayBackClosure?()
    }
    
    @IBAction private func playPauseButtonTapped(_ sender: Any) {
        guard let player = player else { return }
        if player.isPlaying {
            pauseVideo()
        } else {
            if isVideoFinished {
                replayVideo()
            } else {
                playVideo()
            }
        }
        pauseAutoHidePlayBackClosure?()
    }
    
    @IBAction private func audioButtonTapped(_ sender: Any) {
        isMuted = !isMuted
        player?.isMuted = isMuted
        audioButton.setImage(isMuted ? Constant.icNoAudio : Constant.icAudio, for: .normal)
        pauseAutoHidePlayBackClosure?()
    }
}

// MARK: - Play, Pause, Replay Video

extension PlayBackView {
    func playVideo() {
        player?.play()
        playPauseButton.setImage(Constant.icPause, for: .normal)
    }
    
    func pauseVideo() {
        player?.pause()
        playPauseButton.setImage(Constant.icPlay, for: .normal)
    }
    
    func replayVideo() {
        isVideoFinished = false
        player?.seek(to: CMTime.zero, completionHandler: { [weak self] isFinished in
            self?.player?.play()
        })
        playPauseButton.setImage(Constant.icPause, for: .normal)
    }
}

// MARK: - Observers

private extension PlayBackView {
    func addObservers() {
        // Observer player's status
        addPlayerStatusObserver()
        
        // Detect volume output
        AVAudioSession.sharedInstance().addObserver(self, forKeyPath: "outputVolume", options: .new, context: nil)
        
        addTimeObserver()
        addNotificationObserver()
    }
    
    func addPlayerStatusObserver() {
        statusObserver = player?.observe(\.status, options: .new) { [weak self] currentPlayer, _ in
            guard let self = self else { return }
            if currentPlayer.status == .readyToPlay {
                self.playPauseButton.setImage(Constant.icPause, for: .normal)
            }
        }
    }
    
    func addTimeObserver() {
        let interval = CMTime(value: 1, timescale: 2)
        player?.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: { [weak self] progressTime in
            self?.updateVideoPlayerState(progressTime: progressTime)
        })
    }
    
    func updateVideoPlayerState(progressTime: CMTime) {
        // Update time slider's value
        guard let duration = player?.currentItem?.duration else { return }
        timeSlider.value = Float(progressTime.seconds / duration.seconds)

        // Update time remaining label
        let timeRemaining = duration - progressTime
        guard let timeRemainingString = timeRemaining.getTimeString() else { return }
        timeRemainingLabel.text = timeRemainingString
    }
    
    func addNotificationObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackground(_:)),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlaying),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: nil)
    }
    
    @objc func didEnterBackground(_: Notification) {
        player?.pause()
    }
    
    @objc func playerDidFinishPlaying() {
        isVideoFinished = true
        playPauseButton.setImage(Constant.icReplay, for: .normal)
    }
}
