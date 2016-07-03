//
//  Pin.swift
//  VirtualTourist
//
//  Created by Lance Hirsch on 7/3/16.
//  Copyright © 2016 Lance Hirsch. All rights reserved.
//

import Foundation
import CoreData


class Pin: NSManagedObject {

    convenience init(lattitude: Double, longitude: Double, context: NSManagedObjectContext) {
        
        if let ent = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context) {
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.lattitude = lattitude
            self.longitude = longitude
        } else {
            fatalError("Unable to find Entity name")
        }
    }
}
