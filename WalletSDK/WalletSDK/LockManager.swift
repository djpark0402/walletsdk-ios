//
//  LockManager.swift
//  WalletSDK
//
//  Created by dong jun park on 5/22/24.
//

import Foundation

class LockManager {
    
    public static var isLock: Bool = false
    
    init() {
        
    }
    @discardableResult
    func regLock(hWalletToken: String, passcode: String, isLock: Bool) throws -> Bool {
        return try KeyChainWrapper().saveKeyChain(passcode: passcode)
    }
    
    @discardableResult
    func isRegLock() -> Bool {
        if let user = CoreDataManager.shared.selectUser() {
            print("user.finalEncKey: \(user.finalEncKey)")
            // 조건이 false 일때 else문 호출
            if user.finalEncKey != "" {
                return true
            }
        }
        return false
    }
    
    func authLock(passcode: String) throws -> Data? {
        return try KeyChainWrapper().matching(passcode: passcode)
    }
    
//    func setLockStatus(status: Bool) -> Void {
//        self.isLock = status
//    }
//    
//    @discardableResult
//    func isLockStatus() -> Bool {
//        return self.isLock
//    }
}
