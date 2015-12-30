//
//  StudentInformation.swift
//  On The Map
//
//  Created by Patrick Bellot on 12/10/15.
//  Copyright © 2015 Swift File. All rights reserved.
//

import Foundation

struct StudentInformation {
    
    //MARK: -- Properties
    var firstName: String
    var lastName: String
    var latitude: Double
    var longitude: Double
    var mapString: String
    var mediaURL: String
    var objectID: String
    var uniqueKey: String?
    var createdAt: NSDate
    var updatedAt: NSDate
    static var studentData = [StudentInformation]()
    
    //MARK: -- Initializer that takes a dictionary
    init(dictionary: [String : AnyObject]) {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        self.firstName = dictionary[ParseClient.JSONResponseKeys.FirstName] as! String
        self.lastName = dictionary[ParseClient.JSONResponseKeys.LastName] as! String
        self.latitude = dictionary[ParseClient.JSONResponseKeys.Latitude] as! Double
        self.longitude = dictionary[ParseClient.JSONResponseKeys.Longitude] as! Double
        self.mapString = dictionary[ParseClient.JSONResponseKeys.MapString] as! String
        self.mediaURL = dictionary[ParseClient.JSONResponseKeys.MediaURL] as! String
        self.objectID = dictionary[ParseClient.JSONResponseKeys.ObjectID] as! String
        self.uniqueKey = dictionary[ParseClient.JSONResponseKeys.UniqueKey] as! String?
        self.createdAt = dateFormatter.dateFromString(dictionary[ParseClient.JSONResponseKeys.CreatedAt] as! String)!
        self.updatedAt = dateFormatter.dateFromString(dictionary[ParseClient.JSONResponseKeys.UpdatedAt] as! String)!
    }
    
   
}
