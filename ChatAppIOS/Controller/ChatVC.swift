//
//  ChatVC.swift
//  ChatAppIOS
//
//  Created by Nguyễn Duy Việt on 12/08/2022.
//

import UIKit
import MessageKit
import NVActivityIndicatorView
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import InputBarAccessoryView
import YPImagePicker
import SDWebImage
import AVFoundation
import CoreLocation

protocol ChatVCDelegate {
    func removeAllUser()
    func sortArrUserByTimestamp()
    func reloadUserList()
}

class ChatVC: MessagesViewController {
    
    var delegate: ChatVCDelegate?
    
    let viewIndicator = UIView()
    var loadingIndicator: NVActivityIndicatorView?
    
    var titleLbName = UILabel()
    var titleImgOnOff = UIImageView()
    var titleLbOnOff = UILabel()
    
    let dbRef = Database.database().reference()
    let storageRef = Storage.storage().reference()
    
    var currUser: User?
    var otherUser: User?
    
    var arrMessage = [Message]()
    
    var senderRoom = ""
    var receiverRoom = ""
    var numberOfMsg = 0
    
    var refHandleSenderMsgCount: DatabaseHandle?
    
    var imgPicker = YPImagePicker()
    var btnPickImg = InputBarButtonItem()
    var btnMoreChoice = InputBarButtonItem()
    
    var imageCache: SDImageCache = SDImageCache()
    var thumbnailImg = UIImage()
    
    let locationManager = CLLocationManager()
    var audioController: AudioController?
    var isPlayingSound = false
    
