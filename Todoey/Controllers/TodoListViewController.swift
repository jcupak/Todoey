//
//  TodoListViewController.swift
//  Todoey
//
//  Created by John Cupak on 1/1/18.
//  Copyright © 2018 John Cupak. All rights reserved.
//

import UIKit

// was ViewController : UIViewController
class TodoListViewController: UITableViewController {

    // var itemArray = ["Find Mike", "Buy Eggs", "Destory Demorgorgon"]
    var itemArray = [Item]() // Array of items
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    // let defaults = UserDefaults.standard // Save to plist file
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(dataFilePath!)
        
     // Commented out when using loadItems
     //   let newItem0 = Item()
     //   newItem0.title = "Find Mike"
     //   newItem.done = false
     //   itemArray.append(newItem0)
        
    //  let newItem1 = Item()
    //    newItem1.title = "Buy Eggos"
    //    newItem1.done = false
    //    itemArray.append(newItem1)
        
    //    let newItem2 = Item()
    //    newItem2.title = "Destroy Demogorgon"
    //    newItem2.done = false
    //   itemArray.append(newItem2)
        
// Commented out when using Item array
//    if let items = defaults.array(forKey: "TodoListArray") as? [String] {
//         itemArray = items
//     }

// Commented out when using encodable items
//      if let items = defaults.array(forKey: "TodoListArray") as? [Item] {
//          itemArray = items
//      }
        
        loadItems() // Called to reload itemsArray from encoded plist file
    }

    //MARK - Tableview Datasoure Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row] // Alias shortcut for code below
        
        cell.textLabel?.text = item.title   // Get class property
        
        // if item.done == true {
        //    cell.accessoryType = .checkmark // Turn on checkmark
        // } else {
        //     cell.accessoryType = .none      // Turn off checkmark
        // }
 
        // Ternary operator ==>
        // value = condition ? valueIfTrue : valueIfFalse
        // Replaces 5 lines above with 1 line below
        cell.accessoryType = item.done ? .checkmark : .none

        return cell
    }
    
    //MARK - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print(indexPath.row)            // Which row number
        print(itemArray[indexPath.row]) // Show cell contents
        
        // Toggle Item done property
        //if itemArray[indexPath.row].done == false {
        //    itemArray[indexPath.row].done = true
        //} else {
        //    itemArray[indexPath.row].done = false
        //}
        
        // Simpler code of above to toggle done property
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        
        // tableView.reloadData() 
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todo Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default)  {(action) in
            
            // What will happen after user clicks the "Add Item" button on the UIAlert
            // print(textField.text) // Debug
            
            // self.itemArray.append(textField.text!)
            let newItem = Item()
            newItem.title = textField.text!
            
            self.itemArray.append(newItem)
            
            self.saveItems()
          }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField // Save
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK - Model Manipulation Methods
    
    // Save encoded itemArray to local pcode file
    // Requires Item be Encoded (or Coded, if Decoded)
    // Called from addButtonPressed and didSelectRowAt
    func saveItems() {
        
        // Encode itemArray into a plist
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        } catch {
            print("Error encoding item array, \(error)")
        } // end do-catch
        
        tableView.reloadData()

    }
    
    // Restore itemArray from encoded local pcode file
    // Requires Item be Decoded (or Coded, if Encoded)
    // Called by viewDidLoad
    func loadItems() {
        
        if let data = try? Data(contentsOf: dataFilePath!) {
            
            let decoder = PropertyListDecoder()
            
            do {
                itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("Error decoding item array, \(error)")
            } // end do-catch
        } // end if
    } // end loadItems
    
}

