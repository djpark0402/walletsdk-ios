//
//  CoreWalletProtocol.swift
//  WalletSDK
//
//  Created by dong jun park on 4/22/24.
//

import Foundation

import OpenDID_DataModel
import DataModelSDK

protocol CoreWalletProtocol {
    
    func createDidDocument(hWalletToken: String, type: DidDocumentType) throws -> Bool
    func getDidDocument(type: DidDocumentType) -> DIDDocument?
    func generateKeyPair(hWalletToken: String, passcode: String, type: Int, keyId: String, algType: Int) throws -> Bool
    
    func sign(keyId: String, data: Data) -> Data?
//    func requestVC(hWalletToken: String, condition: OmniOneWallet_iOS.SubmissionCondition, refId: String, isEnc: Bool) -> Bool
//    func createVP(hWalletToken: String, vc: String, condition: OmniOneWallet_iOS.SubmissionCondition) -> DataModelSDK.VerifiablePresentation?
    func verify(hWalletToken: String, keyId: String, data: Data, signature: Data) -> Bool
    func storeVC(hWalletToken: String, vc: String) -> Bool
    func revokeVC(hWalletToken: String) -> Bool
    func getVCList(hWalletToken: String) -> [String]?
//    func getVCListByCondition(hWalletToken: String, condition: OmniOneWallet_iOS.SubmissionCondition) -> [String]?
}
