//
//  CoffeeTableViewController.swift
//  CoffeeApp
//
//  Created by Kolby Sisk on 1/20/15.
//  Copyright (c) 2015 DATA, Inc. All rights reserved.
//

import UIKit
import Alamofire

class CoffeeTableViewController: UITableViewController {
    
    var data = NSMutableArray()
    var brandData = NSMutableArray()
    var lastBrewedData:AnyObject = []
    var deviceId = NSUserDefaults.standardUserDefaults().objectForKey("deviceId") as String!
    var dataLoading = true
    var active = false
    
    @IBOutlet var lastBrewedBrandLabel: UILabel!
    
    @IBOutlet var lastBrewedNameLabel: UILabel!
    
    @IBOutlet var lastBrewedView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.addLastBrewInfoView()

        self.loadData()
    }
    
    func addLastBrewInfoView(){
        
        println(lastBrewedData)
        
        if let lastBrewedCoffeeBrand: AnyObject? = self.lastBrewedData["coffeeBrand"]{
            self.lastBrewedBrandLabel.text = lastBrewedCoffeeBrand as? String
        }
        
        if let lastBrewedCoffeeName: AnyObject? = self.lastBrewedData["coffeeName"]{
            self.lastBrewedNameLabel.text = lastBrewedCoffeeName as? String
        }
        
        if self.lastBrewedData as NSObject == []{
            lastBrewedView.removeFromSuperview()
        }
        
        // attempt to hide the last brewed coffee view for first time using the app and there hasn't been anything brewed yet.
        // stopped half way through because this will never be used.
//        let screenSize: CGRect = UIScreen.mainScreen().bounds
//        
//        var brewInfoView = UIView(frame: CGRectMake(0, 0, screenSize.width, 150))
//        view.backgroundColor = UIColor.redColor()
//        self.view.addSubview(brewInfoView)
//        
//        var titleLabel = UILabel(frame: CGRectMake(0, 13, screenSize.width, 20))
//        titleLabel.textAlignment = NSTextAlignment.Center
//        titleLabel.text = "Last coffee brewed was:"
//        brewInfoView.addSubview(titleLabel)
        
        
    }
    
    
    func loadData(){
        self.dataLoading = true
        self.data = NSMutableArray()
        self.brandData = NSMutableArray()
        
        //store data in singleton or alamocache

        Alamofire.request(.GET, "http://coffee.datausadev.com/api/getCoffeeBrands")
            .responseJSON { (request, response, data, error) in

                let coffeeBrands = data as NSArray;

                for brand in coffeeBrands {
                    var coffeeTypes = NSMutableArray()

                    let coffeeBrandName = brand["name"] as String
                    let coffeeBrandId = brand["_id"] as String
                    
                    let coffeeNames = brand["coffeeNames"] as NSMutableArray
                    
                    self.brandData.addObject(brand)

                    for name in coffeeNames{
                        let coffeeName = name["name"] as String
                        let coffeeType = ["BrandId": coffeeBrandId, "coffeeBrand": coffeeBrandName, "coffeeName": coffeeName]
                        
                        self.data.addObject(coffeeType)
                    }
                }
                
                // order data by the Brand name
                var descriptor: NSSortDescriptor = NSSortDescriptor(key: "coffeeBrand", ascending: true)
                self.data.sortUsingDescriptors([descriptor])
                

                self.tableView.reloadData()
                
                self.dataLoading = false
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)
        
        let selectedCoffee: AnyObject = self.data[indexPath.row]
        
        postCoffeEvent(selectedCoffee)
    }
    
    func postCoffeEvent(selectedCoffee: AnyObject){
        
        if self.active{
            return
        }

        self.active = true

        let coffeeBrand = selectedCoffee["coffeeBrand"] as String!
        let coffeeName = selectedCoffee["coffeeName"] as String!

        let parameters = [
            "deviceId": deviceId,
            "coffeeName" : coffeeName,
            "coffeeBrand": coffeeBrand,
            "eventType": "BREWING"
        ]
        
        Alamofire.request(.POST, "http://coffee.datausadev.com/api/createCoffeeEvent", parameters: parameters, encoding: .JSON)
            .responseJSON { (request, response, data, error) in
                if(error == nil){
                    
                    // show alert to confirm the coffee event has been successfully posted
                    
                    var alert = UIAlertController(title: "Mmmm Coffee", message: "Thanks for brewing coffee!", preferredStyle: UIAlertControllerStyle.Alert)

                    alert.addAction(UIAlertAction(title: "Cool", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
                        self.popCoffeeTableView()
                    }))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                    self.active = false

                }else{
                    // handle error
                }
        }
    }
    
    func popCoffeeTableView(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    
    
    
    @IBAction func onUseLastBrewedCoffee(sender: AnyObject) {
        self.postCoffeEvent(self.lastBrewedData)
    }
    
    
    
    
    
    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return data.count
    }

    @IBAction func onCloseModal(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: CoffeeTableViewCell = tableView.dequeueReusableCellWithIdentifier("cell") as CoffeeTableViewCell
        
        if !self.dataLoading{
            cell.brandLabel.text = data[indexPath.row]["coffeeBrand"] as? String
            cell.nameLabel.text = data[indexPath.row]["coffeeName"] as? String
        }

        return cell
    }
    

    
    
    
    
    // MARK: - Navigation
    
    @IBAction func onShowAddCoffeeTypeView(sender: AnyObject) {
        if self.dataLoading{
            return
        }
        
        self.performSegueWithIdentifier("showAddCoffeeType", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let addCoffeeTypeView:AddCoffeeTypeViewController = segue.destinationViewController as AddCoffeeTypeViewController
        
        addCoffeeTypeView.data = self.brandData
    }

    
    
    
    
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

}
