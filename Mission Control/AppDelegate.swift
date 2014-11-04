//
//  AppDelegate.swift
//  Mission Control
//
//  Created by Garrett Davidson on 10/24/14.
//  Copyright (c) 2014 Garrett Davidson. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.

        let defaults = NSUserDefaults.standardUserDefaults()

        if (defaults.objectForKey("host") == nil)
        {
            defaults.setObject("127.0.0.1", forKey: "host")
        }

        if (defaults.objectForKey("user") == nil)
        {
            defaults.setObject("username", forKey: "user")
        }

        if (defaults.objectForKey("port") == nil)
        {
            defaults.setObject("22", forKey: "port")
        }

        if (defaults.objectForKey("startOnLaunch") == nil)
        {
            defaults.setBool(false, forKey: "startOnLaunch")
        }


        

        if (defaults.objectForKey("lightOn") == nil)
        {
            defaults.setObject("On", forKey: "lightOn")
        }

        if (defaults.objectForKey("lightOff") == nil)
        {
            defaults.setObject("Off", forKey: "lightOff")
        }

        if (defaults.objectForKey("serialRelayCommand") == nil)
        {
            defaults.setObject("python \"btsync/Test (1)/ArduinoControl/serial-relay.py\"", forKey: "serialRelayCommand")
        }

        return true
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
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

