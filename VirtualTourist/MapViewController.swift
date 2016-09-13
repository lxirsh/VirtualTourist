//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Lance Hirsch on 7/3/16.
//  Copyright © 2016 Lance Hirsch. All rights reserved.
//
//  I made use of the information on http://juliusdanek.de/blog/coding/2015/07/14/persistent-pins-tutorial/ to help set-up core data with the map view
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
    var destinationCoreDataPin: Pin?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide editing label
        self.label.alpha = 0.0
        
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

    // Add a pin annotaion where the user touches the map and, save it to core data and call a method to get photos based on the location.
    func addAnnotation(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            
            let touchPoint = gestureRecognizer.locationInView(mapView)
            let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            let annotation = Pin(lattitude: newCoordinates.latitude, longitude: newCoordinates.longitude, context: appDelegate.managedObjectContext)
            mapView.addAnnotation(annotation)
            appDelegate.saveContext()
            
            fetchPhotos(annotation)
        }
    }
    
    func fetchAnnotations() -> [Pin]? {
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        do {
            let fetchResults = try sharedContext.executeFetchRequest(fetchRequest) as! [Pin]
//            print("Fetched results for 'Pin': \(fetchResults)")
            return fetchResults
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
            return nil
        }
    }
    
    // Get the Pin associated with a given latitude and longitude
    func getCoreDataPin(latitude: Double, longitude: Double) -> Pin? {
        
        if let savedPins = fetchAnnotations() {
            
            for pin in savedPins {
                if pin.latitude == latitude && pin.longitude == longitude {
//                    print(pin)
                    return pin
                }
            }
        }
        return nil
    }
    
    func fetchPhotos(pin: Pin) {
        
            VTClient.sharedInstance().getPhotosByLocation(pin) { (success, photosURLArray, errorString) in
                if success {
//                    print("photosURLArray: \(photosURLArray)")
                    print("Got a photo array")
                    for photoURL in photosURLArray! {
//                        print("getting an image...\(photoURL)")
                        
                        // First creat a Photo entity without an image
                        var imageData: NSData?
                        imageData = nil
                        self.sharedContext.performBlockAndWait({
                            let photo = Photo(image: imageData, context: self.sharedContext)
                            photo.pin = pin
                            self.appDelegate.saveContext()
                        })
                        
                    }
                    
                    self.setImageForPhotos(pin, photosURLArray: photosURLArray!)
                    
                } else {
                    print(errorString)
                }
        }
        
        
    }
    
    func setImageForPhotos(pin: Pin, photosURLArray: [String]) {
        
        var localPhotosURLArray = photosURLArray
        
        // Set the image for each photo of the pin
        self.sharedContext.performBlock({
            
            for photo in pin.photos! {
                
                let photoURL = localPhotosURLArray.popLast()
                self.getImageForPhoto(photoURL!, photo: photo as! Photo, pin: pin)
                
            }
        })
    }
    
    func getImageForPhoto(photoURL: String, photo: Photo, pin: Pin) {
        
        VTClient.sharedInstance().getImageForURL(photoURL, completionHandler: { (success, imageData, error) in
            
            if success {
                // update photo and save
                self.sharedContext.performBlock({
                    photo.image = imageData
                    print("got photo")
                    photo.pin = pin
                    self.appDelegate.saveContext()

                })
            } else {
                print("error: \(error)")
            }
        })
    }
    
    @IBAction func edit(sender: UIBarButtonItem) {
        
        if editButton.title == "Edit" {
            self.label.alpha = 1.0
            editButton.title = "Done"

        } else {
            self.label.alpha = 0.0
            editButton.title = "Edit"
        }
    }
    
    // MARK: Map view delegates
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        annotationView.canShowCallout = false
        
        return annotationView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        // Move to the image vc for the selected pin
        if self.editButton.title == "Edit" {
            let pin = view.annotation
            destinationLatitude = pin?.coordinate.latitude
            destinationLongitude = pin?.coordinate.longitude
            
            self.performSegueWithIdentifier("showImages", sender: self)
            
        // Remove the selected pin
        } else {
            let pin = view.annotation as! Pin
            mapView.removeAnnotation(pin)
            
            sharedContext.performBlockAndWait({ 
                self.sharedContext.deleteObject(pin)
                self.appDelegate.saveContext()
            })
        }
        
        
        
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showImages" {
            if let destination = segue.destinationViewController as? VTImagesViewController {
                
                // TODO: Pass the Pin stored in core data
                if let destinationPin = getCoreDataPin(destinationLatitude!, longitude: destinationLongitude!) {
                    destinationCoreDataPin = destinationPin
                }

                destination.latitude = destinationLatitude
                destination.longitude = destinationLongitude
                destination.sentPin = destinationCoreDataPin
            }
            
        }
    }
    
}

