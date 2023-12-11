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
class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tasks: [TaskModel] = []
    var logyet: Bool = true
    
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
        if logyet == true{
            observeTasks()
        }
        else if logyet == false{
            print("Not loged yet")
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        validateAuth()
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
        logyet = true
    }
    
    @IBAction func addTasksButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "AddTask", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AddTask")
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    private func observeTasks() {
        let email = UserDefaults.standard.value(forKey: "email")
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email as! String)
        
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
            self.tableView.reloadData()
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
        print(tasks[indexPath.row].id)
    }
    private func setupUI(){
        addTasksButton.layer.cornerRadius = 12
    }
}

