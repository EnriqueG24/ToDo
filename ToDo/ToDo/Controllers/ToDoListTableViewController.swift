//
//  ToDoListTableViewController.swift
//  ToDo
//
//  Created by Enrique Gongora on 9/13/20.
//  Copyright © 2020 Enrique Gongora. All rights reserved.
//

import UIKit
import CoreData

class ToDoListTableViewController: UITableViewController {
    
    // MARK: - Properties
    var itemArray = [Item]()
    var selectedCategory: Category? {
        didSet {
            loadItem()
        }
    }
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - IBActions
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        // The alert controller that will be presented to the user so they can add a new item
        let alert = UIAlertController(title: "Add New ToDo Item", message: nil, preferredStyle: .alert)
        
        // Textfield so the user has something to write their input to
        alert.addTextField()
        
        // We'll use "weak self, weak alert" so that the reference count will be automatically set to nil when the reference object gets deallocated.
        let action = UIAlertAction(title: "Add Item", style: .default) { [weak self, weak alert] _ in
            
            
            let newItem = Item(context: self!.context)
            newItem.title = alert?.textFields?[0].text
            newItem.done = false
            newItem.parentCategory = self?.selectedCategory
            
            // Append it to our array
            self?.itemArray.append(newItem)
            
            // Reload the table view so it displays the users input
            self?.tableView.reloadData()
            
            self?.saveItem()
        }
        
        // Add the UIAlertAction to the UIAlertController
        alert.addAction(action)
        
        // Present the UIAlertController to the user
        present(alert, animated: true)
    }
    
    // MARK: - CRUD Methods
    func saveItem() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
        tableView.reloadData()
    }
    
    func loadItem(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context: \(error)")
        }
        tableView.reloadData()
    }
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = itemArray[indexPath.row].title
        
        // Ternary Operator to add or remove the checkmark
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // If the cell has a checkmark, remove it when selected. It if doesn't, then add one.
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItem()
        
        // This will remove the highlight after the user has tapped on a cell
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - SearchBar Extension
extension ToDoListTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        // Our predicate will look in our item array, and locate the "title" that CONTAINS the specified text we inputed. Then add our query to our request
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        // Sort using the key "title" in alphabetical order. Then add our sort descriptor to our request
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItem(with: request, predicate: predicate)
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
