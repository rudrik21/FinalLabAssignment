//
//  ProductData.swift
//  FinalLabAssignment
//
//  Created by Rudrik Panchal on 2020-01-24.
//  Copyright © 2020 Back benchers. All rights reserved.
//

import Foundation
import CoreData

@objc(ProductData)
class ProductData: NSManagedObject {
    @NSManaged var id: Int32
    @NSManaged var name: String
    @NSManaged var desc: String
    @NSManaged var price: Float
    
    var product: Product{
        get{
            Product(id: self.id, name: self.name, desc: self.desc, price: self.price)
        }
        set{
            self.id = newValue.id
            self.name = newValue.name
            self.desc = newValue.desc
            self.price = newValue.price
        }
    }
}
