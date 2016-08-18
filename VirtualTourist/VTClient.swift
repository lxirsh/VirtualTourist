//
//  VTClient.swift
//  VirtualTourist
//
//  Created by Lance Hirsch on 7/18/16.
//  Copyright © 2016 Lance Hirsch. All rights reserved.
//

import Foundation

class VTClient: NSObject {
    
    // Mark: Properties
    var pinLatitude: Double? = nil
    var pinLongitude: Double? = nil
    
    // Shared session
    var session = NSURLSession.sharedSession()
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    // MARK: GET
    
    func taskForGETMethod(parameters: [String: AnyObject], completionHandlerForGet: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        var parameters = parameters
        
//        print(parameters)
        
        // Build the URL and configure the request
        let request = NSMutableURLRequest(URL: urlFromParameters(parameters))
        
        // Make the request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForGet(result: nil, error: NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            // GUARD: Did we get a successful 2XX response?
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            // GUARD: Was there any data returned?
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            // Parse the data and use the data (in completion handler)
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGet)
            
        }
        
        // Start the request
        task.resume()
        
        return task
    }
    
    
    // MARK: Helpers
    
    // Define a bounding box for the location search
    func creatBoundingBoxString() -> String {
        
        let latitude = pinLatitude!
        let longitude = pinLongitude!
        
        // Ensure box is bounded by minimums and maximums
        let bottomLeftLongitude = max(longitude - VTClient.BBoxConstants.BoundingBoxHalfWidth, VTClient.BBoxConstants.LongitudeMinimum)
        let bottomLeftLatitude = max(latitude - VTClient.BBoxConstants.BoundingBoxHalfHeight, VTClient.BBoxConstants.LatitudeMinimum)
        let topRightLongitude = min(longitude + VTClient.BBoxConstants.BoundingBoxHalfWidth, VTClient.BBoxConstants.LongitudeMaximum)
        let topRightLatitude = min(latitude + VTClient.BBoxConstants.BoundingBoxHalfHeight, VTClient.BBoxConstants.LatitiudeMaximum)
        
        return "\(bottomLeftLongitude),\(bottomLeftLatitude),\(topRightLongitude),\(topRightLatitude)"
        
    }

    
    // Substitute the key for the value that is contained within the method name
    func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    // Return a useable Foundation object from raw JSON data
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey: "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(result: nil, error: NSError(domain: "converDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(result: parsedResult, error: nil)
    }
    
    // Create a URL from parameters
    private func urlFromParameters(parameters: [String: AnyObject], withPathExtention: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = VTClient.URLConstants.FlickrScheme
        components.host = VTClient.URLConstants.FlickrHost
        components.path = VTClient.URLConstants.ApiPath + (withPathExtention ?? "")
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
    
    // MARK: Shared instance
    class func sharedInstance() -> VTClient {
        struct Singleton {
            static var sharedInstance = VTClient()
        }
        return Singleton.sharedInstance
    }
    
}
