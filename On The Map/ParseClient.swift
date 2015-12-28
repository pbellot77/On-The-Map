//
//  ParseClient.swift
//  On The Map
//
//  Created by Patrick Bellot on 12/10/15.
//  Copyright © 2015 Swift File. All rights reserved.
//

import Foundation

class ParseClient : NSObject {
    
    //shared session
    var session: NSURLSession
    
    //shared student location arrays
    var studentLocations = [StudentLocation]()
    
    override init() {
        
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    //Mark -- Get
    func taskForGetMethod(method: String, parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        //build url and configure request
        let urlString = ParseClient.Constants.BaseURLSecure + method + ParseClient.escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        request.addValue(Constants.ParseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.RestAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        //make request
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
            //parse and use data
            if let error = downloadError{
                
                let newError = ParseClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
            
            }else{
               
                ParseClient.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
            }
        }
        
        task.resume()
        return task
    }
    
    //Mark -- Post
    func taskForPostMethod(method: String, jsonBody: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask{
        
        let urlString = ParseClient.Constants.BaseURLSecure + method
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "POST"
        request.addValue(Constants.ParseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.RestAPIKey, forHTTPHeaderField: "X-Parse-REST-API-KEY")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do{
            
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(jsonBody, options: [])
        
        } catch _ as NSError {
            
            request.HTTPBody = nil
        }
        
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
            if let error = downloadError {
                
                let newError = ParseClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
            
            }else{
                
                ParseClient.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
            }
        }
        
        task.resume()
        return task
    
    }
    
    //Mark -- Put
    func taskForPutMethod(method: String, jsonBody: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask{
        
        let urlString = ParseClient.Constants.BaseURLSecure + method
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "PUT"
        request.addValue(Constants.ParseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.RestAPIKey, forHTTPHeaderField: "X-Parse-REST-API-KEY")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do{
            
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(jsonBody, options: [])
            
        } catch _ as NSError {
            
            request.HTTPBody = nil
        }
        
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
            if let error = downloadError {
                
                let newError = ParseClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
                
            }else{
                
                ParseClient.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
            }
        }
        
        task.resume()
        return task
        
    }
    
    //Mark -- Helpers: Given a response with error, check status_message is returned, otherwise return previous error
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError?) -> NSError {
        
        if let parsedResult = (try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as? [String : AnyObject] {
            
            if let errorMessage = parsedResult[ParseClient.JSONResponseKeys.StatusMessage] as? String {
                
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                
                if let errorCode = parsedResult[ParseClient.JSONResponseKeys.StatusCode] as? Int {
                    
                    return NSError(domain: "Parse Error", code: errorCode, userInfo: userInfo)
                }
                
                return NSError(domain: "Parse Error", code: 1, userInfo: userInfo)
            }
        }
        
        return error!
    }
    
    //Mark -- Given raw JSON and returning useable Foundation object
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsingError: NSError? = nil
        
        var parsedResult: AnyObject?
        do {
            
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        
        } catch let error as NSError {
            
            parsingError = error
            parsedResult = nil
        }
        
        if let error = parsingError{
            
            completionHandler(result: nil, error: error)
        
        }else{
            
            if let _ = parsedResult?.valueForKey(ParseClient.JSONResponseKeys.StatusMessage) as? String {
                
                let newError = errorForData(data, response: nil, error: nil)
                completionHandler(result: nil, error: newError)
            
            }else{
                
                completionHandler(result: parsedResult, error: nil)
            }
        }
    }
    
    //Given a dictionary of parameters, convert string for a url
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        let queryItems = parameters.map { NSURLQueryItem(name: $0, value: $1 as? String) }
        let components = NSURLComponents()
        
        components.queryItems = queryItems
        return components.percentEncodedQuery ?? ""
    }
    
    //Mark -- shared instance
    class func sharedInstance() -> ParseClient {
        
        struct Singleton {
            
            static var sharedInstance = ParseClient()
        }
        
        return Singleton.sharedInstance
    }
}
