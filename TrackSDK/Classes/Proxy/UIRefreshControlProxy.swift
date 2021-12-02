//
//  UIViewControllerProxy.swift
//  TrackSDK
//
//  Created by jonzzhao on 2021/9/15.
//

import Foundation
import UIKit

class UIRefreshControlProxy:NSObject{

    
    static let instance = UIRefreshControlProxy.init();
    private override init(){super.init()};
    
    func doProxyPullDownRefresh(){
        proxyPullDownRefresh();
    }
  
}

// aop swizzle
extension UIRefreshControlProxy{
    dynamic private func swizzle(originalSelector: Selector, swizzledSelector: Selector){
       
        let originalMethod = class_getInstanceMethod(UIRefreshControl.self, originalSelector);
        let swizzledMethod = class_getInstanceMethod(UIRefreshControl.self, swizzledSelector);

        guard originalMethod != nil && swizzledMethod != nil else {
            return
        }
        
        if class_addMethod(UIRefreshControl.self, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!)) {
            class_replaceMethod(UIRefreshControl.self, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
        }else {
            method_exchangeImplementations(originalMethod!, swizzledMethod!);
        }
        
    }
}

// proxy view lifecycle function
extension UIRefreshControlProxy{
    
    func proxyPullDownRefresh(){
        let originalSelector = #selector(UIRefreshControl.addTarget(_:action:for:));
        let swizzledSelector = #selector(UIRefreshControl.aopAddTarget(_:action:for:));
        swizzle(originalSelector: originalSelector, swizzledSelector: swizzledSelector);
    }
}


// view lifecycle aop
extension UIRefreshControl{
    
    private struct AssociatedKey {
        static var page: String = ""
        static var title: String = ""
    }
    
    public var page: String {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.page) as? String ?? ""
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.page, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    public var title: String {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.title) as? String ?? ""
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.title, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    @objc
    func addReportTarget(){
        let param: [String: String] = ["page": page, "page_title": title];
        TrackManager.shareInstance().baseActionReportToServer(actionName: .PAGE_PULL_DOWN_REFRESH, withParam: param);
    }
    
    @objc
    func aopAddTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event){
        if (controlEvents == .valueChanged) {
            let currTarget = target as! UIViewController;
            page = NSStringFromClass(currTarget.classForCoder);
            title = currTarget.navigationItem.title ?? "";
            aopAddTarget(self, action: #selector(UIRefreshControl.addReportTarget), for: .valueChanged)
        }
        aopAddTarget(target, action: action, for: controlEvents);
    }
}
