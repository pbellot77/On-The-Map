//
//  StudentTableViewController.swift
//  On The Map
//
//  Created by Patrick Bellot on 12/23/15.
//  Copyright © 2015 Swift File. All rights reserved.
//

import UIKit

class StudentTableViewController: UITableViewController {
    
    //MARK: -- Properties
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    //MARK: -- Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Adjust the tableView so that it's not covered by the tab bar
        let adjustForTabBar = UIEdgeInsetsMake(0, 0, CGRectGetHeight(tabBarController!.tabBar.frame), 0)
        tableView.contentInset = adjustForTabBar
        getStudentData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        setupNavigationBar()
        getStudentData()
    }
    
    //MARK: - Helper functions
    
    //Function to logout
    func logOut() {
        UdacityClient.sharedInstance().deleteSession() {(result, error) in
            
            guard error == nil else {
                let alertTitle = "Couldn't log out!"
                let alertMessage = error?.userInfo[NSLocalizedDescriptionKey] as? String
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.showAlert(alertTitle, errorString: alertMessage!)
                })
                return
            }
        }
        
        /* Show the log in view controller */
        tabBarController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Function that fetches the student data for the table
    func getStudentData(){
        
        /* Change the UI to indicat processing */
        let activityView = UIView.init(frame: tableView.frame)
        activityView.backgroundColor = UIColor.grayColor()
        activityView.alpha = 0.8
        view.addSubview(activityView)
        
        /* Show activity spinner when processing */
        let activitySpinner = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        activitySpinner.center = view.center
        activitySpinner.startAnimating()
        activityView.addSubview(activitySpinner)
        
        ParseClient.sharedInstance().getStudentLocations {(result, error) in
            
            /* GUARD: Was there an error fetching the student data? */
            guard error == nil else {
                let errorString = "There was a problem fetching the student data."
                
                /* Display an alert to the user stating there was an error getting student data */
                dispatch_async(dispatch_get_main_queue(), {
                    self.showStudentDataDownloadAlert(errorString)
                    
                    /* Show that activity has stopped */
                    activityView.removeFromSuperview()
                    activitySpinner.stopAnimating()
                })
                
                return
            }
            
            /* Clear any previously fetched student data */
            if !StudentInformation.studentData.isEmpty{
                StudentInformation.studentData.removeAll()
            }
            
            /* For each student in the return results add to the array */
            for s in result! {
                StudentInformation.studentData.append(StudentInformation(dictionary: s))
            }
            
            /* Sort the student data in order of last updated */
            StudentInformation.studentData = StudentInformation.studentData.sort() {$0.updatedAt.compare($1.updatedAt) == NSComparisonResult.OrderedDescending}
            
            /* Present the next view controller showing the student data */
            dispatch_async(dispatch_get_main_queue(), {
                activityView.removeFromSuperview()
                activitySpinner.stopAnimating()
                
                self.tableView.reloadData()
            })
        }
    }
    
    //MARK: -- User interface functions
    
    //Function that configures the navigation bar
    func setupNavigationBar() {
        let tableViewController = tabBarController?.viewControllers![1]
        
        /* Set the back button on the navigation bar to be log out */
        let customLeftBarButton = UIBarButtonItem(title: "Log out", style: .Plain, target: tableViewController, action: "logOut")
        navigationItem.setLeftBarButtonItem(customLeftBarButton, animated: false)
        
        /* Create an array of bar button items */
        var customButtons = [UIBarButtonItem]()
        
        /* Create pin button */
        let pinImage = UIImage(named: "pin")
        let pinButton = UIBarButtonItem(image: pinImage, style: .Plain, target: tableViewController, action: "presentInformationPostingViewController")
        
        /* Create refresh button */
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "getStudentData")
        
        /* Add the buttons to the array */
        customButtons.append(refreshButton)
        customButtons.append(pinButton)
        
        /* Add the buttons to the nav bar */
        navigationItem.setRightBarButtonItems(customButtons, animated: false)
    }
    
    //Function that returns styled text from a unstyled string
    func getAttributedText(textToStyle: String) -> NSMutableAttributedString{
        let rangeToStyle = NSRange.init(location: 0, length: (textToStyle as NSString).length)
        let attributedText = NSMutableAttributedString(string: textToStyle)
        let font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        attributedText.addAttributes([NSFontAttributeName: font!], range: rangeToStyle)
        
        return attributedText
    }
    
    //MARK: -- Error helper functions
    
    //Function that presents an alert failure for downloading student data
    func showStudentDataDownloadAlert(errorString: String) {
        showAlert("Download failed", errorString: errorString)
    }
    
    //Function that configures and shows an alert
    func showAlert(titleString: String, errorString: String){
        
        /* Configure the alert view to display the error */
        let alert = UIAlertController(title: titleString, message: errorString, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Try Again", style: .Default, handler: nil))
        
        /* Present the alert view */
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //Mark: -- Table view data source
    
    //Function for defining the number of rows the table should have.
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentInformation.studentData.count
    }
    
    //Function for defining the contents for each row
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("studentCell")!
        let student = StudentInformation.studentData[indexPath.row]
        let textForTitle = student.firstName + "" + student.lastName
        
        cell.textLabel?.attributedText = getAttributedText(textForTitle)
        cell.detailTextLabel!.text = student.mediaURL
        
        return cell
    }
    
    //Function that opens a webpage when a row is clicked
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let app = UIApplication.sharedApplication()
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath){
            if let toOpen = cell.detailTextLabel?.text {
                if UIApplication.sharedApplication().canOpenURL(NSURL(string: toOpen)!){
                    let url = NSURL(string: toOpen)
                    app.openURL(url!)
                } else {
                    showAlert("Unable to load webpage", errorString: "Webpage couldn't be opened because the link was invalid.")
                }
            }
        }
    }
}
