//
//  MapViewController.swift
//  On The Map
//
//  Created by Patrick Bellot on 12/22/15.
//  Copyright © 2015 Swift File. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate {
    
    //MARK: -- Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: -- Variables
    var locationsSet = false
    let emptyURLSubtitleText = "Student has not entered a URL"

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        
        //Set bar button items
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("logout:"))
        
        let refreshButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: Selector("refreshButtonClicked:"))
        let pinImage: UIImage = UIImage(named: "pin")!
        let pinButton: UIBarButtonItem = UIBarButtonItem(image: pinImage, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("addPin:"))
        let buttons = [refreshButton, pinButton]
        
        navigationItem.rightBarButtonItems = buttons
        
        setLocations()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if(locationsSet){
            setPinsOnMap()
        }
    }
    
    //MARK: -- Tab Bar Buttons
    func logout(sender: AnyObject){
        UdacityClient.sharedInstance().logoutOfSession() { result, error in
            if let error = error {
                self.showAlertController("Udacity Logout Error", message: error.localizedDescription)
            }else{
                print("Successfully logged out of Udacity session")
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    func addPin(sender: AnyObject) {
        let object:AnyObject = storyboard!.instantiateViewControllerWithIdentifier("InfoPostingViewController")
        let addPinVC = object as! InfoPostingViewController
        
        presentViewController(addPinVC, animated: true, completion: nil)
    }
    
    func refreshButtonClicked(sender: AnyObject){
        setLocations()
    }
    
    //MARK: -- Map Behavior
    func setLocations(){
        ParseClient.sharedInstance().getStudentLocation() { result, error in
            if let error = error {
                self.showAlertController("Parse Error", message: error.localizedDescription)
            }else{
                print("Successfully got student info!")
                
                ParseClient.sharedInstance().studentLocations = result!
                self.locationsSet = true
                self.setPinsOnMap()
            }
        }
    }
    
    func setPinsOnMap(){
        dispatch_async(dispatch_get_main_queue(), {
            
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            var annotations = [MKPointAnnotation]()
            
            for student in ParseClient.sharedInstance().studentLocations {
                
                let firstName = student.firstName
                let lastName = student.lastName
                
                var mediaURL = ""
                if (student.mediaURL != nil){
                    mediaURL = student.mediaURL!
                }else{
                    mediaURL = self.emptyURLSubtitleText
                }
                
                let latitude = CLLocationDegrees(student.latitude!)
                let longitude = CLLocationDegrees(student.longitude!)
                let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
                _ = student.uniqueKey
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinates
                annotation.title = "\(firstName) \(lastName)"
                annotation.subtitle = mediaURL
                annotations.append(annotation)
            }
            self.mapView.addAnnotations(annotations)
        })
    }
    
    //MARK: -- MKMapViewDelegate functions
    func mapView(mapview: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID) as? MKPinAnnotationView
        
        if(pinView == nil) {
            
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView!.canShowCallout = true
            _ = annotation.title!
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }else{
            pinView!.annotation = annotation
        }
        return pinView
    }

    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if(annotationView.annotation!.subtitle! != emptyURLSubtitleText) {
            if(control == annotationView.rightCalloutAccessoryView){
                let urlString = annotationView.annotation!.subtitle!
            
                if(verifyURL(urlString)){
                    UIApplication.sharedApplication().openURL(NSURL(string: urlString!)!)
                }else{
                    showAlertController("URL Lookup Failed", message: "The provided URL is not valid.")
            
                }
            }
        }
    }
    //MARK: -- Helpers
    // learned how to verify urls from this question: http://stackoverflow.com/questions/28079123/how-to-check-validity-of-url-in-swift
    func verifyURL(urlString: String?) -> Bool {
        
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                return UIApplication.sharedApplication().canOpenURL(url)
            }
        }
        return false
    }
    
    func showAlertController(title: String, message: String){
        
        dispatch_async(dispatch_get_main_queue(), {
            
            print("failure string from client: \(message)")
            
            let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            alert.addAction(okAction)
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        })
    }
}
