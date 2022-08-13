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

    let dbRef = Database.database().reference()
    
    var currUser: User?
    var otherUser: User?
    
    var arrMessage = [Message]()
    
    var senderRoom = ""
    var receiverRoom = ""
    
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
        getMsgData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
                self.messagesCollectionView.scrollToLastItem()
            }
    }
    
    func getMsgData() {
        dbRef.child("Messages").child(senderRoom).observe(.childAdded) { snapshot in
            self.dbRef.child("Messages").child(self.senderRoom).child(snapshot.key).observe(.value) { data in
                if let dict = data.value as? [String: Any] {
                    let msg = Message(dict: dict)
                    msg.sender = User(senderId: msg.senderId, displayName: msg.senderName)
                    msg.kind = .text(msg.textContent)
                    self.arrMessage.append(msg)
                    self.messagesCollectionView.insertSections([self.arrMessage.count - 1])
                    self.messagesCollectionView.scrollToLastItem()
                }
            }
        }
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    func getStringFromDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY,MMM d,HH:mm:ss"
        
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
    
}

extension ChatVC : InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let key = dbRef.childByAutoId().key
        let currDate = Date()
        let date = getStringFromDate(date: currDate)
        
        let msg = Message(sender: currUser!, messageId: key!, senderId: currUser!.senderId, receiverId: otherUser!.senderId, strSentDate: date, kind: .text(text), type: MessageKind.text(text).msgKind, textContent: text, sentDate: currDate)
        
        let val = ["messageId": msg.messageId, "senderId": msg.senderId, "senderName": currUser?.displayName, "receiverId": msg.receiverId, "strSentDate": msg.strSentDate, "type": msg.type, "textContent": msg.textContent]
        
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
