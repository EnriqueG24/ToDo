//
//  ToDoListTableViewController.swift
//  ToDo
//
//  Created by Enrique Gongora on 9/13/20.
//  Copyright © 2020 Enrique Gongora. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListTableViewController: SwipeTableViewController {
    
    // MARK: - Properties
    var todoItems: Results<Item>?
    let realm = try! Realm()
    var selectedCategory: Category? {
        didSet {
            loadItem()
        }
    }
    // MARK: - IBOutlets
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.separatorStyle = .none
    }
    
    // MARK: - IBActions
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        // The alert controller that will be presented to the user so they can add a new item
        let alert = UIAlertController(title: "Add New ToDo Item", message: nil, preferredStyle: .alert)
        
        // Textfield so the user has something to write their input to
        alert.addTextField()
        
        // We'll use "weak self, weak alert" so that the reference count will be automatically set to nil when the reference object gets deallocated.
        let action = UIAlertAction(title: "Add Item", style: .default) { [weak self, weak alert] _ in
            
            if let currentCategory = self?.selectedCategory {
                do {
                    try self?.realm.write {
                        let newItem = Item()
                        newItem.title = (alert?.textFields?[0].text)!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error savingn new items: \(error)")
                }
            }
            
            // Reload the table view so it displays the users input
            self?.tableView.reloadData()
        }
        
        // Add the UIAlertAction to the UIAlertController
        alert.addAction(action)
        
        // Present the UIAlertController to the user
        present(alert, animated: true)
    }
    
    // MARK: - CRUD Methods
    
    func loadItem() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write{
                    realm.delete(item)
                }
            } catch {
                print("Error deleting item, \(error)")
            }
        }
    }
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            if let color = FlatSkyBlue().darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status: \(error)")
            }
        }
        
        tableView.reloadData()
        
        // This will remove the highlight after the user has tapped on a cell
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - SearchBar Extension
extension ToDoListTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // This will query our items using the given predicates and sort it by the "date created" in ascending order
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }
    
    // This gets triggered when the text inside the search bar has changed
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItem()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
