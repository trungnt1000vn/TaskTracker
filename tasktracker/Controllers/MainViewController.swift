//
//  ViewController.swift
//  tasktracker
//
//  Created by Nguyễn Thành Trung on 01/11/2023.
//

import UIKit

class MainViewController: UIViewController {


    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
      
        
    }
    override func viewDidAppear(_ animated: Bool) {
        setupLogin()
    }
    private func  setupLogin(){
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Login")
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav,animated: false)
    }
}

