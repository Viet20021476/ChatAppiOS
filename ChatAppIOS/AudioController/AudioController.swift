import UIKit
import AVFoundation
import MessageKit

/// The `PlayerState` indicates the current audio controller state
public enum PlayerState {

    /// The audio controller is currently playing a sound
    case playing

    /// The audio controller is currently in pause state
    case pause

    /// The audio controller is not playing any sound and audioPlayer is nil
    case stopped
}

/// The `AudioController` update UI for current audio cell that is playing a sound
/// and also creates and manage an `AVAudioPlayer` states, play, pause and stop.
open class AudioController: NSObject, AVAudioPlayerDelegate {
    
    /// The `AVPlayer` that is playing the sound
    open var mp3Player: AVPlayer?
    
    /// The `notificationObserver` that is for the AVPlayer
    var notificationObserverDidPlayToEndTime:NSObjectProtocol?
    var notificationObserverFailedToPlayToEndTime:NSObjectProtocol?
    var notificationObserverNewErrorLogEntry:NSObjectProtocol?
    

    /// The `AudioMessageCell` that is currently playing sound
    open weak var playingCell: AudioMessageCell?

    /// The `MessageType` that is currently playing sound
    open var playingMessage: MessageType?

    /// Specify if current audio controller state: playing, in pause or none
    open private(set) var state: PlayerState = .stopped

    // The `MessagesCollectionView` where the playing cell exist
    public weak var messageCollectionView: MessagesCollectionView?

    /// The `Timer` that update playing progress
    internal var progressTimer: Timer?

    // MARK: - Init Methods

    public init(messageCollectionView: MessagesCollectionView) {
        self.messageCollectionView = messageCollectionView
        super.init()
    }

    // MARK: - Methods

    /// Used to configure the audio cell UI:
    ///     1. play button selected state;
    ///     2. progressView progress;
    ///     3. durationLabel text;
    ///
    /// - Parameters:
    ///   - cell: The `AudioMessageCell` that needs to be configure.
    ///   - message: The `MessageType` that configures the cell.
    ///
    /// - Note:
    ///   This protocol method is called by MessageKit every time an audio cell needs to be configure
    open func configureAudioCell(_ cell: AudioMessageCell, message: MessageType) {
        if playingMessage?.messageId == message.messageId, let collectionView = messageCollectionView, let player = mp3Player {
            playingCell = cell
            let duration = Double(CMTimeGetSeconds((player.currentItem?.asset.duration)!))
            let currentTime = Double(CMTimeGetSeconds(player.currentTime()))

            cell.progressView.progress = (duration == 0) ? 0 : Float(currentTime/duration)
            
            if ((player.rate != 0) && (player.error == nil)) {
                cell.playButton.isSelected = true
            }
            else {
                cell.playButton.isSelected = false
            }
            guard let displayDelegate = collectionView.messagesDisplayDelegate else {
                fatalError("MessagesDisplayDelegate has not been set.")
            }
            cell.durationLabel.text = displayDelegate.audioProgressTextFormat(Float(currentTime), for: cell, in: collectionView)
        }
    }

    /// Used to start play audio sound
    ///
    /// - Parameters:
    ///   - message: The `MessageType` that contain the audio item to be played.
    ///   - audioCell: The `AudioMessageCell` that needs to be updated while audio is playing.
    open func playSound(for message: MessageType, in audioCell: AudioMessageCell) {
        switch message.kind {
        case .audio(let item):
            playingCell = audioCell
            playingMessage = message
            
            //configuring AVPlayerItem and notifications
            let playerItem = AVPlayerItem(url: item.url)
            self.notificationObserverDidPlayToEndTime = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem, queue: nil) { notification in
                self.stopAnyOngoingPlaying()
            }
            
            self.notificationObserverFailedToPlayToEndTime = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: playerItem, queue: nil) { notification in
                self.stopAnyOngoingPlaying()
            }
                        
