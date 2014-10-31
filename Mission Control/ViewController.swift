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

    @IBOutlet weak var lightStateLabel: UILabel!
    var sshSession: NMSSHSession?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.


        if (defaults.boolForKey("startOnLaunch"))
        {
            self.connectSession()
        }

    }

    func connectSession()
    {

        let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        self.view.addSubview(spinner)
        spinner.startAnimating()

        let host = defaults.objectForKey("host") as String
        let user = defaults.objectForKey("user") as String
        let pass = defaults.objectForKey("pass") as String
        let port = defaults.objectForKey("port") as String
        //TODO
        //store pass in keychain

        sshSession = NMSSHSession.connectToHost(host, port: port.toInt()!, withUsername: user)
        if (sshSession != nil && sshSession!.connected)
        {
            sshSession!.authenticateByPassword(pass)
            spinner.stopAnimating()
            spinner.removeFromSuperview()
        }

        else
        {
            spinner.stopAnimating()
            spinner.removeFromSuperview()
            let alert = UIAlertView(title: "Connection Error", message: "SSH session was unable to connect", delegate: self, cancelButtonTitle: "OK")
            alert.show()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func toggleLight(sender: AnyObject) {
        lightStateLabel.text = sendCommand(defaults.objectForKey("lightCommand") as String!);
    }


    func sendCommand(command: String) -> String
    {
        if (sshSession == nil || !sshSession!.connected)
        {
            connectSession()
        }

        if (!sshSession!.connected)
        {
            return "Error"
        }

        var error: NSError?
        let response = sshSession!.channel.execute(command, error: &error)

        if (error != nil)
        {
            println("Connection sending error: \(error)")
        }

        return response
    }
}

