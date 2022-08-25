//
//  FriendRequestCell.swift
//  ChatAppIOS
//
//  Created by Nguyễn Duy Việt on 24/08/2022.
//

import UIKit

protocol FriendRequestCellDelegate {
    func acceptRequest(cell: FriendRequestCell)
    func declineRequest(cell: FriendRequestCell)
}

class FriendRequestCell: UITableViewCell {
    
    var delegate: FriendRequestCellDelegate?

    @IBOutlet weak var lbFromUser: UILabel!
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var btnDecline: UIButton!
    
    @IBOutlet weak var imgAvatar: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       setupView()
    }
    
    func setupView() {
        imgAvatar.layer.masksToBounds = false
        imgAvatar.layer.cornerRadius = imgAvatar.frame.size.width / 2
        imgAvatar.clipsToBounds = true
        imgAvatar.contentMode = .scaleAspectFill
        
        btnAccept.layer.cornerRadius = 10
        btnAccept.layer.masksToBounds = true
        btnDecline.layer.cornerRadius = 10
        btnDecline.layer.masksToBounds = true
        
        btnAccept.addTarget(self, action: #selector(accept), for: .touchUpInside)
        btnDecline.addTarget(self, action: #selector(decline), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func accept() {
        delegate?.acceptRequest(cell: self)
    }
    
    @objc func decline() {
        delegate?.declineRequest(cell: self)
    }
    
}
