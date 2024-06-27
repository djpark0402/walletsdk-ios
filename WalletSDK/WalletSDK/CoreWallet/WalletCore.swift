//
//  WalletCore.swift
//  
//
//  Created by dong jun park on 4/18/24.
//

import Foundation
import OmniOneWallet_iOS

public class WalletCore {
    
    var keyMnr: KeyManager?
    var didMnr: DIDManager?
    var vcMnr: VCManager?
    
    public init() {
        keyMnr = KeyManager()
    }
    
    
    public func storeVC() {
        
        if !LockManager.isLock { return }
//            didMnr = DIDManager()
//            vcMnr = VCManager()
//            vcMnr?.addCredential(multibaseJson: "", issuerDIDDoc: nil)
        
    }
    
    public func secureEncrypt(plainData: Data) throws -> Data {

        print("secureEncrypt")
        return try CryptoSuites.secureEncrypt(plain: plainData)
    }
    
    public func secureDecrypt(cipherData: Data) throws -> Data {
        
        print("secureDecrypt")
        return try CryptoSuites.secureDecrypt(cipher: cipherData)
    }
}
