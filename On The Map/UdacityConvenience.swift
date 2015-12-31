//
//  UdacityConvenience.swift
//  On The Map
//
//  Created by Patrick Bellot on 12/9/15.
//  Copyright © 2015 Swift File. All rights reserved.
//

import Foundation

extension UdacityClient{
    
    //MARK: -- Function that POSTs new session
    func postSession(username: String, password: String, completionHandler: (result: String?, error: NSError?) -> Void){
        let method = Methods.Session
        let jsonBody = [
            JSONBodyKeys.Udacity : [
                JSONBodyKeys.Username : username,
                JSONBodyKeys.Password : password
            ],
        ]
        
        taskForPostMethod(method, jsonBody: jsonBody) { (JSONResult, error) in
            
            guard error == nil else {
                completionHandler(result: nil, error: error)
                return
            }
            
            if let dictionary = JSONResult! [JSONResponseKeys.Account] as? [String : AnyObject] {
                if let result = dictionary[JSONResponseKeys.Key] as? String {
                    completionHandler(result: result, error: nil)
                } else {
                    completionHandler(result: nil, error: NSError(domain: "postSession parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse session"]))
                }
            } else {
                completionHandler(result: nil, error: NSError(domain: "postSession parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse session"]))
                
            }
        }
    }
    
    //MARK: -- Function that DELETEs the current session
    func deleteSession(completionHandler: (result: AnyObject?, error: NSError?) -> Void) {
        let method = Methods.Session
        
        taskForDeleteMethod(method) {(JSONResult, error) in
            
            guard error == nil else {
                completionHandler(result: nil, error: error)
                return
            }
            
            if let dictionary = JSONResult[JSONResponseKeys.Session] as? [String:AnyObject] {
                if let result = dictionary[JSONResponseKeys.ID] as? String {
                completionHandler(result: result, error: nil)
                } else {
                    completionHandler(result: nil, error: NSError(domain: "deleteSession", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not delete session"]))
                }
            } else {
                completionHandler(result: nil, error: NSError(domain: "deleteSession", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not delete session"]))
            }
        }
    }
    
    //MARK: -- Function that GETs user information
    func getUserData(userID: String, completionHandler: (result: [String]?, error: NSError?) -> Void) {
        let method = Methods.Users + userID
        
        taskForGetMethod(method) {(JSONResult, error) in
            
            guard error == nil else {
                completionHandler(result: nil, error: error)
                return
            }
            
            if let dictionary = JSONResult[JSONResponseKeys.User] as? [String:AnyObject] {
                /* Array for user name */
                var result = [String]()
                
                if let firstName = dictionary[JSONResponseKeys.FirstName] as? String{
                    result.append(firstName)
                    if let lastName = dictionary[JSONResponseKeys.LastName] as? String {
                        result.append(lastName)
                        completionHandler(result: result, error: nil)
                    } else {
                        completionHandler(result: nil, error: NSError(domain: "getUserData parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse user data: Last Name"]))
                    }
                } else {
                    completionHandler(result: nil, error: NSError(domain: "getUserData parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse user data: First Name"]))
                }
            }
        }
    }
}