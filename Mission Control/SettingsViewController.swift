//
//  SettingsViewController.swift
//  Mission Control
//
//  Created by Garrett Davidson on 10/26/14.
//  Copyright (c) 2014 Garrett Davidson. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var hostTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var advancedView: UIView!

    let defaults = NSUserDefaults(suiteName: "group.com.A-Programmer-s-Crucible.Mission-Control")!

    var firstResponder: AnyObject?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        println("Loading settings")
        loadSettings()
        println("Settings loaded")
    }

    func loadSettings() {

        let view = mainView == nil ? advancedView : mainView

        for myView in view.subviews
        {
            let key = myView.restorationIdentifier as String?

            if myView.isMemberOfClass(UITextField)
            {
                switch key!
                {
                    case "pass":

                        (myView as UITextField).text = SSKeychain.passwordForService("MissionControlSSH", account: defaults.objectForKey("user") as String!)
                        break

                    default:
                        (myView as UITextField).text = defaults.objectForKey(myView.restorationIdentifier!!) as String
                        break
                }
            }

            else if myView.isMemberOfClass(UISwitch)
            {
                (myView as UISwitch).on = defaults.boolForKey(key!)
            }

            if (key != nil)
            {
                println("Loaded setting for: " + key!)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func dismissKeyboard1(sender: AnyObject) {
        println("Dismissing keyboard")
        if (firstResponder != nil)
        {
            firstResponder!.resignFirstResponder()
            println("Resigning first responder")
            firstResponder = nil
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

    @IBAction func writeSettings(sender: UITextField) {

        let key = sender.restorationIdentifier!

        println("Writing settings for: " + key)

        switch key
        {
            case "pass":
                SSKeychain.setPassword(sender.text, forService: "MissionControlSSH", account: defaults.objectForKey("user") as String!)

                break

            default:
                defaults.setObject(sender.text, forKey: sender.restorationIdentifier!)
        }


//        sender.resignFirstResponder()
//        println("Resinging first responder")
    }

    @IBAction func writeBool(sender: UISwitch) {
        println("Writing bool \(sender.on) for key: \(sender.restorationIdentifier)")
        defaults.setBool(sender.on, forKey: sender.restorationIdentifier!)
    }
    @IBAction func changeFirstResponder(sender: AnyObject) {
        firstResponder = sender
    }

    @IBAction func showAdvanced(sender: AnyObject) {
    }

    @IBAction func dismissModal(sender: AnyObject) {
        println("Dismissing modal controller")
        dismissViewControllerAnimated(true, completion: nil)
    }

}
