//
//  Crypto.swift
//  powerManager
//
//  Created by Paul Olphert on 19/02/2023.
//

import Foundation
import CryptoKit

struct SHA256Crypto {
    static func hashString(_ string: String) -> String {
        let inputData = Data(string.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.map { String(format: "%02x", $0) }.joined()
        return hashString
    }

    static func hash(data: Data) -> Data {
        let hashed = SHA256.hash(data: data)
        return Data(hashed)
    }
}

