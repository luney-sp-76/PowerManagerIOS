//
//  Crypto.swift
//  powerManager
//
//  Created by Paul Olphert on 19/02/2023.
//

import Foundation
import CryptoKit

//cryptography for hashing the token and url for home assistant
//the struct takes an additional salt parameter for both the hashString and hash methods. The salt is appended to the input string or data before it is hashed with SHA256.
struct SHA256Crypto {
    static func hashString(_ string: String, salt: String, password: String) -> String {
        let inputData = Data((string + salt + password).utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.map { String(format: "%02x", $0) }.joined()
        return hashString
    }

    static func hash(data: Data, salt: String, password: String) -> Data {
        let inputData = Data(data + Data(salt.utf8) + Data(password.utf8))
        let hashed = SHA256.hash(data: inputData)
        return Data(hashed)
    }
    
    static func decryptString(_ encryptedString: String, salt: String, password: String) -> String {
        let inputData = Data((encryptedString + salt + password).utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.map { String(format: "%02x", $0) }.joined()
        return hashString
    }
    
    static func decrypt(data: Data, salt: String, password: String) -> Data {
        let inputData = Data(data + Data(salt.utf8) + Data(password.utf8))
        let hashed = SHA256.hash(data: inputData)
        return Data(hashed)
    }
}

