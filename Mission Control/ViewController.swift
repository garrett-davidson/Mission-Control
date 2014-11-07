//
//  ViewController.swift
//  Mission Control
//
//  Created by Garrett Davidson on 10/24/14.
//  Copyright (c) 2014 Garrett Davidson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let defaults = NSUserDefaults(suiteName: "group.com.A-Programmer-s-Crucible.Mission-Control")!

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

        println("Main view loaded")

        activityView.layer.cornerRadius = 10.0
        activityView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        println("Set up activity view")
    }

    override func viewDidAppear(animated: Bool) {
        println("View appeared")
        if (defaults.boolForKey("startOnLaunch"))
        {
            println("Calling connectSession()")
            self.connectSession()
        }

        else
        {
            println("Not connecting on launch")
        }
    }

    override func applicationFinishedRestoringState() {
        connectSession()
    }

    func connectSession()
    {


        if (sshSession == nil || !sshSession!.connected)
        {
            println("Began connecting")
            activityView.hidden = false
            activityLabel.text = "Connecting..."
            spinner.startAnimating()
            println("Showing activity view")

            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                println("Dispatched connection thread")
                let host = self.defaults.objectForKey("host") as String
                let user = self.defaults.objectForKey("user") as String
                let pass = SSKeychain.passwordForService("MissionControlSSH", account: user) as String?
                let port = self.defaults.objectForKey("port") as String


                if (pass != nil)
                {
                    println("Pass not nil")
                    self.sshSession = NMSSHSession.connectToHost(host, port: port.toInt()!, withUsername: user)

                    if (self.sshSession != nil && self.sshSession!.connected)
                    {
                        println("Connected")
                        dispatch_async(dispatch_get_main_queue(), {
                            self.activityLabel.text = "Authenticating..."
                        })

                        println("Begin authenticating")
                        self.sshSession!.authenticateByPassword(pass)
                    }

                    else
                    {
                        dispatch_async(dispatch_get_main_queue(), {
                            println("Connection error")
                            let alert = UIAlertView(title: "Connection Error", message: "SSH session was unable to connect", delegate: self, cancelButtonTitle: "OK")
                            alert.show()
                        })
                    }

                    dispatch_async(dispatch_get_main_queue(), {
                        println("Stopping activity view")
                        self.spinner.stopAnimating()
                        self.activityView.hidden = true
                    })
                }
            })

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func toggleLight(sender: UISwitch) {
        print("Toggling light to: ")
        let serialRelay = defaults.objectForKey("serialRelayCommand") as String!
        var command = ""

        if (sender.on)
        {
            println("On")
            command = defaults.objectForKey("lightOn") as String!
        }

        else
        {
            println("Off")
            command = defaults.objectForKey("lightOff") as String!
        }

        lightStateLabel.text = sendCommand("\(serialRelay) \(command)")
    }

    @IBAction func toggleLightImage(sender: AnyObject) {
        println("Image pressed")
        lightSwitch.setOn(!lightSwitch.on, animated: true)
        toggleLight(lightSwitch)
    }

    func sendCommand(command: String) -> String
    {
        println("Will send command: " + command)
        if (sshSession == nil || !sshSession!.connected)
        {
            println("Session not connected")
            connectSession()
        }

        let timeout = 10000
        var currentTime = 0
        while (sshSession == nil || (!sshSession!.connected && sshSession!.lastError == nil) && currentTime < timeout)
        {
            sleep(100)
            currentTime += timeout
            println("Waiting to connect")
        }

        if (!sshSession!.connected)
        {
            let alert = UIAlertView(title: "Error", message: "Not connected", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            return "Not connected"
        }

        var error: NSError?
        println("Sending command")
        let response = sshSession!.channel.execute(command, error: &error)
        println("Received response: " + response)

        if (error != nil)
        {
            println("Command sending returned error: \(error!)")
            let alert = UIAlertView(title: "Command Error", message: error!.description, delegate: self, cancelButtonTitle: "OK")
            alert.show()
        }

        return response
    }
}

