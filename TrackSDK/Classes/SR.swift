//
//  SR.swift
//  TrackSDK
//
//  Created by jonzzhao on 2021/9/9.
//

import Foundation
import UIKit

public class SR:NSObject{
    
    private static let instance = SR.init();
    private var manager: TrackManager?;
    
    private override init(){super.init()};
    
    @objc public static func initSDK (config: TrackConfig){
        if (instance.manager != nil) {
            return;
        }
        if (config.secretId.count == 0) {
            return;
        }
        if (config.secretKey.count == 0) {
            return;
        }
        
        instance.manager = TrackManager.initManager(config: config);
    }
    
    @objc public static func sharedInstance() -> SR{
        return instance;
    }
}

extension SR{
    @objc public func setUser(userId: String){
        guard let manager = manager else{ return }
        manager.setUser(userId: userId)
    }
    @objc public func setChan(chanShopId: String, chanShopName: String, chanCustom: Any, extra: Any){
        guard let manager = manager else{ return }
        manager.setChan(chanShopId: chanShopId, chanShopName: chanShopName, chanCustom: chanCustom, extra: extra)
    }
    
}

// report function
extension SR{
    @objc public func track(actionName: String, actionParam: Dictionary<String, String>){
        guard let manager = manager else{ return }
        manager.reportActionToServer(actionName: actionName, withParam: actionParam);
    }
}
