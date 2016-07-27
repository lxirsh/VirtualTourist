//
//  VTImagesViewController.swift
//  VirtualTourist
//
//  Created by Lance Hirsch on 7/14/16.
//  Copyright © 2016 Lance Hirsch. All rights reserved.
//

import UIKit
import MapKit

class VTImagesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var mapView: MKMapView!
    
    // Properties
    var latitude: Double!
    var longitude: Double!
    
    let reuseIdentifier = "cell"
    var items = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48"]


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the layout and set three images per row for portrait and five for landscape
        let space: CGFloat = 1.5
        let dimension = self.view.frame.width <= self.view.frame.height ? (self.view.frame.width - (2 * space)) / 3.0 : (self.view.frame.width - (2 * space)) / 5.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSizeMake(dimension, dimension)
        
        showLocation()
        showPhotos()
    }
    
    func showPhotos() {
        
        VTClient.sharedInstance().getPhotos { (success, errorString) in
            
            dispatch_async(dispatch_get_main_queue(), { 
                if success {
                    print("success")
                } else {
                    print(errorString)
                }
            })
            
        }
    }

    // MARK: - UICollectionViewDataSource protocol

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! VTCollectionViewCell
        
        cell.myLabel.text = items[indexPath.item]
        cell.backgroundColor = UIColor.whiteColor()
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.item)!")
    }
    
    // MARK: - Map View
    
    // Zoom in on the selcted region
    func showLocation() {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let regionRadius: CLLocationDistance = 10000
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
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