    var timeStampRef:DatabaseReference?
    var currentTimeStamp: TimeInterval?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        navigationController?.navigationBar.isHidden = false
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.red ] // Title color
        
        setupServerTimestamp()
        setupRightBarBtnItem()
        customInputView()
        setupIndicator()
        
        senderRoom = "\(currUser?.senderId as! String)\(otherUser?.senderId as! String)"
        receiverRoom = "\(otherUser?.senderId as! String)\(currUser?.senderId as! String)"
        
        messagesCollectionView.showsVerticalScrollIndicator = false
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        
        let tapHideKeyboardGes = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        //messagesCollectionView.addGestureRecognizer(tapHideKeyboardGes)
        
        
        messageInputBar.delegate = self
        
        audioController = AudioController(messageCollectionView: messagesCollectionView)
        
        dbRef.child("Users").child(currUser!.senderId).child("beingInRoom").setValue(senderRoom)
        dbRef.child("Users").child(currUser!.senderId).child("beingInRoom").observe(.value) { snapshot in
            self.dbRef.child("Users").child(self.currUser!.senderId).child("beingInRoom").removeAllObservers()
            self.currUser?.beingInRoom = snapshot.value as! String
        }
        
        refHandleSenderMsgCount = dbRef.child("Messages").child(senderRoom).observe(.value) { snapshot in
            self.numberOfMsg = Int(snapshot.childrenCount) - 1
        }
        
        setupTitleView()
        getMsgData()
        setupOnlineState()
        handleEvent()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        dbRef.child("Users").child(currUser!.senderId).child("beingInRoom").setValue("")
        currUser?.beingInRoom = ""
    }
    
    func setupIndicator() {
        viewIndicator.backgroundColor = .black.withAlphaComponent(0.6)
        viewIndicator.layer.cornerRadius = 10
        viewIndicator.layer.masksToBounds = true
        view.addSubview(viewIndicator)
        viewIndicator.translatesAutoresizingMaskIntoConstraints = false
        viewIndicator.widthAnchor.constraint(equalToConstant: 60).isActive = true
        viewIndicator.heightAnchor.constraint(equalToConstant: 60).isActive = true
        viewIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        viewIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        viewIndicator.isHidden = true
        
        let frame = CGRect(x: 15, y: 15, width: 30, height: 30)
        loadingIndicator = NVActivityIndicatorView(frame: frame, type: .lineScale, color: .white, padding: 0)
        viewIndicator.addSubview(loadingIndicator!)
        
    }
    
    func setupRightBarBtnItem() {
        let infoItemBtn = UIButton(type: .custom)
        infoItemBtn.translatesAutoresizingMaskIntoConstraints = false
        infoItemBtn.setImage(UIImage(named: "information"), for: .normal)
        infoItemBtn.contentVerticalAlignment = .fill
        infoItemBtn.contentHorizontalAlignment = .fill
        infoItemBtn.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        infoItemBtn.widthAnchor.constraint(equalToConstant: 40).isActive = true
        infoItemBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let phoneItemBtn = UIButton(type: .custom)
        phoneItemBtn.translatesAutoresizingMaskIntoConstraints = false
        phoneItemBtn.setImage(UIImage(named: "phone"), for: .normal)
        phoneItemBtn.contentVerticalAlignment = .fill
        phoneItemBtn.contentHorizontalAlignment = .fill
        phoneItemBtn.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        phoneItemBtn.widthAnchor.constraint(equalToConstant: 40).isActive = true
        phoneItemBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        navigationItem.rightBarButtonItems = [infoItemBtn.toBarButtonItem()!, phoneItemBtn.toBarButtonItem()!]
        
        phoneItemBtn.addTarget(self, action: #selector(makePhoneCall), for: .touchUpInside)
        infoItemBtn.addTarget(self, action: #selector(getToOtherUserProfile), for: .touchUpInside)
    }
    
    func setupOnlineState() {
        dbRef.child("Users").child(otherUser!.senderId).child("isOnline").observe(.value) { snapshot in
            let isOnline = snapshot.value as! Bool
            if isOnline {
                self.titleLbOnOff.text = "Online"
                self.titleImgOnOff.image = UIImage(named: "green_dot")
            } else {
                self.titleImgOnOff.image = UIImage(named: "gray_dot")
                self.dbRef.child("Users").child(self.otherUser!.senderId).child("lastOnline").observe(.value) { snapshot in
                    let lastOn = snapshot.value as! String
                    self.titleLbOnOff.text = "Last online: \(lastOn)"
                }
            }
        }
    }
    
    func setupTitleView() {
        titleLbName.text = navigationItem.title
        titleLbName.font = .boldSystemFont(ofSize: 18)
        
        if otherUser?.isOnline == true {
            titleImgOnOff.image = UIImage(named: "green_dot")
            titleLbOnOff.text = "Online"
        } else {
            titleImgOnOff.image = UIImage(named: "gray_dot")
        }
        titleLbOnOff.font = .systemFont(ofSize: 14)
        titleImgOnOff.translatesAutoresizingMaskIntoConstraints = false
        titleImgOnOff.contentMode = .scaleAspectFill
        
        titleImgOnOff.widthAnchor.constraint(equalToConstant: 16).isActive = true
        titleImgOnOff.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        let hStackView = UIStackView(arrangedSubviews: [titleImgOnOff, titleLbOnOff])
        hStackView.axis = .horizontal
        hStackView.spacing = 8
        hStackView.alignment = .center
        
        let vStackView = UIStackView(arrangedSubviews: [titleLbName, hStackView])
        vStackView.axis = .vertical
        vStackView.alignment = .center
        
        
        navigationItem.titleView = vStackView
        
    }
    
    
    func getMsgData() {
        
        dbRef.child("Messages").child(senderRoom).observe(.childAdded) { snapshot in
            if snapshot.key == "LastMsg" {
                return
            }
            self.dbRef.child("Messages").child(self.senderRoom).child(snapshot.key).observe(.value) { data in
                self.dbRef.child("Messages").child(self.senderRoom).child(snapshot.key).removeAllObservers()
                guard let dict = data.value as? [String: Any] else {return}
                
                // Check xem co phai node LastMsg khong
                if dict["messageId"] == nil {return}
                
                if self.numberOfMsg != 0 {
                    self.startAnimating()
                }
                let msg = Message(dict: dict)
                msg.sender = User(senderId: msg.senderId, displayName: msg.senderName)
                if msg.type == IMAGE {
                    // Load truoc placeholder
                    msg.kind = .photo(Media(url: URL(string: "https://dantri.com.vn/")!, image: UIImage(named: "ic_pickimg")!, placeholderImage: UIImage(named: "ic_pickimg")!, size: CGSize(width: 200, height: 200)))
                    self.arrMessage.append(msg)
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem()
                    
                    
                    SDWebImageManager.shared.loadImage(with: URL(string: msg.downloadURL),
                                                       options: .allowInvalidSSLCertificates) { int1, int2, int3 in
                        
                    } completed: { img, data, err, type, bool1, url in
                        msg.kind = .photo(Media(url: URL(string: msg.downloadURL)!, image: img!, placeholderImage: UIImage(named: "ic_pickimg")!, size: CGSize(width: 200, height: 200)))
                        self.messagesCollectionView.reloadData()
                        
                        if self.arrMessage.count == self.numberOfMsg {
                            self.stopAnimating()
                        }
                    }
                    
                } else if msg.type == VIDEO {
                    // Load truoc placeholder
                    msg.kind = .photo(Media(url: URL(string: "https://dantri.com.vn/")!, image: UIImage(named: "ic_pickimg")!, placeholderImage: UIImage(named: "ic_pickimg")!, size: CGSize(width: 200, height: 200)))
                    self.arrMessage.append(msg)
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem()
                    
                    // LUU ANH THUMBNAIL CUA VIDEO VAO CACHE
                    SDWebImageManager.shared.loadImage(with: URL(string: msg.thumbnailDownloadURL),
                                                       options: .allowInvalidSSLCertificates) { int1, int2, int3 in
                    } completed: { img, data, err, type, bool1, url in
                        msg.kind = .photo(Media(url: URL(string: msg.thumbnailDownloadURL)!, image: img!, placeholderImage: UIImage(named: "ic_pickimg")!, size: CGSize(width: 200, height: 200)))
                        
                        self.messagesCollectionView.reloadData()
                        
                        if self.arrMessage.count == self.numberOfMsg {
                            self.stopAnimating()
                        }
                    }
                } else if msg.type == LOCATION {
                    let arrCoordinates = msg.location.split(separator: " ")
                    let latitude = Double(arrCoordinates[0])!
                    let longitude = Double(arrCoordinates[1])!
                    msg.kind = .location(Location(location: CLLocation(latitude: latitude, longitude: longitude), size: CGSize(width: 200, height: 200)))
                    
                    self.arrMessage.append(msg)
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem()
                    
                    if self.arrMessage.count == self.numberOfMsg {
                        self.stopAnimating()
                    }
                } else if msg.type == AUDIO {
                    msg.kind = .audio(Audio(url: URL(string: msg.downloadURL)!, duration: 10, size: CGSize(width: 200, height: 30)))
                    self.arrMessage.append(msg)
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem()
                    
                    if self.arrMessage.count == self.numberOfMsg {
                        self.stopAnimating()
                    }
                } else if msg.type == TEXT {
                    msg.kind = .text(msg.textContent)
                    self.arrMessage.append(msg)
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem()
                    
                    if self.arrMessage.count == self.numberOfMsg {
                        self.stopAnimating()
                    }
                }
                
                if msg.receiverId == self.currUser?.senderId && self.currUser!.beingInRoom != "" {
                    msg.isSeen = true
                    self.dbRef.child("Messages").child(self.senderRoom).child(msg.messageId).child("isSeen").setValue(true)
                    self.dbRef.child("Messages").child(self.receiverRoom).child(msg.messageId).child("isSeen").setValue(true)
                    
                    self.dbRef.child("Messages").child(self.senderRoom).child("LastMsg").child("lastmsg").child("isSeen").setValue(true)
                    self.dbRef.child("Messages").child(self.receiverRoom).child("LastMsg").child("lastmsg").child("isSeen").setValue(true)
                    
                }
                
                
            }
        }
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    func beingInTheSameRoom(user1: User, user2: User) -> Bool {
        let room1 = "\(user1.senderId)\(user2.senderId)"
        let room2 = "\(user2.senderId)\(user1.senderId)"
        
        if (user1.beingInRoom == room1 && user2.beingInRoom == room2) || (user1.beingInRoom == room2 && user2.beingInRoom == room1) {
            return true
        }
        return false
    }
    
    @objc func makePhoneCall() {
        startAnimating()
        dbRef.child("Users").child(otherUser!.senderId).child("phoneNumber").observe(.value) { snapshot in
            guard let phoneNumber = snapshot.value as? String else {return}
            guard let number = URL(string: "tel://" + phoneNumber) else { return }
            UIApplication.shared.open(number)
            self.stopAnimating()
        }
    }
    
    @objc func getToOtherUserProfile() {
        let vc = ProfileVC(nibName: "ProfileVC", bundle: nil)
        vc.currUser = otherUser
        vc.isOtherUserProfile = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func customInputView() {
        
        messageInputBar.sendButton.setSize(CGSize(width: 36, height: 36), animated: true)
        messageInputBar.sendButton.image = UIImage(named: "ic_send")
        messageInputBar.sendButton.imageView?.layer.cornerRadius = 10
        messageInputBar.sendButton.backgroundColor = .clear
        
        messageInputBar.middleContentViewPadding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        
        btnPickImg = makeButton(image: UIImage(named: "ic_pickimg")!)
        btnMoreChoice = makeButton(image: UIImage(named: "4dots")!)
        
        let items = [btnMoreChoice, btnPickImg]
        
        messageInputBar.setLeftStackViewWidthConstant(to: 80, animated: true)
        messageInputBar.setStackViewItems(items, forStack: .left, animated: true)
    }
    
    func makeButton(image: UIImage) -> InputBarButtonItem {
        return InputBarButtonItem()
            .configure {
                $0.spacing = .fixed(10)
                $0.image = image
                $0.setSize(CGSize(width: 36, height: 36), animated: false)
            }
    }
    
    func handleEvent() {
        var config = YPImagePickerConfiguration()
        config.library.maxNumberOfItems = 4
        config.screens = [.library, .photo, .video]
        config.library.mediaType = .photoAndVideo
        imgPicker = YPImagePicker(configuration: config)
        
        btnPickImg.onSelected {_ in
            self.imgPicker.didFinishPicking { items, cancelled in
                for item in items {
                    switch item {
                    case .photo(let photo):
                        self.startAnimating()
                        self.uploadImageToStorage(image: photo.image)
                        
                    case .video(let video):
                        self.startAnimating()
                        self.thumbnailImg = self.generateThumbnail(url: video.url)!
                        self.uploadVideoToStorage(file: video.url)
                    }
                }
                self.imgPicker.dismiss(animated: true, completion: nil)
            }
            self.present(self.imgPicker, animated: true, completion: nil)
        }
        
        btnMoreChoice.onSelected { _ in
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let actionLocation = UIAlertAction(title: "Location", style: .default) { ac in
                // Ask for Authorisation from the User.
                if self.locationManager.authorizationStatus == .notDetermined {
                    self.locationManager.requestAlwaysAuthorization()
                    // For use in foreground
                    self.locationManager.requestWhenInUseAuthorization()
                    
                } else if self.locationManager.authorizationStatus == .denied {
                    self.requestAccessToLocationAgain()
                    return
                }
                
                
                if CLLocationManager.locationServicesEnabled() {
                    self.locationManager.delegate = self
                    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                    self.locationManager.startUpdatingLocation()
                }
            }
            let actionAudio = UIAlertAction(title: "Audio", style: .default) { ac in
                let vc = AudioRecorderVC()
                vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true)
            }
            let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            alert.addAction(actionLocation)
            alert.addAction(actionAudio)
            alert.addAction(actionCancel)
            
            self.present(alert, animated: true)
        }
    }
    
    func uploadImageToStorage(image: UIImage) {
        
        let date = Util.getStringFromDate(format: "YYYY,MM dd,HH:mm:ss", date: Date())
        let imgName = "\(date) \(UUID().uuidString)"
        
        let data = image.jpegData(compressionQuality: 0.3)
        // DUONG DAN CHO THU MUC CHUA IMAGE
        let imgStorageRef = storageRef
        let imgFolder = imgStorageRef.child(senderRoom).child(imgName)//-> DUONG DAN LUU AVATAR
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        imgFolder.putData(data!, metadata: metaData) { meta, err in
            if err != nil {
                return
            } else {
                imgFolder.downloadURL { url, err in
                    if err != nil {
                        return
                    } else {
                        // POST DATA
                        let key = self.dbRef.childByAutoId().key
                        let msg = Message(sender: self.currUser!,
                                          messageId: key!,
                                          senderId: self.currUser!.senderId,
                                          receiverId: self.otherUser!.senderId,
                                          strSentDate: date,
                                          kind: .photo(Media(url: url!, image: image, placeholderImage: image, size: CGSize(width: 200, height: 200))),
                                          type: IMAGE,
                                          textContent: "",
                                          sentDate: Date(),
                                          location: "",
                                          downloadURL: "\(url!)",
                                          thumbnailDownloadURL: "",
                                          isSeen: false,
                                          msgTimeStamp: 0.0)
                        
                        let val = ["messageId": msg.messageId,
                                   "senderId": msg.senderId,
                                   "senderName": self.currUser?.displayName,
                                   "receiverId": msg.receiverId,
                                   "strSentDate": msg.strSentDate,
                                   "type": msg.type,
                                   "textContent": msg.textContent,
                                   "location": msg.location,
                                   "downloadURL": msg.downloadURL,
                                   "thumbnailDownloadURL": "",
                                   "isSeen": msg.isSeen,
                                   "msgTimeStamp": ServerValue.timestamp()] as [String : Any]
                        
                        self.dbRef.child("Messages").child(self.senderRoom).child(key!).setValue(val)
                        self.dbRef.child("Messages").child(self.receiverRoom).child(key!).setValue(val)
                        
                        // Last message
                        self.dbRef.child("Messages").child(self.senderRoom).child("LastMsg").child("lastmsg").setValue(val)
                        self.dbRef.child("Messages").child(self.receiverRoom).child("LastMsg").child("lastmsg").setValue(val)
                        
                        self.dbRef.child("Users").child(self.currUser!.senderId).removeAllObservers()
                        self.dbRef.child("Users").child(self.otherUser!.senderId).removeAllObservers()
                        
                        self.delegate?.removeAllUser()
                        
                        self.timeStampRef!.setValue(ServerValue.timestamp())
                        
                        self.dbRef.child("Users").child(self.currUser!.senderId).child("friends").child(self.otherUser!.senderId).child("timeStamp").setValue(self.currentTimeStamp)
                        self.dbRef.child("Users").child(self.otherUser!.senderId).child("friends").child(self.currUser!.senderId).child("timeStamp").setValue(self.currentTimeStamp)
                        
                        self.messageInputBar.inputTextView.text = ""
                        
                        self.delegate?.reloadUserList()
                    }
                }
                
            }
        }
    }
    
    func uploadVideoToStorage(file: URL) {
        var thumbnailDownloadURl = ""
        
        let date = Util.getStringFromDate(format: "YYYY,MM dd,HH:mm:ss", date: Date())
        let videoName = date
        let randomUUID = UUID().uuidString
        
        let dataVideo = try! Data(contentsOf: file)
        // DUONG DAN CHO THU MUC CHUA VIDEO
        let videoStorageRef = storageRef
        let videoSpecificPath = videoStorageRef.child(senderRoom).child("Video \(randomUUID)").child(videoName)
        
        let metaDataVideo = StorageMetadata()
        metaDataVideo.contentType = "video/mp4"
        
        let dataThumbnail = thumbnailImg.jpegData(compressionQuality: 0.3)
        let meteDataThumbnail = StorageMetadata()
        meteDataThumbnail.contentType = "image/jpeg"
        
        let thumbnailImageSpecificPath = videoStorageRef.child(senderRoom).child("Video \(randomUUID)").child("thumbnail")
        
        thumbnailImageSpecificPath.putData(dataThumbnail!, metadata: meteDataThumbnail) { meta, err in
            if err != nil {
                print(err?.localizedDescription)
            } else {
                thumbnailImageSpecificPath.downloadURL { url, err in
                    if err != nil {
                        print(err?.localizedDescription)
                    } else {
                        thumbnailDownloadURl = "\(url!)"
                    }
                }
            }
        }
        
        videoSpecificPath.putData(dataVideo, metadata: metaDataVideo) { meta, err in
            if err != nil {
                return
            } else {
                videoSpecificPath.downloadURL { url, err in
                    if err != nil {
                        return
                    } else {
                        // POST DATA
                        let key = self.dbRef.childByAutoId().key
                        let msg = Message(sender: self.currUser!,
                                          messageId: key!,
                                          senderId: self.currUser!.senderId,
                                          receiverId: self.otherUser!.senderId,
                                          strSentDate: date,
                                          kind: .video(Media(url: url!, image: UIImage(named: "img_video_placeholder")!, placeholderImage: UIImage(named: "img_video_placeholder")!, size: CGSize(width: 200, height: 200))),
                                          type: VIDEO,
                                          textContent: "",
                                          sentDate: Date(),
                                          location: "",
                                          downloadURL: "\(url!)",
                                          thumbnailDownloadURL: thumbnailDownloadURl,
                                          isSeen: false,
                                          msgTimeStamp: 0.0)
                        
                        let val = ["messageId": msg.messageId,
                                   "senderId": msg.senderId,
                                   "senderName": self.currUser?.displayName,
                                   "receiverId": msg.receiverId,
                                   "strSentDate": msg.strSentDate,
                                   "type": msg.type,
                                   "textContent": msg.textContent,
                                   "location": msg.location,
                                   "downloadURL": msg.downloadURL,
                                   "thumbnailDownloadURL": msg.thumbnailDownloadURL,
                                   "isSeen": msg.isSeen,
                                   "msgTimeStamp": ServerValue.timestamp()] as [String : Any]
                        
                        self.dbRef.child("Messages").child(self.senderRoom).child(key!).setValue(val)
                        self.dbRef.child("Messages").child(self.receiverRoom).child(key!).setValue(val)
                        
                        // Last message
                        self.dbRef.child("Messages").child(self.senderRoom).child("LastMsg").child("lastmsg").setValue(val)
                        self.dbRef.child("Messages").child(self.receiverRoom).child("LastMsg").child("lastmsg").setValue(val)
                        
                        self.dbRef.child("Users").child(self.currUser!.senderId).removeAllObservers()
                        self.dbRef.child("Users").child(self.otherUser!.senderId).removeAllObservers()
                        
                        self.delegate?.removeAllUser()
                        
                        self.timeStampRef!.setValue(ServerValue.timestamp())
                        
                        self.dbRef.child("Users").child(self.currUser!.senderId).child("friends").child(self.otherUser!.senderId).child("timeStamp").setValue(self.currentTimeStamp)
                        self.dbRef.child("Users").child(self.otherUser!.senderId).child("friends").child(self.currUser!.senderId).child("timeStamp").setValue(self.currentTimeStamp)
                        
                        self.messageInputBar.inputTextView.text = ""
                        
                        self.delegate?.reloadUserList()
                    }
                }
            }
        }
    }
    
    func requestAccessToLocationAgain() {
        let alert = UIAlertController(title: "Change your location authorization in the settings to send your location", message: nil, preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "OK", style: .default) { ac in
            if let url = NSURL(string:UIApplication.openSettingsURLString) {
                UIApplication.shared.openURL(url as URL)
            }
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .default)
        
        alert.addAction(actionOK)
        alert.addAction(actionCancel)
        
        present(alert, animated: true)
    }
    
    func setupServerTimestamp() {
        timeStampRef = dbRef.child("serverTimestamp")
        timeStampRef!.setValue(ServerValue.timestamp())
        
        timeStampRef!.observe(.value, with: { snap in
            if let t = snap.value as? TimeInterval {
                self.currentTimeStamp = t/1000
            }
        })
    }
}

extension ChatVC : MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    var currentSender: SenderType {
        return currUser!
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return arrMessage[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return arrMessage.count
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner =
        isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if message.sender.senderId == currUser?.senderId {
            avatarView.sd_setImage(with: URL(string: currUser!.avatar))
        } else {
            avatarView.sd_setImage(with: URL(string: otherUser!.avatar))
        }
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if message.sender.senderId == currUser?.senderId {
            return #colorLiteral(red: 0.09133880585, green: 0.7034819722, blue: 0.9843640924, alpha: 1)
        }
        return .lightGray.withAlphaComponent(0.4)
    }
    
    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 8) // -> Them khoang trong giua cac tin nhan
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        let currMsg = arrMessage[indexPath.section]
        let arrDate = currMsg.strSentDate.split(separator: ",")
        let strHour = arrDate[2]
        
        if currMsg.isSeen == true && currUser?.senderId == currMsg.senderId && indexPath.section == numberOfMsg - 1 {
            return 20
        }
        return 10
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        let currMsg = arrMessage[indexPath.section]
        let arrDate = currMsg.strSentDate.split(separator: ",")
        let strHour = arrDate[2]
        
        if currMsg.isSeen == true && currUser?.senderId == currMsg.senderId && indexPath.section == numberOfMsg - 1 {
            return NSAttributedString(
                string: "√Seen",
                attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
        }
        return nil
    }
    
    
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if arrMessage.count > 1 && indexPath.section > 0 {

            let prevMsg = arrMessage[indexPath.section - 1]
            let currMsg = arrMessage[indexPath.section]

            if currMsg.msgTimeStamp - prevMsg.msgTimeStamp > 60000 {
                return 40
            }

        }
        return 0
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        if arrMessage.count > 1 && indexPath.section > 0 {

            let prevMsg = arrMessage[indexPath.section - 1]
            let currMsg = arrMessage[indexPath.section]

            if currMsg.msgTimeStamp - prevMsg.msgTimeStamp > 60000 {
                return NSAttributedString(
                    string: Util.getStringFromDate(format: " dd/MM/YYYY HH:mm", date: Date(timeIntervalSince1970: currMsg.msgTimeStamp / 1000)),
                    attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
            }

        }
        return nil
        
    }
}

extension ChatVC : InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let key = dbRef.childByAutoId().key
        let currDate = Date()
        let date = Util.getStringFromDate(format: "YYYY,MM dd,HH:mm:ss", date: currDate)
        
        let msg = Message(sender: currUser!,
                          messageId: key!,
                          senderId: currUser!.senderId,
                          receiverId: otherUser!.senderId,
                          strSentDate: date,
                          kind: .text(text),
                          type: MessageKind.text(text).msgKind,
                          textContent: text,
                          sentDate: currDate,
                          location: "",
                          downloadURL: "",
                          thumbnailDownloadURL: "",
                          isSeen: false,
                          msgTimeStamp: 0.0)
        
        let val = ["messageId": msg.messageId,
                   "senderId": msg.senderId,
                   "senderName": currUser?.displayName,
                   "receiverId": msg.receiverId,
                   "strSentDate": msg.strSentDate,
                   "type": msg.type,
                   "textContent": msg.textContent,
                   "location": msg.location,
                   "downloadURL": msg.downloadURL,
                   "thumbnailDownloadURL": msg.thumbnailDownloadURL,
                   "isSeen": msg.isSeen,
                   "msgTimeStamp": ServerValue.timestamp()] as [String : Any]
        
        dbRef.child("Messages").child(senderRoom).child(key!).setValue(val)
        dbRef.child("Messages").child(receiverRoom).child(key!).setValue(val)
        
        // Last message
        dbRef.child("Messages").child(senderRoom).child("LastMsg").child("lastmsg").setValue(val)
        dbRef.child("Messages").child(receiverRoom).child("LastMsg").child("lastmsg").setValue(val)
        
                
        delegate?.removeAllUser()
        
        timeStampRef!.setValue(ServerValue.timestamp())
        
        dbRef.child("Users").child(currUser!.senderId).child("friends").child(otherUser!.senderId).child("timeStamp").setValue(currentTimeStamp)
        dbRef.child("Users").child(otherUser!.senderId).child("friends").child(currUser!.senderId).child("timeStamp").setValue(currentTimeStamp)
        
        messageInputBar.inputTextView.text = ""
        
        delegate?.reloadUserList()
        
        
    }
    
}

