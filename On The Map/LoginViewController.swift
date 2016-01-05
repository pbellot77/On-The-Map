//
//  LoginViewController.swift
//  On The Map
//
//  Created by Patrick Bellot on 12/3/15.
//  Copyright © 2015 Swift File. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
   //MARK: -- Properties
    let gradientLayer = CAGradientLayer()
    var session: NSURLSession!
    var appDelegate: AppDelegate!
    
    //MARK: -- Outlets
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    //MARK: -- View lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Get the shared URL session */
        session = NSURLSession.sharedSession()
        
        /* Get the app delegate */
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        /* Configure the look and feel of the user interface */
        configureUI()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setGradientLayerFrame()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        hideNavigationBar()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        //Show the navigation bar
        navigationController?.navigationBar.hidden = false
    }
    
    //MARK: -- Actions
    
    //Function is called when a user presses the log in button; it authenticates with Udacity
    @IBAction func logInButton(sender: UIButton) {
        
        /* Disable the buttons in the UIonce the Login button has been pressed */
        disableButtons(sender)
        
        /* Show activity to show the app is processing data */
        let activityView = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        activityView.center = view.center
        activityView.startAnimating()
        view.addSubview(activityView)
        
        /* POST a new session */
        UdacityClient.sharedInstance().postSession(emailTextField.text!, password: passwordTextField.text!) {(result, error) in
            
            /* GUARD: Was there an error? */
            guard error == nil else {
                
                /* Check to see what type of error occured */
                if let errorString = error?.userInfo[NSLocalizedDescriptionKey] as? String {
                    
                    /* Display an alert and shake the view letting the user know the authentication failed */
                    dispatch_async(dispatch_get_main_queue(),{
                        
                        self.showAuthenticationAlert(errorString)
                        self.shakeScreen()
                        activityView.stopAnimating()
                    })
                }
                return
            }
            
            self.appDelegate.userID = result!
            
            dispatch_async(dispatch_get_main_queue(), {
                
                // Display the tabbed view controller
                let tabViewController = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController")
                self.navigationController?.pushViewController(tabViewController, animated: true)
                
                //Stop animating the spinner and enable buttons
                self.enableButtons(sender)
                activityView.stopAnimating()
            })
        }
    }
   //Function is called when a user presses the sign up button; opens the Udacity sign in page in safari
    @IBAction func signUpButton(sender: UIButton){
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signin")!)
    }
    
    //MARK: -- Helper functions
    
    //MARK: -- User interface helper functions
    //Function sets up the user interface
    func configureUI(){
        //Add set and add gradientLayer to the view
        setGradientLayerColors()
        setGradientLayerFrame()
        view.layer.insertSublayer(gradientLayer, atIndex: 0)
        
        //Configure the textFields to each have an indent
        indentTextInTextfield(emailTextField)
        indentTextInTextfield(passwordTextField)
        
        //Configure the placeholder text in the textfields to be white
        configurePlaceHolderText()
        
        //Make the ViewController the delegate of the text fields
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        //Round the corners of the buttons
        roundButtonCorner(loginButton)
        roundButtonCorner(facebookLoginButton)
        
        //Hide the navigation bar
        hideNavigationBar()
        
        //Facebook integration not implemented so hide the button
        facebookLoginButton.hidden = true
    }
    
    //Function to hide the navigation
    func hideNavigationBar(){
        navigationController?.navigationBar.hidden = true
    }
    
    //Function that rounds the corners of the button
    func roundButtonCorner(button: UIButton){
        button.layer.cornerRadius = 3
        button.clipsToBounds = true
    }
    
    //Function to enable the login button
    func enableButtons(sender: UIButton){
        loginButton.enabled = true
        facebookLoginButton.enabled = true
        signUpButton.enabled = true
        sender.alpha = 1.0
    }
    
    //Function to diable the login button to prevent it from being pressed multiple times
    func disableButtons(sender: UIButton) {
        loginButton.enabled = true
        facebookLoginButton.enabled = false
        signUpButton.enabled = false
        sender.alpha = 1.0
    }
    
    //Function that sets the frame of the gradient layer to the bounds of the mainView
    func setGradientLayerFrame(){
        gradientLayer.frame = mainView.bounds
    }
    
    //Function that sets the colors of the gradient layer
    func setGradientLayerColors(){
        
        //Light orange
        let firstColor = UIColor(red: 0.992, green: 0.592, blue: 0.165, alpha: 1)
        //Dark orange
        let secondColor = UIColor(red: 0.992, green: 0.435, blue: 0.129, alpha: 1)
        gradientLayer.colors = [firstColor.CGColor, secondColor.CGColor]
    }
    
    //MARK: -- Textfield helper functions
    
    //Function that sets the color and placeholder text for locationTextField
    func indentTextInTextfield(textField: UITextField) {
        let spacerView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        textField.leftViewMode = UITextFieldViewMode.Always
        textField.leftView = spacerView
    }
    
    //Function that sets the color and placeholder text for locationTextField
    func configurePlaceHolderText(){
        /*Set the style for the Email text field */
        var attributedString = NSAttributedString(string: "Email", attributes:  [NSForegroundColorAttributeName:UIColor.whiteColor()])
        emailTextField.attributedPlaceholder = attributedString
        /*Set the style for the Password text field */
        attributedString = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        passwordTextField.attributedPlaceholder = attributedString
        
    }
    
    //MARK: -- Error helper functions
    
    //Functions that presents an alert to the user with a reason as to why their login failed
    func showAuthenticationAlert(errorString: String){
        let titleString = "Authentication failed!"
        var errorString = errorString
        
        if errorString.rangeOfString("400") != nil{
            errorString = "Please enter your email address and password."
        } else if errorString.rangeOfString("403")  != nil {
            errorString = "Wrong email address or password entered."
        } else if errorString.rangeOfString("1009") != nil {
            errorString = "Something is wrong with the network connection."
        } else {
            errorString = "Something went wrong! Try again"
        }
        
        showAlert(titleString, alertMessage: errorString, actionTitle: "Try again")
    }
    
    //Function that configures and shows an alert
    func showAlert(alertTitle: String, alertMessage: String, actionTitle: String){
        
        /* Configure the alert view to display the error */
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .Default, handler: nil))
        
        /* Present the alert view */
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //Function that animates the screen to show login has failed
    func shakeScreen(){
        
        /*Configure a shake animation */
        let shakeAnimation = CABasicAnimation(keyPath: "position")
        shakeAnimation.duration = 0.07
        shakeAnimation.repeatCount = 4
        shakeAnimation.autoreverses = true
        shakeAnimation.fromValue = NSValue(CGPoint: CGPointMake(self.mainView.center.x - 10, self.mainView.center.y - 10))
        shakeAnimation.toValue = NSValue(CGPoint: CGPointMake(self.mainView.center.x + 10, self.mainView.center.y + 10))
        
        /* Shake the view */
        self.mainView.layer.addAnimation(shakeAnimation, forKey: "position")
    }
    
    //MARK: -- Text field delegate functions
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}

