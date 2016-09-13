//
//  VTImagesViewController.swift
//  VirtualTourist
//
//  Created by Lance Hirsch on 7/14/16.
//  Copyright © 2016 Lance Hirsch. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class VTImagesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bottomButton: UIBarButtonItem!
    
    // MARK: - Properties
    var appDelegate: AppDelegate!
    var sharedContext: NSManagedObjectContext!
    var latitude: Double!
    var longitude: Double!
    var sentPin: Pin!
    
    var selectedIndexes = [NSIndexPath]()
    
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    let reuseIdentifier = "cell"
    
    var items = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48"]


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bottomButton.title = "New Collection"
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        sharedContext = appDelegate.managedObjectContext
        
        // Configure the layout and set three images per row for portrait and five for landscape
        let space: CGFloat = 1.5
        let dimension = self.view.frame.width <= self.view.frame.height ? (self.view.frame.width - (2 * space)) / 3.0 : (self.view.frame.width - (2 * space)) / 5.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSizeMake(dimension, dimension)
        
        // Start the fetched results controller
        var error: NSError?
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
        
        if let error = error {
            print("Error performing initial fetch: \(error)")
        }
        
        print(sentPin)
        showLocation()
        showPhotos()
    }
    
    func showPhotos() {
        
       let pin = sentPin
        for photo in pin.photos! {
            print(photo)
        }
//        
//        VTClient.sharedInstance().getPhotos { (imageData, success, errorString) in
//            
//            dispatch_async(dispatch_get_main_queue(), { 
//                if success {
//                    print("success")
//                } else {
//                    print(errorString)
//                }
//            })
//            
//        }
    }
    
    // MARK: - UICollectionView
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let sectionInfo = self.fetchedResultsController.sections![section]
        
        print("number of Cells: \(sectionInfo.numberOfObjects)")
        
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! VTCollectionViewCell
        
        // TODO: Configure cell?
        self.configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! VTCollectionViewCell
        
        if let index = selectedIndexes.indexOf(indexPath) {
            selectedIndexes.removeAtIndex(index)
        } else {
            selectedIndexes.append(indexPath)
        }
        
        // Toggle the title of the bottom buttom according to whether there are any images selected for deletion
        if selectedIndexes.isEmpty {
            bottomButton.title = "New Collection"
        } else {
            bottomButton.title = "Delete selected images"
        }
        
        configureCell(cell, atIndexPath: indexPath)
        
    }
    
    // MARK: - Configure Cell
    func configureCell(cell: VTCollectionViewCell, atIndexPath indexPath: NSIndexPath) {
                
        if let photo = self.fetchedResultsController.objectAtIndexPath(indexPath) as? Photo {
            if let imageData = photo.image {
                cell.activityIndicator.stopAnimating()
                cell.imageView.image = UIImage(data: imageData)
            } else {
                cell.imageView.image = UIImage(named: "Placeholder")
                cell.activityIndicator.startAnimating()
//                let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
//                activityIndicator.frame = CGRect(x: 0, y: 0, width: cell.bounds.width, height: cell.bounds.height)
//                activityIndicator.startAnimating()
                print(self.fetchedResultsController.objectAtIndexPath(indexPath))

            }
//            print("Got an image")
        } else {
            print("Huh?")
        }
        
        
        print("selectedIndexes: \(selectedIndexes)")
        print("indexPath: \(indexPath)")
        if let index = selectedIndexes.indexOf(indexPath) {
            cell.alpha = 0.5
        } else {
            cell.alpha = 1.0
        }
        
    }

    // MARK: - Map View
    
    // Zoom in on the selcted region
    func showLocation() {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let regionRadius: CLLocationDistance = 10000
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // MARK: - NSFetchedResultsController
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = []
        
        let predicate = NSPredicate(format: "pin == %@", self.sentPin)
        
        fetchRequest.predicate = predicate
        
        let fetchedResulstsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResulstsController.delegate = self
        
        return fetchedResulstsController
    }()
    
    // MARK: - Fetched Results Controller Delegate
    
    // Whenever changes are made to Core Data the following three methods are invoked. This first method is used to create
    // three fresh arrays to record the index paths that will be changed.
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        // We are about to handle some new changes. Start out with empty arrays for each change type
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
        
        print("in controllerWillChangeContent")
    }
    
    // The second method may be called multiple times, once for each Color object that is added, deleted, or changed.
    // We store the incex paths into the three arrays.
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type{
            
        case .Insert:
            print("Insert an item")
            // Here we are noting that a new Color instance has been added to Core Data. We remember its index path
            // so that we can add a cell in "controllerDidChangeContent". Note that the "newIndexPath" parameter has
            // the index path that we want in this case
            insertedIndexPaths.append(newIndexPath!)
            break
        case .Delete:
            print("Delete an item")
            // Here we are noting that a Color instance has been deleted from Core Data. We keep remember its index path
            // so that we can remove the corresponding cell in "controllerDidChangeContent". The "indexPath" parameter has
            // value that we want in this case.
            deletedIndexPaths.append(indexPath!)
            break
        case .Update:
            print("Update an item.")
            // We don't expect Color instances to change after they are created. But Core Data would
            // notify us of changes if any occured. This can be useful if you want to respond to changes
            // that come about after data is downloaded. For example, when an images is downloaded from
            // Flickr in the Virtual Tourist app
            updatedIndexPaths.append(indexPath!)
            break
        case .Move:
            print("Move an item. We don't expect to see this in this app.")
            break
        default:
            break
        }
    }
    
    // This method is invoked after all of the changed in the current batch have been collected
    // into the three index path arrays (insert, delete, and upate). We now need to loop through the
    // arrays and perform the changes.
    //
    // The most interesting thing about the method is the collection view's "performBatchUpdates" method.
    // Notice that all of the changes are performed inside a closure that is handed to the collection view.
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        print("in controllerDidChangeContent. changes.count: \(insertedIndexPaths.count + deletedIndexPaths.count)")
        
        collectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItemsAtIndexPaths([indexPath])
            }
            
            }, completion: nil)
    }
    
    // MARK: - Actions and Helpers

    
    @IBAction func bottomButtonTapped(sender: UIBarButtonItem) {
        
        if bottomButton.title == "New Collection" {
            
            // Delete the current set of photos associated with the pin
            for photo in self.sentPin.photos! {
                sharedContext.deleteObject(photo as! NSManagedObject)
            }
            
            appDelegate.saveContext()
            // Get a new collection
            fetchPhotos(sentPin)
            
            
        } else {
            deleteSelectedImages()
            bottomButton.title = "New Collection"
        }
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

    

    
    func deleteSelectedImages() {
        
        var imagesToDelete = [Photo]()
        
        for indexPath in selectedIndexes {
            imagesToDelete.append(fetchedResultsController.objectAtIndexPath(indexPath) as! Photo)
        }
        
        for image in imagesToDelete {
            sharedContext.deleteObject(image)
        }
        
        self.appDelegate.saveContext()
        
        selectedIndexes = []
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
