//
//  DateHelper.swift
//  TrackSDK
//
//  Created by jonzzhao on 2021/9/28.
//

import Foundation

class DateHelper: NSObject{
    static func getCurrentTimeString(format:String?) -> String {
        let timeStamp = DateHelper.getCurrentTimeStamp()
        return DateHelper.timeStampToString(timeStamp: timeStamp, format: format)
    }
    
    static func getCurrentTimeStamp() -> String {
        let date = NSDate()
        let timeInterval = Int(date.timeIntervalSince1970)
        return "\(timeInterval)";
    }
    
    static func getCurrentTimeMilliStamp() -> String {
        let date = NSDate()
        let timeInterval = date.timeIntervalSince1970
        let millisecond = CLongLong(round(timeInterval*1000));
        return "\(millisecond)";
    }
    
    static func timeStampToString(timeStamp:String,format:String?)->String {
        
        let string = NSString(string: timeStamp)
        
        let timeSta:TimeInterval = string.doubleValue
        let dfmatter = DateFormatter()
        dfmatter.dateFormat = format == nil ? "yyyy-MM-dd HH:mm:ss" : format
        let date = NSDate(timeIntervalSince1970: timeSta)
        return dfmatter.string(from: date as Date)
    }
    
    static func stringToTimeStamp(stringTime:String,format:String?)->String {
        
        let dfmatter = DateFormatter()
        dfmatter.dateFormat = format == nil ? "yyyy年MM月dd日" : format
        let date = dfmatter.date(from: stringTime)
        let dateStamp:TimeInterval = date!.timeIntervalSince1970
        let dateSt:Int = Int(dateStamp)
        return String(dateSt)
    }
    
    /// GCD实现定时器
    ///
    /// - Parameters:
    ///   - timeInterval: 间隔时间
    ///   - handler: 事件
    ///   - needRepeat: 是否重复
    static func dispatchTimer(timeInterval: Double, handler: @escaping (DispatchSourceTimer?) -> Void, needRepeat: Bool) {
        
        let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
        timer.schedule(deadline: .now(), repeating: timeInterval)
        timer.setEventHandler {
            DispatchQueue.main.async {
                if needRepeat {
                    handler(timer)
                } else {
                    timer.cancel()
                    handler(nil)
                }
            }
        }
        timer.resume()
        
    }
}
