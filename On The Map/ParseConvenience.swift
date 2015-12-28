//
//  ParseConvenience.swift
//  On The Map
//
//  Created by Patrick Bellot on 12/16/15.
//  Copyright © 2015 Swift File. All rights reserved.
//

import Foundation
import UIKit

extension ParseClient {
    
    //Mark -- Student Location Methods
    func getStudentLocation(completionHandler: (result: [StudentLocation]?, error: NSError?) -> Void){
        
        //parameters and methods
        let parameters = [
            ParseClient.ParameterKeys.Limit: "\(100)",
            ParseClient.ParameterKeys.Skip: "\(0)",
            ParseClient.ParameterKeys.Order: "-updatedAt"
        ]
        
        let method: String = Methods.StudentLocation + "?"
        
        //make the request
        taskForGetMethod(method, parameters: parameters) { JSONResult, error in
            
            if let error = error {
                
                completionHandler(result: nil, error: error)
            
            }else{
                
                if let results = JSONResult.valueForKey(ParseClient.JSONResponseKeys.Results) as? [[String : AnyObject]]{
                    
                    let locations = StudentLocation.locationsFromResults(results)
                    
                    completionHandler(result: locations, error: nil)
                    
                }else{
                    
                    print("Error parsing getStudentLocation -- couldn't find results string in json results")
                    completionHandler(result: nil, error: NSError(domain: "getStudentLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey : "Could not parse getStudentLocation"]))
                }
            }
        }
    }
    
    func postStudentLocation(location: StudentLocation, completionHandler: (result: String?, error: NSError?) -> Void) {
        
        //specify method and HTTP Body
        let method: String = Methods.StudentLocation
        
        let jsonBody: [String : AnyObject] = [
            ParseClient.JSONBodyKeys.UniqueKey: location.uniqueKey,
            ParseClient.JSONBodyKeys.FirstName: location.firstName,
            ParseClient.JSONBodyKeys.LastName: location.lastName,
            ParseClient.JSONBodyKeys.MapString: location.mapString,
            ParseClient.JSONBodyKeys.MediaURL: location.mediaURL! as String,
            ParseClient.JSONBodyKeys.Latitude: location.latitude! as Double,
            ParseClient.JSONBodyKeys.Longitude: location.longitude! as Double
        ]
        
        //make request
        taskForPostMethod(method, jsonBody: jsonBody) { JSONResult, error in
        
        //send the desired values to the completion handler
            if let error = error {
                
                print("error from post method \(error)")
                completionHandler(result: nil, error: error)
            
            }else{
                
                if let objectID = JSONResult.valueForKey(ParseClient.JSONResponseKeys.ObjectID) as? String {
                    
                    if let createdAt = JSONResult.valueForKey(ParseClient.JSONResponseKeys.CreatedAt) as? String {
                        
                        print("Student Location Posted \(objectID) \(createdAt)")
                        completionHandler(result: objectID, error: nil)
                    
                    }else{
                        
                        print("Error parsing postStudentLocation -- couldn't find createdAt in json result")
                        completionHandler(result: nil, error: NSError(domain: "postStudentLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey : "couldn't find createdAt key in result"]))
                    }
                
                }else{
                    
                    print("Error parsing postStudentLocation -- couldn't find objectID in json result")
                    completionHandler(result: nil, error: NSError(domain: "postStudentLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey : "couldn't find objectID key in result"]))
                }
            }
        }
        
    }
}