extension ChatVC : MessageCellDelegate {
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        let indexPath = messagesCollectionView.indexPath(for: cell)
        let msg = arrMessage[indexPath!.section]
        
        
        switch msg.kind {
        case .location(let locationData):
            let coordinates = locationData.location.coordinate
            let vc = LocationPickerVC()
            vc.coordinates = coordinates
            vc.isPickable = false
            vc.title = "Location"
            
            self.navigationController?.pushViewController(vc, animated: true)
        case .audio(_):
            if audioController?.state == .stopped {
                audioController!.playSound(for: msg, in: cell as! AudioMessageCell)
            } else if audioController?.state == .playing {
                audioController?.pauseSound(for: msg, in: cell as! AudioMessageCell)
            } else if audioController?.state == .pause {
                audioController?.resumeSound()
            }
        default:
            print("do nothing")
        }
    }
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        let indexPath = messagesCollectionView.indexPath(for: cell)
        let msg = arrMessage[indexPath!.section]
        if msg.type == IMAGE {
            let vc = ImageViewVC(nibName: "ImageViewVC", bundle: nil)
            vc.mediaView.sd_setImage(with: URL(string: "\(msg.downloadURL)"))
            navigationController?.pushViewController(vc, animated: true)
        } else if msg.type == VIDEO {
            let vc = VideoViewVC(nibName: "VideoViewVC", bundle: nil)
            vc.videoURL = msg.downloadURL
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func didTapBackground(in cell: MessageCollectionViewCell) {
        view.endEditing(true)
    }
}

