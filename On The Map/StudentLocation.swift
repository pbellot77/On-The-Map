//
//  StudentLocation.swift
//  On The Map
//
//  Created by Patrick Bellot on 12/10/15.
//  Copyright © 2015 Swift File. All rights reserved.
//

struct StudentLocation {
    
    var firstName = ""
    var lastName = ""
    var latitude: Double? = nil
    var longitude: Double? = nil
    var mapString = ""
    var mediaURL: String? = nil
    var objectID = ""
    var uniqueKey = ""
    var createdAt = ""
    var updatedAt = ""
    
    //construct a student location result from a dictionary
    init(){}
    
    init(dictionary: [String : AnyObject]) {
        
        firstName = dictionary[ParseClient.JSONResponseKeys.FirstName] as! String
        lastName = dictionary[ParseClient.JSONResponseKeys.LastName] as! String
        latitude = dictionary[ParseClient.JSONResponseKeys.Latitude] as? Double
        longitude = dictionary[ParseClient.JSONResponseKeys.Longitude] as? Double
        mapString = dictionary[ParseClient.JSONResponseKeys.MapString] as! String
        mediaURL = dictionary[ParseClient.JSONResponseKeys.MediaURL] as? String
        objectID = dictionary[ParseClient.JSONResponseKeys.ObjectID] as! String
        uniqueKey = dictionary[ParseClient.JSONResponseKeys.UniqueKey] as! String
        createdAt = dictionary[ParseClient.JSONResponseKeys.CreatedAt] as! String
        updatedAt = dictionary[ParseClient.JSONResponseKeys.UpdatedAt] as! String
    }
    
    //convert the array of dictionaries into an array of student locations
    static func locationsFromResults(results: [[String : AnyObject]]) -> [StudentLocation]{
        
        var studentLocations = [StudentLocation]()
        
        for result in results{
            
            studentLocations.append(StudentLocation(dictionary: result))
        }
        
        return studentLocations
    }
}