            self.notificationObserverNewErrorLogEntry = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemNewErrorLogEntry, object: playerItem, queue: nil) { notification in
                self.stopAnyOngoingPlaying()
            }
            
            if mp3Player != nil {
                self.stopAnyOngoingPlaying()
            }

            mp3Player = AVPlayer(playerItem:playerItem)
            mp3Player!.volume = 1.0
            mp3Player?.playImmediately(atRate: 1.0)
            mp3Player!.play()
            
            //other settings
            state = .playing
            audioCell.playButton.isSelected = true  // show pause button on audio cell
            startProgressTimer()
            audioCell.delegate?.didStartAudio(in: audioCell)
        default:
            print("AudioPlayer failed play sound because given message kind is not Audio")
        }
    }

    /// Used to pause the audio sound
    ///
    /// - Parameters:
    ///   - message: The `MessageType` that contain the audio item to be pause.
    ///   - audioCell: The `AudioMessageCell` that needs to be updated by the pause action.
    open func pauseSound(for message: MessageType, in audioCell: AudioMessageCell) {
        mp3Player?.pause()
        state = .pause
        audioCell.playButton.isSelected = false // show play button on audio cell
        progressTimer?.invalidate()
        if let cell = playingCell {
            cell.delegate?.didPauseAudio(in: cell)
        }
    }

    /// Stops any ongoing audio playing if exists
    open func stopAnyOngoingPlaying() {
        guard let player = mp3Player, let collectionView = messageCollectionView else { return } // If the audio player is nil then we don't need to go through the stopping logic
        player.seek(to: CMTime.zero)
        player.pause()

        state = .stopped
        if let cell = playingCell {
            cell.progressView.progress = 0.0
            cell.playButton.isSelected = false
            guard let displayDelegate = collectionView.messagesDisplayDelegate else {
                fatalError("MessagesDisplayDelegate has not been set.")
            }
            let duration = Double(CMTimeGetSeconds((player.currentItem?.asset.duration)!))
            cell.durationLabel.text = displayDelegate.audioProgressTextFormat(Float(duration), for: cell, in: collectionView)
            cell.delegate?.didStopAudio(in: cell)
        }
        progressTimer?.invalidate()
        progressTimer = nil
       
        if mp3Player != nil {
            mp3Player?.replaceCurrentItem(with: nil)
            mp3Player = nil
            
            NotificationCenter.default.removeObserver(notificationObserverDidPlayToEndTime!)
            NotificationCenter.default.removeObserver(notificationObserverFailedToPlayToEndTime!)
            NotificationCenter.default.removeObserver(notificationObserverNewErrorLogEntry!)
        }
        
        playingMessage = nil
        playingCell = nil
    }

    /// Resume a currently pause audio sound
    open func resumeSound() {
        guard let player = mp3Player, let cell = playingCell else {
            stopAnyOngoingPlaying()
            return
        }
        player.play()
        state = .playing
        startProgressTimer()
        cell.playButton.isSelected = true // show pause button on audio cell
        cell.delegate?.didStartAudio(in: cell)
    }

    // MARK: - Fire Methods
    @objc private func didFireProgressTimer(_ timer: Timer) {
        guard let player = mp3Player, let collectionView = messageCollectionView, let cell = playingCell else {
            return
        }
        // check if can update playing cell
        if let playingCellIndexPath = collectionView.indexPath(for: cell) {
            // 1. get the current message that decorates the playing cell
            // 2. check if current message is the same with playing message, if so then update the cell content
            // Note: Those messages differ in the case of cell reuse
            let currentMessage = collectionView.messagesDataSource?.messageForItem(at: playingCellIndexPath, in: collectionView)
            if currentMessage != nil && currentMessage?.messageId == playingMessage?.messageId {
                // messages are the same update cell content
                let duration = Double(CMTimeGetSeconds((player.currentItem?.asset.duration)!))
                let currentTime = Double(CMTimeGetSeconds(player.currentTime()))

                cell.progressView.progress = (duration == 0) ? 0 : Float(currentTime/duration)
                guard let displayDelegate = collectionView.messagesDisplayDelegate else {
                    fatalError("MessagesDisplayDelegate has not been set.")
                }
                cell.durationLabel.text = displayDelegate.audioProgressTextFormat(Float(currentTime), for: cell, in: collectionView)
            } else {
                // if the current message is not the same with playing message stop playing sound
                stopAnyOngoingPlaying()
            }
        }
    }

    // MARK: - Private Methods
    private func startProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
        progressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(AudioController.didFireProgressTimer(_:)), userInfo: nil, repeats: true)
    }
}
