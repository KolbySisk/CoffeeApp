//
//  AddCoffeeTypeViewController.swift
//  CoffeeApp
//
//  Created by Kolby Sisk on 1/21/15.
//  Copyright (c) 2015 DATA, Inc. All rights reserved.
//

import UIKit
import Alamofire

class AddCoffeeTypeViewController: UIViewController, UIPickerViewDelegate, UITextFieldDelegate {
    
    var data = NSMutableArray()
    var active = false

    var selectedBrandId:String = ""
    var selectedBrandName:String = ""

    @IBOutlet var brandInput: UITextField!
    @IBOutlet var nameInput: UITextField!
    @IBOutlet var brandPicker: UIPickerView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    override func viewWillAppear(animated: Bool) {

        self.brandInput.delegate = self;
        self.nameInput.delegate = self;
        
        if self.data != []{
            if let initialBrandName: AnyObject? = self.data[0]["name"]{
                self.brandInput.text =  initialBrandName as String
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onNavCancel(sender: AnyObject) {
        self.popAddCoffeeView()
    }

    @IBAction func onCancel(sender: AnyObject) {
        self.popAddCoffeeView()
    }

    @IBAction func onSubmit(sender: AnyObject) {
        
        if self.active {
            return
        }

        self.active = true
        
        if(self.selectedBrandId != ""){
            
            let parameters = [
                "name": nameInput.text
            ]
            
            Alamofire.request(.POST, "http://coffee.datausadev.com/api/createCoffeeNameByBrandId/\(self.selectedBrandId)", parameters: parameters, encoding: .JSON)
                .responseJSON { (request, response, data, error) in

                    if(error == nil){
                        self.alertSuccessAndPopView()
                        self.active = false
                    }else{
                        // handle error
                    }
            }
        }else{
            
            let parameters: [String: NSObject] = [
                "name": brandInput.text,
                "coffeeNames": [[
                    "name": nameInput.text
                ]]
            ]
            
            Alamofire.request(.POST, "http://coffee.datausadev.com/api/createCoffeeBrand/", parameters: parameters, encoding: .JSON)
                .responseJSON { (request, response, data, error) in

                    if(error == nil){
                        self.alertSuccessAndPopView()
                        self.active = false
                    }else{
                        // handle error
                    }
            }
        }
    }
    
    func alertSuccessAndPopView(){
        var alert = UIAlertController(title: "New Coffee Type", message: "You added a new coffee type", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Sweet", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            self.popAddCoffeeView()
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func popAddCoffeeView(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    // MARK: - Picker

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return self.data.count
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String!{
        if let brandName: AnyObject? = self.data[row]["name"]{
            return brandName as String
        }
        
        return nil
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        
        if self.data != []{
            if let coffeeBrand: AnyObject? = self.data[row]["name"]{
                self.selectedBrandName = coffeeBrand as String
                brandInput.text = self.selectedBrandName
            }
            
            if let coffeeBrandId: AnyObject? = self.data[row]["_id"]{
                self.selectedBrandId = coffeeBrandId as String
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        self.view.endEditing(true);
        return false;
    }
    
}
