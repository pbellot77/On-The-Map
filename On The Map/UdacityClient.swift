//
//  UdacityClient.swift
//  On The Map
//
//  Created by Patrick Bellot on 12/8/15.
//  Copyright © 2015 Swift File. All rights reserved.
//

import Foundation

class UdacityClient: NSObject {

    //shared session
    var session: NSURLSession
    
    //authentication state
    var sessionID: String? = nil
    var userID: Int? = nil
    
    //MARK: -- Initializer
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    //MARK: -- Get
    func taskForGetMethod(method: String, completionHandler:(result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask{
        
        //build and configure Get request
        let urlString = Constants.UdacityBaseURL + method
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        //make the request
        let task = session.dataTaskWithRequest(request){ data, response, error) in
            
            /* GUARD: Was there an error */
            guard error == nil else {
                let userInfo = [NSLocalizedDescriptionKey: "There was an error with your request: \(error)"]
                completionHandler(result: nil, error: NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && stutusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    let userInfo = [NSLocalizedDescriptionKey: "Your Request returned an invalid respons! Status code: \(response.statusCode)!"]
                    completionHandler(result: nil, error: NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
                } else if let response = response {
                    let userInfo = [NSLocalizedDescriptionKey: "Your request returned an invalid response! Response: \(response)!"]
                    completionHandler(result: nil, error: NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
                } else {
                    let userInfo = [NSLocalizedDescriptionKey: "Your request returned an invalid response!"]
                    completionHandler(result: nil, error: NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                let userInfo = [NSLocalizedDescriptionKey: "No data was returned by the request!"]
                completionHandler(result: nil, error: NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
                return
            }
            
            /* Parse and use data */
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            UdacityClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
        }
        
        //start the request
        task.resume()
        return task
    }
    
    //Mark -- Post
    func taskForPostMethod(method: String, jsonBody: [String: AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask{
        
        //build and configure Post request
        let urlString = Constants.UdacityBaseURL + method
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do{
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
        }
        
        let task = session.dataTaskWithRequest(request){ (data, response, error) in
            
            guard error == nil else {
                let userInfo = [NSLocalizedDescriptionKey: "There was an error with your request: \(error)"]
                completionHandler(result: nil, error: NSerror(domain: "taskForPostMethod", code: 1, userInfo: userInfo))
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    let userInfo = [NSLocalizedDescriptionKey: "Your request returned an invalid response! Status code: \(response.statusCode)!"]
                    completionHandler(result: nil, error: NSError(domain: "taskForPostMethod", code: 1, userInfo: userInfo))
                } else if let response = response {
                    let userInfo = [NSLocalizedDescriptionKey: "Your request returned an invalid response! Response: \(response)!"]
                    completionHandler(result: nil, error: NSError(domain: "taskForPostMethod", code: 1, userInfo: userInfo))
                } else {
                    let userInfo = [NSLocalizedDescriptionKey: "Your request returned an invalid response!"]
                    completionHandler(result: nil, error: NSError(domain: "taskForPostMethod'", code: 1, userInfo: userInfo))
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                let userInfo = [NSLocalizedDescriptionKey: "No data was returned by the request!"]
                completionHandler(result: nil, error: NSError(domain: "taskForPostMethod", code: 1, userInfo: userInfo))
                return
            }
            /* Parse and use data */
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
            UdacityClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
        }
        
        task.resume()
        return task
    }
    
    //Mark -- Delete
    func taskForDeleteMethod(method: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask{
        
        let urlString = UdacityClient.Constants.BaseURLSecure + method
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        for cookie in sharedCookieStorage.cookies! as [NSHTTPCookie]{
            
            if(cookie.name == "XSRF-Token"){
                xsrfCookie = cookie
            }
        }
        if let xsrfCookie = xsrfCookie{
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = session.dataTaskWithRequest(request){ data, response, downloadError in
            
            if let error = downloadError{
                let newError = UdacityClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
            }else{
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
                UdacityClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            }
        }
        
        task.resume()
        return task
    }
    
    //Given an error response, check status-message is returned, otherwise return previous error
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError{
        
        if let parsedResult = (try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as? [String : AnyObject]{
            
            if let errorMessage = parsedResult[UdacityClient.JSONResponseKeys.StatusMessage] as? String{
                
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                if let errorCode = parsedResult[UdacityClient.JSONResponseKeys.StatusCode] as? Int{
                    
                    return NSError(domain: "Udacity Error", code: errorCode, userInfo: userInfo)
                }
                
                return NSError(domain: "Udacity Error", code: 1, userInfo: userInfo)
            }
        }
        
        return error
    }
    
    //Given raw JSON, return a useable Foundation object
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void){
        
        var parsingError: NSError? = nil
        let parsedResult: AnyObject?
        do {
            
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch let error as NSError {
            
            parsingError = error
            parsedResult = nil
        }
        
        if let error = parsingError {
            
            completionHandler(result: nil, error: error)
        
        }else{
            
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    //Mark -- Share Instance
    class func sharedInstance() -> UdacityClient{
        
        struct Singleton {
            
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }
}
