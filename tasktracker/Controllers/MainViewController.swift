//
//  ViewController.swift
//  tasktracker
//
//  Created by Nguyễn Thành Trung on 01/11/2023.
//

import UIKit
import FirebaseAuth
import JGProgressHUD
import FirebaseDatabase
import UserNotifications

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let spinner = JGProgressHUD(style: .dark)
    var tasks: [TaskModel] = []
    var logyet: Bool = false
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addTasksButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
        let nib = UINib(nibName: "TasksTableViewCell", bundle: nil)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(nib, forCellReuseIdentifier: TasksTableViewCell.identifier)
        checkPermisson()
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    }
    @objc  private func didPullToRefresh(){
        tasks = []
        observeTasks()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.tableView.refreshControl?.endRefreshing()
        })
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        validateAuth()
        if logyet == true {
            tasks = []
            observeTasks()
        }
        else if logyet == false{
            print("Not loged yet")
        }
        tableView.reloadData()
    }
    private func validateAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil || FirebaseAuth.Auth.auth().currentUser?.isEmailVerified == false {
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "Login")
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav,animated: false)
            logyet = false
        }
        else{
            logyet = true
        }
    }
    
    @IBAction func addTasksButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "AddTask", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AddTask")
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    private func observeTasks() {
        let email = UserDefaults.standard.value(forKey: "email")
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email as! String)
        self.spinner.show(in: view)
        // Create references to Firebase Realtime Database
        let databaseRef = Database.database().reference()
        let tasksRef = databaseRef.child(safeEmail).child("tasks")
        
        // Retrieve all existing tasks once
        tasksRef.observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: [String: String]] else { return }
            for key in value.keys {
                if let taskData = value[key] {
                    let id = key
                    let title = taskData["title"]!
                    let note = taskData["note"]!
                    let task = TaskModel(id: id, title: title, note: note)
                    self.tasks.append(task)
                }
            }
            //   self.tableView.reloadData()
        }
        
        // Observe new tasks being added
        tasksRef.observe(.childAdded) { snapshot in
            guard let value = snapshot.value as? [String: String] else { return }
            let id = snapshot.key
            let title = value["title"]!
            let note = value["note"]!
            let task = TaskModel(id: id, title: title, note: note)
            self.tasks.append(task)
            self.tableView.reloadData()
        }
        DispatchQueue.main.async{
            self.spinner.dismiss(animated: true)
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = tasks[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: TasksTableViewCell.identifier, for: indexPath) as! TasksTableViewCell
        cell.configureTitle(model.title)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyboard = UIStoryboard(name: "TaskDetails", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "TaskDetails") as? TaskDetailsViewController{
            vc.navigationItem.largeTitleDisplayMode = .never
            vc.TaskID = tasks[indexPath.row].id
            vc.taskTitle = tasks[indexPath.row].title
            vc.taskNote = tasks[indexPath.row].note
            navigationController?.pushViewController(vc, animated: true)
        }
        print(tasks[indexPath.row].id)
    }
    private func setupUI(){
        addTasksButton.layer.cornerRadius = 12
    }
    private func checkPermisson(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: {
            success, error in
            if success{
                //self.scheduleTest()
            }
            else if error != nil {
                print("Error Occured")
            }
        })
    }
//    func scheduleTest() {
//        let content = UNMutableNotificationContent()
//        content.title = "Hello bros"
//        content.sound = .default
//        content.body = "Deo hieu sao lai suspend acc dang nhan voi be yeu"
//        let targetDate = Date().addingTimeInterval(5)
//        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: targetDate), repeats: false)
//        
//        let request = UNNotificationRequest(identifier: "damn_id", content: content, trigger: trigger)
//        UNUserNotificationCenter.current().add(request, withCompletionHandler:
//        { error in
//            if error != nil{
//                print("Something bad has happened !")
//            }
//        }
//        )
//    }
}
