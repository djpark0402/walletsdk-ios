//
//  WalletManager.swift
//  WalletSDK
//
//  Created by dong jun park on 2024/04/12.
//

import Foundation
import CommSDK
import LocalAuthentication
import DataModelSDK
import OpenDID_DataModel
import OpenDIDCryptoSDK

// Controller
public class WalletAPI : WalletServiceProtocol {
    
    public static let shared: WalletAPI = {
        let instance = WalletAPI()
        return instance
    }()
    
    
    // 서비스 월렛
    private let walletToken = WalletToken()
    private let walletCore = WalletCore()
    private let lockMnr = LockManager()
    
    public func errorTest() throws -> Void {
        
        
        let clientPri = "zHr5d9pyMRnyz2aByr6dYdV5kdfnWRUkiFxjSaoFJwecs"
        let clientPub = "z23Uuwgru7ajHWvArTtq2GDBBC3y6VoWnNVPFDRP2pawkG"
        
        let serverPri = "zHktTNVoihXXUHQ1EHDgeyfqCAMwQAQtQR3joBuimiFRb"
        let serverPub = "z28XtSAueqap6J594CwXJjxUumZKmdLjiPPWPq2b4pyH4q"
        
//        let keyInfo = try CryptoUtils.generateECKeyPair(ecType: ECType.secp256r1)
//        print("pri: \(MultibaseUtils.encode(type: MultibaseType.base58BTC, data: keyInfo.privateKey))")
//        print("pub: \(MultibaseUtils.encode(type: MultibaseType.base58BTC, data: keyInfo.publicKey))")
        
        let clientSecretKey = try CryptoUtils.generateSharedSecret(ecType: ECType.secp256r1,
                                                                   privateKey:MultibaseUtils.decode(encoded: clientPri),
                                                                   publicKey:MultibaseUtils.decode(encoded: serverPub))
        
        let salt = try MultibaseUtils.decode(encoded: "f6c646576656c6f7065726c3139383540676d61696c2e636f6d")
        
        let kek = try CryptoUtils.pbkdf2(password: clientSecretKey, salt: salt, iterations: 2048, derivedKeyLength: 32)
        
        let iv = "z75M7MfQsC4p2rTxeKxYh2M".data(using: .utf8)!
        print("iv: \(iv)")
        
        
        let plainCreateDidDocStd = try ServerTokenData(purpose: ServerTokenPurposeEnum.CREATE_DID, walletId: "walletId", caAppId: "org.omnione.did.ca", validUntil: "2024-07-31T13:51:25Z", provider: Provider(did: "did sample", certVcRef: "certVcRef sample"), nonce: "nonce sample", proof: Proof(type: ProofType.SECP256R1, created: "2024-07-31T13:51:25Z", verificationMethod: "verificationMethod sample", proofPurpose: ProofPurpose.AssertionMethod)).toJsonData()
        
        print("originCreateDidDocStd: \(plainCreateDidDocStd)")
        
//        let vc = """
//        {
//          "@context": [
//            "https://www.w3.org/ns/credentials/v2"
//          ],
//          "id": "99999999-9999-9999-9999-999999999999",
//          "type": [
//            "VerifiableCredential"
//          ],
//          "issuer": {
//            "id": "did:raon:issuer",
//            "name": "issuer"
//          },
//          "issuanceDate": "2024-01-01T09:00:00Z",
//          "validFrom": "2024-01-01T09:00:00Z",
//          "validUntil": "2099-01-01T09:00:00Z",
//          "encoding": "UTF-8",
//          "formatVersion": "1.0",
//          "language": "ko",
//          "evidence": [
//            {
//              "type": "DocumentVerification",
//              "verifier": "did:raon:issuer",
//              "evidenceDocument": "BusinessLicense",
//              "subjectPresence": "Physical",
//              "documentPresence": "Physical"
//            }
//          ],
//          "credentialSchema": {
//            "id": "http://192.168.3.130:8090/tas/api/v1/download/schema?name=mdl",
//            "type": "OsdSchemaCredential"
//          },
//          "credentialSubject": {
//            "id": "did:raon:issuer",
//            "claims": [
//              {
//                "code": "org.iso.18013.5.family_name",
//                "caption": "성",
//                "value": "김",
//                "type": "text",
//                "format": "plain"
//              },
//              {
//                "code": "org.iso.18013.5.given_name",
//                "caption": "이름",
//                "value": "라온",
//                "type": "text",
//                "format": "plain"
//              },
//              {
//                "code": "org.iso.18013.5.birth_date",
//                "caption": "생년월일",
//                "value": "2012-10-02",
//                "type": "text",
//                "format": "plain"
//              },
//              {
//                "code": "org.iso.18013.5.age_in_years",
//                "caption": "연령",
//                "value": "12",
//                "type": "text",
//                "format": "plain",
//                "required": false
//              },
//              {
//                "code": "org.iso.18013.5.portrait",
//                "caption": "증명서진",
//                "value": "data:image/png;base64,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",
//                "type": "image",
//                "format": "jpg"
//              },
//              {
//                "code": "org.opendid.v1.pii",
//                "caption": "개인식별자",
//                "value": "123456",
//                "type": "text",
//                "format": "plain"
//              }
//            ]
//          },
//          "proof": {
//            "type": "Secp256r1Signature2018",
//            "created": "2024-01-01T09:00:00Z",
//            "verificationMethod": "did:raon:issuer?version=1.0#assert",
//            "proofPurpose": "assertionMethod",
//            "proofValue": "전체 클레임에 대한 서명",
//            "proofValueList": [
//              "개별 클레임에 대한 서명"
//            ]
//          }
//        }
//"""
        
//        let data = vc.data(using: .utf8)
//        let vc1 = try VerifiableCredential.init(from: data!)
        
        
        
        let encCreateDidDocStd = try CryptoUtils.encrypt(plain:plainCreateDidDocStd, info: CipherInfo(cipherType: SymmetricCipherType.aes256CBC, padding: SymmetricPaddingType.pkcs5), key: kek, iv: iv)
        
        print("multibase encCreateDidDocStd: \(MultibaseUtils.encode(type: MultibaseType.base58BTC, data: encCreateDidDocStd))")
        
        
        let decCreateDidDocStd = try CryptoUtils.decrypt(cipher: encCreateDidDocStd, info: CipherInfo(cipherType: SymmetricCipherType.aes256CBC, padding: SymmetricPaddingType.pkcs5), key: kek, iv: iv)
        
        
        
        
        print("decCreateDidDocStd: \(String(data: decCreateDidDocStd, encoding: .utf8))")
        print("multi decCreateDidDocStd: \(MultibaseUtils.encode(type: MultibaseType.base58BTC, data: decCreateDidDocStd))")
        
        
        let orignCreateDidDocStd = try ServerTokenData.init(from: decCreateDidDocStd)
        
        print("originCreateDidDocStd: \(try orignCreateDidDocStd.toJson())")
        
        
        //        let dec = CryptoAPI().aesDecrypt(cipherData: MultibaseEnum.decode(multibase:"f9be439e9b86a1e700741950915c465fa01b17671788255cf2b489fa50ecfafc2")!, symmetricKey: secretKey, iv: iv!)
        
        
        
        let issuerProfile = """
        {
           "txId":"99999999-9999-9999-9999-999999999999",
           "authNonce":"ImVTtFHLnm150Di0S++NBw==",
           "profile":{
              "id":"jhkim6557",
              "type":"IssueProfile",
              "title":"국가신분증",
              "description":"국가 신분증 입니다.",
              "encoding":"UTF-8",
              "language":"ko",
              "profile":{
                 "issuer":{
                    "did":"http://192.168.3.130:8090/tas/download/schema?name=",
                    "certVcRef":"http://192.168.3.130:8090/tas/download/vc?name=issuer",
                    "description":"발급한 증명서 설명",
                    "name":"홍길동",
                    "ref":"http://192.168.3.130:8090/tas/download/schema?name=mdl",
                    "logo":{
                       "format":"jpg",
                       "link":"http://192.168.3.130:8090/tas/download/openRndTeam.jpg",
                       "value":"6BhWy1Yk8qF6GGHKUDtfRzreZLJphVyTR8pTPPqGMogwz"
                    }
                 },
                 "credentialSchema":{
                    "id":"http://192.168.3.130:8090/tas/download/schema?name=mdl",
                    "type":"OsdSchemaCredential",
                    "value":"z3gfnvcRkriibxW5Z19ii7CotXqgiENJXY43mXbVsG5FwwQNb27stSw59RfARQ6DGKBo9SuRvQxpwP7Lhq1HDE6Wh6C3zuD2j8fS2SJNaquXhYtNd4MhUTGJ5VbzjVuhBDVCLsDVCMCdXNtW4fnKTixngcpXM5nRamhJrf3Kaw3grffBvYHco8zphzP6pD1sMjmtkWrQuLTewhzrRgQSUrVKz23SisoXKmi14LxLdGThq35PfWzSYA6roSJ76m4uQuzLpA1NHWmdDNFKhKNiFZqCz2itXJQJmdy4sZ7EFKZ2ZTXA16RHiyejEWQzQdF9uaHAS8BfS9KT1NNn2uE8crBhpXD4kkNttT1PH5hq2Q4KKiWWzXcPFEbzc1Kpo7Wy3sr1Ff7aPEiGUHC4Ua7xvnmX1EsEhmtETCnFHhNEm41ZqFszApodVyKZQRuMmi6gj6QyJVeaqKyAeFvVj9bVpCsh4mYUzSNmgqDJmb26Fwqmw9jPSe8QsVUybvv6JKvY5xDDXG8yAdZnFbezw4FncUd8CQmAdFFhBTTWBVD5BFNWjhSbUu36uiukc34T2ADDhJsthLoZZPYpd26fjXRcedcj37o8RmWGe8xk1pnZqhbiwRWPRgDmPNoQzaqx1DdEqMwDGvGSfVsJzhWFNDQzTnPVqM8kn5uxp9XASEdDvHpRPEUkUJze4fShwDJBiTieFLEKGpWYy2x6yxyWBVNHA1M1xcEGfTeSmG9MWN4cxfo8Lr65puBwvuyTdXv3K4dvFS7FNsg21vcUyf9SRYxX8YUzbyEss9E7nBcmPgVoVgQoquLYc11Z7vLu9wwRVwqqmJymAqKqBMpsGHoAWFXCEzguUAFUNnaShaZ2z5CJikKUrNUBbZWhw7EeteWwUfrswasG9QqJMgRi9yY8nMh49Hj3i9oNPobbn359V2SvHzyVsCpn5i7rzfutqAwy8FT724h"
                 },
                 "process":{
                    "issuerNonce":"zNgLzfu8edopNmKhmuGMv32",
                    "reqE2e":{
                       "nonce":"y52yzfu8ed241NmKhmuGMv32",
                       "curve":"Secp256k1",
                       "publicKey":"z2D6BhWy1Yk8qF6GGHKUDtfRzreZLJphVyTR8pTPPqGMogwzxPedTJcDUMYMiw3TG3VWRNTqwFuG2aj55G88nFf59dG5gmtXxEULvBFht8GBV2cAF5rVfc27APs7XsFbwb7sNpvpTyqE6TG2E6ynQsGpnHEFX8EE9jwbeLhgiDA",
                       "cipher":"AES-128-CBC",
                       "padding":"PKCS5",
                       "proof":{
                          "type":"Secp256k1Signature2018",
                          "created":"2024-01-01T09:00:00Z",
                          "verificationMethod":"did:raon:tas?version=1#assert",
                          "proofPurpose":"assertionMethod",
                          "proofValue":"1234567890"
                       }
                    },
                    "endpoints":[
                       "http://192.168.3.130:8091/issuer"
                    ]
                 }
              },
              "proof":{
                 "type":"Secp256k1Signature2018",
                 "created":"2024-01-01T09:00:00Z",
                 "verificationMethod":"did:raon:tas?version=1#assert",
                 "proofPurpose":"assertionMethod",
                 "proofValue":"1234567890"
              }
           }
        }
        """
        
        
        
            if let data = issuerProfile.data(using: .utf8) {

                    let issuerProfile = try _M210_RequestIssueProfile(from: data)
                    print("issuerProfile JSON: \(try issuerProfile.toJson())")
    //                        let profile = try decoder.decode(_M210_RequestIssueProfile.self, from: data)
//                    let iv = "1234567890123456".data(using: .utf8)
//                    let enc = CryptoAPI().aesEncrypt(plainData: data, symmetricKey: secretKey, iv: iv!)
//                    let encBase16 = MultibaseEnum.encode(with: enc, to: MultibaseEnum.base16upper)
                    
//                    let originBase16 = MultibaseEnum.encode(with: data, to: MultibaseEnum.base16upper)
//                    print("상준프로님 원본 보세요: \(originBase16)")
//                    print("상준프로님 암호화 보세요: \(encBase16)")

            }
//        print("result: \(MultibaseEnum.encode(with: secretKey, to: MultibaseEnum.base58btc))")
//        throw WalletApiError(errorCode: WalletErrorCodeEnum.FAIL)
    }

    
    public func osfinger() -> Observable<Data?, Error?> {
        return Observable() { emitter in
            
            let context = LAContext()
            
            // alert view 에서 cancel button 메시지.
            context.localizedCancelTitle = "Enter Username/Password"
            
            var error: NSError?
            
            // 지정한 policy 로 biometrics 인증이 가능한지 테스트.
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                
                let reason = "Log in to your account"
                
                // 지정한 policy 로 biometrics 인증 시작.
                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { success, error in
                    if success {
                        // state 업데이트는 UI 변화를 일으켜서 main thread 에서 처리해야한다.
                        emitter(nil, nil)
                    } else {
                        print(error?.localizedDescription ?? "Failed to authenticate")
                        Task { @MainActor in
                            emitter(nil, nil)
                        }
                        // Fall back to a asking for username and password.
                    }
                }
            }
            
        }
    }
    
    // 유저등록 (didDoc)
    public func requestRegisterUser(url: String, id: String, txId: String, hWalletToken: String, serverToken: String) async throws -> _M132_RequestRegisterUser? {
         
        if verifyWalletToken(hWalletToken: hWalletToken, purpose: WalletTokenPurposeEnum.CREATE_DID) {
            let wallet = Wallet(id: try WalletAPI.shared.getWalletId()!, did: holderDidDoc!.id)
            let nonce = CryptoUtil.generateNonce()!
//            let hexNonce = CryptoAPI().multibaseEncode(plainData: nonce)

            let hexNonce = MultibaseUtils.encode(type: MultibaseType.base58BTC, data: nonce)
            let proof = Proof(type: .SECP256R1, created: DateUtil.calculateTimeAfter(min: 0, sec: 0), verificationMethod: "sadfs", proofPurpose: ProofPurpose.AssertionMethod, proofValue: "1")
            
            // getDidDocument
            
            let signedDidDoc = SignedDidDoc(ownerDidDoc: "ownerDidDoc", wallet: wallet, nonce: hexNonce, proof: proof)
            let parameter = try M132_RequestRegisterUser(id: id, txId: txId, signedDidDoc: signedDidDoc, serverToken:serverToken).toJsonData()
            let responseData = try await NetworkClient().doPost1(url: URL(string:url)!, requestJsonData: parameter)
            
            return try _M132_RequestRegisterUser.init(from: responseData)
        }
                
        throw WalletApiError(errorCode: WalletErrorCodeEnum.VERIFY_TOKEN_FAIL)
    }
    
    public func getDidAuth(hWalletToken: String, authNonce: String, didType: DidDocumentType) throws -> DidAuth? {
        
        if verifyWalletToken(hWalletToken: hWalletToken, purpose: WalletTokenPurposeEnum.ISSUE_VC) {
            // 1. proofValue를 제외한 proof 생성
            let proof = Proof(type: ProofType.SECP256R1,
                              created: DateUtil.calculateTimeAfter(min: 0, sec: 0),
                              verificationMethod: "did:omn:client?version=1.0#assert",
                              proofPurpose: ProofPurpose.Authentication) // 서명값 멀티베이스
            // 2. 홀더 did 조회
    //            guard let didDoc = getDidDocument(type: didType) else {
    //                throw WalletApiError(errorCode: WalletErrorCodeEnum.FAIL, errorMessage: nil)
    //            }
            
            // 3. 홀더 did, authnonce, proof(proofValue제외) 준비
    //            var didAuth = DidAuth(did: didDoc.id, authNonce: authNonce, proof: proof)
            var didAuth = DidAuth(did: holderDidDoc!.id, authNonce: authNonce, proof: proof)
            
            // 4. core sdk에 서명 요청
    //            guard let signature = sign(keyId: "keyId", data: try didAuth.toJsonData()) else {
    //                throw WalletApiError(errorCode: WalletErrorCodeEnum.FAIL, errorMessage: nil)
    //            }

            let signature = "signature".data(using: .utf8)!
            
            
            // 5. 최종 DidAuth의 proof 준비
//            didAuth.proof.proofValue = CryptoAPI().multibaseEncode(plainData: signature)
            didAuth.proof.proofValue = MultibaseUtils.encode(type: MultibaseType.base58BTC, data: signature)
            
            // 6. didAuth 리턴
            return didAuth
        }
            
        throw WalletApiError(errorCode: WalletErrorCodeEnum.VERIFY_TOKEN_FAIL)
    }
    
    
    public func requestIssueVc(url: String, id: String, hWalletToken: String, didAuth: DidAuth, issuerProfile: _M210_RequestIssueProfile, refId: String, serverToken: String) async throws -> _M210_RequestIssueVc? {
        
        if verifyWalletToken(hWalletToken: hWalletToken, purpose: WalletTokenPurposeEnum.ISSUE_VC) {
            
            let proof = Proof(type: ProofType.SECP256R1,
                              created: DateUtil.calculateTimeAfter(min: 0, sec: 0),
                              verificationMethod: "did:omn:client?version=1.0#assert",
                              proofPurpose: ProofPurpose.Authentication)
            
            var accE2e = AccE2e(publicKey: issuerProfile.profile.profile.process.reqE2e.publicKey, iv: "iv", proof: proof)
            
            // 2. 홀더 did 조회
            //            guard let didDoc = getDidDocument(type: DidDocumentType.HolderDidDocumnet) else {
            //                throw WalletApiError(errorCode: WalletErrorCodeEnum.FAIL, errorMessage: nil)
            //            }
            
            //            guard let signature = sign(keyId: "keyId", data: try accE2e.toJsonData()) else {
            //                throw WalletApiError(errorCode: WalletErrorCodeEnum.FAIL, errorMessage: nil)
            //            }
            
            let signature = "signature".data(using: .utf8)!
//            accE2e.proof.proofValue = CryptoAPI().multibaseEncode(plainData: signature)
            accE2e.proof.proofValue = MultibaseUtils.encode(type: MultibaseType.base58BTC, data: signature)
            
            let reqVcProfile = ReqVcProfile(id: issuerProfile.profile.id, issuerNonce: issuerProfile.profile.profile.process.issuerNonce)
            
            let reqVC = ReqVC(refId: refId, profile: reqVcProfile)

            /*
            let sessKey = try CryptoAPI().generateSecretKey(privateKey: "zRoyT9DoXKRc1gBmGxSKhVHPAz1PVQXa35cGQmGpdSTU",
                                                            publicKey: "z2BP4K4FxQhX6nU1SbPi8Yc5oU2xYETu5H4fJSkL4pTz3t"/*issuerProfile.profile.profile.process.reqE2e.publicKey*/)
             */
            
            
            let sessKey = try CryptoUtils.generateSharedSecret(ecType: ECType.secp256r1,
                                                               privateKey: MultibaseUtils.decode(encoded: "zHr5d9pyMRnyz2aByr6dYdV5kdfnWRUkiFxjSaoFJwecs"),
                                                               publicKey: MultibaseUtils.decode(encoded: "z28XtSAueqap6J594CwXJjxUumZKmdLjiPPWPq2b4pyH4q"))
            
            
//            let sessKeyResult = CryptoAPI().multibaseEncode(plainData: sessKey)
            let sessKeyResult = MultibaseUtils.encode(type: MultibaseType.base58BTC, data: sessKey)
            print("sessKeyResult: \(sessKeyResult)")
            
            
            
            
//            guard let iv = try CryptoAPI().multibaseDecode(encodeString: "z75M7MfQsC4p2rTxeKxYh2M") else {
            guard let iv = try? MultibaseUtils.decode(encoded: "z75M7MfQsC4p2rTxeKxYh2M") else {
                throw WalletApiError(errorCode: WalletErrorCodeEnum.FAIL, errorMessage: nil)
            }
            
//            let encReqVc = try CryptoAPI().aesDecrypt(cipherData: reqVC.toJsonData(), symmetricKey: sessKey, iv: iv)
            let encReqVc = try CryptoUtils.encrypt(plain: reqVC.toJsonData(), info: CipherInfo(cipherType: SymmetricCipherType.aes256CBC, padding: SymmetricPaddingType.pkcs5), key: sessKey, iv: iv)
            
//            let multiEncReqVc = CryptoAPI().multibaseEncode(plainData: encReqVc)
            let multiEncReqVc = MultibaseUtils.encode(type: MultibaseType.base58BTC, data: encReqVc)
            
            let parameter = try M210_RequestIssueVc(id: id, txId: issuerProfile.txId, serverToken: serverToken, didAuth: didAuth, accE2e: accE2e, encReqVc: multiEncReqVc).toJsonData()
            
            let responseData = try await NetworkClient().doPost1(url: URL(string:url)!, requestJsonData: parameter)
            
            let decodedResponse = try _M210_RequestIssueVc.init(from: responseData)
            // 복호화, 월렛에 vc 저장
//            try CryptoAPI().multibaseDecode(encodeString: decodedResponse.e2e.encVc)
            try MultibaseUtils.decode(encoded: decodedResponse.e2e.encVc)
            // 이슈어 서명 검증 통신 (블록체인)
            
            return decodedResponse
        }
        throw WalletApiError(errorCode: WalletErrorCodeEnum.VERIFY_TOKEN_FAIL)
    }
    
    public func getSignedWalletInfo(hWalletToken: String) throws -> SignedWalletInfo? {
        
        if verifyWalletToken(hWalletToken: hWalletToken, purpose: WalletTokenPurposeEnum.CREATE_DID) ||
            verifyWalletToken(hWalletToken: hWalletToken, purpose: WalletTokenPurposeEnum.ISSUE_VC) {
            
            let proof = Proof(type: .SECP256R1, created: DateUtil.calculateTimeAfter(min: 0, sec: 0), verificationMethod: "sdfasdfsf", proofPurpose: ProofPurpose.AssertionMethod, proofValue: "1")
            let wallet = Wallet(id: try WalletAPI.shared.getWalletId()!, did: holderDidDoc!.id)
            let nonce = try CryptoUtils.generateNonce(size: 16)
            let hexNonce = MultibaseUtils.encode(type: MultibaseType.base58BTC, data:nonce)
            let signedWalletInfo = SignedWalletInfo(wallet: wallet, nonce: hexNonce, proof: proof)
            print("getSignedWalletInfo verifyWalletToken 성공")
            return signedWalletInfo
        }
        
        throw WalletApiError(errorCode: WalletErrorCodeEnum.VERIFY_TOKEN_FAIL)
    }

    /*
     1. token의 유효시간 검사
     2. purpose 검사
     */
    @discardableResult
    private func verifyWalletToken(hWalletToken: String, purpose: WalletTokenPurposeEnum) -> Bool {
        
        guard let token = CoreDataManager.shared.selectToken() else {
            return false
        }
        
        let validUntil = DateUtil.convertStringtoDate(str: token.validUntil)
        
        print("input hWalletToken: \(purpose.value)")
        print("saved purpose: \(token.purpose)")
        print("input hWalletToken: \(hWalletToken)")
        print("saved hWalletToken: \(token.hWalletToken)")
        print("saved isValid: \(DateUtil.isValid(date: validUntil!))")
        
        
        if hWalletToken == token.hWalletToken && DateUtil.isValid(date: validUntil!) 
            && purpose.value == token.purpose {
            return true
        }
        
        return false
    }
    
    public func createVp(hWalletToken: String, purpose: WalletTokenPurposeEnum) throws -> VerifiablePresentation? {
        
        if verifyWalletToken(hWalletToken: hWalletToken, purpose: WalletTokenPurposeEnum.PRESENT_VP) {
            print("createVp verifyWalletToken 성공")
            
            //            walletCore.vcMnr?.makePresentation(requestList: <#T##[PresentationRequestInfo]#>, conditionList: <#T##[SubmissionCondition]?#>, validUntil: <#T##String#>)
            //            let vp = VerifiablePresentation(from: <#any Decoder#>)
            print("createVp vp생성 성공")
            return nil
        }
        throw WalletApiError(errorCode: WalletErrorCodeEnum.VERIFY_TOKEN_FAIL)
    }
    
    
    public var holderDidDoc : DIDDocument? = nil
    public var verifiableCredential : VerifiableCredential? = nil
    
    public func fatchCaInfo() async throws -> Void {
        
        if let data = try? await NetworkClient().doGet1(url: URL(string:"http://192.168.3.130:8090/tas/api/v1/download/diddoc?name=user1")!) {
            
//            print("user \(String(describing: String(data: data, encoding: .utf8)))")
            // 목록사업자 서버통신 후 db에 저장
            
//            let didDoc = "{\"assertionMethod\":[\"pin\",\"bio\"],\"authentication\":[\"pin\",\"bio\"],\"@context\":[\"https://www.w3.org/ns/did/v1\"],\"controller\":\"did:omn:user1\",\"created\":\"2024-06-12T16:29:45Z\",\"deactivated\":false,\"id\":\"did:omn:user1\",\"updated\":\"2024-06-12T16:29:45Z\",\"verificationMethod\":[{\"authType\":4,\"controller\":\"did:omn:user1\",\"id\":\"bio\",\"publicKeyMultibase\":\"bio_Pub\",\"type\":\"Secp256r1VerificationKey2018\"},{\"authType\":4,\"controller\":\"did:omn:user1\",\"id\":\"bio\",\"publicKeyMultibase\":\"bio_Pub\",\"type\":\"Secp256r1VerificationKey2018\"}],\"versionId\":\"1\"}"
//            if let data = didDoc.data(using: .utf8) {
            do {
                holderDidDoc = try DIDDocument.init(from: data)
                print("holderDidDoc: \(String(describing: holderDidDoc))")
                
            } catch {
                print("error : \(error)")
            }
//            }
        }
        
        
        let vc = """
        {
          "@context": [
            "https://www.w3.org/ns/credentials/v2"
          ],
          "id": "99999999-9999-9999-9999-999999999999",
          "type": [
            "VerifiableCredential"
          ],
          "issuer": {
            "id": "did:raon:issuer",
            "name": "issuer"
          },
          "issuanceDate": "2024-01-01T09:00:00Z",
          "validFrom": "2024-01-01T09:00:00Z",
          "validUntil": "2099-01-01T09:00:00Z",
          "encoding": "UTF-8",
          "formatVersion": "1.0",
          "language": "ko",
          "evidence": [
            {
              "type": "DocumentVerification",
              "verifier": "did:raon:issuer",
              "evidenceDocument": "BusinessLicense",
              "subjectPresence": "Physical",
              "documentPresence": "Physical"
            }
          ],
          "credentialSchema": {
            "id": "http://192.168.3.130:8090/tas/api/v1/download/schema?name=mdl",
            "type": "OsdSchemaCredential"
          },
          "credentialSubject": {
            "id": "did:raon:issuer",
            "claims": [
              {
                "code": "org.iso.18013.5.family_name",
                "caption": "성",
                "value": "김",
                "type": "text",
                "format": "plain"
              },
              {
                "code": "org.iso.18013.5.given_name",
                "caption": "이름",
                "value": "라온",
                "type": "text",
                "format": "plain"
              },
              {
                "code": "org.iso.18013.5.birth_date",
                "caption": "생년월일",
                "value": "2012-10-02",
                "type": "text",
                "format": "plain"
              },
              {
                "code": "org.iso.18013.5.age_in_years",
                "caption": "연령",
                "value": "12",
                "type": "text",
                "format": "plain",
                "required": false
              },
              {
                "code": "org.iso.18013.5.portrait",
                "caption": "증명서진",
                "value": "data:image/png;base64,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",
                "type": "image",
                "format": "jpg"
              },
              {
                "code": "org.opendid.v1.pii",
                "caption": "개인식별자",
                "value": "123456",
                "type": "text",
                "format": "plain"
              }
            ]
          },
          "proof": {
            "type": "Secp256r1Signature2018",
            "created": "2024-01-01T09:00:00Z",
            "verificationMethod": "did:raon:issuer?version=1.0#assert",
            "proofPurpose": "assertionMethod",
            "proofValue": "전체 클레임에 대한 서명",
            "proofValueList": [
              "개별 클레임에 대한 서명"
            ]
          }
        }
"""
        
        if let data = vc.data(using: .utf8) {
            do {
                
                verifiableCredential = try VerifiableCredential.init(from: data)
                print("vc..decodedResponse: \(String(describing: verifiableCredential))")
                
//                verifiableCredential = decodedResponse
            } catch {
                print("error: \(error)")
            }
        }
        
//    }
        CoreDataManager.shared.deleteCaPakage()
        CoreDataManager.shared.insertCaPakage(pkgName: "org.omnione.did.ca")
    }
    
    /*
     1. 월렛 ID 생성
     2. Device Diddoc 생성
     3, embedded Wallet일 경우 caPkg 정보 저장
     */
    @discardableResult
    public func createWallet() async throws -> Bool {
        
        PrefWrapper().generateWalletId()
        
        // device didDoc 생성
        try await fatchCaInfo()
        
        // core호출
        return true
//        throw WalletApiError.init(errorCode: .FAIL, errorMessage: nil)
    }
    
    /*
     1. 월렛 파일 삭제 (vc, diddoc)
     2. DB 삭제
     3, pref 삭제
     */
    @discardableResult
    public func deleteWallet() -> Bool {
//        walletCoreHlr.keyMnr.
        return false
    }
    

    
    
    /*
     1. token table clear (유효시간 체크해서)
     */
    @discardableResult
    public func createWalletTokenSeed(purpose: WalletTokenPurposeEnum, pkgName: String) throws -> WalletTokenSeed? {
        
        guard let nonce = CryptoUtil.generateNonce() else {
            print("createWalletTokenSeed nonce 생성 실패")
            throw WalletApiError(errorCode: WalletErrorCodeEnum.FAIL, errorMessage: nil)
        }
        
        let hexNonce = MultibaseUtils.encode(type: MultibaseType.base58BTC, data: nonce)
        let seed = WalletTokenSeed(purpose: purpose, pkgName: pkgName, nonce: hexNonce, validUntil: DateUtil.calculateTimeAfter(min: 0, sec: 0))
                       
        return seed
    }
    
    public func createNonceForWalletToken(walletTokeData: WalletTokenData) throws -> String? {

        let resultNonce = MultibaseUtils.encode(type: MultibaseType.base58BTC, data: try CryptoUtils.generateNonce(size: 16))
        let hWalletToken = try walletTokeData.toJson().appending(resultNonce).sha256()
        print("sdk hWalletToken \(hWalletToken)")
        
        
        let purpose = WalletTokenPurpose(purpose: walletTokeData.seed.purpose)
        
        if let walletId = PrefWrapper().getWalletId(), 
            CoreDataManager.shared.insertToken(walletId: walletId,
                                              hWalletToken: hWalletToken,
                                              purpose: purpose.purposeCode.value,
                                              pkgName: walletTokeData.seed.pkgName,
                                              nonce: walletTokeData.seed.nonce,
                                              pii: walletTokeData.sha256_pii) {
            return resultNonce
        }
        print("bindUser selectToken 실패")
        throw WalletApiError(errorCode: WalletErrorCodeEnum.QUERY_DATABASE_FAIL, errorMessage: nil)
    }
    
    @discardableResult
    public func bindUser(hWalletToken: String) throws -> Bool {
        
        print("hWalletToken: \(hWalletToken)")

        if verifyWalletToken(hWalletToken: hWalletToken, purpose: WalletTokenPurposeEnum.PERSONALIZED)
            || verifyWalletToken(hWalletToken: hWalletToken, purpose: WalletTokenPurposeEnum.PERSONALIZE_AND_CONFIGLOCK) {
            if let token = CoreDataManager.shared.selectToken() {
                print("bindUser verifyWalletToken 등록 성공")
                // 최초 유저 등록 시 finalEncKey값 존재하지 않음 (PIN 입력 후 매핑 됨)
                CoreDataManager.shared.insertUser(finalEncKey: "", pii: token.pii)
                return true
            } else {
                print("bindUser selectToken 실패")
                throw WalletApiError(errorCode: WalletErrorCodeEnum.QUERY_DATABASE_FAIL, errorMessage: nil)
            }
        }
        throw WalletApiError(errorCode: WalletErrorCodeEnum.VERIFY_TOKEN_FAIL, errorMessage: nil)
   
    }
    
    @discardableResult
    func unbindUser(hWalletToken: String) throws -> Bool {
        
        if verifyWalletToken(hWalletToken: hWalletToken, purpose: WalletTokenPurposeEnum.DEPERSONALIZED) {
            print("unbindUser 토큰 검증 성공")
            if CoreDataManager.shared.deleteUser() {
                return true
            } else {
                throw WalletApiError(errorCode: WalletErrorCodeEnum.FAIL, errorMessage: nil)
            }
        }
        
        throw WalletApiError(errorCode: WalletErrorCodeEnum.VERIFY_TOKEN_FAIL)
    }
    
    public func getWalletId() throws -> String? {
        
        if let walletId = PrefWrapper().getWalletId() {
            return walletId
        }
        throw WalletApiError(errorCode: WalletErrorCodeEnum.FAIL, errorMessage: nil)
    }
    
    // Core SDK 접근 제어를 위한 lock 상태 저장/ 조회
    public func registerLock(hWalletToken: String, passcode: String, isLock: Bool) throws -> Bool {
        
        if verifyWalletToken(hWalletToken: hWalletToken, purpose: WalletTokenPurposeEnum.PERSONALIZED) ||
            verifyWalletToken(hWalletToken: hWalletToken, purpose: WalletTokenPurposeEnum.PERSONALIZE_AND_CONFIGLOCK) {
            
            try lockMnr.regLock(hWalletToken: hWalletToken, passcode: passcode, isLock: isLock)
            print("setLockType 등록 성공")
            return true
        }
        
        throw WalletApiError(errorCode: WalletErrorCodeEnum.VERIFY_TOKEN_FAIL)
    }
    
    public func isLock() throws -> Bool {
        
        return lockMnr.isRegLock()
    }
    
    public func authenticateLock(passcode: String) throws -> Data? {
        
        return try lockMnr.authLock(passcode: passcode)
    }
}