extension ChatVC: LocationPickerVCDelegate {
    func getLocation(coordinates: CLLocationCoordinate2D) {
        let key = dbRef.childByAutoId().key
        let currDate = Date()
        let date = Util.getStringFromDate(format: "YYYY,MM dd,HH:mm:ss", date: currDate)
        
        let latitude = coordinates.latitude
        let longitude = coordinates.longitude
        
        let msg = Message(sender: currUser!,
                          messageId: key!,
                          senderId: currUser!.senderId,
                          receiverId: otherUser!.senderId,
                          strSentDate: date,
                          kind: .location(Location(location: CLLocation(latitude: latitude, longitude: longitude), size: CGSize(width: 200, height: 200))),
                          type: LOCATION,
                          textContent: "",
                          sentDate: currDate,
                          location: "\(latitude) \(longitude)",
                          downloadURL: "",
                          thumbnailDownloadURL: "",
                          isSeen: false,
                          msgTimeStamp: 0.0)
        
        let val = ["messageId": msg.messageId,
                   "senderId": msg.senderId,
                   "senderName": currUser?.displayName,
                   "receiverId": msg.receiverId,
                   "strSentDate": msg.strSentDate,
                   "type": msg.type,
                   "textContent": msg.textContent,
                   "location": msg.location,
                   "downloadURL": msg.downloadURL,
                   "thumbnailDownloadURL": msg.thumbnailDownloadURL,
                   "isSeen": msg.isSeen,
                   "msgTimeStamp": ServerValue.timestamp()] as [String : Any]
        
        dbRef.child("Messages").child(senderRoom).child(key!).setValue(val)
        dbRef.child("Messages").child(receiverRoom).child(key!).setValue(val)
        
        // Last message
        self.dbRef.child("Messages").child(self.senderRoom).child("LastMsg").child("lastmsg").setValue(val)
        self.dbRef.child("Messages").child(self.receiverRoom).child("LastMsg").child("lastmsg").setValue(val)
        
        dbRef.child("Users").child(currUser!.senderId).removeAllObservers()
        dbRef.child("Users").child(otherUser!.senderId).removeAllObservers()
        
        delegate?.removeAllUser()
        
        timeStampRef!.setValue(ServerValue.timestamp())
        
        dbRef.child("Users").child(currUser!.senderId).child("friends").child(otherUser!.senderId).child("timeStamp").setValue(currentTimeStamp)
        dbRef.child("Users").child(otherUser!.senderId).child("friends").child(currUser!.senderId).child("timeStamp").setValue(currentTimeStamp)
        
        messageInputBar.inputTextView.text = ""
        
        delegate?.reloadUserList()
    }
}

