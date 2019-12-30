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
        swiftLog.addLogOutput(JJFileOutput()!)
        swiftLog.addLogOutput(JJConsoleOutput())
    }

    override func viewDidLoad() {
         super.viewDidLoad()
         setupLog()
         swiftLog.verbose("verbose")
         swiftLog.debug("debug")
         swiftLog.info("info")
         swiftLog.warning("warn")
         swiftLog.error("error")
    }


}

