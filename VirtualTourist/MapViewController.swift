//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Lance Hirsch on 7/3/16.
//  Copyright © 2016 Lance Hirsch. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var pin: Pin?
    var appDelegate: AppDelegate!
    var sharedContext: NSManagedObjectContext!
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        sharedContext = appDelegate.managedObjectContext
        
        // Add a long touch gesture recognizer for the user to place pins on the map.
        var gestureRecognizer = UILongPressGestureRecognizer(target: self, action: "addAnnotation:")
        gestureRecognizer.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(gestureRecognizer)
        
//        // Get the stack
//        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        let stack = delegate.stack
//
        // Create a fetchrequest
//        let fr = NSFetchRequest(entityName: "Pin")
//        fr.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true),
//                              NSSortDescriptor(key: "creationDate", ascending: false)]
        
        if let savedAnnotations = fetchAnnotations() {
            mapView.addAnnotations(savedAnnotations)
        }
    }

    // Add a pin annotaion where the user touches the mao.
    func addAnnotation(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            
            let touchPoint = gestureRecognizer.locationInView(mapView)
            let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            let annotation = Pin(lattitude: newCoordinates.latitude, longitude: newCoordinates.longitude, context: appDelegate.managedObjectContext)
            mapView.addAnnotation(annotation)
            appDelegate.saveContext()
        }
    }
    
    func fetchAnnotations() -> [Pin]? {
//        let error: NSErrorPointer = nil
        let fetchRequest = NSFetchRequest(entityName: "Pin")
//        let results = sharedContext.executeFetchRequest(fetchRequest)
        do {
            let fetchResults = try sharedContext.executeFetchRequest(fetchRequest) as! [Pin]
            return fetchResults
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
            return nil
        }
    }
    
}