extension ChatVC : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
        
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        if !checkIfVCAlreadyExistsInStack(ofClass: LocationPickerVC.self) {
            let vc = LocationPickerVC()
            vc.coordinates = locValue
            vc.isPickable = true
            vc.delegate = self
            
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
}

extension ChatVC : AudioRecorderVCDelegate {
    func uploadAudioToStorage(file: URL) {
        startAnimating()
        let dataAudio = try! Data(contentsOf: file)
        let date = Util.getStringFromDate(format: "YYYY,MM dd,HH:mm:ss", date: Date())
        let audioName = "\(date)  \(UUID().uuidString)"
        let audioSpecificPath = storageRef.child(senderRoom).child(audioName)
        let metaData = StorageMetadata()
        metaData.contentType = "audio/mp3"
        
        audioSpecificPath.putData(dataAudio, metadata: metaData) { meta, err in
            if err != nil {
                return
            } else {
                audioSpecificPath.downloadURL { url, err in
                    if err != nil {
                        return
                    } else {
                        // POST DATA
                        let key = self.dbRef.childByAutoId().key
                        let msg = Message(sender: self.currUser!,
                                          messageId: key!,
                                          senderId: self.currUser!.senderId,
                                          receiverId: self.otherUser!.senderId,
                                          strSentDate: date,
                                          kind: .audio(Audio(url: url!, duration: 10, size: CGSize(width: 200, height: 200))),
                                          type: AUDIO,
                                          textContent: "",
                                          sentDate: Date(),
                                          location: "",
                                          downloadURL: "\(url!)",
                                          thumbnailDownloadURL: "",
                                          isSeen: false,
                                          msgTimeStamp: 0.0)
                        
                        let val = ["messageId": msg.messageId,
                                   "senderId": msg.senderId,
                                   "senderName": self.currUser?.displayName,
                                   "receiverId": msg.receiverId,
                                   "strSentDate": msg.strSentDate,
                                   "type": msg.type,
                                   "textContent": msg.textContent,
                                   "location": msg.location,
                                   "downloadURL": msg.downloadURL,
                                   "thumbnailDownloadURL": "",
                                   "isSeen": msg.isSeen,
                                   "msgTimeStamp": ServerValue.timestamp()] as [String : Any]
                        
                        self.dbRef.child("Messages").child(self.senderRoom).child(key!).setValue(val)
                        self.dbRef.child("Messages").child(self.receiverRoom).child(key!).setValue(val)
                        
                        // Last message
                        self.dbRef.child("Messages").child(self.senderRoom).child("LastMsg").child("lastmsg").setValue(val)
                        self.dbRef.child("Messages").child(self.receiverRoom).child("LastMsg").child("lastmsg").setValue(val)
                        
                        self.dbRef.child("Users").child(self.currUser!.senderId).removeAllObservers()
                        self.dbRef.child("Users").child(self.otherUser!.senderId).removeAllObservers()
                        
                        self.delegate?.removeAllUser()
                        
                        self.timeStampRef!.setValue(ServerValue.timestamp())
                        
                        self.dbRef.child("Users").child(self.currUser!.senderId).child("friends").child(self.otherUser!.senderId).child("timeStamp").setValue(self.currentTimeStamp)
                        self.dbRef.child("Users").child(self.otherUser!.senderId).child("friends").child(self.currUser!.senderId).child("timeStamp").setValue(self.currentTimeStamp)
                        
                        self.messageInputBar.inputTextView.text = ""
                        
                        self.delegate?.reloadUserList()
                        
                        self.stopAnimating()
                    }
                }
            }
        }
    }
}

