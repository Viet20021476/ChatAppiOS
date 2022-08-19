//
//  UIViewController+Extensions.swift
//  CustomVideoPlayer
//
//  Created by Huy Nguyen on 4/30/21.
//

import UIKit

extension UIViewController {
    func presentInFullScreen(_ viewController: UIViewController,
                             animated: Bool,
                             completion: (() -> Void)? = nil) {
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: animated, completion: completion)
    }
}
