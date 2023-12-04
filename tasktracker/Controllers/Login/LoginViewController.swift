//
//  LoginViewController.swift
//  tasktracker
//
//  Created by Trung on 04/12/2023.
//

import UIKit

class LoginViewController: UIViewController {

    
    
    @IBOutlet weak var labelEmail: UILabel!
    
    @IBOutlet weak var labelPassword: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        labelEmail.layer.borderWidth = 1
        labelPassword.layer.borderWidth = 1
        labelEmail.layer.cornerRadius = 10
        labelPassword.layer.cornerRadius = 10
        // Do any additional setup after loading the view.
    }
    



}
