//
//  UserCell.swift
//  ChatAppIOS
//
//  Created by Nguyễn Duy Việt on 12/08/2022.
//

import UIKit

class UserCell: UITableViewCell {

    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var imgOnOff: UIImageView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbLastMsg: UILabel!
    @IBOutlet weak var imgNotSeen: UIImageView!
    var cellId = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupImgAvatar()
    }

    func setupImgAvatar() {
        imgAvatar.layer.masksToBounds = false
        imgAvatar.layer.cornerRadius = imgAvatar.frame.size.width / 2
        imgAvatar.clipsToBounds = true
        
        imgAvatar.contentMode = .scaleToFill
        
        imgOnOff.contentMode = .scaleAspectFill
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = .clear
    }
    
}
