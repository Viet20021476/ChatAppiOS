//
//  ProfileVC.swift
//  ChatAppIOS
//
//  Created by Nguyễn Duy Việt on 15/08/2022.
//

import UIKit
import FirebaseAuth

class ProfileVC: BaseViewController {

    @IBOutlet weak var btnLogout: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }
    
    func setupViews() {
        setupBtnLogout()
    }
    
    func setupBtnLogout() {
        roundCorner(views: [btnLogout], radius: 30)
    }
    
    @IBAction func topOnLogout(_ sender: Any) {
        let alert = UIAlertController(title: "Do you want to log out?", message: nil, preferredStyle: .alert)
        let actionYes = UIAlertAction(title: "Yes", style: .destructive) { ac in
            self.dbRef.child("Users").child(globalCurrUser!.senderId).child("isOnline").setValue(false)
            self.dbRef.child("Users").child(globalCurrUser!.senderId).child("lastOnline").setValue(self.getStringFromDate(format: "HH:mm:ss dd/MM/YYYY", date:Date()))
            self.navigationController?.popToViewController(ofClass: InitialScreenVC.self, animated: true)
        }
        
        let actionNo = UIAlertAction(title: "No", style: .default, handler: nil)
        
        alert.addAction(actionYes)
        alert.addAction(actionNo)
        
        present(alert, animated: true)
    }
    

}
