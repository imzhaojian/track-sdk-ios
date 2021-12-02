//
//  TrackManager.swift
//  TrackSDK
//
//  Created by jonzzhao on 2021/9/9.
//

import Foundation
import UIKit

class TrackManager:NSObject{
    
    private static let instance = TrackManager();
    public var config: TrackConfig?;
    
    private override init() {super.init()}
    
    static func initManager(config: TrackConfig) -> TrackManager{
        instance.config = config;
        //
        instance.baseActionReportToServer(actionName: .APP_LAUNCH, withParam: ["page": TrackEventType.APP_LAUNCH.rawValue]);
        //
        AppLifecycleObserver.instance.doObserverAppLifecycle();
        UIViewControllerProxy.instance.doProxyViewLifecycle();
        UIRefreshControlProxy.instance.doProxyPullDownRefresh();
        UIApplicationProxy.instance.doProxyApplication();
        //
        if (config.async && SQLiteManger.shareInstance().openDB()) {
            DateHelper.dispatchTimer(timeInterval: 5 * 60, handler: {(timer: DispatchSourceTimer?) -> Void in
                instance.ReportDBDataToServer();
            }, needRepeat: true);
        }
        //
        return instance;
    }
    
    static func shareInstance() -> TrackManager {
        return instance;
    }
    
    func baseActionReportToServer(actionName: TrackEventType, withParam: [String: Any]){
        self.reportActionToServer(actionName: actionName.rawValue, withParam: withParam)
    }
    
    func reportActionToServer(actionName: String, withParam: [String: Any]){
        guard let config = config else{ return }
        // 自增id=
        config.actionRequestData.log_id += 1;
        var currActionRequestData = config.actionRequestData;
        //
        currActionRequestData.type = actionName;
        currActionRequestData.props.updateValue(DateHelper.getCurrentTimeMilliStamp(), forKey: "time");
        
        // 参数序列化
        currActionRequestData.props = JsonHelper.toDictionary(currActionRequestData.props) as! [String : Any];
        let param = JsonHelper.toDictionary(withParam) as! [String: Any];
        //
        merge(current: &currActionRequestData.props, other: param, ignoreKeys: ["wx_user"]);
        
        let paras = JsonHelper.toJson(currActionRequestData);
        if (config.debug) {
            print("actionRequestData:", paras)
        }
        if (config.async) {
            DispatchQueue.main.async {
                let sql = "insert into t_action_request (data, timestamp) values('\(paras)',\(DateHelper.getCurrentTimeMilliStamp()))"
                SQLiteManger.shareInstance().execSql(sql: sql);
            }
        } else {
            DispatchQueue.main.async {
                self.doReport(paras: paras);
            }
        }
    }
    
    func ReportDBDataToServer(){
        guard let config = config else{ return }
        
        let records = SQLiteManger.shareInstance().querySql(sql: "select * from t_action_request order by id asc") ?? [];
        var reportDataArr = [String]();
        var maxId = 0;
        for record in records {
            let data = record["data"] as! String;
            reportDataArr.append(data);
            let id = record["id"] as! Int;
            maxId = maxId < id ? id : maxId;
        }
        if (reportDataArr.count > 0) {
            doReport(paras: "[" + reportDataArr.joined(separator: ",") + "]", succ: {(_ result: String) -> Void in
                SQLiteManger.shareInstance().execSql(sql: "delete from t_action_request where id <= \(maxId)");
            });
        }
        if (config.debug) {
            print("db report data:", records)
        }
    }
    
    func setUser(userId: String){
        guard let config = config else{ return }
        
        var user = config.actionRequestData.props["wx_user"] as! [String: Any];
        if userId != "" {
            user.merge(["user_id": userId], uniquingKeysWith: {(current, new) in new});
        }else {
            user.removeValue(forKey: "user_id");
        }
        
        config.actionRequestData.props.updateValue(user, forKey: "wx_user");
    }
    
    func setChan(chanShopId: String, chanShopName: String, chanCustom: Any, extra: Any){
        guard let config = config else{ return }
        
        var chan = config.actionRequestData.props["chan"] as! [String: Any];
        chan.merge(["chan_shop_id": chanShopId, "chan_shop_name": chanShopName, "chan_custom": chanCustom, "extra": extra], uniquingKeysWith: {(current, new) in new});
        config.actionRequestData.props.updateValue(chan, forKey: "chan");
    }
    
    private func merge(current: inout [String: Any], other: [String: Any], ignoreKeys: [String]){
        for (key, value) in other {
            if ignoreKeys.contains(key) { continue }
            if value is [String: Any] {
                var subCurrent: [String: Any] = [:];
                if (current[key] != nil) {
                    subCurrent = current[key] as! [String : Any] ;
                }
                merge(current: &subCurrent, other: value as! [String : Any], ignoreKeys: ignoreKeys);
                current.updateValue(subCurrent, forKey: key);
            }else {
                current.updateValue(value, forKey: key);
            }
        }
    }
    
    private func generateReportParams() -> String {
        guard let config = self.config else{ return ""};
        //
        let timeStamp = DateHelper.getCurrentTimeStamp();
        var params = "app_id=\(config.secretId)&nonce=track-sdk-ios&sign=sha256&timestamp=\(timeStamp)";
        //
        let signature = sign(secretKey: config.secretKey, str: params);
        //
        params += "&signature=\(signature)";
        
        return params;
    }
    
    private func sign(secretKey: String, str: String)-> String{
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH));
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), secretKey, secretKey.count, str, str.count, &digest);
        let data = Data(digest);
        return data.map { String(format: "%02hhx", $0) }.joined();
    }
    
    private func doReport(paras: String) {
        guard let config = self.config else{ return };
        let params = generateReportParams();
        HttpHelper.post(path: "\(config.serverUrl)?\(params)", paras: paras, success: requestSucc, failure: requestErr);
    }
    
    private func doReport(paras: String, succ: @escaping ((_ result: String) -> ())) {
        guard let config = self.config else{ return };
        let params = generateReportParams();
        HttpHelper.post(path: "\(config.serverUrl)?\(params)", paras: paras, success: {(result: String) -> Void in self.requestSucc(result: result); succ(result)}, failure: requestErr);
    }
    
    private func requestSucc (result: String){
        guard let config = config else{ return }
        if (config.debug) {
            print("report success result:", result);
        }
    }
    
    private func requestErr(error: Error){
        guard let config = config else{ return }
        if (config.debug) {
            print("report error result:", error);
        }
    }
}
