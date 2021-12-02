//
//  ActionRequestData.swift
//  TrackSDK
//
//  Created by jonzzhao on 2021/9/9.
//
import Foundation
import UIKit

struct ActionRequestData{
    
    var log_id: Int = 0;
    var from: String = SDK_FROM;   // 来源
    var type: String = "";   // 类型
    var tracking_id: String = UIDevice.current.identifierForVendor!.uuidString;
    var props: [String: Any];
    
    init(){
        let userDefaults:UserDefaults = UserDefaults.standard;
        var uuid: String! = userDefaults.string(forKey: "uuid");
        if uuid == nil {
            uuid = DateHelper.getCurrentTimeMilliStamp() + "-";
            let tempStr: String = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx";
            for ch in tempStr {
                let r = arc4random_uniform(17);
                var v = r;
                if ch == "x" {
                    uuid.append(String(v, radix: 16))
                } else if ch == "y"{
                    v = r & 0x3 | 0x8;
                    uuid.append(String(v, radix: 16))
                } else {
                    uuid.append(ch)
                }
            }
            
            userDefaults.set(uuid, forKey: "uuid");
        }
        tracking_id = uuid!;
        let chan = ["chan_wxapp_scene": 1000];
        let user: [String: Any] = [:];
        props = [ "sr_sdk_version": SDK_VERSION, "wx_user": user, "chan": chan];
    }
}
//
//struct CommonProps: Codable{
//    var page: String;
//    var page_title: String?;
//    var sr_sdk_version: String?; // 版本号
//    var time: String;
//    var wx_user:User;
//    var chan: Chan;
//    var component: Component?;
//}
//
//// 用户相关属性
//struct User: Codable{
//    var app_id: String;
//    var open_id: String;
//    var user_id: String?;
//    var union_id: String?;
//    var local_id: String?;
//    var tag: [UserTag]?;
//    var extra: Dictionary<String, String>?;
//}
//
//struct UserTag: Codable{
//    var tag_id: String;
//    var tar_name: String;
//}

//// 渠道相关属性
//struct Chan: Codable{
//    var chan_wxapp_scene: String;
//    var chan_id: String?;
//    var chan_refer_app_id: String?;
//    var chan_shop_id: String?;
//    var chan_shop_name: String?;
//    var chan_custom: ChanCustom?;
//    var extra: Dictionary<String, String>?;
//}
//
//struct ChanCustom: Codable{
//    var chan_custom_id: String;
//    var chan_custom_id_desc: String;
//    var chan_custom_cat_3: String;
//    var chan_custom_cat_3_desc: String;
//    var chan_custom_cat_2: String;
//    var chan_custom_cat_2_desc: String;
//    var chan_custom_cat_1: String;
//    var chan_custom_cat_1_desc: String;
//}
//
//// 组件(视图上的一个区块元素)
//struct Component: Codable{
//    var component_id: String;
//    var component_name: String;
//}
