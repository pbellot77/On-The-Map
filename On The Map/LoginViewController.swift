//
//  LoginViewController.swift
//  On The Map
//
//  Created by Patrick Bellot on 12/3/15.
//  Copyright © 2015 Swift File. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    
    //Mark -- Outlets
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    //Mark -- Variables
    var appDelegate: AppDelegate!
    var session: NSURLSession!
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    //Mark -- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        session = NSURLSession.sharedSession()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        //set placeholder text color
        //found from Stackoverflow topic: http://stackoverflow.com/questions/26076054/changing-placeholder-text-color-with-swift
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSBackgroundColorAttributeName: UIColor.whiteColor()])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSBackgroundColorAttributeName: UIColor.whiteColor()])
        
        //left indent
        //found from Stackoverflow topic: http://stackoverflow.com/questions/7565645/indent-the-text-in-a-uitextfield
        let emailSpacerView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        emailTextField.leftViewMode = UITextFieldViewMode.Always
        emailTextField.leftView = emailSpacerView
        
        let passwordSpacerView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        passwordTextField.leftViewMode = UITextFieldViewMode.Always
        passwordTextField.leftView = passwordSpacerView
        
        loginButton.enabled = false
        
        //initialize tap recognizer
        tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleSingleTap:"))
        tapRecognizer!.numberOfTapsRequired = 1
    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        addKeyboardDismissRecognizer()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeKeyboardDismissRocognizer()
        
        emailTextField.text = ""
        passwordTextField.text = ""
        loginButton.enabled = false
    }
    
    
    @IBAction func loginToUdacity(sender: UIButton) {
        dismissAnyVisibleKeyboards()
        
        UdacityClient.sharedInstance().createSession(emailTextField.text!, password: passwordTextField.text!){ message, error in
        
                if let error = error {
                print("Login Failed: \(message)")
                let failureString = error.localizedDescription
                
                if(failureString.rangeOfString("server") != nil){
                    self.displayError("\(failureString)")
                }else{
                    self.shakeView()
                }
                    
            }else{
                    
                print("Login Complete! \(message)")
                self.completeLogin()
            }
        }
    }
    
    @IBAction func signUpWithUdacity(sender: UIButton) {
        let url = NSURL(string: "https://www.google.com/url?q=https://www.udacity.com/account/auth%23!/signin&sa=D&usg=AFQjCNHOjlXo3QS15TqT0Bp_TKoR9Dvypw")!
        UIApplication.sharedApplication().openURL(url)
    }
    
    //Mark -- Login
    func completeLogin(){
        
        dispatch_async(dispatch_get_main_queue(), {
          
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("UserTabBarController") as! UITabBarController
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }
    
    //learned shake animation from stackOverflow: http://stackoverflow.com/questions//27987048/shake-animation-for-uitextfield-uiview-in-swift
    func shakeView(){
        
        dispatch_async(dispatch_get_main_queue(), {
            
            let animation = CABasicAnimation(keyPath: "position")
            animation.duration = 0.07
            animation.repeatCount = 4
            animation.autoreverses = true
            animation.fromValue = NSValue(CGPoint: CGPointMake(self.view.center.x - 5, self.view.center.y))
            animation.toValue = NSValue(CGPoint: CGPointMake(self.view.center.x + 5, self.view.center.y))
            self.view.layer.addAnimation(animation, forKey: "position")
        })
    }
    
    func displayError(errorString: String?){
        UdacityClient.sharedInstance().loginError = errorString
        
        dispatch_async(dispatch_get_main_queue(), {
            
            let alert: UIAlertController = UIAlertController(title: "Login Failed", message: errorString, preferredStyle: .Alert)
            let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            alert.addAction(okAction)
            
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    @IBAction func textFieldChanged(sender: UITextField) {
        
        if(emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty){
            loginButton.enabled = false
        }else{
            loginButton.enabled = true
        }
    }
    
    // Mark -- Keyboard helpers
    func addKeyboardDismissRecognizer(){
        view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRocognizer(){
        view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

extension LoginViewController{
    func dismissAnyVisibleKeyboards(){
        
        if(emailTextField.isFirstResponder() || passwordTextField.isFirstResponder()){
            view.endEditing(true)
        }
    }
}

