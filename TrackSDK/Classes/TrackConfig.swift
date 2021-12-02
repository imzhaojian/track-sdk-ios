//
//  TrackConfig.swift
//  TrackSDK
//
//  Created by jonzzhao on 2021/9/30.
//

import Foundation
import UIKit

public class TrackConfig: NSObject{
    var serverUrl: String = "https://zhls.qq.com/api/v1/safe-report"
    
    var secretId: String;
    var secretKey: String;
    var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    var actionRequestData: ActionRequestData;
    
    @objc public var debug: Bool = false;
    
    @objc public var async: Bool = false;
    
    
    @objc public init (secretId: String, secretKey: String, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        self.secretId = secretId;
        self.secretKey = secretKey;
        self.launchOptions = launchOptions;
        self.actionRequestData = ActionRequestData();
    }
}
