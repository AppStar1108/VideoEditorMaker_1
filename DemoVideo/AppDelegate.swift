//
//  AppDelegate.swift
//  DemoVideo
//
//  Created by SOTSYS027 on 9/28/16.
//  Copyright © 2016 SOTSYS027. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import GoogleMobileAds
import FBSDKCoreKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
     var videoUrl = NSURL()
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Fabric.with([Crashlytics.self])

        //  let navBackgroundImage:UIImage! = UIImage(named: "hader_img")
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        /*UINavigationBar.appearance().tintColor = UIColor.whiteColor()*/
        //UINavigationBar.appearance().backgroundColor = UIColor.blackColor()

      //  UINavigationBar.appearance().barTintColor = UIColor(red: 21.0/255.0, green: 21.0/255.0, blue: 21.0/255.0, alpha: 1.0)
         // UINavigationBar.appearance().tintColor = UIColor.blackColor()
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        

        // Configure tracker from GoogleService-Info.plist.
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        // Optional:                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      .
        let gai = GAI.sharedInstance()
        gai.trackUncaughtExceptions = true  // report uncaught exceptions
       // gai.logger.logLevel = GAILogLevel.Verbose  // remove before app release

        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)

        
       // UINavigationBar.appearance().tintColor = UIColor.blackColor()
       // UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.blackColor()]
        
        if NSUserDefaults.standardUserDefaults().objectForKey("ScheduleLocalNotification") == nil
        {
            self.setScheduleLocalNotification()
        }
        if NSUserDefaults.standardUserDefaults().objectForKey("RateAlertDate") == nil
        {
            let today = NSDate()
            NSUserDefaults.standardUserDefaults().setObject(today, forKey:"RateAlertDate")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        return true
    }
    
//    func getSixPMDate(hours : Int, min : Int = 0, seconds : Int = 0) -> NSDate?
//    {
//        let calendar: NSCalendar! = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
//        let now: NSDate! = NSDate()
//        print(now)
//        let date10h = calendar.dateBySettingHour(hours, minute: min, second: seconds, ofDate: now, options: NSCalendarOptions.MatchFirst)!
//        return date10h
//    }
    
    func setScheduleLocalNotification()
    {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "ScheduleLocalNotification")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        let calendar: NSCalendar! = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        
        var finalFireDate = calendar.dateBySettingHour(18, minute: 0, second: 0, ofDate: NSDate(), options: NSCalendarOptions.MatchFirst)!
        
        let currentTimestamp = NSDate().timeIntervalSince1970 * 1000
        
        if currentTimestamp > finalFireDate.timeIntervalSince1970 * 1000
        {
            finalFireDate = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: 1, toDate: finalFireDate, options: [] )!
        }
        
        let oneNotification = UILocalNotification()
        oneNotification.fireDate = finalFireDate
        oneNotification.alertBody = "Enhance your beautiful moments by adding music, special effects and filters."
        oneNotification.alertAction = "oneNotification"
        oneNotification.soundName = UILocalNotificationDefaultSoundName
        oneNotification.userInfo = ["LocalNotification1": "one"]
        oneNotification.repeatInterval = NSCalendarUnit.WeekOfYear
        UIApplication.sharedApplication().scheduleLocalNotification(oneNotification)
        
        let twoNotification = UILocalNotification()
        twoNotification.fireDate = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: 1, toDate: finalFireDate, options: [] )!
        twoNotification.alertBody = "Don’t like any part of your video? Just trim it out. Wrong orientation? Just rotate it. Its that simple."
        twoNotification.alertAction = "twoNotification"
        twoNotification.soundName = UILocalNotificationDefaultSoundName
        twoNotification.userInfo = ["LocalNotification2": "two"]
        UIApplication.sharedApplication().scheduleLocalNotification(twoNotification)
        
        let threeNotification = UILocalNotification()
        threeNotification.fireDate = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: 2, toDate: finalFireDate, options: [] )!
        threeNotification.alertBody = "Have you tried the slow motion function? It makes moments unforgettable!"
        threeNotification.alertAction = "threeNotification"
        threeNotification.soundName = UILocalNotificationDefaultSoundName
        threeNotification.userInfo = ["LocalNotification3": "three"]
        UIApplication.sharedApplication().scheduleLocalNotification(threeNotification)
        
        let fourNotification = UILocalNotification()
        fourNotification.fireDate = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: 3, toDate: finalFireDate, options: [] )!
        fourNotification.alertBody = "Make your video with friends a whole lot more FUN with Stickers and customizable Texts!"
        fourNotification.alertAction = "fourNotification"
        fourNotification.soundName = UILocalNotificationDefaultSoundName
        fourNotification.userInfo = ["LocalNotification4": "four"]
        UIApplication.sharedApplication().scheduleLocalNotification(fourNotification)
        
        let fiveNotification = UILocalNotification()
        fiveNotification.fireDate = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: 4, toDate: finalFireDate, options: [] )!
        fiveNotification.alertBody = "C’mon we’ll make beautiful moments even more memorable! Add song, effects, filters, stickers & manage speed."
        fiveNotification.alertAction = "fiveNotification"
        fiveNotification.soundName = UILocalNotificationDefaultSoundName
        fiveNotification.userInfo = ["LocalNotification5": "five"]
        UIApplication.sharedApplication().scheduleLocalNotification(fiveNotification)

        let sixNotification = UILocalNotification()
        sixNotification.fireDate = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: 5, toDate: finalFireDate, options: [] )!
        sixNotification.alertBody = "Have you tried the slow motion function? It makes moments unforgettable!"
        sixNotification.alertAction = "sixNotification"
        sixNotification.soundName = UILocalNotificationDefaultSoundName
        sixNotification.userInfo = ["LocalNotification6": "six"]
        UIApplication.sharedApplication().scheduleLocalNotification(sixNotification)
        
        let sevenNotification = UILocalNotification()
        sevenNotification.fireDate = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: 6, toDate: finalFireDate, options: [] )!
        sevenNotification.alertBody = "Make your video with friends a whole lot more FUN with Stickers and customizable Texts!"
        sevenNotification.alertAction = "sevenNotification"
        sevenNotification.soundName = UILocalNotificationDefaultSoundName
        sevenNotification.userInfo = ["LocalNotification7": "seven"]
        UIApplication.sharedApplication().scheduleLocalNotification(sevenNotification)

    }
    
