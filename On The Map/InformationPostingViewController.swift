//
//  InformationPostingViewController.swift
//  On The Map
//
//  Created by Patrick Bellot on 12/28/15.
//  Copyright © 2015 Swift File. All rights reserved.
//

import UIKit
import MapKit

class InformationPostingViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate {
    
    //MARK: -- Outlets
    @IBOutlet weak var studyingLabel: UILabel!
    @IBOutlet weak var locationPromptView: UIView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var findOnTheMapButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: -- Properties
    var userLocation = [CLPlacemark]()
    var appDelegate: AppDelegate!
    
    /*Student Location details*/
    var studentLat = CLLocationDegrees()
    var studentLon = CLLocationDegrees()
    var studentLocationName = ""

    //MARK: -- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        /* Make this View Controller the delegate of the text fields */
        locationTextField.delegate = self
        urlTextField.delegate = self
        
        /* textfield and button setup */
        configurePlaceholderText("Enter your location here", textField: locationTextField)
        roundButtonCorner(findOnTheMapButton)
        boldText()
    }
    
    //MARK: -- Actions
    @IBAction func cancel(sender: UIButton){
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func findOnTheMap(sender: UIButton){
        
        let geocoder = CLGeocoder()
        if let stringToGeocode = locationTextField.text {
            guard stringToGeocode != "" else {
                
                let alertTitle = "No location provided"
                let alertMessage = "You must enter your location before proceeding"
                let actionTitle = "OK"
                showAlert(alertTitle, alertMessage: alertMessage, actionTitle: actionTitle)
                return
            }
            
            let activityView = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
            activityView.center = view.center
            activityView.startAnimating()
            view.addSubview(activityView)
            
            /* Make the UI appear disabled */
            let views = [cancelButton!, studyingLabel!, locationTextField!, locationPromptView!, findOnTheMapButton!]
            changeAlphaFor(views, alpha: 0.5)
            
            /* Geocode the provided string */
            geocoder.geocodeAddressString(stringToGeocode) { (placemark, error) in
                
                guard error == nil else {
                    
                    let alertTitle = "Couldn't get your location"
                    let alertMessage = "There was an error while fetching you location"
                    let actionTitle = "Try Again"
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.showAlert(alertTitle, alertMessage: alertMessage, actionTitle: actionTitle)
                        self.changeAlphaFor(views, alpha: 1.0)
                        activityView.stopAnimating()
                    })
                    
                    return
                }
                
                /* Assign the returned location to the userLocation property */
                self.userLocation = placemark!
                
                /* Setup the map with the pin coresponding to placemark */
                self.configureMap()
                
                /* Makes the appropriate changes to the UI after getting a successful placemark */
                self.changeUserInterface()
                
                // Stop the activity spinner
                activityView.stopAnimating()
            }
        }
    }
    
    @IBAction func submitStudentLocation(sender: UIButton){
        
        guard urlTextField.text! != "" else{
            
            let alertTitle = "No URL provided"
            let alertMessage = "You must enter a URL before proceeding"
            let actionTitle = "OK"
            showAlert(alertTitle, alertMessage: alertMessage, actionTitle: actionTitle)
            return
        }
        
        guard UIApplication.sharedApplication().canOpenURL(NSURL(string: urlTextField.text!)!) else {
            let alertTitle = "Invalid URL provided"
            let alertMessage = "You must enter a valid URL before proceeding. Ensure you include http:// or https://"
            let actionTitle = "OK"
            showAlert(alertTitle, alertMessage: alertMessage, actionTitle: actionTitle)
            return
        }
        
        /*Prepare the data to POST to the Parse API */
        let studentLocationArray : [String : AnyObject] = [
            ParseClient.JSONBodyKeys.UniqueKey: appDelegate.userID,
            ParseClient.JSONBodyKeys.FirstName: appDelegate.userData[0],
            ParseClient.JSONBodyKeys.LastName: appDelegate.userData[1],
            ParseClient.JSONBodyKeys.MapString: studentLocationName,
            ParseClient.JSONBodyKeys.MediaURL: urlTextField.text!,
            ParseClient.JSONBodyKeys.Latitude: studentLat,
            ParseClient.JSONBodyKeys.Longitude: studentLon
        ]
        
        if appDelegate.objectID == "" {
            
            ParseClient.sharedInstance().postStudentLocation(studentLocationArray) {(result, error) in
            
                guard error == nil else {
                    
                    let alertTitle = "Couldn't submit your location"
                    let alertMessage = "There was an error while trying to post your location to the server."
                    let actionTitle = "Try again"
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                    return
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            }
            
        } else {
                
                ParseClient.sharedInstance().putStudentLocation(appDelegate.objectID, jsonBody: studentLocationArray) {(result, error) in
                    
                    guard error == nil else {
                        
                        let alertTitle = "Couldn't update your location"
                        let alertMessage = "There was an error while trying to update you location on the server."
                        let actionTitle = "Try again"
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            self.showAlert(alertTitle, alertMessage: alertMessage, actionTitle: actionTitle)
                        })
                        return
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
            }
        }
    }
    
    //MARK: -- Helper functions and User Helper functions
    func configurePlaceholderText(text: String, textField: UITextField){
        let attributedString = NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        textField.attributedPlaceholder = attributedString
    }
    
    func roundButtonCorner(button: UIButton){
        button.layer.cornerRadius = 6
        button.clipsToBounds = true
    }
    
    func boldText(){
        let text = studyingLabel.text!
        let attributedText = NSMutableAttributedString(string: text)
        let font = UIFont(name: "HelveticaNeue-Medium", size: 25)
        
        attributedText.addAttributes([NSFontAttributeName: font!], range: NSRange.init(location: 14, length: 8))
        studyingLabel.attributedText = attributedText
    }
    
    func changeAlphaFor(views: [UIView], alpha: CGFloat){
        
        for view in views{
            view.alpha = alpha
        }
    }
    
    func changeUserInterface(){
        
        cancelButton.titleLabel?.textColor = UIColor.whiteColor()
        changeAlphaFor([self.cancelButton], alpha: 1.0)
        
        studyingLabel.hidden = true
        locationPromptView.hidden = true
        findOnTheMapButton.hidden = true
        
        configurePlaceholderText("Enter a link to share here", textField: self.urlTextField)
        urlTextField.hidden = false
        
        submitButton.hidden = false
        roundButtonCorner(self.submitButton)
        
        mapView.hidden = false
        
        view.backgroundColor = UIColor(red: 65.0/255.0, green: 117.0/255.0, blue: 164.0/255.0, alpha: 1)
    }
    
    func configureMap(){
        let topPlacemarkResult = self.userLocation[0]
        let placemarkToPlace = MKPlacemark(placemark: topPlacemarkResult)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemarkToPlace.coordinate
        
        studentLocationName = placemarkToPlace.name!
        
        studentLat = annotation.coordinate.latitude
        studentLon = annotation.coordinate.longitude
        let pinCoordinate = CLLocationCoordinate2DMake(studentLat, studentLon)
        
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegionMake(pinCoordinate, span)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.mapView.addAnnotation(annotation)
            self.mapView.setRegion(region, animated: true)
            self.mapView.regionThatFits(region)
        })
    }
    
    //MARK: -- Error helper functions
    func showAlert(alertTitle: String, alertMessage: String, actionTitle: String){
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: -- Textfield delegate functions
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
