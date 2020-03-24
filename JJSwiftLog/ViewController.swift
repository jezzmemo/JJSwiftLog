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
        var bugly = BuglyOutput()
        bugly.logLevel = .error
        jjLogger.addLogOutput(bugly)
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
        
        print(self.parsePadding("Mkk "))
        print(self.parsePadding("123 ,12321."))
    }


    /// returns (padding length value, offset in string after padding info)
    private func parsePadding(_ text: String) -> (Int, Int) {
        // look for digits followed by a alpha character
        var s: String!
        var sign: Int = 1
        if text.first == "-" {
            sign = -1
            s = String(text.suffix(from: text.index(text.startIndex, offsetBy: 1)))
        } else {
            s = text
        }
        let numStr = s.prefix { $0 >= "0" && $0 <= "9" }
        if let num = Int(String(numStr)) {
            return (sign * num, (sign == -1 ? 1 : 0) + numStr.count)
        } else {
            return (0, 0)
        }
    }
}

