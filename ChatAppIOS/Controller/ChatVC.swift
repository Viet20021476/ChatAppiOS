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
import InputBarAccessoryView

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        navigationController?.navigationBar.isHidden = false
        
        senderRoom = "\(currUser?.senderId as! String)\(otherUser?.senderId as! String)"
        receiverRoom = "\(otherUser?.senderId as! String)\(currUser?.senderId as! String)"
        
        let tapGesture = UITapGestureRecognizer(target: self, action:#selector(hideKeyboard))
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        
        messagesCollectionView.addGestureRecognizer(tapGesture)
        
        messageInputBar.delegate = self
        
        setupTitleView()
        getMsgData()
        
        dbRef.child("Users").child(currUser!.senderId).child("beingInRoom").setValue(senderRoom)
        
        setupOnlineState()
        

    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        DispatchQueue.main.async {
//            self.messagesCollectionView.scrollToLastItem()
//        }
//    }
    
    override func viewDidDisappear(_ animated: Bool) {
        dbRef.child("Users").child(currUser!.senderId).child("beingInRoom").setValue("")
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
            //titleLbOnOff.text = "Offline, last online: \(otherUser?.lastOnline)"
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
                    msg.kind = .text(msg.textContent)
                    if msg.receiverId == self.currUser?.senderId {
                        msg.isSeen = true
                        self.dbRef.child("Messages").child(self.senderRoom).child(msg.messageId).child("isSeen").setValue(true)
                        self.dbRef.child("Messages").child(self.receiverRoom).child(msg.messageId).child("isSeen").setValue(true)
                        
                    }
                    self.arrMessage.append(msg)
                    self.messagesCollectionView.insertSections([self.arrMessage.count - 1])
                    self.messagesCollectionView.scrollToLastItem()
                }
            }
        }
        
        dbRef.child("Messages").child(senderRoom).observe(.value) { snapshot in
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
    
    func getStringFromDate(format: String, date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        //dateFormatter.dateFormat = "YYYY,MMM d,HH:mm:ss"
        
        return dateFormatter.string(from: date)
    }
}

extension ChatVC : MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
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
    
}

extension ChatVC : InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let key = dbRef.childByAutoId().key
        let currDate = Date()
        let date = getStringFromDate(format: "YYYY,MM dd,HH:mm:ss", date: currDate)
        
        let msg = Message(sender: currUser!, messageId: key!, senderId: currUser!.senderId, receiverId: otherUser!.senderId, strSentDate: date, kind: .text(text), type: MessageKind.text(text).msgKind, textContent: text, sentDate: currDate, isSeen: false)
        
        let val = ["messageId": msg.messageId, "senderId": msg.senderId, "senderName": currUser?.displayName, "receiverId": msg.receiverId, "strSentDate": msg.strSentDate, "type": msg.type, "textContent": msg.textContent, "isSeen": false] as [String : Any]
                
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
