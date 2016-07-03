//
//  Pin+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Lance Hirsch on 7/3/16.
//  Copyright © 2016 Lance Hirsch. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Pin {

    @NSManaged var lattitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var photos: NSSet?

}
