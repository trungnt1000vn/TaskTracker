//
//  ForgotPasswordViewController.swift
//  tasktracker
//
//  Created by Trung on 15/12/2023.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
class ForgotPasswordViewController : UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        emailField.delegate = self
    }
    
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        guard let email = emailField.text, !email.isEmpty else {
            // Show alert for empty email field
            return
        }
        DatabaseManager.shared.userExists(with: email, completion: {[weak self] exists in
            guard let strongSelf = self else {
                return
            }
            guard exists else {
                let alert = UIAlertController(title: "Woopss", message: "Looks like the email you entered hasn't been registered", preferredStyle: .alert)
                let alertDismiss = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                alert.addAction(alertDismiss)
                self?.present(alert, animated: true)
                return
            }
            Auth.auth().sendPasswordReset(withEmail: self?.emailField.text ?? "", completion: {
                error in
                if let error = error {
                    let alert = UIAlertController(title: "Failed to send", message: "\(error.localizedDescription)", preferredStyle: .alert)
                    let alertOK = UIAlertAction(title: "Try Again", style: .default, handler: nil)
                    let alertCancel = UIAlertAction(title: "Cancel", style: .destructive, handler: {acting in
                        self?.emailField.text = ""
                    })
                    alert.addAction(alertOK)
                    alert.addAction(alertCancel)
                    self!.present(alert, animated: true)
                }
                else {
                    let alert = UIAlertController(title: "Success", message: "An email has been sent, please check it !!!", preferredStyle: .actionSheet)
                    let alertOK = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(alertOK)
                    self!.present(alert, animated: true)
                }
            })
        })
    }
    private func setupUI(){
        emailLabel.layer.borderWidth = 1
        emailLabel.layer.cornerRadius = 12
        sendButton.layer.cornerRadius = 12
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailField.resignFirstResponder()
    }
}
