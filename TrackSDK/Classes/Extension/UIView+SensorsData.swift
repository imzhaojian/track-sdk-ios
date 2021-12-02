//
//  UIView+SensorsData.swift
//  TrackSDK
//
//  Created by weiqifu on 2021/9/28.
//

import Foundation
import UIKit


extension UIView{
    func sensorsdata_elementType() -> String {
        return NSStringFromClass(self.classForCoder);
    }
    @objc func sensorsdata_elementContent() -> String{
        return "";
    }
    func sensorsdata_viewController() -> String {
        var responder:UIResponder = self;

        while((responder.next) != nil){
            
            if(responder.isKind(of: UIViewController.self)){
                return NSStringFromClass(responder.classForCoder);
            }
            responder = responder.next!;
        };
        return "";
    }

    func currentUIViewController() -> UIViewController? {
        var responder:UIResponder = self;
        while((responder.next) != nil){
            if(responder.isKind(of: UIViewController.self)){
                return responder as? UIViewController;
            }
            responder = responder.next!;
        };
        return nil;
    }


    func getViewTitle() -> String {
        var responder:UIResponder = self;

        while((responder.next) != nil){
            
            if(responder.isKind(of: UIViewController.self)){
                return (responder as! UIViewController).navigationItem.title ?? "";
            }
            responder = responder.next!;
        };
        return "";
    }
    
}

extension UIViewController{
    // 获取不同组件放到标题位置充当标题的文本
    func contentFromView(rootView:UIView)-> String {
        if(rootView.isHidden){
            return "";
        }
        var elementContent = "";
        if(rootView.isKind(of: UIButton.classForCoder())){
            let button = rootView as! UIButton;
            let title = button.titleLabel?.text ?? "";
            if(title.count > 0) {
                elementContent = title;
            }
        }else if(rootView.isKind(of: UILabel.classForCoder())) {
            let label = rootView as! UILabel;
            let title:String = label.text ?? "";
            if(title.count > 0) {
                elementContent = title;
            }
        }else if(rootView.isKind(of: UITextView.classForCoder())) {
            let textView = rootView as! UITextView;
            let title:String = textView.text ?? "";
            if(title.count > 0) {
                elementContent = title;
            }
        }
        // 在这里扩充其他情况

        return elementContent;
    }
}


extension UITabBar {
    override func sensorsdata_elementContent() -> String {
        return self.selectedItem?.title ?? "";
    }
    
    func sensorsdata_elementFindIndex() -> String {
        let res = self.items?.firstIndex(of: self.selectedItem!);
        return String(format: "%ld", res!);
    }

    func sensorsdata_itemPath() -> String {
        return super.sensorsdata_viewController();
    }
}

extension UIButton{
    override func sensorsdata_elementContent() -> String {
        if(self.titleLabel?.text == nil && self.currentTitle == nil) {
            return ""
        }
        return self.titleLabel?.text ?? self.currentTitle!;
    }
}

extension UISwitch{
    override func sensorsdata_elementContent() -> String {
        return self.isOn ? "checked" : "unchecked";
    }
}

extension UISlider{
    override func sensorsdata_elementContent() -> String {
        return String(format: "%.2f", self.value);
    }
}

extension UISegmentedControl{
    override func sensorsdata_elementContent() -> String {
        return self.titleForSegment(at: self.selectedSegmentIndex) ?? "";
    }
}

extension UIStepper{
    override func sensorsdata_elementContent() -> String {
        return String(format: "%g", self.value);
    }
}
