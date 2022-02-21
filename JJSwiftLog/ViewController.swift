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
        JJLogger.setup(level: .verbose)

        JJLogger.format = JJSwiftLog.simpleFormat
//        JJLogger.onlyLogFile("ViewController")

        JJLogger.verbose("verbose")
        JJLogger.debug("debug")
        JJLogger.info("info")
        JJLogger.warning("warn")
        JJLogger.error("error")

        JJLogger.verbose(123)
        JJLogger.debug(1.2)
        JJLogger.info(Date())
        JJLogger.warning(["1", "2"])
        
        JJLogger.enable = true
        
        setupLog()
        setupVendor(parameter: "Show the error log")
        JJLogger.verbose("Start the record")
        JJLogger.debug("Debug the world")
        JJLogger.info("Show log info")
        JJLogger.warning("Build warning")
        JJLogger.error("can’t fetch user info without user id")
        
        let button = UIButton(type: .custom)
        button.setTitle("Add log", for: .normal)
        button.addTarget(self, action: #selector(clickButton), for: .touchUpInside)
        button.setTitleColor(.red, for: .normal)
        button.frame = CGRect(x: 0, y: 200, width: 200, height: 50)
        self.view.addSubview(button)
    }
    
    func advanceUsage() {
        let file = JJFileOutput(delegate: JJLogger, identifier: "file")
        if file != nil {
            file?.targetMaxFileSize = 1000 * 1024
            file?.targetMaxTimeInterval = 600
            file?.targetMaxLogFiles = 20
            file?.formatters = [JJFormatterLogANSIColor()]
            JJLogger.addLogOutput(file!)
        }
        #if DEBUG
        let console = JJConsoleOutput(identifier: "console")
        console.isUseNSLog = false
        JJLogger.addLogOutput(console)
        #endif
        JJLogger.startLogInfo()
    }
    
    func sentryUsage() {
        let sentry = JJSentryOutput(sentryKey: "key", sentryURL: URL(string: "http://www.exmaple.com/api/5/store/")!, delegate: JJLogger)
        sentry.completion = { result in
            
        }
        sentry.failure = { error in
            
        }
        JJLogger.addLogOutput(sentry)
    }
    
    @objc func clickButton() {
        JJLogger.verbose("Start the record")
        JJLogger.debug("Debug the world")
        JJLogger.info("Show log info")
        JJLogger.warning("Build warning")
        JJLogger.error("can’t fetch user info without user id")
    }

}
