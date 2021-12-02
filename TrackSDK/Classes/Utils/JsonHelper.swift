//
//  JsonHelper.swift
//  TrackSDK
//
//  Created by jonzzhao on 2021/9/28.
//

import Foundation

class JsonHelper {
    static let decoder=JSONDecoder();
    static let encoder=JSONEncoder();
    static func toJson<T:Codable>(_ obj:T) -> String {
        let data=try! JsonHelper.encoder.encode(obj)
        let str=String(data:data,encoding:.utf8)!
        return str
    }
    static func toJson(_ obj: Any) -> String {
        let dictionary = JsonHelper.toDictionary(obj);
        
        guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted),
            let jsonStr = String(data: data, encoding: .utf8) else{
                fatalError("`JSON Object Encode Failed`")
        }
        return jsonStr;
    }
    static func toDictionary (_ obj: Any) -> Any {
        
        if (obj is Int || obj is UInt || obj is Float || obj is Double || obj is Bool || obj is String || obj is Character || obj == nil) {
            return obj;
        }
        
        // 数组类型
        if (obj is Array<Any> ) {
            let objArr = obj as! Array<Any>;
            var arr = [Any]();
            for valueItem in objArr {
                arr.append(JsonHelper.toDictionary(valueItem));
            }
            return arr;
        }
        
        let mirror = Mirror.init(reflecting: obj);
    
        // 字典类型
        if (mirror.displayStyle == .dictionary) {
            var objDic = obj as! [String: Any];
            for (key, value) in objDic {
                objDic.updateValue(JsonHelper.toDictionary(value), forKey: key);
            }
            return objDic;
        }
        
        // 其他类型
        var dictionary = [String: Any]();
        for (key, value) in mirror.children {
            guard let key = key else{ continue }
            dictionary.updateValue(JsonHelper.toDictionary(value), forKey: key);
        }
        return dictionary;
    }
    static func toObject<T:Codable>(_ data:String) -> T{
        let obj=try! JsonHelper.decoder.decode(T.self, from: data.data(using: .utf8)!)
        return obj;
    }
    static func getData(_ str:String) -> Data {
        return str.data(using: .utf8)!
    }
    static func getJson(_ data:Data) -> String {
        return String(data:data,encoding:.utf8)!
    }
}
