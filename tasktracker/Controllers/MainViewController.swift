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
    
    var tasks: [String] = []
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
            
            // Tạo một tham chiếu đến Firebase Realtime Database
            let databaseRef = Database.database().reference()
            
            // Tạo một child node mới tại đường dẫn "/(safeEmail)/tasks"
            let tasksRef = databaseRef.child(safeEmail).child("tasks")
            
            // Sử dụng observe(_:with:) để lắng nghe sự thay đổi trong mảng "tasks"
            tasksRef.observe(.value) { [weak self] snapshot in
                guard let self = self else {
                    return
                }
                
                // Đặt mảng "Tasks" về trạng thái ban đầu (rỗng)
                self.tasks = []
                
                // Kiểm tra xem snapshot có tồn tại và lấy danh sách các phần tử nếu có
                if snapshot.exists() {
                    let tasksSnapshot = snapshot.children.allObjects as! [DataSnapshot]
                    for taskSnapshot in tasksSnapshot {
                        let task = taskSnapshot.value as! String
                        self.tasks.append(task)
                        print(task)
                    }
                }
                
                // Reload data trong tableView để hiển thị danh sách các tasks
                self.tableView.reloadData()
            }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = tasks[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: TasksTableViewCell.identifier, for: indexPath) as! TasksTableViewCell
        cell.configureTitle(model)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    private func setupUI(){
        addTasksButton.layer.cornerRadius = 12
    }
}

