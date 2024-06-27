//
//  Token.swift
//  WalletSDK
//
//  Created by dong jun park on 4/25/24.
//

import Foundation

struct Token {
    var idx: String
    var walletId: String
    var hWalletToken: String
    var validUntil: String
    var purpose: String
    var nonce: String
    var pkgName: String
    var pii: String
    var createDate: String
    
    init(idx: String, walletId: String, hWalletToken: String, validUntil: String, purpose: String, nonce: String, pkgName: String, pii: String, createDate: String) {
        self.idx = idx
        self.walletId = walletId
        self.hWalletToken = hWalletToken
        self.validUntil = validUntil
        self.purpose = purpose
        self.nonce = nonce
        self.pkgName = pkgName
        self.pii = pii
        self.createDate = createDate
    }
}

// let token = Token(walletId: "", purpose: "", nonce: "", hashCI: "", pkgNm: "", expiredDate: "")
