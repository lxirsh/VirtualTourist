//
//  Photo.swift
//  VirtualTourist
//
//  Created by Lance Hirsch on 7/3/16.
//  Copyright © 2016 Lance Hirsch. All rights reserved.
//

import Foundation
import CoreData


class Photo: NSManagedObject {

    convenience init(image: NSData?, context: NSManagedObjectContext) {
        
        if let ent = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context) {
            
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.image = image
        } else {
            fatalError("Unable to find Entity name!")
        }
    }

}
