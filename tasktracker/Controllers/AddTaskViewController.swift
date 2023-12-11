//
//  AddTaskViewController.swift
//  tasktracker
//
//  Created by Trung on 07/12/2023.
//

import UIKit
import Firebase
import FirebaseDatabase

class AddTaskViewController: UIViewController {
    
    
    @IBOutlet weak var titleField: UITextField!
    
    @IBOutlet weak var noteField: UITextField!
    
    
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            print("No email in User Defaults yet!")
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        let databaseRef = Database.database().reference()
        let userTaskRef = databaseRef.child(safeEmail)
        let taskRef = userTaskRef.child("tasks")
        
        let alertSuccess = UIAlertController(title: "Add Successfully", message: "Your task has been added successfully!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        alertSuccess.addAction(okAction)
        
        let alertFailed = UIAlertController(title: "Failed to add", message: "Your task hasn't been added", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alertFailed.addAction(dismissAction)
        
        taskRef.observeSingleEvent(of: .value) { snapshot in
            var newTaskID = 0
            
            if snapshot.exists() {
                // Child node "tasks" đã tồn tại
                let tasks = snapshot.children.allObjects as! [DataSnapshot]
                let lastTask = tasks.last!
                let lastTaskID = lastTask.key
                
                if let lastTaskIDInt = Int(lastTaskID) {
                    newTaskID = lastTaskIDInt + 1
                }
            }
            
            let newTaskRef = taskRef.child(String(newTaskID))
            
            let newTaskTitle = self.titleField.text ?? ""
            let newTaskNote = self.noteField.text ?? ""
            
            let newTask = [
                "title": newTaskTitle,
                "note": newTaskNote
            ]
            
            newTaskRef.setValue(newTask) { error, _ in
                if let error = error {
                    print("Failed to add new task: \(error)")
                    self.present(alertFailed, animated: true)
                } else {
                    print("Added successfully")
                    self.present(alertSuccess, animated: true)
                }
            }
        }
    }
}
