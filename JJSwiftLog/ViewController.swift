//
//  ViewController.swift
//  JJSwiftLog
//
//  Created by Jezz on 2019/12/27.
//  Copyright © 2019 JJ. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let file = JJFileOutput()

    func setupLog() {

    }
    
    func setupVendor(parameter: String) {
        JJLogger.verbose("method set the parameter")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if file != nil {
            JJLogger.addLogOutput(file!)
        }
        #if DEBUG
        var console = JJConsoleOutput()
        console.isUseNSLog = true
        JJLogger.addLogOutput(console)
        #endif

        JJLogger.format = JJSwiftLog.simpleFormat
        JJLogger.onlyLogFile("ViewController")

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
    }

    func testDeleteFile() {
        file?.deleteLogFile()
    }

    func testArchiveFile() {
        let appURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        let logFileURL = appURL!.appendingPathComponent("jjlogger1.log", isDirectory: false)
        file?.archiveLogFilePath(logFileURL.path)
    }

}
