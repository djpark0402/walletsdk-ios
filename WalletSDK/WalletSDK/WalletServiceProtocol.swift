//
//  AppWalletProtocol.swift
//  WalletSDK
//
//  Created by dong jun park on 4/22/24.
//

import Foundation
import DataModelSDK

protocol WalletServiceProtocol {
    
    func createWalletTokenSeed(purpose: WalletTokenPurposeEnum, pkgName: String) throws -> WalletTokenSeed?
    func createNonceForWalletToken(walletTokeData: WalletTokenData) throws -> String?
    
    // 유저 바인드
    func bindUser(hWalletToken: String) throws -> Bool
    func unbindUser(hWalletToken: String) throws -> Bool
    
    // 월렛 형태 변경
    func registerLock(hWalletToken: String, passcode: String, isLock: Bool) throws -> Bool
    func isLock() throws -> Bool
    func authenticateLock(passcode: String) throws -> Data?
    
    func getWalletId() throws -> String?
}
