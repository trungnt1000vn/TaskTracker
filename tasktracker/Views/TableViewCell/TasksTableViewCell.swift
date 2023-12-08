//
//  TasksTableViewCell.swift
//  tasktracker
//
//  Created by Trung on 07/12/2023.
//

import UIKit

class TasksTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    static let identifier = "TasksTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        print(titleLabel.text)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    //    public func configure(model: TaskModel){
    //        self.titleLabel.text = model.title
    //    }
    public func configureTitle(_ title: String) {
        titleLabel?.text = title
    }
}
