//
//  NotHaveFRVC.swift
//  ChatAppIOS
//
//  Created by Nguyễn Duy Việt on 25/08/2022.
//

import UIKit

class NotHaveFRVC: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        ivBack.isHidden = true

        // Do any additional setup after loading the view.
        view.backgroundColor = .white.withAlphaComponent(0.9)
    }
}
