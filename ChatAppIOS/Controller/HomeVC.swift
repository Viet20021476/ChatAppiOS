//
//  HomeVC.swift
//  ChatAppIOS
//
//  Created by Nguyễn Duy Việt on 12/08/2022.
//

import UIKit
import SDWebImage

class HomeVC: BaseViewController {
    
    @IBOutlet weak var viewUserList: UIView!
    
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var tableUser: UITableView!
    
    var lastMsg = ""
    
    var arrUser = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
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
        setupViewUserList()
        setupTableUser()
    }
    func getData() {
        getCurrUserData()
        getUserListData()
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
    
    func setupViewUserList() {
        viewUserList.clipsToBounds = true
        viewUserList.layer.cornerRadius = 40
        viewUserList.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner] // Top right corner, Top left corner respectively
    }
    
    func setupTableUser() {
        tableUser.delegate = self
        tableUser.dataSource = self
        
        tableUser.backgroundColor = .clear
        
        let nib = UINib(nibName: "UserCell", bundle: nil)
        tableUser.register(nib, forCellReuseIdentifier: "userCell")
    }
    
    func getCurrUserData() {
        startAnimating()
        
        dbRef.child("Users").child(auth.currentUser!.uid).observe(.value) { snapshot in
            if let dict = snapshot.value as? [String: Any] {
                self.currUser = User(dict: dict)
                self.lbName.text = self.currUser?.displayName
                let url = URL(string: self.currUser!.avatar)
                self.imgAvatar.sd_setImage(with: url)
                globalCurrUser = self.currUser
            }
        }
        dbRef.child("Users").child(auth.currentUser!.uid).child("isOnline").setValue(true)
    }
    
    func getUserListData() {
        dbRef.child("Users").observe(.childAdded) { snapshot in
            self.dbRef.child("Users").child(snapshot.key).observe(.value) { data in
                
                let dict = data.value as? [String: Any]
                let user = User(dict: dict!)
                if user.senderId != self.currUser?.senderId {
                    self.arrUser.append(user)
                    //                    self.tableUser.insertRows(at: [IndexPath.init(row: self.arrUser.count - 1, section: 0)], with: .automatic)
                    self.sortArrUserByTimestamp()
                    self.tableUser.reloadData()
                    self.dbRef.child("Users").child(snapshot.key).removeAllObservers()
                }
                
            }
            self.stopAnimating()
        }
    }
    
    @objc func getToProfile() {
        let vc = ProfileVC(nibName: "ProfileVC", bundle: nil)
        vc.currUser = currUser
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension HomeVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrUser.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableUser.dequeueReusableCell(withIdentifier: "userCell") as! UserCell
        let data = arrUser[indexPath.row]
        
        cell.imgAvatar.sd_setImage(with: URL(string: data.avatar))
        cell.lbName.text = data.displayName
        cell.imgNotSeen.isHidden = true
        
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
        
        let senderRoom = "\(currUser?.senderId as! String)\(data.senderId)"
        
        dbRef.child("Messages").child(senderRoom).observe(.childAdded) { snapshot in
            self.startAnimating()
            self.dbRef.child("Messages").child(senderRoom).child(snapshot.key).observe(.value) { data in
                //self.dbRef.child("Messages").child(senderRoom).child(snapshot.key).removeAllObservers()
                let dict = data.value as? [String: Any]
                let msg = Message(dict: dict!)
                if msg.senderId == self.currUser?.senderId {
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
                } else {
                    self.dbRef.child("Messages").child(senderRoom).child(msg.messageId).child("isSeen").observe(.value) { data in
                        let isSeen = data.value as! Bool
                        if isSeen {
                            cell.lbLastMsg.font = .systemFont(ofSize: 17)
                            cell.imgNotSeen.isHidden = true
                        }
                    }
                    if !msg.isSeen {
                        cell.lbLastMsg.font = .boldSystemFont(ofSize: 17)
                        cell.imgNotSeen.isHidden = false
                    }
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
            }
            self.stopAnimating()
        }
        
        
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableUser.cellForRow(at: indexPath) as! UserCell
        cell.lbLastMsg.font = .systemFont(ofSize: 17)
        cell.imgNotSeen.isHidden = true
        
        let vc = ChatVC(nibName: "ChatVC", bundle: nil)
        vc.currUser = currUser
        vc.otherUser = arrUser[indexPath.row]
        vc.title = arrUser[indexPath.row].displayName
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
        tableUser.deselectRow(at: indexPath, animated: true)
    }
}

extension HomeVC : ChatVCDelegate {
    func removeAllUser() {
        arrUser.removeAll()
    }
    
    func sortArrUserByTimestamp() {
        arrUser.sort { user1, user2 in
            user1.timeStamp > user2.timeStamp
        }
    }
    
    func reloadUserList() {
        getUserListData()
    }
    
}
