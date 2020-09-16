//
//  CategoryTableViewController.swift
//  ToDo
//
//  Created by Enrique Gongora on 9/15/20.
//  Copyright © 2020 Enrique Gongora. All rights reserved.
//

import UIKit
import CoreData

class CategoryTableViewController: UITableViewController {
    
    // MARK: - Properties
    var categoryArray = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    // MARK: - IBActions
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add new Category", message: nil, preferredStyle: .alert)
        
        alert.addTextField()
        
        let action = UIAlertAction(title: "Add Category", style: .default) { [weak self, weak alert] _ in
            let newCategory = Category(context: self!.context)
            newCategory.name = alert?.textFields?[0].text
            
            self?.categoryArray.append(newCategory)
            self?.tableView.reloadData()
            self?.saveData()
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    // MARK: - CRUD Methods
    func saveData() {
        do {
            try context.save()
        } catch {
            print("Error saving category data: \(error)")
        }
        tableView.reloadData()
    }
    
    func loadData(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            categoryArray = try context.fetch(request)
        } catch {
            print("Error fetching category data from context: \(error)")
        }
        tableView.reloadData()
    }
    
    // MARK: - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categoryArray[indexPath.row].name
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListTableViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
}
