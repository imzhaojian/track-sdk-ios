//
//  SQLiteManager.swift
//  TrackSDK
//
//  Created by jonzzhao on 2021/9/27.
//

import UIKit
import SQLite3

class SQLiteManger: NSObject {
    
    private static let instance = SQLiteManger();
    private var db:OpaquePointer? = nil
    
    private override init() {super.init()}
    
    static func shareInstance() -> SQLiteManger {
        return instance;
    }

    func openDB() -> Bool {
        let filePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last!
        let file = filePath + "/track_sdk.sqlite"
        let cfile = file.cString(using: String.Encoding.utf8)
        let state = sqlite3_open(cfile,&db)
        if state != SQLITE_OK{
            return false
        }
        //创建表
        return creatTable()
    }

    func creatTable() -> Bool {
        let sql = "CREATE TABLE IF NOT EXISTS 't_action_request' ('id' integer NOT NULL PRIMARY KEY AUTOINCREMENT,'data' text,'timestamp' integer );"
        return execSql(sql: sql)
    }

    @discardableResult func execSql(sql:String) -> Bool {
        let csql = sql.cString(using: String.Encoding.utf8)
        return sqlite3_exec(db, csql, nil, nil, nil) == SQLITE_OK
    }

    @discardableResult func querySql(sql:String) -> [[String: Any]]? {
        var stmt:OpaquePointer? = nil
        let csql = (sql.cString(using: String.Encoding.utf8))!
        
        if sqlite3_prepare(db, csql, -1, &stmt, nil) != SQLITE_OK {
            return nil
        }
        
        var records = [[String: Any]]()
        
        while sqlite3_step(stmt) == SQLITE_ROW {
            let record = self.queryWithStmt(stmt: stmt!);
            records.append(record);
        }
        sqlite3_finalize(stmt);
        return records;
    }
    
    func queryWithStmt(stmt: OpaquePointer) ->[String: Any]
        {
            let count = sqlite3_column_count(stmt)
            var record  = [String: Any]()
            
            for index in 0..<count
            {
                let cName = sqlite3_column_name(stmt, index)
                let name = String.init(cString: cName!)
                //
                let type = sqlite3_column_type(stmt, index)
                
                switch type
                {
                case SQLITE_INTEGER:
                    // 整形
                    let num = sqlite3_column_int64(stmt, index)
                    record[name] = Int.init(num)
                case SQLITE_FLOAT:
                    // 浮点型
                    let double = sqlite3_column_double(stmt, index)
                    record[name] = Double.init(double)
                case SQLITE3_TEXT:
                    // 文本类型
                    let cText = sqlite3_column_text(stmt, index)
                    let text = String.init(cString: cText!)
                    record[name] = text
                case SQLITE_NULL:
                    // 空类型
                    record[name] = NSNull()
                default:
                    // 二进制类型 SQLITE_BLOB
                    print("")
                }
            }
            return record
        }
}
