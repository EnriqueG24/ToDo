//
//  ToDoListTableViewController.swift
//  ToDo
//
//  Created by Enrique Gongora on 9/13/20.
//  Copyright © 2020 Enrique Gongora. All rights reserved.
//

import UIKit

class ToDoListTableViewController: UITableViewController {
    
    // MARK: - Properties
    // Dummy data - Will be replaced once I get realm up
    var itemArray = ["Find Mike", "Buy Eggos", "Destroy Demogorgon"]
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - IBActions
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        // The alert controller that will be presented to the user so they can add a new item
        let alert = UIAlertController(title: "Add New ToDo Item", message: nil, preferredStyle: .alert)
        
        // Textfield so the user has something to write their input to
        alert.addTextField()
        
        // We'll use "weak self, weak alert" so that the reference count will be automatically set to nil when the reference object gets deallocated.
        let action = UIAlertAction(title: "Add Item", style: .default) { [weak self, weak alert] _ in
            // Store what the user inputed into a new variable
            guard let toDoEntered = alert?.textFields?[0].text else { return }
            
            // Append it to our array
            self?.itemArray.append(toDoEntered)
            
            // Reload the table view so it displays the users input
            self?.tableView.reloadData()
        }
        
        // Add the UIAlertAction to the UIAlertController
        alert.addAction(action)
        
        // Present the UIAlertController to the user
        present(alert, animated: true)
    }
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // This will check if the cell that was tapped has a checkmark. If it doesn't, add one. If it does, remove it.
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        // This will remove the highlight after the user has tapped on a cell
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
