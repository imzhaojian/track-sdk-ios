//
//  UIApplicationProxy.swift
//  TrackSDK
//
//  Created by weiqifu on 2021/9/24.
//

import Foundation
import UIKit

class UIApplicationProxy:NSObject{

    
    static let instance = UIApplicationProxy.init();
    private override init(){super.init()};
    
    func doProxyApplication(){
        proxyApplication();
    }
}

// aop swizzle
extension UIApplicationProxy{
    dynamic private func swizzle(originalSelector: Selector, swizzledSelector: Selector){
        let originalMethod = class_getInstanceMethod(UIApplication.self, originalSelector);
        let swizzledMethod = class_getInstanceMethod(UIApplication.self, swizzledSelector);
        guard originalMethod != nil && swizzledMethod != nil else {
            return
        }
        
        if class_addMethod(UIApplication.self, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!)) {
            class_replaceMethod(UIApplication.self, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
        }else {
            method_exchangeImplementations(originalMethod!, swizzledMethod!);
        }
        
    }
}

// proxy view lifecycle function
extension UIApplicationProxy{
    
    func proxyApplication(){
        let originalSelector = #selector(UIApplication.sendAction(_:to:from:for:));
        let swizzledSelector = #selector(UIApplication.aopAction(_:to:from:for:));
        swizzle(originalSelector: originalSelector, swizzledSelector: swizzledSelector);
    }
    
}

func getTouches(event: UIEvent?) -> Int?{
    let touches = event?.allTouches;
    if (touches != nil){
        var touchValue:Int? = 0; // 存储0按下，1移动，2按下没移动，3触摸移除
        for touch in touches ?? [] {
            touchValue = touch.phase.rawValue   // 获取后存储状态
        }
        return touchValue;
    }
    return nil;
}


// view lifecycle aop
extension UIApplication{
    
    @objc
    func aopAction(_ action: Selector, to target: Any?, from sender: Any?, for event: UIEvent?){
             let se = sender as AnyObject;
             let se_class: String = NSStringFromClass(se.classForCoder);
             let se_next:UITabBar? = se.next as? UITabBar;
             var title = "";
             var elementPage = "";
             var elementType = "";
             var elementContent = "";
             var touchValue = getTouches(event: event);
//           print("touchValue",touchValue,se_class)
             if(se_class == "UITabBarButton" && touchValue == nil){
                elementType = se_class;
                elementContent = se_next?.sensorsdata_elementContent() ?? "";
                title = se_next?.sensorsdata_elementContent() ?? "";
                elementPage = se_next?.sensorsdata_itemPath() ?? "";
                touchValue = 3;
             }else if((touchValue == 3 && sender is UISlider) || sender is UISwitch || sender is UISegmentedControl || sender is UIStepper ||  sender is UIButton) {
                 let view = sender as! UIView;
                 elementType = view.sensorsdata_elementType() // 获取点击的类型
                 elementContent = view.sensorsdata_elementContent(); // 获取点击的控件文字
                 elementPage = view.sensorsdata_viewController();    // 获取点击的控件路径
                 let uiview = view.currentUIViewController();  // 获取所在UIViewController
                 if(uiview?.navigationItem.titleView !== nil){
                     title = uiview?.contentFromView(rootView: (uiview?.navigationItem.titleView)!) ?? "";
                 }
                 if(title.count == 0) {
                     title = view.getViewTitle();
                 }
             }else{
                self.aopAction(action,to:target,from:sender,for:event);
                return;
             }
             
             let param: [String: String] = [
                 "page": elementPage,
                 "page_title": title,
                 "element_type": elementType,
                 "element_content": elementContent,
                 "element_id": "#\(action)",
                 "type": "tap",
             ];
     //        print(param);
            
             // 部分控件需要特殊判断 它点击状态是0
             TrackManager.shareInstance().baseActionReportToServer(actionName: .ELEMENT, withParam: param);
             
             self.aopAction(action,to:target,from:sender,for:event);
    }
}
