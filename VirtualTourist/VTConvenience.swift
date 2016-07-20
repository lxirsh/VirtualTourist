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
    
    func getPhotosByLocation(completionHanlerForGetPhotosByLocation: (success: Bool, errorString: String?) -> Void) {
    
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
                completionHanlerForGetPhotosByLocation(success: false, errorString: "Could not fetch any photos")
            } else {
                guard let results = result else {
                    completionHanlerForGetPhotosByLocation(success: false, errorString: "Could not parse the JSON data as a dictionary")
                    return
                }
                completionHanlerForGetPhotosByLocation(success: true, errorString: nil)
//                print(results)
            }
            
            
        }
        
    }
    
}
