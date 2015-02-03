//
//  ClockView.swift
//  CoffeeApp
//
//  Created by Kolby Sisk on 1/26/15.
//  Copyright (c) 2015 DATA, Inc. All rights reserved.
//

import UIKit

class ClockView: UIView {

    var circleBottomLayer: CAShapeLayer!
    var circleTopLayer: CAShapeLayer!
    var circleFillLayer: CAShapeLayer!

    var lastBrewData:AnyObject = []
    var timer: NSTimer?
    var startAngle: CGFloat = 0

    let dateTimeFormatter = NSDateFormatter()
        
    func initClockView(){
        
        dateTimeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateTimeFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        dateTimeFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")

        if let lastBrewDateTime: AnyObject? = self.lastBrewData["dateTime"]{
            if lastBrewData["eventType"] as String! == "BREWING" {
                makeProgressMeter()
            }else{
                // the last event was probably CANCLE meaning there is no coffee.
                // change the view to show a BREW button
            }
        }
    }
    
    func makeProgressMeter(){
        
        // set up properties of the fill layer that do not change

        self.startAngle = self.timeToRadians(self.lastBrewData["dateTime"] as String!)
        circleFillLayer = CAShapeLayer()
        circleFillLayer.fillColor = UIColor.clearColor().CGColor
        circleFillLayer.strokeColor = UIColor(red: 188/255, green: 101/255, blue: 34/255, alpha: 1).CGColor
        circleFillLayer.lineWidth = 10.0;
        circleFillLayer.strokeEnd = 1
        
        
        // set up background layers
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0), radius: (frame.size.width - 10)/2, startAngle: 0.0, endAngle: CGFloat(M_PI * 2.0), clockwise: true)

        circleBottomLayer = CAShapeLayer()
        circleBottomLayer.path = circlePath.CGPath
        circleBottomLayer.fillColor = UIColor.clearColor().CGColor
        circleBottomLayer.strokeColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5).CGColor
        circleBottomLayer.lineWidth = 20.0;
        circleBottomLayer.strokeEnd = 1.0
        
        circleTopLayer = CAShapeLayer()
        circleTopLayer.path = circlePath.CGPath
        circleTopLayer.fillColor = UIColor.clearColor().CGColor
        circleTopLayer.strokeColor = UIColor(red: 188/255, green: 101/255, blue: 34/255, alpha: 0.2).CGColor
        circleTopLayer.lineWidth = 12.0;
        circleTopLayer.strokeEnd = 1.0
        
        layer.addSublayer(circleBottomLayer)
        layer.addSublayer(circleTopLayer)
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateProgress"), userInfo: nil, repeats: true)
    }
    
    func updateProgress(){
        
        let now = dateTimeFormatter.stringFromDate(NSDate())
        
        let endAngle = self.timeToRadians(now)
        
        let fillPath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0), radius: (frame.size.width - 10)/2, startAngle: startAngle, endAngle: endAngle, clockwise: true)

        circleFillLayer.path = fillPath.CGPath
        
        layer.addSublayer(circleFillLayer)
    }
    
    func timeToRadians(t:String)->CGFloat{

        // convert the time of brew to degrees then to radians
        // First convert the time of brew into minutes - Equation: Hours * 60 + Minutes. So 11:35 will be 11 * 60 + 35 = 696
        // Next find percent out of a 12 hour clock. - Equation: resultFromLastStep / (12 * 60). So 696 / 720 = 0.96666667
        // Next convert the result to degrees by multiplying clock hours by minutes in hourthen adjust for radian conversion. - Equation: (12 * 60) * resultFromLastStep - 90
        // So 360 * 0.96666667 - 90 = 257.9976
        // 257.9976 is the degree where our circle should start.
        // Lastly convert degrees to radians - Equation: degrees * pi / 180.
        // Decided to use seconds instead of minutes for smoother animating.

        let hoursFormatter = NSDateFormatter()
        hoursFormatter.dateFormat = "hh"
        
        let minutesFormatter = NSDateFormatter()
        minutesFormatter.dateFormat = "mm"
        
        let secondsFormatter = NSDateFormatter()
        secondsFormatter.dateFormat = "ss"
        
        let nsDateLastBrewTime = dateTimeFormatter.dateFromString(t)
        
        let lastBrewHours = hoursFormatter.stringFromDate(nsDateLastBrewTime!).toInt()!
        let lastBrewMinutes = minutesFormatter.stringFromDate(nsDateLastBrewTime!).toInt()!
        let lastBrewSeconds = secondsFormatter.stringFromDate(nsDateLastBrewTime!).toInt()!
    
        let lastBrewTimeInSeconds = Double(lastBrewHours * 3600 + lastBrewMinutes * 60 + lastBrewSeconds)
        let percentRelativeToClock = Double(lastBrewTimeInSeconds / 43200)
        
        let degrees = Double(360 * percentRelativeToClock - 90)
        
        return CGFloat(degrees * M_PI / 180)
    }
    
    func removeClockView(){
        self.timer?.invalidate()
        self.layer.sublayers = nil;
    }
}
