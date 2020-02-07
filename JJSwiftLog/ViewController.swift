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
        if let file = JJFileOutput() {
            jjLogger.addLogOutput(file)
        }
        #if DEBUG
        jjLogger.addLogOutput(JJConsoleOutput())
        #endif
    }
    
    func setupVendor() {
        jjLogger.addLogOutput(BuglyOutput())
        jjLogger.addLogOutput(UmengOutput())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLog()
        setupVendor()
        jjLogger.verbose("verbose")
        jjLogger.debug("debug")
        jjLogger.info("info")
        jjLogger.warning("warn")
        jjLogger.error("error")
    }


}

