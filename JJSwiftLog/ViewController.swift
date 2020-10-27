//
//  ViewController.swift
//  JJSwiftLog
//
//  Created by Jezz on 2019/12/27.
//  Copyright © 2019 JJ. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    func setupLog() {

    }
    
    func setupVendor(parameter: String) {
        JJLogger.verbose("method set the parameter")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        JJLogger.enable = true
        
        setupLog()
        setupVendor(parameter: "Show the error log")
        JJLogger.verbose("Start the record")
        JJLogger.debug("Debug the world")
        JJLogger.info("Show log info")
        JJLogger.warning("Build warning")
        JJLogger.error("can’t fetch user info without user id")
    
    }

}
