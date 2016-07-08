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
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.addAnnotation(_:)))
        gestureRecognizer.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(gestureRecognizer)
        
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
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        do {
            let fetchResults = try sharedContext.executeFetchRequest(fetchRequest) as! [Pin]
            return fetchResults
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
            return nil
        }
    }
    
}

