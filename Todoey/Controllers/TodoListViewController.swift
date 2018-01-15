//
//  TodoListViewController.swift
//  Todoey
//
//  Created by John Cupak on 1/1/18.
//  Copyright © 2018 John Cupak. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {

    let defaultNavBarHexColor : String = "1D9BF6"
    
    let realm = try! Realm()
    
    var todoItems: Results<Item>?

    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory : Category? {
        didSet {
             loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Set NavBar colors with Category color
    override func viewWillAppear(_ animated: Bool) {
        
        title = selectedCategory?.name // Set todo list title to category name
        
        guard let colorHex = selectedCategory?.color else { fatalError() }

        updateNavBar(withHexCode: colorHex)
    }
    
    // Reset NavBar colors before returning
    override func viewWillDisappear(_ animated: Bool) {
        
        updateNavBar(withHexCode: defaultNavBarHexColor)
    }

    //MARK: - Nav Bar Setup Methods
    
    func updateNavBar(withHexCode colorHexCode: String) {
        
        // Use of guard instead of if to avoid unnecessary nesting
        
       guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist")}
        
        guard let navBarColor = UIColor(hexString: colorHexCode) else { fatalError() }
        
        navBar.barTintColor = navBarColor // Set navbar color to that of category color
        
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true) // Set button color
        
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)] // Set title to contrasting color
        
        searchBar.barTintColor = navBarColor // Set search bar color to that of category color
        

    }
    
    //MARK: - Tableview Datasoure Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row]  {
            
            cell.textLabel?.text = item.title
            
            // Change background darken color percentage based on row and total rows
            // Change text color to a contrasting color based on background color
            // Base the color on the parent selectedCategory color
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage:CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
            cell.accessoryType = item.done ? .checkmark : .none

        } else {
            
            cell.textLabel?.text = "No items added"
        }

        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                // try realm.delete {
                try realm.write {
                    item.done = !item.done // Toggle status
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }

        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new items, \(error)")
                }
            }
            
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField // Save
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(item)
                }
            } catch {
                print("Error deleting item, \(error)")
            }
        }
    }
    
   //MARK: - Model Manipulation Methods
    
    func loadItems() {

        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
    
}

//MARK: - Extend TodoListViewController with search bar methods

extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        // Check for empty search bar
        if searchBar.text?.count == 0 {

            loadItems() // Reload with all items

            // Return control to user and hide keyboard
            DispatchQueue.main.async {
                searchBar.resignFirstResponder() // Run in foreground
            }
        }
    }

}

