//
//  UIView+Extensions.swift
//  CustomVideoPlayer
//
//  Created by Huy Nguyen on 4/30/21.
//

import UIKit

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    func getViewsByType<T: UIView>(type _: T.Type) -> [T] {
        return getAllSubViews().compactMap { $0 as? T }
    }
    
    private func getAllSubViews() -> [UIView] {
        var subviews = self.subviews
        if subviews.isEmpty {
            return subviews
        }
        for view in subviews {
            subviews += view.getAllSubViews()
        }
        return subviews
    }
}

extension UIView {
    @discardableResult
    func loadFromNib<T: UIView>() -> T? {
        guard let contentView = Bundle(for: type(of: self)).loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?.first as? T else { return nil }
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        contentView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        contentView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        return contentView
    }
}
