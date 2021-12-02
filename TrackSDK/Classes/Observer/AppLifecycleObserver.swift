//
//  AppLifecycleObserver.swift
//  TrackSDK
//
//  Created by jonzzhao on 2021/9/15.
//

import Foundation
import UIKit

class AppLifecycleObserver: NSObject{
    
    static let instance = AppLifecycleObserver.init();
    private override init(){super.init()};
    
    func doObserverAppLifecycle(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.aopApplicationDidBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.aopApplicationDidEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
}

// app lifecycle observer func
extension AppLifecycleObserver{
    
    @objc func aopApplicationDidBecomeActive(){
        TrackManager.shareInstance().baseActionReportToServer(actionName:.APP_SHOW, withParam: ["page":TrackEventType.APP_SHOW.rawValue]);
    }
    
    @objc func aopApplicationDidEnterBackground(){
        TrackManager.shareInstance().baseActionReportToServer(actionName: .EXIT_WXAPP, withParam: ["page":TrackEventType.EXIT_WXAPP.rawValue]);
    }
}
