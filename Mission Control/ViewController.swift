//
//  ViewController.swift
//  Mission Control
//
//  Created by Garrett Davidson on 10/24/14.
//  Copyright (c) 2014 Garrett Davidson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let defaults = NSUserDefaults.standardUserDefaults()

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var activityView: UIView!

    @IBOutlet weak var lightStateLabel: UILabel!
    @IBOutlet weak var lightSwitch: UISwitch!
    var sshSession: NMSSHSession?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        activityView.layer.cornerRadius = 10.0
        activityView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
    }

    override func viewDidAppear(animated: Bool) {
        if (defaults.boolForKey("startOnLaunch"))
        {
            self.connectSession()
        }

        else
        {
            println("Not connecting on launch")
        }
    }

    func connectSession()
    {


        if (sshSession == nil || !sshSession!.connected)
        {
            activityView.hidden = false
            activityLabel.text = "Connecting..."
            spinner.startAnimating()

            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                let host = self.defaults.objectForKey("host") as String
                let user = self.defaults.objectForKey("user") as String
                let pass = SSKeychain.passwordForService("MissionControlSSH", account: user) as String
                let port = self.defaults.objectForKey("port") as String


                self.sshSession = NMSSHSession.connectToHost(host, port: port.toInt()!, withUsername: user)
                if (self.sshSession != nil && self.sshSession!.connected)
                {
                    self.activityLabel.text = "Authenticating..."
                    self.sshSession!.authenticateByPassword(pass)
                }

                else
                {
                    let alert = UIAlertView(title: "Connection Error", message: "SSH session was unable to connect", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                }

                self.spinner.stopAnimating()
                self.activityView.hidden = true
            })

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func toggleLight(sender: UISwitch) {
        let pythonRelay = defaults.objectForKey("pythonRelayCommand") as String!
        var command = ""

        if (sender.on)
        {
            command = defaults.objectForKey("lightOn") as String!
        }

        else
        {
            command = defaults.objectForKey("lightOff") as String!
        }

        lightStateLabel.text = sendCommand("\(pythonRelay) \(command)")
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

        while (!sshSession!.connected && sshSession!.lastError == nil)
        {
            sleep(100)
        }

        var error: NSError?
        let response = sshSession!.channel.execute(command, error: &error)

        if (error != nil)
        {
            println("Connection sending error: \(error!)")
            let alert = UIAlertView(title: "Command Error", message: error!.description, delegate: self, cancelButtonTitle: "OK")
        }

        return response
    }
}