extension ChatVC {
    
    func generateThumbnail(url: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            
            let cgImage = try imageGenerator.copyCGImage(at: .zero,
                                                         actualTime: nil)
            
            var thumbnailImage =  UIImage(cgImage: cgImage)
            
            // TAO NUT CONTINUE VIDEO CHO THUMBNAIL CHO VIDEO
            let iconContinueVideo = UIImage(named: "ic_continue_video")
            
            UIGraphicsBeginImageContextWithOptions(thumbnailImage.size, false, 0.0)
            thumbnailImage.draw(in: CGRect(x: 0, y: 0, width: thumbnailImage.size.width, height: thumbnailImage.size.height))
            iconContinueVideo?.draw(in: CGRect(x: thumbnailImage.size.width / 2 - 70, y: thumbnailImage.size.height / 2 - 70, width: 150, height: 150))
            
            let newImg = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            thumbnailImage = newImg!
            
            return thumbnailImage
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func checkIfVCAlreadyExistsInStack(ofClass: AnyClass) -> Bool {
        if let viewControllers = self.navigationController?.viewControllers {
            for viewController in viewControllers {
                if viewController.isKind(of: ofClass) {
                    return true
                }
            }
        }
        return false
    }

    func startAnimating() {
        viewIndicator.isHidden = false
        view.isUserInteractionEnabled = false
        loadingIndicator?.startAnimating()
    }
    
    func stopAnimating() {
        viewIndicator.isHidden = true
        view.isUserInteractionEnabled = true
        loadingIndicator?.stopAnimating()
    }
    
}


