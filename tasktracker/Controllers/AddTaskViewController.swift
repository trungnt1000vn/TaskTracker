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
    
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let email = UserDefaults.standard.value(forKey: "email") else {
            print("No email in User Default yet !!!!")
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email as! String)
        let databaseRef = Database.database().reference()
        let userTaskRef = databaseRef.child("\(safeEmail)")
        let taskRef = userTaskRef.child("tasks")
        let alertSuccess = UIAlertController(title: "Add Successfully", message: "Your task has been added succesfully !", preferredStyle: .alert)
        let okaction = UIAlertAction(title: "OK", style: .default, handler: {_ in 
            self.navigationController?.popViewController(animated: true)
        })
        let okefailaction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alertSuccess.addAction(okaction)
        let alertFailed = UIAlertController(title: "Failed to add", message: "Your task hasn't been added", preferredStyle: .alert )
        alertFailed.addAction(okefailaction)
        taskRef.observeSingleEvent(of: .value) { snapshot in
            var newTaskID: Int
            if snapshot.exists() {
                // Child node "tasks" đã tồn tại
                // Bạn có thể thực hiện các hành động phù hợp ở đây
                let tasks = snapshot.children.allObjects as! [DataSnapshot]
                let lastTask = tasks.last!
                let lastTaskID = lastTask.key
                newTaskID = Int(lastTaskID)! + 1
                let newTaskRef = taskRef.child(String(newTaskID))
                
                let newTask: String = self.titleField.text ?? ""
                
                newTaskRef.setValue(newTask){ error, _ in
                    if let error = error {
                        print("Failed to add new tasks")
                        self.present(alertFailed, animated: true)
                    }
                    else{
                        print("Add succesfully")
                        self.present(alertSuccess, animated: true)
                        
                    }
                }
                
            } else {
                // Child node "tasks" chưa tồn tại
                // Bạn có thể tạo một mảng "tasks" mới và lưu nó vào Firebase Realtime Database
                let firstTask: String = self.titleField.text ?? ""
                let newTasks: [String] = [firstTask]
                
                taskRef.setValue(newTasks) { error, _ in
                    if let error = error {
                        // Nếu có lỗi xảy ra, bạn có thể hiển thị một thông báo lỗi cho người dùng
                        // Ví dụ: showAlert(message: "Failed to create tasks. Error: \(error.localizedDescription)")
                    } else {
                        // Nếu không có lỗi, bạn có thể hiển thị một thông báo thành công hoặc thực hiện bất kỳ xử lý nào khác sau khi tạo thành công
                        // Ví dụ: showAlert(message: "Tasks created successfully!")
                    }
                }
            }
        }
        
        
    }
}
