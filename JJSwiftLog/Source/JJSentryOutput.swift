//
//  JJUmengOutput.swift
//  JJSwiftLog: https://github.com/jezzmemo/JJSwiftLog
//
//  Created by Jezz on 2022/2/12.
//  Copyright © 2022 JJSwiftLog. All rights reserved.
//

import Foundation
#if os(iOS)
import UIKit
#endif

/// Send log to the Sentry
///
/// Send log result success is`completion` and failed is `failure`
/// And Must config the url,key
open class JJSentryOutput: JJLogObject {
    
    /// Success closure
    public var completion: (([String: Any]) -> Void)?
    
    /// Failed closure
    public var failure: ((Error) -> Void)?
    
    /// Sentry auth key
    private let sentryKey: String
    
    /// Sentry URL
    private let sentryURL: URL
    
    /// Config user id, this config is option
    private var userId: String?
    
    /// Init for JJSentryOutput
    /// - Parameters:
    ///   - sentryKey: Http header key is X-Sentry-Auth
    ///   - sentryHost: Customer sentry private url, example: https://xxx.xx.xx/api/5/store/
    ///   - userId: Optional user id
    ///   - delegate: Internal log
    public init(sentryKey: String, sentryURL: URL, userId: String? = nil, delegate: JJLogOutputDelegate? = nil) {
        self.sentryKey = sentryKey
        self.sentryURL = sentryURL
        self.userId = userId
        super.init(identifier: "JJSentryOutput", delegate: delegate)
    }
    
    open override func output(log: JJLogEntity, message: String) {
        self.sendJSONRequest(parameters: self.sentryJSONParameters(message: message))
    }
}

extension JJSentryOutput {
    
    /// Wrap the message to Dictionary
    /// - Parameter message: Format message
    /// - Returns: Format message result
    public func sentryJSONParameters(message: String) -> [String: Any] {
        
        let appInfo = self.currentAppInfo()
        
        var parameters = [String: Any]()
        //        parameters["extra"] = nil
        parameters["event_id"] = UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
        parameters["message"] = message
        parameters["release"] = appInfo["app_identifier"]
        parameters["level"] = self.logLevel.stringLevel
        parameters["platform"] = "cocoa"
        parameters["sdk"] = ["name": "zg-sentry-cocoa", "version": "0.0.1"]
        
        if let userId = self.userId {
            parameters["user"] = ["id": userId]
        }
#if os(iOS)
        let systemVersion = UIDevice.current.systemVersion
        let model = UIDevice.current.model + UIDevice.current.systemName + UIDevice.current.systemVersion

        parameters["contexts"] = ["os": ["name": UIDevice.current.systemName, "version": systemVersion], "app": self.currentAppInfo(), "device": ["model": model]]
#else
        parameters["contexts"] = ["app": self.currentAppInfo()]
#endif
        return parameters
    }
    
    /// Send parameters by the http post
    /// - Parameter parameters: HTTP post parameters
    public func sendJSONRequest(parameters: [String: Any]) {
        
        let timestamp: Int = Int(Date().timeIntervalSince1970)
        
        let jsonData = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        
        var request = URLRequest(url: self.sentryURL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 20)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("sentry-cocoa", forHTTPHeaderField: "User-Agent")
        request.addValue("Sentry sentry_version=7,sentry_client=sentry-cocoa/4.5.0,sentry_timestamp=\(timestamp),sentry_key=\(self.sentryKey)", forHTTPHeaderField: "X-Sentry-Auth")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, _, error) in
            guard let strongSelf = self else {
                return
            }
            guard let data = data else {
                strongSelf.handleError(message: "Http get data failed")
                return
            }
            
            guard error == nil else {
                strongSelf.handleError(message: error!.localizedDescription)
                return
            }
            
            guard let jsonResult =  try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
                strongSelf.handleError(message: "Convert data to JSON failed")
                return
            }
            
            if jsonResult["id"] == nil {
                strongSelf.completion?(jsonResult)
            } else {
                strongSelf.handleError(message: "Post log error, response is \(jsonResult)")
            }
        }
        
        task.resume()
    }
    
    func handleError(message: String) {
        self.failure?(NSError(domain: "sentry.error", code: 0, userInfo: [NSLocalizedDescriptionKey: message]))
        let log = JJLogEntity(level: .info, date: Date(), message: message, functionName: "", fileName: "", lineNumber: 0)
        self.delegate?.internalLog(source: self, log: log)
    }
    
    /// App info
    /// - Returns: App Dictionary info
    public func currentAppInfo() -> [String: Any] {
        var appInfo = [String: Any]()
        let infoDictionary = Bundle.main.infoDictionary
        appInfo["app_identifier"] = infoDictionary?["CFBundleIdentifier"]
        appInfo["app_name"] = infoDictionary?["CFBundleName"]
        appInfo["app_build"] = infoDictionary?["CFBundleVersion"]
        appInfo["app_version"] = infoDictionary?["CFBundleShortVersionString"]
        return appInfo
    }
}
