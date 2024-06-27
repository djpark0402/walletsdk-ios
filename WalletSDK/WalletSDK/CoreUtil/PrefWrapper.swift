//
//  PrefWrapper.swift
//  WalletSDK
//
//  Created by dong jun park on 4/24/24.
//

import Foundation

public class PrefWrapper {
    
    public init() {}
    
    
    public func getWalletId() -> String? {
        
        let result: String? = UserDefaults.standard.string(forKey: "walletId")
        return result
    }
    
    public func generateWalletId() -> Void {
        
        if let walletId = getWalletId() {
            //..
        } else {
            let walletId = "WID" + CryptoUtil.generateStringWithRegex()!
            print("walletId: \(walletId)")
            UserDefaults.standard.setValue(walletId, forKey: "walletId")
            UserDefaults.standard.synchronize()
        }
        
    }
}
