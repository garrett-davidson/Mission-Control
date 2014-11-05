//
//  TodayViewController.swift
//  Mission Control Widget
//
//  Created by Garrett Davidson on 11/4/14.
//  Copyright (c) 2014 Garrett Davidson. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {

    let defaults = NSUserDefaults(suiteName: "group.com.A-Programmer-s-Crucible.Mission-Control")!
    var sshSession: NMSSHSession?

    @IBOutlet weak var sessionStateLabel: UILabel!
    @IBOutlet weak var lightStateLabel: UILabel!
    @IBOutlet weak var lightSwitch: UISwitch!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        connectSession()
        self.preferredContentSize = CGSizeMake(0, 80)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.NewData)
    }

    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets
    {
        let newInsets = UIEdgeInsets(top: defaultMarginInsets.top, left: defaultMarginInsets.left, bottom: 0, right: defaultMarginInsets.right)
        return newInsets
    }


    @IBAction func toggleLight(sender: UISwitch) {
        let serialRelay = defaults.objectForKey("serialRelayCommand") as String!
        var command = ""

        if (sender.on)
        {
            command = defaults.objectForKey("lightOn") as String!
        }

        else
        {
            command = defaults.objectForKey("lightOff") as String!
        }

        lightStateLabel.text = sendCommand("\(serialRelay) \(command)")
    }

    @IBAction func toggleLightImage(sender: AnyObject) {
        lightSwitch.setOn(!lightSwitch.on, animated: true)
        toggleLight(lightSwitch)
    }

    func sendCommand(command: String) -> String
    {
        if (sshSession == nil || !sshSession!.connected)
        {
            connectSession()
        }

        while (sshSession == nil || !sshSession!.connected)
        {
            sleep(100)
        }

        var error: NSError?
        let response = sshSession!.channel.execute(command, error: &error)

        if (error != nil)
        {
            println("Connection sending error: \(error!)")
//            let alert = UIAlertView(title: "Command Error", message: error!.description, delegate: self, cancelButtonTitle: "OK")

        }
        
        return response
    }

    func connectSession()
    {
        if (sshSession == nil || !sshSession!.connected)
        {
//            activityView.hidden = false
            sessionStateLabel.text = "Connecting..."
//            spinner.startAnimating()

            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                let host = self.defaults.objectForKey("host") as String?
                let user = self.defaults.objectForKey("user") as String?
                let pass = SSKeychain.passwordForService("MissionControlSSH", account: user) as String?
                let port = self.defaults.objectForKey("port") as String?


                if (pass != nil)
                {
                    self.sshSession = NMSSHSession.connectToHost(host!, port: port!.toInt()!, withUsername: user!)
                    if (self.sshSession != nil && self.sshSession!.connected)
                    {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.sessionStateLabel.text = "Authenticating..."
                        })

                        self.sshSession!.authenticateByPassword(pass!)
                    }

                    else
                    {
                        println("SSH connection error")
    //                    let alert = UIAlertView(title: "Connection Error", message: "SSH session was unable to connect", delegate: self, cancelButtonTitle: "OK")
    //                    alert.show()
                    }

                    dispatch_async(dispatch_get_main_queue(), {
    //                    self.spinner.stopAnimating()
    //                    self.activityView.hidden = true
                        self.sessionStateLabel.text = "Connected"
                    })
                }

                else
                {
                    self.sessionStateLabel.text = "Not connected"
                }
            })
            
        }
    }
}
