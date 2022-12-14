//
//  HomeVC.swift
//  ChatAppIOS
//
//  Created by Nguyễn Duy Việt on 12/08/2022.
//

import UIKit
import SDWebImage
import Firebase
import FirebaseDatabase

class HomeVC: BaseViewController {
    
    @IBOutlet weak var viewUserList: UIView!
    
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var tableFriends: UITableView!
    
    @IBOutlet weak var imgNoti: UIImageView!
    @IBOutlet weak var imgAddFriend: UIImageView!
    var lastMsg = ""
    
    var arrFriends = [User]()
    var numOfNoti = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = #colorLiteral(red: 0.09133880585, green: 0.7034819722, blue: 0.9843640924, alpha: 1)
        view.removeGestureRecognizer(tapGesture!)
        ivBack.isHidden = true
        setupViews()
        getData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if currUser != nil {
            dbRef.child("Users").child(currUser!.senderId).child("beingInRoom").setValue("")
        }
    }
    
    func setupViews() {
        setupImgAvatar()
        setupRightBarItem()
        setupViewUserList()
        setupTableUser()
    }
    func getData() {
        getCurrUserData()
        getUserListData()
        checkFriendRequestAndNoti()
    }
    
    func setupImgAvatar() {
        imgAvatar.layer.masksToBounds = false
        imgAvatar.layer.cornerRadius = imgAvatar.frame.size.width / 2
        imgAvatar.clipsToBounds = true
        
        imgAvatar.contentMode = .scaleToFill
        
        imgAvatar.isUserInteractionEnabled = true
        let profileTapGes = UITapGestureRecognizer(target: self, action: #selector(getToProfile))
        imgAvatar.addGestureRecognizer(profileTapGes)
    }
    
    func setupRightBarItem() {
        let tapAddGes = UITapGestureRecognizer(target: self, action: #selector(tapOnAddFriend))
        imgAddFriend.addGestureRecognizer(tapAddGes)
        let tapNotiGes = UITapGestureRecognizer(target: self, action: #selector(tapOnSeeNoti))
        imgNoti.addGestureRecognizer(tapNotiGes)
    }
    
    func setupViewUserList() {
        viewUserList.clipsToBounds = true
        viewUserList.layer.cornerRadius = 40
        viewUserList.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner] // Top right corner, Top left corner respectively
    }
    
    func setupTableUser() {
        tableFriends.delegate = self
        tableFriends.dataSource = self
        
        tableFriends.backgroundColor = .clear
        
        let nib = UINib(nibName: "UserCell", bundle: nil)
        tableFriends.register(nib, forCellReuseIdentifier: "userCell")
    }
    
    func getCurrUserData() {
        startAnimating()
        
        dbRef.child("Users").child(auth.currentUser!.uid).observe(.value) { snapshot in
            if let dict = snapshot.value as? [String: Any] {
                self.currUser = User(dict: dict)
                self.lbName.text = self.currUser!.displayName
                let url = URL(string: self.currUser!.avatar)
                self.imgAvatar.sd_setImage(with: url)
                globalCurrUser = self.currUser
            }
        }
        dbRef.child("Users").child(auth.currentUser!.uid).child("isOnline").setValue(true)
    }
    
    func getUserListData() {
        
        dbRef.child("Users").child(auth.currentUser!.uid).child("friends").observe(.childAdded) { snapshot in
            self.dbRef.child("Users").child(self.auth.currentUser!.uid).child("friends").child(snapshot.key).observe(.value) { data in
                guard let dict = data.value as? [String: Any] else {return}
                
                let user = User(dict: dict)
                
                if !self.arrFriends.contains(user) {
                    self.arrFriends.append(user)
                } else {
                    guard let idx = self.arrFriends.firstIndex(of: user) else {return}
                    self.arrFriends[idx].timeStamp = user.timeStamp
                }
                self.sortArrUserByTimestamp()
                self.tableFriends.reloadData()
            }
            
            self.stopAnimating()
            
        }
        
        
        // Neu gap loi thi cho vao trong
        self.dbRef.child("Users").child(self.auth.currentUser!.uid).child("friends").observe(.childRemoved) { snapshot in
            guard let removedIdx = self.arrFriends.firstIndex(where: {$0.senderId == snapshot.key}) else {return}
            self.arrFriends.remove(at: removedIdx)
            self.tableFriends.reloadData()
        }
    }
    
    func checkFriendRequestAndNoti() {
        
        dbRef.child("Users").child(auth.currentUser!.uid).child("friends").observe(.value) { snapshot in
            do {
                let val = try snapshot.value as? String
                if val == "" {
                    self.stopAnimating()
                    return
                }
            } catch {
                return
            }
        }
        
        dbRef.child("Users").child(auth.currentUser!.uid).child("friendsRequest").observe(.value) { snapshot in
            if snapshot.childrenCount != 0 {
                self.numOfNoti = Int(snapshot.childrenCount)
                self.imgNoti.image = UIImage(named: "bellWithNoti")
            } else {
                self.imgNoti.image = UIImage(named: "bell")
            }
        }
        stopAnimating()
    }
    
    @objc func getToProfile() {
        let vc = ProfileVC(nibName: "ProfileVC", bundle: nil)
        vc.currUser = currUser
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func tapOnAddFriend() {
        let vc = SendFriendRequestAlert()
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    @objc func tapOnSeeNoti() {
        if numOfNoti == 0 {
            let vc = NotHaveFRVC(nibName: "NotHaveFRVC", bundle: nil)
            present(vc, animated: true)
            
        } else {
            let vc = FriendRequestVC(nibName: "FriendRequestVC", bundle: nil)
            vc.delegate = self
            present(vc, animated: true)
        }
    }
}

extension HomeVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableFriends.dequeueReusableCell(withIdentifier: "userCell") as! UserCell
        let data = arrFriends[indexPath.row]
        
        cell.imgAvatar.sd_setImage(with: URL(string: data.avatar))
        cell.lbName.text = data.displayName
        cell.imgNotSeen.isHidden = true
        cell.cellId = data.senderId
        
        dbRef.child("Users").child(data.senderId).child("isOnline").observe(.value) { snapshot in
            let isOn = snapshot.value as! Bool
            if isOn {
                cell.imgOnOff.image = UIImage(named: "green_dot")
            } else {
                cell.imgOnOff.image = UIImage(named: "gray_dot")
                
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.stopAnimating()
        }
        
        let senderRoom = "\(currUser!.senderId as! String)\(data.senderId)"
        
        dbRef.child("Messages").child(senderRoom).child("LastMsg").child("lastmsg").observe(.value) { snap in
            
            guard let dict = snap.value as? [String: Any] else {return}
            
            // To fix weird behavior on last message display, may works
            if dict["messageId"] == nil {return}
            
            // Check for the situation deleteing friends
            let msg = Message(dict: dict)
            
            
            //Problem: Khi người ở bên kia nhấn vào xem tin nhắn, Callback có vấn đề, những cell của friends không liên quan cũng được gọi khiến cho last message bị trùng lặp giữa các cell, ở dưới là 1 solution
            if (cell.cellId != msg.senderId) && (cell.cellId != msg.receiverId) {return}
            

            
            if msg.senderId == self.currUser!.senderId {
                cell.lbLastMsg.font = .systemFont(ofSize: 17)
                if msg.type == IMAGE {
                    cell.lbLastMsg.text = "You: Sent an image"
                } else if msg.type == VIDEO {
                    cell.lbLastMsg.text = "You: Sent a video"
                } else if msg.type == LOCATION {
                    cell.lbLastMsg.text = "You: Sent a location"
                } else if msg.type == AUDIO {
                    cell.lbLastMsg.text = "You: Sent an audio"
                } else {
                    cell.lbLastMsg.text = "You: \(msg.textContent)"
                }
            } else if msg.receiverId == self.currUser!.senderId {
                if !msg.isSeen {
                    cell.lbLastMsg.font = .boldSystemFont(ofSize: 17)
                    cell.imgNotSeen.isHidden = false
                }
                self.dbRef.child("Messages").child(senderRoom).child("LastMsg").child("lastmsg").child("isSeen").observe(.value) { data in
                    guard let isSeen = data.value as? Bool else {return}
                    if isSeen {
                        cell.lbLastMsg.font = .systemFont(ofSize: 17)
                        cell.imgNotSeen.isHidden = true
                    }
                }
                
                //                self.dbRef.child("Messages").child(senderRoom).child(msg.messageId).child("isSeen").observe(.value) { data in
                //                    guard let isSeen = data.value as? Bool else {return}
                //                    if isSeen {
                //                        cell.lbLastMsg.font = .systemFont(ofSize: 17)
                //                        cell.imgNotSeen.isHidden = true
                //                    }
                //                }
                //                if !msg.isSeen {
                //                    cell.lbLastMsg.font = .boldSystemFont(ofSize: 17)
                //                    cell.imgNotSeen.isHidden = false
                //                }
                if msg.type == IMAGE {
                    cell.lbLastMsg.text = "Sent an image"
                } else if msg.type == VIDEO {
                    cell.lbLastMsg.text = "Sent a video"
                } else if msg.type == LOCATION {
                    cell.lbLastMsg.text = "Sent a location"
                } else if msg.type == AUDIO {
                    cell.lbLastMsg.text = "Sent an audio"
                } else {
                    cell.lbLastMsg.text = msg.textContent
                }
                
            }
            self.stopAnimating()
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableFriends.cellForRow(at: indexPath) as! UserCell
        cell.lbLastMsg.font = .systemFont(ofSize: 17)
        cell.imgNotSeen.isHidden = true
        
        let vc = ChatVC(nibName: "ChatVC", bundle: nil)
        vc.currUser = currUser
        vc.otherUser = arrFriends[indexPath.row]
        vc.title = arrFriends[indexPath.row].displayName
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
        tableFriends.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: "Are you sure to delete this friend?", message: nil, preferredStyle: .alert)
            
            let actionYes = UIAlertAction(title: "Yes", style: .destructive) { ac in
                let otherUserId = self.arrFriends[indexPath.row].senderId
                self.arrFriends.remove(at: indexPath.row)
                self.tableFriends.reloadData()
                
                // Delete relationship
                self.dbRef.child("Users").child(self.currUser!.senderId).child("friends").child(otherUserId).removeValue()
                self.dbRef.child("Users").child(otherUserId).child("friends").child(self.currUser!.senderId).removeValue()
                
                // Delete messages of the two
                let senderRoom = "\(self.currUser!.senderId)\(otherUserId)"
                let receiverRoom = "\(otherUserId)\(self.currUser!.senderId)"
                
                self.dbRef.child("Messages").child(senderRoom).removeValue()
                self.dbRef.child("Messages").child(receiverRoom).removeValue()
            }
            let actionNo = UIAlertAction(title: "No", style: .default)
            
            alert.addAction(actionYes)
            alert.addAction(actionNo)
            present(alert, animated: true)
        }
    }
}

extension HomeVC : ChatVCDelegate {
    func removeAllUser() {
        arrFriends.removeAll()
    }
    
    func sortArrUserByTimestamp() {
        arrFriends.sort { user1, user2 in
            user1.timeStamp > user2.timeStamp
        }
    }
    
    func reloadUserList() {
        getUserListData()
    }
    
}

extension HomeVC : FriendRequestVCDelegate {
    func decreaseNumOfNoti() {
        numOfNoti -= 1
    }
}
