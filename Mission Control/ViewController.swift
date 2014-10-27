//
//  ViewController.swift
//  Mission Control
//
//  Created by Garrett Davidson on 10/24/14.
//  Copyright (c) 2014 Garrett Davidson. All rights reserved.
//

import UIKit
//import NMSSH

class ViewController: UIViewController {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @IBOutlet weak var lightStateLabel: UILabel!
    var sshSession: NMSSHSession?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.



    }

    func connectSession()
    {
        let defaults = NSUserDefaults.standardUserDefaults()

        let host = defaults.objectForKey("host") as String
        let user = defaults.objectForKey("user") as String
        let pass = defaults.objectForKey("pass") as String
        let port = defaults.objectForKey("port") as String
        //TODO
        //store pass in keychain

        sshSession = NMSSHSession.connectToHost(host, port: port.toInt()!, withUsername: user)
        sshSession!.authenticateByPassword(pass)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func toggleLight(sender: AnyObject) {
        sendCommand("python ~/ArduinoControl/py-lights.py toggle");
    }


    func sendCommand(command: String)
    {
        if (sshSession == nil || !sshSession!.connected)
        {
            connectSession()
        }
        
        var error: NSError?
        sshSession!.channel.execute(command, error: &error)

        if (error != nil)
        {
            println(error)
        }

    }
}

