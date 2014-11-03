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

    let defaults = NSUserDefaults.standardUserDefaults()

    var firstResponder: AnyObject?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadSettings()
    }

    override func viewDidAppear(animated: Bool) {
        loadSettings()
    }

    func loadSettings() {

        for myView in self.mainView.subviews
        {
            if myView.isMemberOfClass(UITextField)
            {
                let key = (myView as UITextField).placeholder! as String

                switch key
                {
                    case "pass":

                        (myView as UITextField).text = SSKeychain.passwordForService("MissionControlSSH", account: defaults.objectForKey("user") as String!)
                        let user = "user"
                        println("Read user: \(defaults.objectForKey(user)!) and pass: \((myView as UITextField).text)")
                        break

                    default:
                        (myView as UITextField).text = defaults.objectForKey((myView as UITextField).placeholder!) as String
                        break
                }


            }

            else if myView.isMemberOfClass(UISwitch)
            {
                (myView as UISwitch).on = defaults.boolForKey(myView.restorationIdentifier!!)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func dismissKeyboard1(sender: AnyObject) {
        if (firstResponder != nil)
        {
            firstResponder!.resignFirstResponder()
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

        let defaults = NSUserDefaults.standardUserDefaults()

        let key = sender.placeholder!

        switch key
        {
            case "pass":
                SSKeychain.setPassword(sender.text, forService: "MissionControlSSH", account: defaults.objectForKey("user") as String!)

                let user = "user"
                println("Wrote user: \(defaults.objectForKey(user)!) and pass: \(sender.text)")
                break

            default:
                defaults.setObject(sender.text, forKey: sender.placeholder!)
        }


        sender.resignFirstResponder()
    }

    @IBAction func writeBool(sender: UISwitch) {

        defaults.setBool(sender.on, forKey: sender.restorationIdentifier!)
    }
    @IBAction func changeFirstResponder(sender: AnyObject) {
        firstResponder = sender

    }

    @IBAction func showAdvanced(sender: AnyObject) {
    }

    @IBAction func dismissModal(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
