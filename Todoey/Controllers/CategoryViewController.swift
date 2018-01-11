//
//  CategoryViewController.swift
//  Todoey
//
//  Created by John Cupak on 1/8/18.
//  Copyright © 2018 John Cupak. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    // Called categories in solution
    var categoryArray = [Category]() // Initialize to empty array
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategories() // Use default query

    }

    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Called "CategoryCell" in solution
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryItemCell", for: indexPath)
        
        cell.textLabel?.text = categoryArray[indexPath.row].name
        
        return cell
    }
    
    //MARK: - Data Manipulation Methods
    
    func saveCategories() {
        
        do {
            try context.save()
        } catch {
            print("Error saving category context \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    // Pass in external (with) fetch request or use default
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest() ) {
        
        do {
            // Specified as categories in solution
            categoryArray = try context.fetch(request)
        } catch {
            print("Error fetching category data from context \(error)")
        }
        
        tableView.reloadData()
    }

    //MARK: - Add New Categories

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default)  {(action) in
            
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            
            // Specified as categories in solution
            self.categoryArray.append(newCategory)
            
            self.saveCategories()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add a new category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
    

}
