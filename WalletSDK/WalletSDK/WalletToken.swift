//
//  WalletToken.swift
//  WalletSDK
//
//  Created by dong jun park on 4/24/24.
//

import Foundation
import DataModelSDK

// 월렛
class WalletToken {
    
    private var resultNonce: String?
    
    private func createWalletToken(tmpToken: String, nonce: String) -> String {
        return ""
    }
    
    func createWalletTokenSeed(purpose: WalletTokenPurposeEnum, pkgName: String?) -> WalletTokenSeed? {
        return nil
    }
    
    func createNonceForWalletToken(walletTokeSeed: WalletTokenSeed, pii: String, provider: Provider, proof: Proof) -> String? {
        return ""
    }
    
}
