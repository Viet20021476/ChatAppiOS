//
//  BaseViewController.swift
//  ChatAppIOS
//
//  Created by Nguyễn Duy Việt on 11/08/2022.
//

import UIKit
import NVActivityIndicatorView
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class BaseViewController: UIViewController {
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    let viewIndicator = UIView()
    var loadingIndicator: NVActivityIndicatorView?
    
    let auth = Auth.auth()
    let dbRef = Database.database().reference()
    let storageRef = Storage.storage().reference()
    var currUser: User?
    
    var ivBack = UIImageView()
    
    var lightGrayFont:[NSAttributedString.Key : NSObject]?
    var redFont:[NSAttributedString.Key : NSObject]?
    
    var userDefault = UserDefaults()
    var tapGesture: UITapGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupIndicator()
        setupIvBack()
        setupCons()
    }
    
    func setupIvBack() {
        view.addSubview(ivBack)
        ivBack.translatesAutoresizingMaskIntoConstraints = false
        
        ivBack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        ivBack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        ivBack.widthAnchor.constraint(equalToConstant: 25).isActive = true
        ivBack.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        ivBack.image = UIImage(named: "ic_back")
        
        ivBack.isUserInteractionEnabled = true
        let backTapGesture = UITapGestureRecognizer(target: self, action: #selector(backScreen))
        ivBack.addGestureRecognizer(backTapGesture)
        
        tapGesture = UITapGestureRecognizer(target: self, action:#selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture!)
    }
    
    func setupIndicator() {
        viewIndicator.backgroundColor = .black.withAlphaComponent(0.6)
        roundCorner(views: [viewIndicator], radius: 10)
        view.addSubview(viewIndicator)
        viewIndicator.translatesAutoresizingMaskIntoConstraints = false
        viewIndicator.widthAnchor.constraint(equalToConstant: 60).isActive = true
        viewIndicator.heightAnchor.constraint(equalToConstant: 60).isActive = true
        viewIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        viewIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        viewIndicator.isHidden = true
        
        let frame = CGRect(x: 15, y: 15, width: 30, height: 30)
        loadingIndicator = NVActivityIndicatorView(frame: frame, type: .lineScale, color: .white, padding: 0)
        viewIndicator.addSubview(loadingIndicator!)
        
    }
    
    func startAnimating() {
        viewIndicator.isHidden = false
        view.isUserInteractionEnabled = false
        loadingIndicator?.startAnimating()
    }
    
    func stopAnimating() {
        viewIndicator.isHidden = true
        view.isUserInteractionEnabled = true
        loadingIndicator?.stopAnimating()
    }
    
    func roundCorner(views: [UIView], radius: CGFloat) {
        views.forEach { v in
            v.layer.cornerRadius = radius
            v.layer.masksToBounds = true
            v.layer.borderWidth = 1
            v.layer.borderColor = v.backgroundColor?.cgColor
        }
    }
    
    func popupAlert(alertTitle: String, acTitle: String) {
        let alert = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)
        let ac = UIAlertAction(title: acTitle, style: .default, handler: nil)
        alert.addAction(ac)
        
        present(alert, animated: true, completion: nil)
    }
    
    func colorString(string: String, startFrom: String, normalFont: [NSAttributedString.Key : NSObject], anotherColorFont: [NSAttributedString.Key : NSObject]) -> NSMutableAttributedString {
        let myAttributedString = NSMutableAttributedString()
        var i = 0
        let index = string.distance(of: startFrom)
        
        while i < string.count {
            var myLetter: NSAttributedString = NSAttributedString()
            if i < index! {
                myLetter = NSAttributedString(string: "\(string[i])", attributes: normalFont)
                myAttributedString.append(myLetter)
            } else {
                myLetter = NSAttributedString(string: "\(string[i])", attributes: anotherColorFont)
                myAttributedString.append(myLetter)
            }
            i += 1
        }
        
        return myAttributedString
    }
    
    @objc func backScreen() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    func setupCons() {
        lightGrayFont = [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: view.frame.width / 25)]
        redFont = [NSAttributedString.Key.foregroundColor: UIColor.red, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: view.frame.width / 25)]
    }
    
    func getStringFromDate(format: String, date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        //dateFormatter.dateFormat = "YYYY,MMM d,HH:mm:ss"
        
        return dateFormatter.string(from: date)
    }
    
    
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
    func disableAutoFill() {
        if #available(iOS 12, *) {
            textContentType = .oneTimeCode
        } else {
            textContentType = .init(rawValue: "")
        }
    }
}

extension UINavigationController {
    func popToViewController(ofClass: AnyClass, animated: Bool = true) {
        if let vc = viewControllers.last(where: { $0.isKind(of: ofClass) }) {
            popToViewController(vc, animated: animated)
        }
    }
}

extension StringProtocol {
    func distance(of element: Element) -> Int? { firstIndex(of: element)?.distance(in: self) }
    func distance<S: StringProtocol>(of string: S) -> Int? { range(of: string)?.lowerBound.distance(in: self) }
}


extension Collection {
    func distance(to index: Index) -> Int { distance(from: startIndex, to: index) }
}

extension String.Index {
    func distance<S: StringProtocol>(in string: S) -> Int { string.distance(to: self) }
}

extension String {
    
    var length: Int {
        return count
    }
    
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    
    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }
    
    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}


