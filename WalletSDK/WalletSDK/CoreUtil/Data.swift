//
//  Data.swift
//  CASample
//
//  Created by dong jun park on 5/14/24.
//

import Foundation

extension Data {
    func hexString() -> String {
        return self.map { String(format: "%02hhx", $0) }.joined()
    }
}