// CoreWallet
extension WalletAPI: CoreWalletProtocol {
    
    // CREATE_DID
    @discardableResult
    public func createDidDocument(hWalletToken: String, type: DidDocumentType) throws -> Bool {
        
        if verifyWalletToken(hWalletToken: hWalletToken, purpose: WalletTokenPurposeEnum.CREATE_DID) {
            print("createDidDocument verifyWalletToken 성공")
            return true
        }
        
        throw WalletApiError(errorCode: WalletErrorCodeEnum.VERIFY_TOKEN_FAIL)
    }
    
    @discardableResult
    public func getDidDocument(type: DidDocumentType) -> DIDDocument? {
    
        return nil
    }
    
    @discardableResult
    public func generateKeyPair(hWalletToken: String, passcode: String, type: Int, keyId: String, algType: Int) throws -> Bool {
        
        if verifyWalletToken(hWalletToken: hWalletToken, purpose: WalletTokenPurposeEnum.CREATE_DID) {
            print("generateKeyPair verifyWalletToken 성공")
            //            try! CryptoSuites.generateKeyPair(algorithmType: .secp256r1)
            return true
        }
        throw WalletApiError(errorCode: WalletErrorCodeEnum.VERIFY_TOKEN_FAIL)
        
    }

    @discardableResult
    public func sign(keyId: String, data: Data) -> Data? {
        
        return nil
    }
    
//    public func requestVC(hWalletToken: String, condition: SubmissionCondition, refId: String, isEnc: Bool) -> Bool {
//        return true
//    }
    
//    public func createVP(hWalletToken: String, vc: String, condition: SubmissionCondition) -> DataModelSDK.VerifiablePresentation? {
//        return nil
//    }
    
    public func verify(hWalletToken: String, keyId: String, data: Data, signature: Data) -> Bool {
        return true
    }
    
    public func storeVC(hWalletToken: String, vc: String) -> Bool {
        return true
    }
    
    public func revokeVC(hWalletToken: String) -> Bool {
        return true
    }
    
    public func getVCList(hWalletToken: String) -> [String]? {
        return nil
    }
    
//    public func getVCListByCondition(hWalletToken: String, condition: SubmissionCondition) -> [String]? {
//        return nil
//    }
    
    public func getDid(hWalletToken: String, type: Int) -> String? {
        
        return ""
    }
    
    
    public func secureEncrypt(plainData: Data) throws -> Data {

        print("secureEncrypt")
        return try walletCore.secureEncrypt(plainData: plainData)
    }
    
    public func secureDecrypt(cipherData: Data) throws -> Data {
        
        print("secureDecrypt")
        return try walletCore.secureDecrypt(cipherData: cipherData)
    }
}
