//
//  UIViewControllerProxy.swift
//  TrackSDK
//
//  Created by jonzzhao on 2021/9/15.
//

import Foundation
import UIKit

class UIViewControllerProxy:UIViewController{

    
    static let instance = UIViewControllerProxy.init();
//    private override init(){super.init()};
    
    func doProxyViewLifecycle(){
        proxyViewDidAppear();
        proxyViewDidDisappear();
    }
}

// aop swizzle
extension UIViewControllerProxy{
    dynamic private func swizzle(originalSelector: Selector, swizzledSelector: Selector){
        let originalMethod = class_getInstanceMethod(UIViewController.self, originalSelector);
        let swizzledMethod = class_getInstanceMethod(UIViewControllerProxy.self, swizzledSelector);
        guard originalMethod != nil && swizzledMethod != nil else {
            return
        }
        
        if class_addMethod(UIViewController.self, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!)) {
            class_replaceMethod(UIViewController.self, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
        }else {
            method_exchangeImplementations(originalMethod!, swizzledMethod!);
        }
        
    }
}

// proxy view lifecycle function
extension UIViewControllerProxy{
    
    func proxyViewDidAppear(){
        let originalSelector = #selector(UIViewController.viewDidAppear(_:));
        let swizzledSelector = #selector(UIViewControllerProxy.aopViewDidAppear(_:));
        swizzle(originalSelector: originalSelector, swizzledSelector: swizzledSelector);
    }
    
    func proxyViewDidDisappear(){
        let originalSelector = #selector(UIViewController.viewDidDisappear(_:));
        let swizzledSelector = #selector(UIViewControllerProxy.aopViewDidDisappear(_:));
        swizzle(originalSelector: originalSelector, swizzledSelector: swizzledSelector);
    }
}


// view lifecycle aop
extension UIViewControllerProxy{
    
    @objc
    func aopViewDidAppear(_ animated: Bool){
        let page = NSStringFromClass(self.classForCoder);
        var title = "";
        if page.split(separator: ".").count > 1 {
            if(self.navigationItem.titleView !== nil ){
                title = self.contentFromView(rootView: self.navigationItem.titleView!);
            }
            if(title.count == 0) {
                title = self.navigationItem.title ?? "";
            }
            let param: [String: String] = ["page": page, "page_title": title];
            TrackManager.shareInstance().baseActionReportToServer(actionName: .BROWSE_WXAPP_PAGE, withParam: param);
        }
    }
    
    @objc
    func aopViewDidDisappear(_ animated: Bool){
        let page = NSStringFromClass(self.classForCoder);
        var title = "";
        if page.split(separator: ".").count > 1 {
            if(self.navigationItem.titleView !== nil ){
                title = self.contentFromView(rootView: self.navigationItem.titleView!) ;
            }
            if(title.count == 0) {
                title = self.navigationItem.title ?? "";
            }
            let param: [String: String] = ["page": page, "page_title": title];
            TrackManager.shareInstance().baseActionReportToServer(actionName: .LEAVE_WXAPP_PAGE, withParam: param);
        }
    }
}
