//
//  ViewController.swift
//  CoffeeApp
//
//  Created by Kolby Sisk on 1/19/15.
//  Copyright (c) 2015 DATA, Inc. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    var lastBrewData:AnyObject = []
    var currentBrewData:AnyObject = []
    var dataLoading = true
    var active = false
    var timer: NSTimer?
    var startTime: NSDate?
    var secondsSinceBrew:Int = 0
    var deviceAdded:Bool? = nil

    let dateTimeFormatter = NSDateFormatter()
    
    @IBOutlet var timeSinceBrewedLabel: UILabel!
    @IBOutlet var currentCoffeeBrandLabel: UILabel!
    @IBOutlet var currentCoffeeNameLabel: UILabel!
    @IBOutlet var currentBrewTimeLabel: UILabel!
    @IBOutlet var clockView: ClockView!
    
    override func viewDidLoad() {
        
        dateTimeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateTimeFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        dateTimeFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillEnterForeground:", name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidEnterBackground:", name: UIApplicationDidEnterBackgroundNotification, object: nil)

        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)

        // check if device has been added using userDefaults
        // if it hasn't run setDeviceStatus and show modal
        // if it has check to make sure deviceId hasn't been removed from the Database

        self.deviceAdded = NSUserDefaults.standardUserDefaults().objectForKey("deviceAdded") as Bool!
        
        if self.deviceAdded == nil {
            self.performSegueWithIdentifier("ShowDeviceRegistration", sender: nil)
        }else{
            // TODO: Show loading indicator
            self.LoadData()
            self.checkDeviceStatus()
        }
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        self.LoadData()
    }
    
    func applicationDidEnterBackground(applicaton: UIApplication){
        self.timer?.invalidate()
        self.clockView.timer?.invalidate()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.timer?.invalidate()
        self.clockView.timer?.invalidate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // checkDeviceStatus checks to make sure the device's deviceId is still stored in the database.
    // If it isn't we will set the deviceAdded Key to false and then show the deviceRegistration Modal
    
    func checkDeviceStatus(){
        var check:Bool = false
        var token = NSUserDefaults.standardUserDefaults().objectForKey("deviceId") as String!
        
        Alamofire.request(.GET, "http://coffee.datausadev.com/api/getIosDevices")
            .responseJSON { (request, response, data, error) in
                if error == nil {
                    let dataArray = data as NSArray;
                    
                    for item in dataArray {
                        let deviceId = item["deviceId"] as String
                        
                        if deviceId == token {
                            check = true
                        }
                    }
                    
                    if !check {
                        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "deviceAdded")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        
                        self.performSegueWithIdentifier("ShowDeviceRegistration", sender: nil)
                    }
                }
        }
    }
    
    func LoadData(){
        self.dataLoading = true
        self.loadLastBrew()
    }
    
    func loadLastBrew(){
        
        let startDateTime = NSDate(timeIntervalSinceNow: -1*24*60*60)
        let endDateTime = NSDate()
        
        Alamofire.request(.GET, "http://coffee.datausadev.com/api/getCoffeeEvents/\(dateTimeFormatter.stringFromDate(startDateTime))/\(dateTimeFormatter.stringFromDate(endDateTime))")
            .responseJSON { (request, response, data, error) in
                let dataArray = data as NSArray

                if let lastBrew: AnyObject = dataArray.lastObject{
                    
                    if lastBrew["eventType"] as String! == "BREWING" {
                        self.currentBrewData = lastBrew
                        self.setUpBrewedUI()
                    }else{
                        self.setUpEmptyUI()
                    }
                    
                    self.lastBrewData = lastBrew
                    self.clockView.lastBrewData = lastBrew
                    self.clockView.initClockView()
                }
                
                self.dataLoading = false
        }
    }
    
    func setUpBrewedUI(){
        
        // set current coffee label

        let lastBrewBrand = self.currentBrewData["coffeeBrand"] as String!
        let lastBrewCoffeeName = self.currentBrewData["coffeeName"] as String!
        
        
        // set time brewed label

        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "h:mm"
        
        let nsDateLastBrewTime = dateTimeFormatter.dateFromString(self.currentBrewData["dateTime"] as String!)
        
        let lastBrewTime = timeFormatter.stringFromDate(nsDateLastBrewTime!)
        
        self.currentCoffeeBrandLabel.text = lastBrewBrand
        self.currentCoffeeNameLabel.text = lastBrewCoffeeName
        self.currentBrewTimeLabel.text = "Brewed at \(lastBrewTime)"
        
        
        // set time since brew

        let now = NSDate()
        
        let converter = now.timeIntervalSinceDate(nsDateLastBrewTime!) as NSNumber
        
        self.secondsSinceBrew = converter as Int
        
        let timeSinceBrew = self.secondsToHoursMinutesSeconds(secondsSinceBrew)
        
        self.timeSinceBrewedLabel.text = "\(timeSinceBrew.0):\(timeSinceBrew.1):\(timeSinceBrew.2)"
        
        self.startTimer()
    }
    
    func setUpEmptyUI(){
        
    }
    
    
    
    // MARK: Timer functionality

    func startTimer(){
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateTime"), userInfo: nil, repeats: true)
    }
    
    
    func updateTime(){
        self.secondsSinceBrew += 1

        let timeSinceBrew = self.secondsToHoursMinutesSeconds(secondsSinceBrew as Int)
        
        self.timeSinceBrewedLabel.text = "\(timeSinceBrew.0):\(timeSinceBrew.1):\(timeSinceBrew.2)"
    }
    
    
    func secondsToHoursMinutesSeconds (s : Int) -> (String, String, String) {
        let intFormatter = NSNumberFormatter()
        intFormatter.minimumIntegerDigits = 2
        
        let hours = String(s / 3600)
        let minutes = intFormatter.stringFromNumber((s % 3600) / 60)!
        let seconds = intFormatter.stringFromNumber((s % 3600) % 60)!
        
        return (hours, minutes, seconds)
    }
    
    
    
    // MARK: UI Actions
    
    @IBAction func onBrewClick(sender: AnyObject) {

        if self.dataLoading {
            return
        }

        self.performSegueWithIdentifier("ShowCoffeeList", sender: nil)
    }

    @IBAction func onCancelClick(sender: AnyObject) {
        
        if self.dataLoading || active {
            return
        }
        
        self.active = true

        if currentBrewData as NSObject != []{
            let parameters: [String: NSObject] = [
                //"_id": brew["_id"] as String!,
                "coffeeBrand": self.lastBrewData["coffeeBrand"] as String!,
                "coffeeName": self.lastBrewData["coffeeName"] as String!,
                "dateTime": self.lastBrewData["dateTime"] as String!,
                "deviceId": self.lastBrewData["deviceId"] as String!,
                "eventType": "CANCELED"
            ]
            
            Alamofire.request(.POST, "http://coffee.datausadev.com/api/createCoffeeEvent", parameters: parameters, encoding: .JSON)
                .responseJSON { (request, response, data, error) in
                    
                    if error == nil {
                        
                        self.timer?.invalidate()
                        self.currentBrewData = []
                        self.currentCoffeeBrandLabel.text = ""
                        self.currentCoffeeNameLabel.text = ""
                        self.currentBrewTimeLabel.text = ""
                        self.timeSinceBrewedLabel.text = ""

                        var alert = UIAlertController(title: "Brew Canceled", message: "The last brew has been canceled", preferredStyle: UIAlertControllerStyle.Alert)
                        
                        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                        
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                        self.active = false
                        self.clockView.removeClockView()

                    }else{
                        // handle error
                    }
            }
        }else{
            
            var alert = UIAlertController(title: "Nothing is brewing", message: "As far as I know there is nothing brewing. If you start a brew don't forget to use the app.", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if self.deviceAdded != nil {
            
            let coffeeTableView:CoffeeTableViewController = segue.destinationViewController as CoffeeTableViewController
            
            coffeeTableView.lastBrewedData = self.lastBrewData
        }
    }
}














