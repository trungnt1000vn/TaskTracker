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
import DropDown

class TaskDetailsViewController: UIViewController, UINavigationControllerDelegate {
    private let spinner = JGProgressHUD(style: .dark)
    
    @IBOutlet weak var titleField: UITextField!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var noteField: UITextField!
    
    @IBOutlet weak var noteLabel: UILabel!
    
    @IBOutlet weak var updateButton: UIButton!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var priorityMenu: UILabel!
    public var TaskID : String = ""
    public var taskTitle: String = ""
    public var taskNote: String = ""
    public var taskPriority: String = ""
    private var isUpdating: Bool = false
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
        setUpUI()
        observeData(taskID: TaskID)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapMenu))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        priorityMenu.addGestureRecognizer(gesture)
        
        dropDown.selectionAction = {
            index, title in
            self.taskPriority = title
            self.priorityMenu.text = title
        }
    }
    @objc func didTapMenu(){
        dropDown.show()
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
        deleteButton.layer.cornerRadius = 12
        
    }
    
    
    @IBAction func updateButtonTapped(_ sender: Any) {
        
        if isUpdating == false {
            noteField.isUserInteractionEnabled = true
            titleField.isUserInteractionEnabled = true
            datePicker.isUserInteractionEnabled = true
            priorityMenu.isUserInteractionEnabled = true
            isUpdating = true
            updateButton.setTitle("Save", for: .normal)
        }
        else if isUpdating == true {
            let alertController = UIAlertController(title: "Saving", message: "Are you sure want to save these changes ?", preferredStyle: .alert)
            let alertOK = UIAlertAction(title: "Yes", style: .default, handler: {_ in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let date = dateFormatter.string(from: self.datePicker.date)
                self.updateTask(taskID: self.TaskID, title: self.titleField.text ?? "", note: self.noteField.text ?? "", date: date, priority: self.taskPriority)
                self.updateScheduleNoti(title: self.titleField.text ?? "", body: self.noteField.text ?? "", targetDate: self.datePicker.date, id: self.TaskID)
                self.updateButton.setTitle("Update", for: .normal)
                self.noteField.isUserInteractionEnabled = false
                self.titleField.isUserInteractionEnabled = false
                self.priorityMenu.isUserInteractionEnabled = false
                self.isUpdating = false
            })
            let alertCancel = UIAlertAction(title: "No", style: .destructive, handler: nil)
            alertController.addAction(alertOK)
            alertController.addAction(alertCancel)
            present(alertController, animated: true)
        }
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Deleting", message: "Are you sure to delete this task ?", preferredStyle: .actionSheet)
        let alertOK = UIAlertAction(title: "Yes", style: .destructive, handler:{_ in 
            self.deleteTask(taskID: self.TaskID)
            self.unScheduleNoti(id: self.TaskID)
            self.navigationController?.popViewController(animated: true)
        } )
        let alertCancel = UIAlertAction(title: "No", style: .default, handler: nil)
        alertController.addAction(alertOK)
        alertController.addAction(alertCancel)
        present(alertController, animated: true)
    }
    private func updateTask(taskID: String, title: String, note: String, date: String, priority: String, kind : String){
        let email = UserDefaults.standard.value(forKey: "email")
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email as! String)
        
        self.spinner.show(in: view)
        let databaseRef = Database.database().reference()
        let taskRef = databaseRef.child("\(safeEmail)/tasks")
        taskRef.child(taskID).setValue([
            "title": title,
            "note": note,
            "date": date,
            "priority": priority,
            "kind": kind
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
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            if let date = dateFormatter.date(from: value["date"]!) {
                self.datePicker.date = date
            }
            self.titleField.text = value["title"]!
            self.noteField.text = value["note"]!
            self.priorityMenu.text = value["priority"]!
            DispatchQueue.main.async {
                self.spinner.dismiss(animated: true)
            }
        }
    }
    private func deleteTask(taskID: String){
        let email = UserDefaults.standard.value(forKey: "email")
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email as! String)
        
        let databaseRef = Database.database().reference()
        let taskRef = databaseRef.child("\(safeEmail)/tasks").child(taskID)
        taskRef.removeValue()
    }
}
extension TaskDetailsViewController{
    func updateScheduleNoti(title: String, body: String, targetDate: Date, id: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.sound = .default
        content.body = body
        let targetDate = targetDate
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: targetDate), repeats: false)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [id])
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
    func unScheduleNoti(id: String){
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [id])
    }
}
