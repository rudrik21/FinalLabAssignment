//
//  MasterViewController.swift
//  FinalLabAssignment
//
//  Created by Rudrik Panchal on 2020-01-24.
//  Copyright © 2020 Back benchers. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    var tvc: UITableViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tvc = self
        navigationItem.leftBarButtonItem = editButtonItem

        checkEmpty()
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }
    
    func checkEmpty() {
        if fetchedResultsController.fetchedObjects?.count ?? 0 < 10 {
            fetchedResultsController.fetchedObjects?.forEach({ (data) in
                fetchedResultsController.managedObjectContext.delete(data)
            })
            do {
                try fetchedResultsController.managedObjectContext.save()
            } catch  {}
            
            for i in 1...10{
                insertProductData(product: Product(id: Int32(i), name: "Product \(i)", desc: "Description\(i)", price: (Float(i*100))))
            }
            
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    @objc
    func insertNewObject(_ sender: Any) {
        let alert = UIAlertController(title: "Enter new product", message: nil, preferredStyle: .alert)
        
        var edtID: UITextField?
        var edtName: UITextField?
        var edtDesc: UITextField?
        var edtPrice: UITextField?
        
        //  ID
        alert.addTextField { (txt) in
            txt.placeholder = "ID"
            txt.keyboardType = .numberPad
            edtID = txt
        }
        //  NAME
        alert.addTextField { (txt) in
            txt.placeholder = "Name"
            edtName = txt
        }
        //  DESC
        alert.addTextField { (txt) in
            txt.placeholder = "Description"
            edtDesc = txt
        }
        //  PRICE
        alert.addTextField { (txt) in
            txt.placeholder = "Price"
            txt.keyboardType = .decimalPad
            edtPrice = txt
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (act) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (act) in
            let p = Product(id: Int32(edtID!.text ?? "-1") ?? -1, name: edtName!.text ?? "", desc: edtDesc!.text ?? "", price: Float(edtPrice?.text ?? "-1.0") ?? -1.0)
            
            if (p.id != -1 && !p.name.isEmpty && !p.desc.isEmpty && p.price != -1.0){
                self.insertProductData(product: p)
            }else{
                self.insertProductData(product: nil)
            }
            
        }))
        
        present(alert, animated: true, completion: {
        alert.view.superview?.isUserInteractionEnabled = true
        alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertBackgroundTapped)))
        })
    }
    
    @objc func alertBackgroundTapped()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func insertProductData(product: Product?) {
        if product != nil {
            
            let context = self.fetchedResultsController.managedObjectContext
            let newProduct: ProductData = NSEntityDescription.insertNewObject(forEntityName: "ProductData", into: context) as! ProductData
            
            // If appropriate, configure the new managed object.
            newProduct.product = product!
            
            // Save the context.
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }else{
            let errorAlert = UIAlertController(title: "All fields are mendatory!", message: nil, preferredStyle: .actionSheet)
            errorAlert.addAction(UIAlertAction(title: "Dismiss", style: .destructive, handler: { (act) in
                errorAlert.dismiss(animated: true, completion: nil)
            }))
            self.present(errorAlert, animated: true, completion: nil)
        }
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
            let object = fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                print(object.name)
                controller.detailItem = object.product
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                detailViewController = controller
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let productData = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withProduct: productData.product)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
                
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func configureCell(_ cell: UITableViewCell, withProduct product: Product) {
        cell.textLabel!.text = product.name
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController<ProductData> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<ProductData> = NSFetchRequest(entityName: "ProductData")
        
        // Set the batch size to a suitable number.
//        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             // Replace this implementation with code to handle the error appropriately.
             // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             let nserror = error as NSError
             fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController<ProductData>? = nil

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                configureCell(tableView.cellForRow(at: indexPath!)!, withProduct: anObject as! Product)
            case .move:
                configureCell(tableView.cellForRow(at: indexPath!)!, withProduct: anObject as! Product)
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
            default:
                return
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         tableView.reloadData()
     }
     */

}

