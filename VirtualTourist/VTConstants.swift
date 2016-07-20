//
//  VTConstants.swift
//  VirtualTourist
//
//  Created by Lance Hirsch on 7/18/16.
//  Copyright © 2016 Lance Hirsch. All rights reserved.
//

import Foundation

extension VTClient {
    
    // MARK: URL Constants
    struct URLConstants {
        
        static let FlickrScheme = "https"
        static let FlickrHost = "api.flickr.com"
        static let ApiPath = "/services/rest"
        
    }
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        
        static let Method = "method"
        static let ApiKey = "api_key"
        static let BBox = "bbox"
        static let SafeSearch = "safe_search"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJsonCallBack = "nojsoncallback"
        
    }
    
    // MARK: Method Arguments
    struct ParameterValues {
        
        static let MethodName = "flickr.photos.search"
        static let ApiKey = "80dd8209c479bc9bc5643d203c0a585e"
        static let Extras = "url_m"
        static let SafeSearch = "1"
        static let DataFormat = "json"
        static let NoJsonCallBack = "1"

    }
    
    // MARK: Bounding Box Constants
    struct BBoxConstants {
        
        static let BoundingBoxHalfWidth = 1.0
        static let BoundingBoxHalfHeight = 1.0
        static let LatitudeMinimum = -90.0
        static let LatitiudeMaximum = 90.0
        static let LongitudeMinimum = -180.0
        static let LongitudeMaximum = 180.0
        
    }
    
}