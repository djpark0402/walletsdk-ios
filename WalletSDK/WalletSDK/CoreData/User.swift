//
//  User.swift
//  WalletSDK
//
//  Created by dong jun park on 5/17/24.
//

import Foundation

struct User {
    var idx: String
    var pii: String
    var finalEncKey: String
    var createDate: String
    var updateDate: String
    
    init(idx: String, pii: String, finalEncKey: String, createDate: String, updateDate: String) {
        self.idx = idx
        self.pii = pii
        self.finalEncKey = finalEncKey
        self.createDate = createDate
        self.updateDate = updateDate
    }
}
