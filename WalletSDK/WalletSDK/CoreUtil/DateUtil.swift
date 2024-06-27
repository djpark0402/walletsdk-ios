//
//  DateUtil.swift
//  WalletSDK
//
//  Created by dong jun park on 5/20/24.
//

import Foundation

public class DateUtil {
    
    public init() {
        
    }
    
    public static func calculateTimeAfter(min: Int, sec: Int) -> String {
        let currentDate = Date()
        let calendar = Calendar.current
        if let futureDate = calendar.date(byAdding: DateComponents(minute: min, second: sec), to: currentDate) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z"
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
            return dateFormatter.string(from: futureDate)
        } else {
            return "Error calculating future time"
        }
    }
    
//    public static func getUTCDateTime() -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z"
//        dateFormatter.timeZone = TimeZone(identifier: "UTC")
//
//        let utcDate = Date()
//        let utcDateString = dateFormatter.string(from: utcDate)
//        
//        return utcDateString
//    }
    
    
    public static func convertStringtoDate(str: String) -> Date? {
        // Date 형식으로 변환
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z"
        if let date = dateFormatter.date(from: str) {
            print(date) // 변환된 Date 객체 출력

            // 만약 Date 객체를 다시 문자열로 변환하려면
            let dateStringFromDate = dateFormatter.string(from: date)
//            print(dateStringFromDate)
            return date
            
        } else {
            print("Invalid date format")
        }
        return nil
    }
    
    public static func isValid(date: Date) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let currentDate = Date()
//        let dateStringFromDate = dateFormatter.string(from: currentDate)
//        let dateStringFromDate2 = dateFormatter.string(from: date)        
//        print("currentDate: \(dateStringFromDate)")
//        print("nCurretDate: \(dateStringFromDate2)")
        
        if currentDate > date {
            return false
        } else {
            return true
        }
    }
}
