//
//  FriendRequestVC.swift
//  ChatAppIOS
//
//  Created by Nguyễn Duy Việt on 24/08/2022.
//

import UIKit
import SDWebImage

protocol FriendRequestVCDelegate {
    func decreaseNumOfNoti()
}

class FriendRequestVC: BaseViewController {
    
    var delegate: FriendRequestVCDelegate?

    @IBOutlet weak var tableRequest: UITableView!
    
    var arrFriendRequest = [FriendRequest]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ivBack.isHidden = true
        view.backgroundColor = .white.withAlphaComponent(0.9)
        setupTableRequest()
        getRequestList()
    }
    
    func setupTableRequest() {
     
        let nib = UINib(nibName: "FriendRequestCell", bundle: nil)
        tableRequest.register(nib, forCellReuseIdentifier: "friendRequestCell")
        
        tableRequest.delegate = self
        tableRequest.dataSource = self
        tableRequest.reloadData()
        
    }
    
    func getRequestList() {
        dbRef.child("Users").child(globalCurrUser!.senderId).child("friendsRequest").observe(.value) { snapshot in
            do {
                let val = try snapshot.value as? String
                if val == "" {
                    return
                }
            } catch {
                return
            }
        }
        
        dbRef.child("Users").child(globalCurrUser!.senderId).child("friendsRequest").observe(.childAdded) { snapshot in
            self.dbRef.child("Users").child(globalCurrUser!.senderId).child("friendsRequest").child(snapshot.key).observe(.value) { data in
                
                let dict = data.value as? [String: Any]
                let friendRequest = FriendRequest(dict: dict!)
                    self.arrFriendRequest.append(friendRequest)
                    self.tableRequest.reloadData()
                    self.dbRef.child("Users").child(globalCurrUser!.senderId).child("friendsRequest").child(snapshot.key).removeAllObservers()
            }
        }
        
    }

    
}

extension FriendRequestVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrFriendRequest.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableRequest.dequeueReusableCell(withIdentifier: "friendRequestCell") as! FriendRequestCell
        let data = arrFriendRequest[indexPath.row]
        
        cell.imgAvatar.sd_setImage(with: URL(string: data.imgAvatarLink))
        cell.lbFromUser.text = data.fromUser
        
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension FriendRequestVC : FriendRequestCellDelegate {

    func acceptRequest(cell: FriendRequestCell) {
        let indexPath = tableRequest.indexPath(for: cell)
        let frRequest = arrFriendRequest[indexPath!.row]
        arrFriendRequest.remove(at: indexPath!.row)
        tableRequest.deleteRows(at: [indexPath!], with: .left)
        
        dbRef.child("Users").child(globalCurrUser!.senderId).child("friendsRequest").child(frRequest.senderId).removeValue()
        
        
        let otherUser = globalArrUser.first(where: {$0.senderId == frRequest.senderId})
        
        let OtherUserValue = ["id": otherUser?.senderId, "email": otherUser?.email, "avatar": otherUser?.avatar, "name": otherUser?.displayName, "timeStamp": otherUser?.timeStamp, "beingInRoom": otherUser?.beingInRoom, "isOnline": otherUser?.isOnline, "lastOnline": otherUser?.lastOnline, "birthDate": otherUser?.birthDate, "phoneNumber": otherUser?.phoneNumber, "feeling": otherUser?.feeling, "friends": "", "friendsRequest": ""] as [String : Any]
        
        self.dbRef.child("Users").child(globalCurrUser!.senderId).child("friends").child(otherUser!.senderId).setValue(OtherUserValue)
        
        
        let currUserValue = ["id": globalCurrUser?.senderId, "email": globalCurrUser?.email, "avatar": globalCurrUser?.avatar, "name": globalCurrUser?.displayName, "timeStamp": globalCurrUser?.timeStamp, "beingInRoom": globalCurrUser?.beingInRoom, "isOnline": globalCurrUser?.isOnline, "lastOnline": globalCurrUser?.lastOnline, "birthDate": globalCurrUser?.birthDate, "phoneNumber": globalCurrUser?.phoneNumber, "feeling": otherUser?.feeling, "friends": "", "friendsRequest": ""] as [String : Any]
        
        self.dbRef.child("Users").child(otherUser!.senderId).child("friends").child(globalCurrUser!.senderId).setValue(currUserValue)
        delegate?.decreaseNumOfNoti()
    }
    
    func declineRequest(cell: FriendRequestCell) {
        let indexPath = tableRequest.indexPath(for: cell)
        let frRequest = arrFriendRequest[indexPath!.row]
        arrFriendRequest.remove(at: indexPath!.row)
        tableRequest.deleteRows(at: [indexPath!], with: .left)
        
        dbRef.child("Users").child(globalCurrUser!.senderId).child("friendsRequest").child(frRequest.senderId).removeValue()
        delegate?.decreaseNumOfNoti()
    }
    
}
