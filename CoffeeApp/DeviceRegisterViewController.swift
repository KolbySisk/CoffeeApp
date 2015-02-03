//
//  DeviceRegisterViewController.swift
//  CoffeeApp
//
//  Created by Kolby Sisk on 1/19/15.
//  Copyright (c) 2015 DATA, Inc. All rights reserved.
//

import UIKit
import Alamofire

class DeviceRegisterViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var deviceName: UITextField!
    
    var deviceId = NSUserDefaults.standardUserDefaults().objectForKey("deviceId") as String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        var type = UIUserNotificationType.Badge | UIUserNotificationType.Alert | UIUserNotificationType.Sound
        var setting = UIUserNotificationSettings(forTypes: type, categories: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelDeviceRegistration(sender: AnyObject) {
        deviceName.resignFirstResponder()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submitDeviceRegistration(sender: AnyObject) {
        let parameters = [
            "deviceId": deviceId,
            "deviceOwner": deviceName.text
        ]
        
        Alamofire.request(.POST, "http://coffee.datausadev.com/api/createIosDevice", parameters: parameters, encoding: .JSON)
            .responseJSON { (request, response, data, error) in
                
                if(error == nil){
                    NSUserDefaults.standardUserDefaults().setObject(true, forKey: "deviceAdded")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    var alert = UIAlertController(title: "Registered", message: "Thanks for registering!", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    alert.addAction(UIAlertAction(title: "Cool", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
                        self.dismissModal()
                    }))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                }else{
                    // handle error if post returns an error
                }
        }
    
        deviceName.resignFirstResponder()
    }
    
    func dismissModal(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
    }
    
    func keyboardWillHide(notification: NSNotification) {
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
