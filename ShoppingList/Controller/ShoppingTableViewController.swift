//
//  ShoppingTableViewController.swift
//  ShoppingList
//
//  Created by iMac on 2022-08-17.
//

import UIKit
import CoreData

class ShoppingTableViewController: UITableViewController
{
    var shopping = [Shopping]()
    var managedObjectContext: NSManagedObjectContext?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = appDelegate.persistentContainer.viewContext
        
        loadData()
    }

    func loadData()
    {
        let request: NSFetchRequest<Shopping> = Shopping.fetchRequest()
        do
        {
            request.sortDescriptors = [NSSortDescriptor(key: "rowOrder", ascending: true)]
            
            if let result = try managedObjectContext?.fetch(request)
            {
                shopping = result
                tableView.reloadData()
            }
        }
        catch
        {
            print("Error in saving core data items!")
        }
    }
    
    func saveData()
    {
        do
        {
            try managedObjectContext?.save()
        }
        catch
        {
            print("Error in loading core data items!")
        }
        loadData()
    }
    
    func deleteAllData(entity: String)
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        
        do
        {
            let results = try managedObjectContext?.fetch(fetchRequest)
            for object in results ?? []
            {
                guard let objectData = object as? NSManagedObject else {continue}
                //dataController.viewContext.delete(objectData)
                //tableView.viewContext.delete()
                managedObjectContext?.delete(objectData)
            }
        }
        catch let error
        {
            print("Detele all data in \(entity) error :", error)
        }
    }
    
    //action func delete all items
    @IBAction func deleteAllItems(_ sender: Any)
    {
        let actionSheetController = UIAlertController(title: "Warning!", message: "Do you really want to remove all items?", preferredStyle: .actionSheet)
        
        actionSheetController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            self.deleteAllData(entity: "Shopping")
            self.loadData()
        }))
        actionSheetController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheetController, animated: true, completion: nil)
    }
    
    @IBAction func addNewItem(_ sender: Any)
    {
        let alertController = UIAlertController(title: "Shopping Item", message: "What do you want to add?", preferredStyle: .alert)
        
        alertController.addTextField
        { textField in
            textField.placeholder = "Enter the name of your item"
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .sentences
        }
                
        alertController.addTextField
        { textField in
            textField.placeholder = "Enter the count of your items"
            textField.autocorrectionType = .no
            textField.keyboardType = .numberPad
        }
        
        let addActionButton = UIAlertAction(title: "Add", style: .default)
        { action in
            let textField = alertController.textFields?.first
            let textField2 = alertController.textFields?[1]
            
            if let entity = NSEntityDescription.entity(forEntityName: "Shopping", in: self.managedObjectContext!)
            {
                let shop = NSManagedObject(entity: entity, insertInto: self.managedObjectContext)
                shop.setValue(textField?.text, forKey: "item")
                shop.setValue(Int32((textField2?.text)!), forKey: "count")
            }
            
            self.saveData()
        }//add
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alertController.addAction(addActionButton)
        alertController.addAction(cancelButton)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // #warning Incomplete implementation, return the number of rows
        return shopping.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shoppingCell", for: indexPath)

       // cell.textLabel?.text = shopping[indexPath.row]
        let shop = shopping[indexPath.row]
        cell.textLabel?.text = "Item: \(shop.value(forKey: "item") ?? "")"

        cell.detailTextLabel?.text = "Count: \(shop.value(forKey: "count") ?? "")"
        cell.accessoryType = shop.completed ? .checkmark : .none
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 80
    }
    
//MARK: - table view delegate
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            // Delete the row from the data source
            managedObjectContext?.delete(shopping[indexPath.row])
        }
        saveData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        shopping[indexPath.row].completed = !shopping[indexPath.row].completed
        saveData()
    }
    
    //tableView.dragInteractionEnabled = true
    //tableView.dragDelegate = self
    //tableView.dropDelegate = self
    
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
        let itemToMove = shopping[sourceIndexPath.row]
        
        shopping.remove(at: sourceIndexPath.row)
        shopping.insert(itemToMove, at: destinationIndexPath.row)
        
        for(newValue, item) in shopping.enumerated()
        {
            item.setValue(newValue, forKey: "rowOrder")
        }
        
        tableView.reloadData()
        saveData()
    }
     
        
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension ShoppingTableViewController: UITableViewDragDelegate
{
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem]
    {
        return [UIDragItem(itemProvider: NSItemProvider())]
    }
}

extension ShoppingTableViewController: UITableViewDropDelegate
{
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal
    {
        if session.localDragSession != nil { // Drag originated from the same app.
            return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }

        return UITableViewDropProposal(operation: .cancel, intent: .unspecified)
    }

    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator)
    {
    }
}
