//
//  VTClient.swift
//  On The Map
//
//  Created by Patrick Bellot on 12/8/15.
//  Copyright © 2015 Swift File. All rights reserved.
//

import Foundation

class VTClient: NSObject {

    //shared session
    var session: NSURLSession
    
    //MARK: -- Initializer
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    //MARK: -- Get
    func taskForGetMethod(urlString: String, headerFields: [String:String], queryParameters: [String: AnyObject]?, completionHandler:(data: NSData?, error: NSError?) -> Void) -> NSURLSessionDataTask{
        
        //build and configure Get request
        let urlString = VTClient.escapedParameters(queryParameters)
        let url = NSURL(string: urlString)!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = VTClient.HTTPMethods.GET
        for (field, value) in headerFields {
            request.addValue(value, forHTTPHeaderField: field)
        }
        
        //make the request
        let task = session.dataTaskWithRequest(request){ (data, response, error) in
            
            if self.isSuccess(data, response: response, error: error, completionHandler: completionHandler) {
                completionHandler(data: data, error: nil)
            }
        }
        
        //start the request
        task.resume()
        return task
    }
    
    //Mark -- Post
    func taskForPostMethod(urlString: String, headerFields: [String:String], bodyParameters: [String:AnyObject], completionHandler: (data: NSData?, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        //build and configure Post request
        let url = NSURL(string: urlString)!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = VTClient.HTTPMethods.POST
        for (field, value) in headerFields {
            request.addValue(value, forHTTPHeaderField: field)
        }
        
        do{
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(bodyParameters, options: .PrettyPrinted)
        }
        
        let task = session.dataTaskWithRequest(request){ (data, response, error) in
            
            if self.isSuccess(data, response: response, error: error, completionHandler: completionHandler) {
                completionHandler(data: data, error: nil)
            }
        }
        
        task.resume()
        
        return task
    }
    
    //MARK: -- Delete
    func taskForDeleteMethod(urlString: String, headerFields: [String:String],  completionHandler: (data: NSData?, error: NSError?) -> Void) -> NSURLSessionDataTask{
        
        let url = NSURL(string: urlString)!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = VTClient.HTTPMethods.DELETE
        for (field, value) in headerFields {
            request.addValue(value, forHTTPHeaderField: field)
        }
        
        let task = session.dataTaskWithRequest(request){ data, response, error in
            
            if self.isSuccess(data, response: response, error: error, completionHandler: completionHandler){
                completionHandler(data: data, error: nil)
            }
        }
        
        task.resume()
        
        return task
    }
    
    //MARK: -- Put
    func taskForPutMethod(urlString: String, headerFields: [String:String], completionHandler: (data: NSData?, error: NSError?) -> Void) -> NSURLSessionDataTask{
        
        let url = NSURL(string: urlString)!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = VTClient.HTTPMethods.PUT
        for (field, value) in headerFields {
            request.addValue(value, forHTTPHeaderField: field)
        }
        
        //make request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            if self.isSuccess(data, response: response, error: error, completionHandler: completionHandler) {
                completionHandler(data: data, error: nil)
            }
        }
        
        task.resume()
        
        return task
        
    }
    
    func isSuccess(data: NSData?, response: NSURLResponse?, error: NSError?, completionHandler: (data: NSData?, error: NSError?) -> Void) -> Bool {
        
        guard error == nil else {
            print("There was an error with your request: \(error)")
            completionHandler(data: nil, error: error)
            return false
        }
        
        guard let data = data else {
            let errorMessage = "No data was returned by the request!"
            print(errorMessage)
            let userInfo = [NSLocalizedDescriptionKey : errorMessage]
            completionHandler(data: nil, error: NSError(domain: "isSuccess", code: 1, userInfo: userInfo))
            return false
        }
        
        guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
            var errorMessage : String
            if let response = response as? NSHTTPURLResponse {
                errorMessage = "Your request returned an invalid response! Status code \(response.statusCode)!"
            } else if let response = response {
                errorMessage = "Your request returned an invalid response! Response \(response)!"
            } else {
                errorMessage = "Your request returned an invalid response!"
            }
            
            print(errorMessage)
            let userInfo = [NSLocalizedDescriptionKey : errorMessage]
            completionHandler(data: data, error: NSError(domain: "isSuccess", code: 1, userInfo: userInfo))
            return false
        }
        
        return true
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String:AnyObject]?) -> String {
        
        guard let parameters = parameters else {
            return ""
        }
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            let stringValue = "\(value)"
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    
    //Given raw JSON, return a useable Foundation object
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void){
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey: "Could not parse the data as JSON: '\(data)'"]
            completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        completionHandler(result: parsedResult, error: nil)
    }
    
    //Mark -- Share Instance
    class func sharedInstance() -> VTClient{
        
        struct Singleton {
            static var sharedInstance = VTClient()
        }
        return Singleton.sharedInstance
    }
}
