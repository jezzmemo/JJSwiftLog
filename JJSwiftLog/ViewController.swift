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
    
    func setupVendor() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        jjLogger.enable = true
        
        setupLog()
        setupVendor()
        jjLogger.verbose("verbose")
        jjLogger.debug("debug")
        jjLogger.info("info")
        jjLogger.warning("warn")
        jjLogger.error("error")
    
    }

}

