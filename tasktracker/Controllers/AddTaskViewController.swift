//
//  AddTaskViewController.swift
//  tasktracker
//
//  Created by Trung on 07/12/2023.
//

import UIKit
import Firebase
import FirebaseDatabase
import UserNotifications
import DropDown
class AddTaskViewController: UIViewController {
    
    
    @IBOutlet weak var titleField: UITextField!
    
    @IBOutlet weak var noteField: UITextField!
    
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var priorityMenu: UILabel!
    
    public var newTaskID = 0
    public var newTaskPriority : String = "Default"
    let dropDown : DropDown = {
       let dropDown = DropDown()
        dropDown.dataSource = [
            "High",
            "Middle",
            "Low"
        ]
        return dropDown
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dropDown.anchorView = priorityMenu
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapMenu))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        priorityMenu.addGestureRecognizer(gesture)
        
        dropDown.selectionAction = {
            index, title in
            self.newTaskPriority = title
            self.priorityMenu.text = title
        }
    }
    @objc func didTapMenu(){
        dropDown.show()
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
        let targetDate = datePicker.date
        let newTaskTitle = self.titleField.text ?? ""
        let newTaskNote = self.noteField.text ?? ""
        let alertSuccess = UIAlertController(title: "Add Successfully", message: "Your task has been added successfully!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        alertSuccess.addAction(okAction)
        
        let alertFailed = UIAlertController(title: "Failed to add", message: "Your task hasn't been added", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alertFailed.addAction(dismissAction)
        
        taskRef.observeSingleEvent(of: .value) { snapshot in
            
            
            if snapshot.exists() {
                // Child node "tasks" đã tồn tại
                let tasks = snapshot.children.allObjects as! [DataSnapshot]
                let lastTask = tasks.last!
                let lastTaskID = lastTask.key

                if let lastTaskIDInt = Int(lastTaskID) {
                    self.newTaskID = lastTaskIDInt + 1
                    
                }
            }
            
            let newTaskRef = taskRef.child(String(self.newTaskID))

            
            let newTask = [
                "title": newTaskTitle,
                "note": newTaskNote,
                "date": self.dateFormatter(datePicker: self.datePicker),
                "priority": self.newTaskPriority
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
            self.scheduleNoti(title: newTaskTitle, body: newTaskNote, targetDate: targetDate, id: String(self.newTaskID))
        }
    }
    private func checkPermisson(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: {
            success, error in
            if success{
                
            }
            else if error != nil {
                print("Error Occured")
            }
        })
    }
    func scheduleNoti(title: String, body: String, targetDate: Date, id: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.sound = .default
        content.body = body
        let targetDate = targetDate
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: targetDate), repeats: false)
        
        let request = UNNotificationRequest(identifier: id , content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler:
        { error in
            if error != nil{
                print("Something bad has happened !")
            }
        }
        )
        print(id)
    }
    func dateFormatter(datePicker: UIDatePicker) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: datePicker.date)
        return dateString
    }
}
