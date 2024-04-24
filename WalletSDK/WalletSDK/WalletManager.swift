//
//  WalletManager.swift
//  WalletSDK
//
//  Created by dong jun park on 2024/04/12.
//

import Foundation

public class WalletManager {
    
    public static let shared: WalletManager = {
        let instance = WalletManager()
        return instance
    }()
    
    
    let walletCore = WalletCore()
    
    public func appFunc1() {
        print("appFunc1…")
    }
}

// CoreWallet
public extension WalletManager{
    
    func coreFunc1() {
        walletCore.coreFunc1()
        print("coreFunc1…")
    }
}
