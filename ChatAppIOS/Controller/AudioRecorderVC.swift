//
//  AudioRecorderVC.swift
//  ChatAppIOS
//
//  Created by Nguyễn Duy Việt on 22/08/2022.
//

import UIKit
import AVFAudio

protocol AudioRecorderVCDelegate {
    func uploadAudioToStorage(file: URL)
}

class AudioRecorderVC: BaseViewController {
    
    var delegate: AudioRecorderVCDelegate?
    
    var recordingSession: AVAudioSession?
    var audioRecorder: AVAudioRecorder?
    
    var numberOfRecords = 0
    
    var counter = 0.0
    var lbTimeCounter = UILabel()
    var btnRecord = UIButton()
    var sendButton = UIBarButtonItem()
    var isRecording = false
    
    var fileName: URL?
    
    var timer: Timer?
    
    var imgStartRecord = UIImage(named: "ic_record")
    var imgRecording = UIImage(named: "ic_recording")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupView()
        setupSession()
    }
    
    func setupView() {
        ivBack.isHidden = true
        view.addSubview(lbTimeCounter)
        view.addSubview(btnRecord)
        
        lbTimeCounter.translatesAutoresizingMaskIntoConstraints = false
        btnRecord.translatesAutoresizingMaskIntoConstraints = false
        
        btnRecord.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        btnRecord.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        btnRecord.widthAnchor.constraint(equalToConstant: 150).isActive = true
        btnRecord.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        btnRecord.setImage(imgStartRecord, for: .normal)
        btnRecord.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        btnRecord.addTarget(self, action: #selector(startRecording), for: .touchUpInside)
        
        lbTimeCounter.centerXAnchor.constraint(equalTo: btnRecord.centerXAnchor).isActive = true
        lbTimeCounter.bottomAnchor.constraint(equalTo: btnRecord.topAnchor, constant: -30).isActive = true
        
        lbTimeCounter.text = String(format: "%.1f", counter)
        lbTimeCounter.font = .systemFont(ofSize: 30, weight: .semibold)
        
        sendButton = UIBarButtonItem(title: "Send",
                                         style: .done,
                                         target: self,
                                         action: #selector(sendAudio))

        navigationItem.rightBarButtonItem = sendButton
        sendButton.isEnabled = false
    }
    
    func setupSession() {
        recordingSession = AVAudioSession.sharedInstance()
        AVAudioSession.sharedInstance().requestRecordPermission { hasPermission in
            if hasPermission {
                print("Accepted")
            }
        }
    }
    
    @objc func startRecording() {
        
        isRecording = !isRecording
        
        if !isRecording {
            btnRecord.setImage(imgStartRecord, for: .normal)
            
            counter = 0.0
            lbTimeCounter.text = String(format: "%.1f", counter)
            
            timer?.invalidate()
            timer = nil
        } else {
            btnRecord.setImage(imgRecording, for: .normal)
            
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(countTimeRecording), userInfo: nil, repeats: true)
        }
        
        if audioRecorder == nil {
            numberOfRecords += 1
            fileName = getDirectory().appendingPathComponent("\(numberOfRecords).m4a")
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                          AVSampleRateKey: 12000,
                    AVNumberOfChannelsKey: 1,
                 AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
            
            // Start Audio Recording
            do {
                audioRecorder = try AVAudioRecorder(url: fileName!, settings: settings)
                audioRecorder?.delegate = self
                audioRecorder?.record()
            } catch {
                print("Not working!")
            }
            
        } else {
            // Stop audio recording
            audioRecorder?.stop()
            audioRecorder = nil
            sendButton.isEnabled = true
        }
    }
    
    @objc func countTimeRecording() {
        counter += 0.1
        lbTimeCounter.text = String(format: "%.1f", counter)
    }
    
    @objc func sendAudio() {
        delegate?.uploadAudioToStorage(file: fileName!)
        navigationController?.popViewController(animated: true)
    }
    
    // Function that get path to the directory
    func getDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
}

extension AudioRecorderVC : AVAudioRecorderDelegate {
    
}
