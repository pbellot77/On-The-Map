//
//  MapViewController.swift
//  On The Map
//
//  Created by Patrick Bellot on 12/22/15.
//  Copyright © 2015 Swift File. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    //MARK: -- Properties
    var appDelegate: AppDelegate!
    
    //MARK: -- Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: -- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        setupMapViewConstraints()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        setupNavigationBar()
        getStudentData()
        getUserData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupMapViewConstraints()
    }
    
    //Function that presents the Information Posting View Controller
    func presentInformationPostingViewController(){
        
        ParseClient.sharedInstance().queryForAStudent() {(result, error) in
            
            guard error == nil else {
                let alertTitle = "Error fetching student data"
                let alertMessage = "Something went wrong when checking to see if you have already posted your location"
                let actionTitle = "Try Again"
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.showAlert(alertTitle, alertMessage: alertMessage, actionTitle: actionTitle)
                })
                return
            }
            
            if result?.count != 0 {
                let resultArray = result![0]
                let objectID = resultArray[ParseClient.JSONResponseKeys.ObjectID]
                self.appDelegate.objectID = objectID as! String
                self.showOverwriteLocationAlert()
            }
        }
    }
    
    //Function that is called when the loout button is pressed
    func logOut() {
        UdacityClient.sharedInstance().deleteSession() {(result, error) in
            
            guard error == nil else {
                let alertTitle = "Couldn't log out!"
                let alertMessage = error?.userInfo[NSLocalizedDescriptionKey] as? String
                let actionTitle = "Try Again"
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.showAlert(alertTitle, alertMessage: alertMessage!, actionTitle: actionTitle)
                })
                return
            }
        }
        
        /* Show the log in view controller */
        navigationController!.popToRootViewControllerAnimated(true)
    }
    
    //Function that gets the student data
    func getStudentData(){
        let activityView = UIView.init(frame: mapView.frame)
        activityView.backgroundColor = UIColor.grayColor()
        activityView.alpha = 0.8
        view.addSubview(activityView)
        
        /* Show activity spinner */
        let activitySpinner = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        activitySpinner.center = view.center
        activitySpinner.startAnimating()
        activityView.addSubview(activitySpinner)
        
        ParseClient.sharedInstance().getStudentLocations {(result, error) in
            
            guard error == nil else {
                let alertTitle = "Download failed"
                let alertMessage = "There was a problem fetching the student data."
                let actionTitle = "Try Again"
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.showAlert(alertTitle, alertMessage: alertMessage, actionTitle: actionTitle)
                    activityView.removeFromSuperview()
                    activitySpinner.stopAnimating()
                })
                return
            }
            
            /* Clear any previously fetched student data */
            if !StudentInformation.studentData.isEmpty {
                StudentInformation.studentData.removeAll()
            }
            
            /* For each student in the returned results add it to the StudentDataStore */
            for s in result! {
                StudentInformation.studentData.append(StudentInformation(dictionary: s))
            }
            
            /* Sort the student data in order of last updated */
            StudentInformation.studentData = StudentInformation.studentData.sort() {$0.updatedAt.compare($1.updatedAt) == NSComparisonResult.OrderedDescending}
            
            /* Present next viewController showing the student data */
            dispatch_async(dispatch_get_main_queue(), {
                self.populateMapWithStudentData()
                
                activityView.removeFromSuperview()
                activitySpinner.stopAnimating()
            })
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
  }
