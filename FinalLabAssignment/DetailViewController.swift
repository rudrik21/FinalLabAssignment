//
//  DetailViewController.swift
//  FinalLabAssignment
//
//  Created by Rudrik Panchal on 2020-01-24.
//  Copyright © 2020 Back benchers. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {

    @IBOutlet weak var lblID: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    func configureView() {
        // Update the user interface for the detail item.
        if let p = detailItem {
            if let lbl = lblID {
                lbl.text = String(p.id)
            }
            if let lbl = lblName {
                lbl.text = p.name
            }
            if let lbl = lblDesc {
                lbl.text = p.desc
            }
            if let lbl = lblPrice {
                lbl.text = String(p.price)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if detailItem == nil {
            let delegate = UIApplication.shared.delegate as? AppDelegate
            let context = delegate?.persistentContainer.viewContext
            let req: NSFetchRequest<ProductData> = NSFetchRequest(entityName: "ProductData")
            do {
                let res = try context?.fetch(req)
                if !res!.isEmpty {
                    let product = (res!).first?.product
                    detailItem = product
                }
            } catch  {
                print(error)
            }
            
            
        }
        configureView()
    }

    var detailItem: Product? {
        didSet {
            // Update the view.
            configureView()
        }
    }


}

