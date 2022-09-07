//
//  SceneDelegate.swift
//  ChatAppIOS
//
//  Created by Nguyễn Duy Việt on 11/08/2022.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var userDefault = UserDefaults()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
                
        window?.windowScene = windowScene
        window?.makeKeyAndVisible()
        window?.backgroundColor = .white
        
        let viewController = InitialScreenVC()
        let navViewController = UINavigationController(rootViewController: viewController)
        window?.rootViewController = navViewController
        
        if let info = userDefault.object(forKey: ACCOUNT) as? String {
            let arrInfo = info.split(separator: " ")
            let email = String(arrInfo[0])
            let password = String(arrInfo[1])
            
            Auth.auth().signIn(withEmail: email, password: password)
            
            let homeVC = HomeVC(nibName: "HomeVC", bundle: nil)
            navViewController.pushViewController(homeVC, animated: true)
        } else {
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        if let currUser = globalCurrUser { Database.database().reference().child("Users").child(currUser.senderId).child("isOnline").setValue(true)
        }
        
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        if let tGlobalCurrUser = globalCurrUser {
            Database.database().reference().child("Users").child(tGlobalCurrUser.senderId).child("beingInRoom").setValue("")
            Database.database().reference().child("Users").child(tGlobalCurrUser.senderId).child("isOnline").setValue(false)
            Database.database().reference().child("Users").child(tGlobalCurrUser.senderId).child("lastOnline").setValue(Util.getStringFromDate(format: "HH:mm:ss dd/MM/YYYY", date:Date()))
        }
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
}

