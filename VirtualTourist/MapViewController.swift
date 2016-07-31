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

class MapViewController: UIViewController, UIGestureRecognizerDelegate, MKMapViewDelegate {
    
    var pin: Pin?
    var appDelegate: AppDelegate!
    var sharedContext: NSManagedObjectContext!
    var destinationLatitude: Double?
    var destinationLongitude: Double?
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
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
            
            // Set the coordinates for the client. Needed in order to get photos
            VTClient.sharedInstance().pinLatitude = newCoordinates.latitude
            VTClient.sharedInstance().pinLongitude = newCoordinates.longitude
            fetchPhotos(annotation)
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
    
    func fetchPhotos(pin: Pin) {
        
        var numberOfPhotosToFetch = 21
        
        repeat {
            
            VTClient.sharedInstance().getPhotos { (imageData, success, error) in
                if success {
                    let photo = Photo(image: imageData!, context: self.appDelegate.managedObjectContext)
                    photo.pin = pin
                    self.appDelegate.saveContext()
                    print(photo)
                }
            }
            
            numberOfPhotosToFetch -= 1
        } while numberOfPhotosToFetch > 0
        

    }
    
    // MARK: Map view delegates
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        annotationView.canShowCallout = false
        
        return annotationView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        let pin = view.annotation
        destinationLatitude = pin?.coordinate.latitude
        destinationLongitude = pin?.coordinate.longitude
        
        VTClient.sharedInstance().pinLatitude = destinationLatitude
        VTClient.sharedInstance().pinLongitude = destinationLongitude
        
        self.performSegueWithIdentifier("showImages", sender: self)
        
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showImages" {
            if let destination = segue.destinationViewController as? VTImagesViewController {
                destination.latitude = destinationLatitude
                destination.longitude = destinationLongitude
            }
            
        }
    }
    
}

