//
//  CryptoUtil.swift
//  WalletSDK
//
//  Created by dong jun park on 4/18/24.
//

import Foundation
import CryptoKit

public class CryptoUtil {
    
    public init() {
        
    }
    
    public static func sha256(object: Data, nonce: String) -> String {
        let encoder = JSONEncoder()
        let formatting : JSONEncoder.OutputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        encoder.outputFormatting = formatting
    
        guard let data = try? encoder.encode(object) else {
            return ""
        }
        
        let hashData = Data(nonce.utf8)
        let inputData = data + hashData
        
        let hashed = SHA256.hash(data: inputData)
        let hashedString = hashed.compactMap { String(format: "%02x", $0) }.joined()
        
        return hashedString
    }
    
    
    public static func generateStringWithRegex() -> String? {
        let regex = "[a-zA-Z_][0-9a-zA-Z_]{19}"
        let pattern = try! NSRegularExpression(pattern: regex)
        
        var generatedString: String?
        
        repeat {
            var randomString = ""
            
            for _ in 0..<20 {
                let asciiValue = Int.random(in: 65...90) // ASCII values for A-Z
                let character = Character(UnicodeScalar(asciiValue)!)
                randomString.append(character)
            }
            
            if pattern.matches(in: randomString, range: NSRange(randomString.startIndex..., in: randomString)).count > 0 {
                generatedString = randomString
            }
        } while generatedString == nil
        
        return generatedString
    }
    
    public static func encodeMultiBase(data: Data, base: String) -> String {
        var encodedString = ""
        for byte in data {
            let index = Int(byte) % base.count
            let encodedChar = base[base.index(base.startIndex, offsetBy: index)]
            encodedString.append(encodedChar)
        }
        return encodedString
    }

    public static func decodeMultiBase(input: String, base: String) -> Data? {
        var decodedData = Data()
        for char in input {
            if let index = base.firstIndex(of: char) {
                let decodedByte = UInt8(base.distance(from: base.startIndex, to: index))
                decodedData.append(decodedByte)
            } else {
                return nil
            }
        }
        return decodedData
    }
    
    public static func generateNonce() -> Data? {
        
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
    
    public static func dataToHex(data: Data) -> String {
            
        let dbytes = [UInt8](data)
        var hexStr = ""
        for byte in dbytes {
            hexStr += String(format: "%02x", byte)
        }
        return hexStr
    }
}
