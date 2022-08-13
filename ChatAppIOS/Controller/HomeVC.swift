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
            }
            self.stopAnimating()
        }
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
        }
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
        
        let senderRoom = "\(currUser?.senderId as! String)\(data.senderId)"
        
        dbRef.child("Messages").child(senderRoom).observe(.childAdded) { snapshot in
            self.startAnimating()
            self.dbRef.child("Messages").child(senderRoom).child(snapshot.key).observe(.value) { data in
                let dict = data.value as? [String: Any]
                let msg = Message(dict: dict!)
                if msg.senderId == self.currUser?.senderId {
                    cell.lbLastMsg.text = "You: \(msg.textContent)"
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
