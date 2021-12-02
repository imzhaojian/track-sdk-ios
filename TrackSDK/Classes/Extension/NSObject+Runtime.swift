//
//  NSObject+Runtime.swift
//  TrackSDK
//
//  Created by jonzzhao on 2021/9/14.
//

import Foundation

extension NSObject{
    
    @objc dynamic func setAssociatedObject(key: UnsafeRawPointer, value: Any?){
        objc_setAssociatedObject(self, key, value, .OBJC_ASSOCIATION_RETAIN);
    }
    
    @objc dynamic func getAssociatedObject(key: UnsafeRawPointer)-> Any?{
        return objc_getAssociatedObject(self, key);
    }
    
    static func swizzle(originalSelector: Selector, swizzledSelector: Selector){
        let originalMethod = class_getInstanceMethod(self, originalSelector);
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
        
        guard originalMethod != nil && swizzledMethod != nil else {
            return
        }
        if class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!)){
            class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
        }else {
            method_exchangeImplementations(originalMethod!, swizzledMethod!);
        }
    }
}
