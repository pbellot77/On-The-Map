//
//  UdacityConvenience.swift
//  On The Map
//
//  Created by Patrick Bellot on 12/9/15.
//  Copyright © 2015 Swift File. All rights reserved.
//

import Foundation
import UIKit

extension UdacityClient{
    
    func createSession(username: String, password: String, completionHandler:(message: String, error: NSError?) -> Void) {
        
        //Specify method and HTTP Body
        let method: String = UdacityClient.Methods.AccountLogIn
        
        let jsonBody: [String : AnyObject] = [
            "udacity" : [UdacityClient.JSONBodyKeys.Username,
                UdacityClient.JSONBodyKeys.Password
            ]
        ]
        
        //Mark -- Request
        taskForPostMethod(method, jsonBody: jsonBody) { JSONResult, error in
            
            //Send values to completionHandler
            if let error = error{
                
                completionHandler(message: "Sign in failed", error: error)
                    
                }else{
                    
                    if let account = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.Account) as? NSDictionary {
                        
                        if let userID = account.valueForKey(UdacityClient.JSONResponseKeys.UserID) as? String{
                            
                            self.getPublicUserData(userID) { message, error in
                                
                                if let error = error {
                                    
                                    completionHandler(message: message, error: error)
                                
                                }else{
                                    
                                    completionHandler(message: message, error: nil)
                                }
                                
                            }
                        }
                    }else{
                        
                        completionHandler(message: "Couldn't find account dictionary in createSession result", error: NSError(domain: "createSession parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Please check your username and password and try again"]))
                    }
                }
            }
        }
    
    func logoutOfSession(completionHandler: (message: String, error: NSError?) -> Void) {
        
        //specify method
        let method: String = UdacityClient.Methods.AccountLogIn
        
        //make the request
        taskForDeleteMethod(method) { JSONResult, error in
            
            if let error = error {
                
                completionHandler(message: "Logout Failed", error: error)
            
            }else{
                
                if let session = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.Session) as? NSDictionary {
                    
                    if let _ = session.valueForKey(UdacityClient.JSONResponseKeys.SessionID) as? String {
                        
                        completionHandler(message: "Logout Successful", error: nil)
                    }
                }else{
                    
                    completionHandler(message: "Couldn't find session dictionary in logoutOfSession result", error: NSError(domain: "LogoutOfSession parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: " Unknown error: Try logging out again"]))
                }
            }
        }
    }
    
    func getPublicUserData(userID: String, completionHandler:(message: String, error: NSError?) -> Void){
        
        let method: String = UdacityClient.Methods.AccountUserData + userID
        
        taskForGetMethod(method) { JSONResult, error in
            
            if let error = error {
                
                completionHandler(message: "Getting public user data failed", error: error)
            
            }else{
                
                if let userDictionary = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.User) as? NSDictionary {
                    
                    if let firstName = userDictionary.valueForKey(UdacityClient.JSONResponseKeys.FirstName) as? String {
                        
                        if let lastName = userDictionary.valueForKey(UdacityClient.JSONResponseKeys.LastName) as? String {
                            
                            UdacityClient.sharedInstance().userID = userID
                            UdacityClient.sharedInstance().firstName = firstName
                            UdacityClient.sharedInstance().lastName = lastName
                            
                            completionHandler(message: "User Info acquired! UserID: \(userID) FirstName: \(firstName) LastName: \(lastName)", error: nil)
                        
                        }else{
                            
                            completionHandler(message: "Unable to find last name in userDictionary", error: NSError(domain: "getPublicUserData parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getPublicUserData"]))
                        }
                    
                    }else{
                        
                        completionHandler(message: "Unable to find first name in userDictionary", error: NSError(domain: "getPublicUserData parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse get publicUserData"]))
                    }
                
                }else{
                   
                    completionHandler(message: "Couldn't find user dictionary in getPublicUserData result", error: NSError(domain: "getPublicUserData parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown Udacity Error -- please check your username and password and try again"]))
                }
            }
            
        }
    }
}