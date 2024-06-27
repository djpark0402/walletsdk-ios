//
//  KeyChainWrapper.swift
//  WalletSDK
//
//  Created by dong jun park on 5/17/24.
//

import Foundation
import OpenDIDCryptoSDK

public class KeyChainWrapper {
    
    public init() {}
    
    private var seedKey: Data? = nil
    
    public func saveKeyChain(passcode: String) throws -> Bool {
        
        var errorRef: Unmanaged<CFError>?
        
        let sacObject = SecAccessControlCreateWithFlags(kCFAllocatorDefault
                                                        , kSecAttrAccessibleWhenUnlockedThisDeviceOnly
                                                        , []
                                                        , &errorRef)
        
        let queryForDelete: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                            kSecAttrService: "KEY_PIN_CHAIN_DATA"]
        
        // 저장된 키체인 service item을 삭제
        var status = SecItemDelete(queryForDelete as CFDictionary)
        print("item delete status: \(status)")
        
        // 1. cek = 랜덤값 생성 (Contents Encrypting Key)
        var cek: NSMutableData
        if self.seedKey == nil {
            cek = NSMutableData(length: 32)!
            _ = SecRandomCopyBytes(kSecRandomDefault, 32, cek.mutableBytes)
        }  else {
            cek = NSMutableData(data: self.seedKey!)
        }
        
        print("======[H] cek: \(CryptoUtil.dataToHex(data: cek as Data))")
        
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: "KEY_PIN_CHAIN_DATA",
            kSecValueData: cek as CFData,
            kSecAttrAccessControl: sacObject!
        ]
        
        status = SecItemAdd(query as CFDictionary, nil)
        print("item add status : \(status)")
        
        if status == errSecSuccess {
            print("저장 성공")
        } else if status == errSecDuplicateItem {
            print("중복 데이터")
            throw WalletApiError(errorCode: WalletErrorCodeEnum.KEYCHAIN_FAIL)
            
        } else {
            print("저장 실패")
            throw WalletApiError(errorCode: WalletErrorCodeEnum.KEYCHAIN_FAIL)
        }
        
        
//        let salt = MultibaseEnum.decode(multibase: "f6c646576656c6f7065726c3139383540676d61696c2e636f6d")
        let salt = try MultibaseUtils.decode(encoded: "f6c646576656c6f7065726c3139383540676d61696c2e636f6d")
//        let kek = try CryptoAPI().pbkdf2(seed: passcode.data(using: .utf8)!, salt: salt)
        let kek = try CryptoUtils.pbkdf2(password: passcode.data(using: .utf8)!, salt: salt, iterations: 2048, derivedKeyLength: 32)
//            let kek = passcode.data(using: .utf8)!
        print("======[H] kek: \(CryptoUtil.dataToHex(data:kek))")
        
//        let iv = try CryptoAPI().multibaseDecode(encodeString: "z75M7MfQsC4p2rTxeKxYh2M")
        let iv = try MultibaseUtils.decode(encoded: "z75M7MfQsC4p2rTxeKxYh2M")
        
//        let encCek = try CryptoAPI().aesEncrypt(plainData: cek as Data, symmetricKey: kek, iv: iv!)
        let encCek = try CryptoUtils.encrypt(plain: cek as Data, info: CipherInfo.init(cipherType: SymmetricCipherType.aes256CBC, padding: SymmetricPaddingType.pkcs5), key: kek, iv: iv)
        print("======[H] encCek: \(CryptoUtil.dataToHex(data:encCek))")
        
        let finalEncCek = try WalletAPI.shared.secureEncrypt(plainData: encCek)
        print("======[H] finalEncCek: \(CryptoUtil.dataToHex(data: finalEncCek))")
        
        print("updateUser결과 \(CoreDataManager.shared.updateUser(finalEncKey: MultibaseUtils.encode(type: MultibaseType.base58BTC, data: finalEncCek)/*CryptoAPI().multibaseEncode(plainData: finalEncCek)*/))")
        return true
    }
    
    
    public func matching(passcode: String) throws -> Data? {
        
        var dataTypeRef: CFTypeRef?
        
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: "KEY_PIN_CHAIN_DATA",
            kSecReturnData: true
        ]
        
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        print("item matching status : \(status)")
        // throw 처리 필요
        
        
        let cek = dataTypeRef as! Data
        
        print("======[H] load cek: \(CryptoUtil.dataToHex(data: cek))")
             
//        let finalEncCek = try CryptoAPI().multibaseDecode(encodeString: CoreDataManager.shared.selectUser()!.finalEncKey)
        let finalEncCek = try MultibaseUtils.decode(encoded: CoreDataManager.shared.selectUser()!.finalEncKey)
        
        
        print("======[H] finalEncCek: \(CryptoUtil.dataToHex(data: finalEncCek))")
        
        let encCek = try WalletAPI.shared.secureDecrypt(cipherData: finalEncCek)
        print("======[H] encCek: \(CryptoUtil.dataToHex(data: encCek))")
        
//        let salt = MultibaseEnum.decode(multibase: "f6c646576656c6f7065726c3139383540676d61696c2e636f6d")
        let salt = try MultibaseUtils.decode(encoded: "f6c646576656c6f7065726c3139383540676d61696c2e636f6d")
        
        
//        let kek = try CryptoAPI().pbkdf2(seed: passcode.data(using: .utf8)!, salt: salt)
        let kek = try CryptoUtils.pbkdf2(password: passcode.data(using: .utf8)!, salt: salt, iterations: 2048, derivedKeyLength: 32)
        
        print("======[H] kek: \(CryptoUtil.dataToHex(data: kek))")
        
//        let iv = try CryptoAPI().multibaseDecode(encodeString: "z75M7MfQsC4p2rTxeKxYh2M")
        let iv = try MultibaseUtils.decode(encoded: "z75M7MfQsC4p2rTxeKxYh2M")
        
//        let decCek = try CryptoAPI().aesDecrypt(cipherData: encCek, symmetricKey: kek, iv: iv)
        
        let decCek = try CryptoUtils.decrypt(cipher: encCek, info: CipherInfo.init(cipherType: SymmetricCipherType.aes256CBC, padding: SymmetricPaddingType.pkcs5), key: kek, iv: iv)
        print("======[H] decCek: \(CryptoUtil.dataToHex(data: kek))")
        
        if cek as Data == decCek {
            print("패스워드 일치")
            print("kek: \(CryptoUtil.dataToHex(data: cek))")
            print("encCek: \(CryptoUtil.dataToHex(data: decCek))")
            print("cek: \(CryptoUtil.dataToHex(data: cek))")
            return cek as Data
        }
        
        throw WalletApiError(errorCode: WalletErrorCodeEnum.KEYCHAIN_FAIL)
    }
}