//    func func_oneNotification()
//    {
//        let oneNotification = UILocalNotification()
//        oneNotification.fireDate = self.getSixPMDate(18)
//        oneNotification.alertBody = "Enhance your beautiful moments by adding music, special effects and filters."
//        oneNotification.alertAction = "oneNotification"
//        oneNotification.soundName = UILocalNotificationDefaultSoundName
//        oneNotification.userInfo = ["LocalNotification1": "one"]
//        oneNotification.repeatInterval = NSCalendarUnit.WeekOfYear
//        UIApplication.sharedApplication().scheduleLocalNotification(oneNotification)
//    }
//    
//    func func_twoNotification()
//    {
//        let twoNotification = UILocalNotification()
//        twoNotification.fireDate = self.getSixPMDate(18)
//        twoNotification.alertBody = "Don’t like any part of your video? Just trim it out. Wrong orientation? Just rotate it. Its that simple."
//        twoNotification.alertAction = "twoNotification"
//        twoNotification.soundName = UILocalNotificationDefaultSoundName
//        twoNotification.userInfo = ["LocalNotification2": "two"]
//        UIApplication.sharedApplication().scheduleLocalNotification(twoNotification)
//    }
//    
//    func func_threeNotification()
//    {
//        let threeNotification = UILocalNotification()
//        threeNotification.fireDate = self.getSixPMDate(18)
//        threeNotification.alertBody = "Have you tried the slow motion function? It makes moments unforgettable!"
//        threeNotification.alertAction = "threeNotification"
//        threeNotification.soundName = UILocalNotificationDefaultSoundName
//        threeNotification.userInfo = ["LocalNotification3": "three"]
//        UIApplication.sharedApplication().scheduleLocalNotification(threeNotification)
//    }
//    
//    func func_fourNotification()
//    {
//        let fourNotification = UILocalNotification()
//        fourNotification.fireDate = self.getSixPMDate(18)
//        fourNotification.alertBody = "Make your video with friends a whole lot more FUN with Stickers and customizable Texts!"
//        fourNotification.alertAction = "fourNotification"
//        fourNotification.soundName = UILocalNotificationDefaultSoundName
//        fourNotification.userInfo = ["LocalNotification4": "four"]
//        UIApplication.sharedApplication().scheduleLocalNotification(fourNotification)
//    }
//    
//    func func_fiveNotification()
//    {
//        let fiveNotification = UILocalNotification()
//        fiveNotification.fireDate = self.getSixPMDate(18)
//        fiveNotification.alertBody = "C’mon we’ll make beautiful moments even more memorable! Add song, effects, filters, stickers & manage speed."
//        fiveNotification.alertAction = "fiveNotification"
//        fiveNotification.soundName = UILocalNotificationDefaultSoundName
//        fiveNotification.userInfo = ["LocalNotification5": "five"]
//        UIApplication.sharedApplication().scheduleLocalNotification(fiveNotification)
//    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

