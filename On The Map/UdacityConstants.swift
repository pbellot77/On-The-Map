//
//  extenstion UdacityClient.swift
//  On The Map
//
//  Created by Patrick Bellot on 12/8/15.
//  Copyright © 2015 Swift File. All rights reserved.
//

extension UdacityClient {
    
    //Mark -- Constants
    struct Constants{
       
        static let BaseURLSecure: String = "https://www.udacity.com/"
    }
    
    //Mark -- Methods
    struct Methods{
        
        static let AccountLogIn = "api/session"
        static let AccountLogOut = "api/session"
        static let AccountUserData = "api/users/"
    }
    
    //Mark -- URLKeys
    struct URLKeys {
        
    }
    
    //Mark -- Parameter Keys
    struct ParameterKeys{
        
    }
    
    //Mark -- JSON Body Keys
    struct JSONBodyKeys {
        
        static let Username = "username"
        static let Password = "password"
    }
    
    //Mark -- JSON Response Keys
    struct JSONResponseKeys {
        
        static let StatusMessage = "error"
        static let StatusCode = "status"
        
        static let Account = "account"
        static let Registered = "registered"
        static let UserID = "key"
        
        static let Session = "session"
        static let SessionID = "id"
        static let Expiration = "expiration"
        
        static let User = "user"
        static let FirstName = "first_name"
        static let LastName = "last_name"
    }
}
