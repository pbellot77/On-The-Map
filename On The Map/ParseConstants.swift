//
//  ParseConstants.swift
//  On The Map
//
//  Created by Patrick Bellot on 12/15/15.
//  Copyright © 2015 Swift File. All rights reserved.
//

import Foundation

extension ParseClient {
    
    //Mark -- Constants
    struct Constants {
        
        // api keys
        static let ParseAppID: String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8yeOdnAbIr"
        static let RestAPIKey: String = "QuWThTdiRmTux3YaDseYSEpUKo7aBYM737yKd4gY"
        
        //url
        static let BaseURLSecure: String = "https://api.parse.com/"
    }
    
    //Mark -- Methods
    struct Methods {
        
        static let StudentLocation: String = "1/classes/StudentLocation"
    }
    
    //Mark -- URL Keys
    
    //Mark -- Parameter Keys
    struct ParameterKeys {
        
        static let Limit = "limit"
        static let Skip = "skip"
        static let Order = "order"
        static let Where = "where"
        static let ObjectID = "objectId"
    }
    
    //Mark -- JSON Body Keys
    struct JSONBodyKeys {
        
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
    }
    
    //Mark -- JSON Response Keys
    struct JSONResponseKeys {
        
        static let Results = "results"
        
        //errors
        static let StatusMessage = "error"
        static let StatusCode = "status"
        
        //students
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let ObjectID = "objectId"
        static let UniqueKey = "uniqueKey"
        static let CreatedAt = "createdAt"
        static let UpdatedAt = "updatedAt"
    }
}