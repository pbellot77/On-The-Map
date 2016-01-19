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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        setupNavigationBar()
        getStudentData()
        getUserData()
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
    
    //Function that is called when the logout button is pressed
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
    
    //MARK: -- Helper functions
    
    //Function that gets the user data
    func getUserData(){
        /* GET the users first and last name */
        UdacityClient.sharedInstance().getUserData(appDelegate.userID) {(result, error) in
            
            guard error == nil else {
                let alertTitle = "Couldn't get your data"
                let alertMessage = "There was a problem trying to fetch your name and user ID."
                let actionTitle = "OK"
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.showAlert(alertTitle, alertMessage: alertMessage, actionTitle: actionTitle)
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
                return
            }
            /* Store the user resulting user data in the appDelegate */
            self.appDelegate.userData = result!
            
        }
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
    
    //Function that populates the map with data
    func populateMapWithStudentData(){
        
        /* Remove any pins previously on the map to avoid duplicates */
        if !mapView.annotations.isEmpty{
            mapView.removeAnnotations(mapView.annotations)
        }
        
        var annotations = [MKPointAnnotation]()
        
        /* For each student in the data */
        for s in StudentInformation.studentData {
            
            /* Get the lat and lon values to create a coordinate */
            let lat = CLLocationDegrees(s.latitude)
            let lon = CLLocationDegrees(s.longitude)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            
            /* Make the map annotation with the coordinate and other student data */
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(s.firstName) \(s.lastName)"
            annotation.subtitle = s.mediaURL
            
            /* Add the annotation to the array */
            annotations.append(annotation)
        }
        /* Add the annotations to the map */
        mapView.addAnnotations(annotations)
    }
    
    //MARK: -- User interface helper functions
    
    
    //Fuction that configures the navigation bar
    func setupNavigationBar(){
        
        /*Set the back button on the navigation bar to be logged out */
        let customLeftBarButton = UIBarButtonItem(title: "Log Out", style: .Plain, target: self, action: "logOut")
        navigationItem.setLeftBarButtonItem(customLeftBarButton, animated: false)
        
        /* Set the title of the navigation bar to be On The Map */
        self.navigationItem.title = "On The Map"
        
        /* Create an array of bar button items */
        var customButtons = [UIBarButtonItem]()
        
        /* Create pin button */
        let pinImage = UIImage(named: "pin")
        let pinButton = UIBarButtonItem(image: pinImage, style: .Plain, target: self, action: "presentInformationPostingViewController")
        
        /* create refresh button */
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "getStudentData")
        
        /* Add the buttons to the array */
        customButtons.append(refreshButton)
        customButtons.append(pinButton)
        
        /* Add buttons to nav bar */
        navigationItem.setRightBarButtonItems(customButtons, animated: false)
        
    }
    
    //MARK: -- Map delegate helper functions
    
    //Function that adds pins to the map
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    //Function that opens the URL a student has provided when the pin detail is clicked
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView{
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                if UIApplication.sharedApplication().canOpenURL(NSURL(string: toOpen)!) {
                    let url = NSURL(string: toOpen)
                    app.openURL(url!)
                } else {
                    let alertTitle = "Unable to load webpage"
                    let alertMessage = "Webpage couldn't be opened because the link was invalid."
                    let actionTitle = "Try Again"
                    
                    showAlert(alertTitle, alertMessage: alertMessage, actionTitle: actionTitle)
                }
            }
        }
    }
    
    //MARK: -- Error helper functions
    
    func showOverwriteLocationAlert(){
        /* Prepare the strings for the alert */
        let userFirstName = self.appDelegate.userData[0]
        let userLastName = self.appDelegate.userData[1]
        let alertTitle = "Overwrite location?"
        let alertMessage = userFirstName + "" + userLastName + "do you really want to overwrite your existing location?"
        
        /* Prepare to overwrite for the alert */
        let overWriteAction = UIAlertAction(title: "Overwrite", style: .Default) {(action) in
            /* instantiate and then present the view controller */
            let informationPostViewController = self.storyboard!.instantiateViewControllerWithIdentifier("InformationPostingViewController")
            self.presentViewController(informationPostViewController, animated: true, completion: nil)
        }
        
        /* Prepare the cancel for the alert */
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) {(action) in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        /* Configure the alert view to display the error */
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
        alert.addAction(overWriteAction)
        alert.addAction(cancelAction)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    //Function that configures and shows alert
    func showAlert(alertTitle: String, alertMessage: String, actionTitle: String){
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
  }
