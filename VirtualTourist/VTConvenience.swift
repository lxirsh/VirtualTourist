    //
//  VTConvenience.swift
//  VirtualTourist
//
//  Created by Lance Hirsch on 7/19/16.
//  Copyright © 2016 Lance Hirsch. All rights reserved.
//

import UIKit
import Foundation

// MARK: VirtualTourist Convenient Resource Methods

extension VTClient {
        
    func getPhotos(completionHandlerForGetPhotos: (imageData: NSData?, success: Bool, error: String?) -> Void) {
        
        getPhotosByLocation { (success, parameters, pageNumber, errorString) in
            if success {
                
                let pageNumber = pageNumber
                let parameters = parameters
                
                self.getPhotosFromFlickrByPageNumber(parameters!, pageNumber: pageNumber!, completionHandlerForGetPhotosFromFlickrByPageNumber: { (imageData, success, errorString) in
                    
                    if success {
                        completionHandlerForGetPhotos(imageData: imageData, success: true, error: nil)
                    } else {
                        completionHandlerForGetPhotos(imageData: nil, success: false, error: errorString)
                    }
                })
            }
        }
        
    }
    
    func getPhotosByLocation(completionHanlerForGetPhotosByLocation: (success: Bool, parameters: [String: AnyObject]? , pageNumber: Int?, errorString: String?) -> Void) {
    
        let parameters = [
            VTClient.ParameterKeys.Method: VTClient.ParameterValues.MethodName,
            VTClient.ParameterKeys.ApiKey: VTClient.ParameterValues.ApiKey,
            VTClient.ParameterKeys.SafeSearch: VTClient.ParameterValues.SafeSearch,
            VTClient.ParameterKeys.BBox: creatBoundingBoxString(),
            VTClient.ParameterKeys.Extras: VTClient.ParameterValues.Extras,
            VTClient.ParameterKeys.Format: VTClient.ParameterValues.DataFormat,
            VTClient.ParameterKeys.NoJsonCallBack: VTClient.ParameterValues.NoJsonCallBack
        ]
        
        
        taskForGETMethod(parameters) { (result, error) in
        
            if error != nil {
                completionHanlerForGetPhotosByLocation(success: false, parameters: nil, pageNumber: nil, errorString: "Could not fetch any photos")
            } else {
                guard let results = result else {
                    completionHanlerForGetPhotosByLocation(success: false, parameters: nil, pageNumber: nil, errorString: "Could not parse the JSON data as a dictionary")
                    return
                }
                
                guard let stat = results["stat"] as? String where stat == "ok" else {
                    print("Flickr API returned an error. See error code in \(results)")
                    completionHanlerForGetPhotosByLocation(success: false, parameters: nil, pageNumber: nil, errorString: "Flickr API returned an error.")
                    return
                }
                
                guard let photosDictionary = results["photos"] as? NSDictionary else {
                    print("Cannot find the key 'photos' in \(results)")
                    completionHanlerForGetPhotosByLocation(success: false, parameters: nil, pageNumber: nil, errorString: "Not able to retrieve photos from Flickr")
                    return
                }
                
                guard let totalPages = photosDictionary["pages"] as? Int else {
                    print("Cannot find the key 'pages' in \(photosDictionary)")
                    completionHanlerForGetPhotosByLocation(success: false, parameters: nil, pageNumber: nil, errorString: "Not able to retrieve photos from Flickr")
                    return
                }
                
                // Choose a random page. Maximum of 40 pages returned.
                let pageLimit = min(totalPages, 40)
                let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
                
                print("Pages = \(totalPages)")
                self.getPhotosFromFlickrByPageNumber(parameters, pageNumber: randomPage, completionHandlerForGetPhotosFromFlickrByPageNumber: { (imageData, success, errorString) in
                    if success {
                        print("got pages")
                        completionHanlerForGetPhotosByLocation(success: true, parameters: parameters, pageNumber: randomPage, errorString: nil)
                    } else {
                        completionHanlerForGetPhotosByLocation(success: false, parameters: nil, pageNumber: nil, errorString: "Could not find a page number")
                    }
                })
            }
            
        }
        
    }
    
    // TODO: check to see if there is a unique id to prevent duplictaes
    func getPhotosFromFlickrByPageNumber(parameters: [String: AnyObject], pageNumber: Int, completionHandlerForGetPhotosFromFlickrByPageNumber: (imageData: NSData?, success: Bool, errorString: String?) -> Void) {
        
        var methodParameters = parameters
        methodParameters["page"] = pageNumber

        taskForGETMethod(methodParameters) { (result, error) in
            
            if let error = error {
                print(error)
                completionHandlerForGetPhotosFromFlickrByPageNumber(imageData: nil, success: false, errorString: "There was an error with the request")
            } else {
                
                guard let results = result else {
                    completionHandlerForGetPhotosFromFlickrByPageNumber(imageData: nil, success: false, errorString: "Could not parse the JSON data as a dictionary")
                    return
                }
                
                guard let stat = results["stat"] as? String where stat == "ok" else {
                    print("Flickr API returned an error. See error code in \(results)")
                    completionHandlerForGetPhotosFromFlickrByPageNumber(imageData: nil, success: false, errorString: "Flickr API returned an error.")
                    return
                }
                
                guard let photosDictionary = results["photos"] as? NSDictionary else {
                    print("Cannot find the key 'photos' in \(results)")
                    completionHandlerForGetPhotosFromFlickrByPageNumber(imageData: nil, success: false, errorString: "Not able to retrieve photos from Flickr")
                    return
                }
                
                guard let totalNumberOfPhotos = (photosDictionary["total"] as? NSString)?.integerValue else {
                    completionHandlerForGetPhotosFromFlickrByPageNumber(imageData: nil, success: false, errorString: "Not able to retrieve photos from Flickr")
                    return
                }
                
                if totalNumberOfPhotos > 0 {
                    
                    guard let photosArray = photosDictionary["photo"] as? [[String: AnyObject]] else {
                        completionHandlerForGetPhotosFromFlickrByPageNumber(imageData: nil, success: false, errorString: "Not able to retrieve photos from Flickr")
                        return
                    }
                    
                    let randonPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
                    let photoDictionary = photosArray[randonPhotoIndex] as [String: AnyObject]
                    
                    guard let imageURLString = photoDictionary["url_m"] as? String else {
                        completionHandlerForGetPhotosFromFlickrByPageNumber(imageData: nil, success: false, errorString: "Cannot find key 'url_m' in \(photoDictionary)")
                        return
                    }
                    
                    let imageURL = NSURL(string: imageURLString)
                    
                    guard let imageData = NSData(contentsOfURL: imageURL!) else {
                        completionHandlerForGetPhotosFromFlickrByPageNumber(imageData: nil, success: false, errorString: "Could not load image")
                        return
                    }
                    completionHandlerForGetPhotosFromFlickrByPageNumber(imageData: imageData, success: true, errorString: nil)
                    
//                    print(imageData)
                    
                    
                }

            }
            
        }
        
    }
    
}
