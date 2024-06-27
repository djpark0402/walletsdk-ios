//
//  ECDH.swift
//  CrpytoSDK
//
//  Created by dong jun park on 4/22/24.
//

import Foundation
import OmniOneWallet_iOS

public class CryptoAPI {
    
    public init() {
        
    }
    
    public func generateNonce() throws -> Data? {
        
        let length = 16
        var data = Data(count: length)
        let result = data.withUnsafeMutableBytes { mutableBytes in
            SecRandomCopyBytes(kSecRandomDefault, length, mutableBytes)
        }
        if result == errSecSuccess {
            return data
        } else {
            return nil
        }
    }
    
    public func generateKeyPair() throws -> KeyPairInfo {
        do {
            let keyPair = try! CryptoSuites.generateKeyPair(algorithmType: .secp256r1)
            return keyPair
        } catch let e as OdiError {
            switch e {
            case .error(let code, let msg):
                print("!! 실패. error code: \(code), msg: \(msg)")
            }
        }
    }
    
    public func generateSecretKey(privateKey: String, publicKey: String) -> Data {
        
        do {
            let sharedSecret = try! CryptoSuites.getECDHSharedSecret(algoType: .secp256r1,
                                                                     privKeyMultibase: privateKey,
                                                                     pubKeyMultibase: publicKey)
            
            // hex -> byte
            let salt = MultibaseEnum.decode(multibase: "f6c646576656c6f7065726c3139383540676d61696c2e636f6d")
            let sharedSecretBase16 = MultibaseEnum.encode(with: sharedSecret, to: MultibaseEnum.base16upper)
            let pbkdf = try! CryptoSuites.pbkdf2(seed: sharedSecretBase16.data(using: .utf8)!, salt: salt!, rounds: 2048, derivedKeyLength: 32)
            
//            print("pbkdf2 result: \(MultibaseEnum.encode(with: pbkdf, to: MultibaseEnum.base58btc))")
            
            return pbkdf
            
        } catch let e as OdiError {
            switch e {
            case .error(let code, let msg):
                print("!! 실패. error code: \(code), msg: \(msg)")
            @unknown default:
                fatalError()
            }
        }
    }
    
    public func aesEncrypt(plainData: Data, symmetricKey: Data, iv: Data) -> Data {

        print("aesEncrypt")
        do {
            let cipher = try! CryptoSuites.aesEncrypt(plain: plainData, key: symmetricKey, iv: iv, keySizeType: .bits256)
            return cipher
        } catch let e as OdiError {
            switch e {
            case .error(let code, let msg):
                print("!! 실패. error code: \(code), msg: \(msg)")
            @unknown default:
                fatalError()
            }
        }

    }
    
    public func aesDecrypt(cipherData: Data, symmetricKey: Data, iv: Data) -> Data {
        
        print("aesDecrypt")
        do {
            let plainData = try! CryptoSuites.aesDecrypt(cipher: cipherData, key: symmetricKey, iv: iv, keySizeType: .bits256)
            return plainData
        } catch let e as OdiError {
            switch e {
            case .error(let code, let msg):
                print("!! 실패. error code: \(code), msg: \(msg)")
            @unknown default:
                fatalError()

            }
        }
    }
    
    public func pbkdf2(seed: Data, salt: Data) throws -> Data{
        
        print("pbkdf2")
        
        let drivedKeyLength: UInt = 32// + 16
        
        let result = try! CryptoSuites.pbkdf2(seed: seed, salt: salt, derivedKeyLength: drivedKeyLength)
        return result
    
    }
    
    public func multibaseEncode(plainData: Data) -> String {

        print("multibaseEncode")
        let encoded = MultibaseEnum.encode(with: plainData, to: .base58btc)
        return encoded
    }
    
    public func multibaseDecode(encodeString: String) -> Data? {
        
        print("multibaseDecode")
        let decoded = MultibaseEnum.decode(multibase: encodeString)!
        return decoded
    }
    
    public func secureEncrypt(plainData: Data) throws -> Data {

        print("secureEncrypt")
        do {
            let cipher = try! CryptoSuites.secureEncrypt(plain: plainData)
            return cipher
        } catch let e as OdiError {
            switch e {
            case .error(let code, let msg):
                print("!! 실패. error code: \(code), msg: \(msg)")
            @unknown default:
                fatalError()
            }
        }
    }
    
    public func secureDecrypt(cipherData: Data) throws -> Data {
        
        print("secureDecrypt")
        
        do {
            let plain = try! CryptoSuites.secureDecrypt(cipher: cipherData)
            return plain
        } catch let e as OdiError {
            switch e {
            case .error(let code, let msg):
                print("!! 실패. error code: \(code), msg: \(msg)")
            @unknown default:
                fatalError()
            }
        }
    }
}


