//
//  WalletApiError.swift
//  WalletSDK
//
//  Created by dong jun park on 5/17/24.
//

import Foundation

public enum WalletErrorCodeEnum: Int, Jsonable {
    case UNNKOWN = -1
    case SUCCESS
    case FAIL
    case VERIFY_TOKEN_FAIL
    case QUERY_DATABASE_FAIL
    case KEYCHAIN_FAIL
    
}

public class WalletApiError: Error {
    private var errorCode: WalletErrorCodeEnum
    private var errorMessage: String?
    
    public func getErrorCode() -> Int {
        return errorCode.rawValue
    }
    
    public func getErrorMessage() -> String {
        if let errMsg = errorMessage, !errMsg.isEmpty {
            return errMsg
        }
        
        switch self.errorCode {
        case .UNNKOWN:
            return "unnkown"
        case .SUCCESS:
            return "success"
        case .FAIL:
            return "fail"
        case .VERIFY_TOKEN_FAIL:
            return "verify token fail"
        case .QUERY_DATABASE_FAIL:
            return "query database fail"
        case .KEYCHAIN_FAIL:
            return "keychain fail"
        }
        
        
    }
    
    public init(errorCode: WalletErrorCodeEnum, errorMessage: String? = nil) {
        self.errorCode = errorCode
        self.errorMessage = errorMessage
    }
}


//extension ErrorEnum {
//    var nsError: NSError {
//        return NSError()
//    }
//}

/*
 do {
     let integer = 1
     let errCode = try test(code: integer)
     print("errCode: \(errCode)")
 } catch let error as ErrorEnum {
     print("TestError: \(error)")
 } catch {
     print(error)
 }
 
 
 func test(code: Int) throws -> ErrorEnum {

     if code == 1 {
         throw ErrorEnum.TEST_FAIL("실패").nsError
     }
     else if code == 0 {
         throw ErrorEnum.TEST_SUCCESS("성공").nsError
     }
     else {
         throw ErrorEnum.TEST_UNNKOWN("알수 없는 에러").nsError
     }
 }
 
 
 */
