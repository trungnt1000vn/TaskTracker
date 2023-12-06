//
//  ViewController.swift
//  tasktracker
//
//  Created by Nguyễn Thành Trung on 01/11/2023.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class MainViewController: UIViewController {


    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
      
        
    }
    override func viewDidAppear(_ animated: Bool) {
        validateAuth()
    }
    private func validateAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil || FirebaseAuth.Auth.auth().currentUser?.isEmailVerified == false{
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "Login")
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav,animated: false)
        }
    }
}

