//
//  ChatVC.swift
//  ChatAppIOS
//
//  Created by Nguyễn Duy Việt on 12/08/2022.
//

import UIKit
import MessageKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import InputBarAccessoryView
import YPImagePicker
import SDWebImage

protocol ChatVCDelegate {
    func removeAllUser()
    func sortArrUserByTimestamp()
    func reloadUserList()
}

class ChatVC: MessagesViewController {
    
    var delegate: ChatVCDelegate?
    
    var titleLbName = UILabel()
    var titleImgOnOff = UIImageView()
    var titleLbOnOff = UILabel()
    
    let dbRef = Database.database().reference()
    
    var currUser: User?
    var otherUser: User?
    
    var arrMessage = [Message]()
    
    var senderRoom = ""
    var receiverRoom = ""
    var numberOfMsg = 0
    
    var refHandleSenderMsgCount: DatabaseHandle?
    
    var imgPicker = YPImagePicker()
    var btnPickImg = InputBarButtonItem()
    
    let currDate = Date()
    var imageCache: SDImageCache = SDImageCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        navigationController?.navigationBar.isHidden = false
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.red ] // Title color
        
        setupRightBarBtnItem()
        customInputView()
        
        senderRoom = "\(currUser?.senderId as! String)\(otherUser?.senderId as! String)"
        receiverRoom = "\(otherUser?.senderId as! String)\(currUser?.senderId as! String)"
        
        //        let tapGesture = UITapGestureRecognizer(target: self, action:#selector(hideKeyboard))
        //        messagesCollectionView.addGestureRecognizer(tapGesture)
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        
        messageInputBar.delegate = self
        
        dbRef.child("Users").child(currUser!.senderId).child("beingInRoom").setValue(senderRoom)
        dbRef.child("Users").child(currUser!.senderId).child("beingInRoom").observe(.value) { snapshot in
            self.dbRef.child("Users").child(self.currUser!.senderId).child("beingInRoom").removeAllObservers()
            self.currUser?.beingInRoom = snapshot.value as! String
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
    
    func setupRightBarBtnItem() {
        let rightItemBtn = UIButton(type: .custom)
        rightItemBtn.translatesAutoresizingMaskIntoConstraints = false
        rightItemBtn.setImage(UIImage(systemName: "info.circle"), for: .normal)
        rightItemBtn.contentVerticalAlignment = .fill
        rightItemBtn.contentHorizontalAlignment = .fill
        rightItemBtn.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        rightItemBtn.widthAnchor.constraint(equalToConstant: 40).isActive = true
        rightItemBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightItemBtn)
        
        rightItemBtn.addTarget(self, action: #selector(getToOtherUserProfile), for: .touchUpInside)
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
                    self.titleLbOnOff.text = "Offline, last online: \(lastOn)"
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
            self.dbRef.child("Messages").child(self.senderRoom).child(snapshot.key).observe(.value) { data in
                self.dbRef.child("Messages").child(self.senderRoom).child(snapshot.key).removeAllObservers()
                if let dict = data.value as? [String: Any] {
                    let msg = Message(dict: dict)
                    msg.sender = User(senderId: msg.senderId, displayName: msg.senderName)
                    if msg.type == "image" {
                        SDWebImageManager.shared.loadImage(with: URL(string: msg.downloadURL), options: .allowInvalidSSLCertificates) { int1, int2, int3 in
                        } completed: { img, data, err, type, bool1, url in
                            msg.kind = .photo(Media(url: URL(string: msg.downloadURL)!, image: img!, placeholderImage: UIImage(named: "ic_pickimg")!, size: CGSize(width: 200, height: 200)))
                            self.arrMessage.append(msg)
                            self.messagesCollectionView.insertSections([self.arrMessage.count - 1])
                            self.messagesCollectionView.scrollToLastItem()
                        }
                    } else {
                        msg.kind = .text(msg.textContent)
                        self.arrMessage.append(msg)
                        self.messagesCollectionView.insertSections([self.arrMessage.count - 1])
                        self.messagesCollectionView.scrollToLastItem()
                    }
                    if msg.receiverId == self.currUser?.senderId && self.currUser!.beingInRoom != "" {
                        msg.isSeen = true
                        self.dbRef.child("Messages").child(self.senderRoom).child(msg.messageId).child("isSeen").setValue(true)
                        self.dbRef.child("Messages").child(self.receiverRoom).child(msg.messageId).child("isSeen").setValue(true)
                        
                    }
                    
                }
            }
        }
        
        refHandleSenderMsgCount = dbRef.child("Messages").child(senderRoom).observe(.value) { snapshot in
            self.numberOfMsg = Int(snapshot.childrenCount)
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
        
        messageInputBar.middleContentViewPadding = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        
        btnPickImg = makeButton(image: UIImage(named: "ic_pickimg")!)
        let items = [btnPickImg]
        
        messageInputBar.setLeftStackViewWidthConstant(to: 40, animated: true)
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
        config.library.maxNumberOfItems = 3
        imgPicker = YPImagePicker(configuration: config)
        
        btnPickImg.onSelected {_ in
            self.imgPicker.didFinishPicking { items, cancelled in
                for item in items {
                    switch item {
                    case .photo(let photo):
                        self.uploadMediaItemToStorage(image: photo.image)
                        
                    case .video(let video):
                        print(video)
                    }
                }
                self.imgPicker.dismiss(animated: true, completion: nil)
            }
            self.present(self.imgPicker, animated: true, completion: nil)
        }
    }
    
    func uploadMediaItemToStorage(image: UIImage){
        var downloadURl = ""
        let storageRef = Storage.storage().reference()
        
        let date = Util.getStringFromDate(format: "YYYY,MM dd,HH:mm:ss", date: currDate)
        let imgName = date
        
        let data = image.jpegData(compressionQuality: 0.3)
        // DUONG DAN CHO THU MUC CHUA AVATAR
        let imgStorageRef = storageRef
        let imgFolder = imgStorageRef.child(senderRoom).child(imgName)//-> DUONG DAN LUU AVATAR
        
        imgFolder.putData(data!, metadata: nil) { meta, err in
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
                                          kind: .photo(Media(url: URL(string: "https://dantri.com.vn/")!, image: image, placeholderImage: image, size: CGSize(width: 200, height: 200))),
                                          type: "image", textContent: "",
                                          sentDate: self.currDate,
                                          downloadURL: "\(url!)",
                                          isSeen: false)
                        
                        let val = ["messageId": msg.messageId,
                                   "senderId": msg.senderId,
                                   "senderName": self.currUser?.displayName,
                                   "receiverId": msg.receiverId,
                                   "strSentDate": msg.strSentDate,
                                   "type": msg.type,
                                   "textContent": msg.textContent,
                                   "downloadURL": msg.downloadURL,
                                   "isSeen": msg.isSeen] as [String : Any]
                        
                        self.dbRef.child("Messages").child(self.senderRoom).child(key!).setValue(val)
                        self.dbRef.child("Messages").child(self.receiverRoom).child(key!).setValue(val)
                        
                        
                        self.dbRef.child("Users").child(self.currUser!.senderId).removeAllObservers()
                        self.dbRef.child("Users").child(self.otherUser!.senderId).removeAllObservers()
                        
                        self.delegate?.removeAllUser()
                        
                        let dictTimeStamp = ["timeStamp": NSDate().timeIntervalSince1970]
                        self.dbRef.child("Users").child(self.currUser!.senderId).updateChildValues(dictTimeStamp)
                        self.dbRef.child("Users").child(self.otherUser!.senderId).updateChildValues(dictTimeStamp)
                        
                        self.messageInputBar.inputTextView.text = ""
                        
                        self.delegate?.reloadUserList()
                        downloadURl = "\(url!)"
                    }
                }
                
            }
        }
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
            return #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        }
        return .lightGray.withAlphaComponent(0.4)
    }
    
    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 8) // -> Them khoang trong giua cac tin nhan
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        let currMsg = arrMessage[indexPath.section]
        let arrDate = currMsg.strSentDate.split(separator: ",")
        let strHour = arrDate[2]
        
        if currMsg.isSeen == true && currUser?.senderId == currMsg.senderId && indexPath.section == numberOfMsg - 1 {
            return NSAttributedString(
                string: "√Seen",
                attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
        } else {
            return NSAttributedString(
                string: String(strHour),
                attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
        }
    }
    
    //    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    //        let msg = arrMessage[indexPath.section]
    //        if  msg.type == "image" {
    //            let vc = MediaViewVC(nibName: "MediaViewVC", bundle: nil)
    //            vc.mediaView.sd_setImage(with: URL(string: msg.downloadURL))
    //            navigationController?.pushViewController(vc, animated: true)
    //        }
    //    }
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
                          downloadURL: "",
                          isSeen: false)
        
        let val = ["messageId": msg.messageId,
                   "senderId": msg.senderId,
                   "senderName": currUser?.displayName,
                   "receiverId": msg.receiverId,
                   "strSentDate": msg.strSentDate,
                   "type": msg.type,
                   "textContent": msg.textContent,
                   "downloadURL": msg.downloadURL,
                   "isSeen": msg.isSeen] as [String : Any]
        
        dbRef.child("Messages").child(senderRoom).child(key!).setValue(val)
        dbRef.child("Messages").child(receiverRoom).child(key!).setValue(val)
        
        
        dbRef.child("Users").child(currUser!.senderId).removeAllObservers()
        dbRef.child("Users").child(otherUser!.senderId).removeAllObservers()
        
        delegate?.removeAllUser()
        
        let dictTimeStamp = ["timeStamp": NSDate().timeIntervalSince1970]
        dbRef.child("Users").child(currUser!.senderId).updateChildValues(dictTimeStamp)
        dbRef.child("Users").child(otherUser!.senderId).updateChildValues(dictTimeStamp)
        
        messageInputBar.inputTextView.text = ""
        
        delegate?.reloadUserList()
        
    }
    
}

extension ChatVC : MessageCellDelegate {
    func didTapImage(in cell: MessageCollectionViewCell) {
        let indexPath = messagesCollectionView.indexPath(for: cell)
        let vc = MediaViewVC(nibName: "MediaViewVC", bundle: nil)
        vc.mediaView.sd_setImage(with: URL(string: "\(arrMessage[indexPath!.section].downloadURL)"))
        navigationController?.pushViewController(vc, animated: true)
    }
}

