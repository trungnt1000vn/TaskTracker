//
//  RegisterViewController.swift
//  tasktracker
//
//  Created by Trung on 04/12/2023.
//

import UIKit
import JGProgressHUD
import FirebaseAuth

class RegisterViewController: UIViewController, UITextFieldDelegate {
    private let spinner = JGProgressHUD(style: .dark)
    
    @IBOutlet weak var firstNameLabel: UILabel!
    
    @IBOutlet weak var secondNameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var passwordLabel: UILabel!
    
    @IBOutlet weak var confirmLabel: UILabel!
    
    @IBOutlet weak var firstNameField: UITextField!
    
    @IBOutlet weak var secondNameField: UITextField!
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var confirmField: UITextField!
    
    
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
        firstNameField.delegate = self
        secondNameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        confirmField.delegate = self
    }
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        firstNameField.resignFirstResponder()
        secondNameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        confirmField.resignFirstResponder()
        guard let firstName = firstNameField.text,
              let secondName = secondNameField.text,
              let email = emailField.text,
              let password = passwordField.text,
              let confirm = confirmField.text,
              !email.isEmpty,!password.isEmpty, !firstName.isEmpty,!secondName.isEmpty, !confirm.isEmpty
        else{
            let alert = UIAlertController(title: "Ooops", message: "You haven't typed enough infor yet", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert,animated: true)
            return
        }
        guard let password = passwordField.text, !password.isEmpty, password.count >= 6
        else{
            let alert = UIAlertController(title: "Password Problem", message: "Your password must be 6 or greater than 6 characters", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert,animated: true)
            return
        }
        guard let password = passwordField.text,
              let confirm = confirmField.text,
              password == confirm
        else{
            let alert = UIAlertController(title: "Password Problem", message: "Your password and your confirmed doesn't match to each other", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert,animated: true)
            return
        }
        DatabaseManager.shared.userExists(with: email, completion: {[weak self]exists in
            guard let strongSelf = self else{
                return
            }
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss(animated: true)
            }
            guard !exists else {
                //user already exists
                strongSelf.alertUserRegisterError(message: "Looks like a user account for that email address already exists")
                return
            }
            UserDefaults.standard.set(email, forKey: "email")
            UserDefaults.standard.set("\(firstName) \(secondName)", forKey: "name")
            if let emailUser = UserDefaults.standard.string(forKey: "email"),
               let userName = UserDefaults.standard.string(forKey: "name") {
                print("Email: \(emailUser)")
                print("Name: \(userName)")
            }
            
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password,completion: {authResult, error in
                
                
                guard authResult != nil, error == nil else{
                    print("Error creating user")
                    return
                }
                let user = Auth.auth().currentUser
                user?.sendEmailVerification(completion: { error in
                    if let error = error {
                        print("Error sending verification email: \(error.localizedDescription)")
                        return
                    }
                    DispatchQueue.main.async {
                        strongSelf.alertVerify(message: "A verification email has been sent to your email address. Please verify your account before logging in.")
                    }
                })
                let appUser = AppUser(firstName: firstName, lastName: secondName, emailAddress: email)
                DatabaseManager.shared.insertUser(with: appUser, completion: {success in
                    if success{
                        //upload image
                        
                        
                    }
                })
            })
        })
        
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField{
        case firstNameField:
            secondNameField.becomeFirstResponder()
        case secondNameField:
            emailField.becomeFirstResponder()
        case emailField:
            passwordField.becomeFirstResponder()
        case passwordField:
            confirmField.becomeFirstResponder()
        case confirmField:
            textField.resignFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}
extension RegisterViewController{
    private func setupUI(){
        firstNameLabel.layer.borderWidth = 1
        secondNameLabel.layer.borderWidth = 1
        emailLabel.layer.borderWidth = 1
        passwordLabel.layer.borderWidth = 1
        confirmLabel.layer.borderWidth = 1
        firstNameLabel.layer.cornerRadius = 12
        secondNameLabel.layer.cornerRadius = 12
        emailLabel.layer.cornerRadius = 12
        passwordLabel.layer.cornerRadius = 12
        confirmLabel.layer.cornerRadius = 12
        registerButton.layer.cornerRadius = 12
    }
    func alertUserRegisterError(message: String = "Please enter all information to create a new account"){
        let alert = UIAlertController(title: "Woops", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
        
    }
    func alertVerify(message: String){
        let alert = UIAlertController(title: "Registered successfully !", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"Dismiss", style: .cancel, handler: { acting in
            self.navigationController?.popToRootViewController(animated: true)
        }))
        present(alert, animated: true)
    }
}
