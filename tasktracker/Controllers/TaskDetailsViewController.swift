//
//  TaskDetailsViewController.swift
//  tasktracker
//
//  Created by Trung on 12/12/2023.
//

import UIKit
import FirebaseDatabase
import JGProgressHUD
import UserNotifications

class TaskDetailsViewController: UIViewController, UINavigationControllerDelegate {
    private let spinner = JGProgressHUD(style: .dark)
    
    @IBOutlet weak var titleField: UITextField!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var noteField: UITextField!
    
    @IBOutlet weak var noteLabel: UILabel!
    
    @IBOutlet weak var updateButton: UIButton!
    
    public var TaskID : String = ""
    public var taskTitle: String = ""
    public var taskNote: String = ""
    private var isUpdating: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        observeData(taskID: TaskID)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func setUpUI(){
        titleLabel.layer.borderWidth = 1
        titleLabel.layer.cornerRadius = 12
        noteLabel.layer.borderWidth = 1
        noteLabel.layer.cornerRadius = 12
        updateButton.layer.cornerRadius = 12
    }
    
    
    @IBAction func updateButtonTapped(_ sender: Any) {
        
        if isUpdating == false {
            noteField.isUserInteractionEnabled = true
            titleField.isUserInteractionEnabled = true
            isUpdating = true
            updateButton.setTitle("Save", for: .normal)
        }
        else if isUpdating == true {
            let alertController = UIAlertController(title: "Saving", message: "Are you sure want to save these changes ?", preferredStyle: .alert)
            let alertOK = UIAlertAction(title: "Yes", style: .default, handler: {_ in
                
                self.updateTask(taskID: self.TaskID, title: self.titleField.text ?? "", note: self.noteField.text ?? "")
                self.updateButton.setTitle("Update", for: .normal)
                self.noteField.isUserInteractionEnabled = false
                self.titleField.isUserInteractionEnabled = false
                self.isUpdating = false
            })
            let alertCancel = UIAlertAction(title: "No", style: .destructive, handler: nil)
            alertController.addAction(alertOK)
            alertController.addAction(alertCancel)
            present(alertController, animated: true)
        }
    }
    private func updateTask(taskID: String, title: String, note: String){
        let email = UserDefaults.standard.value(forKey: "email")
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email as! String)
        self.spinner.show(in: view)
        let databaseRef = Database.database().reference()
        let taskRef = databaseRef.child("\(safeEmail)/tasks")
        taskRef.child(taskID).setValue([
            "title": title,
            "note": note
        ])
        DispatchQueue.main.async {
            self.spinner.dismiss(animated: true)
        }
    }
    private func observeData(taskID: String){
        let email = UserDefaults.standard.value(forKey: "email")
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email as! String)
        self.spinner.show(in: view)
        let databaseRef = Database.database().reference()
        let taskRef = databaseRef.child("\(safeEmail)/tasks").child(taskID)
        taskRef.observeSingleEvent(of: .value){ snapshot in
            guard let value = snapshot.value as? [String:String] else {
                return
            }
            self.titleField.text = value["title"]!
            self.noteField.text = value["note"]!
            DispatchQueue.main.async {
                self.spinner.dismiss(animated: true)
            }
        }
    }
}
