//
//  SecuredDataFetch.swift
//  powerManager
//
//  Created by Paul Olphert on 23/02/2023.
//

import Foundation
import FirebaseFirestore
import CryptoKit
import CommonCrypto


struct SecuredData {
    let email: String
    let url: String
    let token: String
    let password: String
}

class SecuredDataFetcher {
    let db = Firestore.firestore()
    var cache: SecuredData?

    func fetch(email: String, password: String, completion: @escaping (SecuredData?, Error?) -> Void) {
        // Check if the data is already in the cache
        if let data = cache {
            completion(data, nil)
            return
        }
        
        // Retrieve the document from Firestore
        let docRef = db.collection("securedData").document(email)
        
        // Capture a mutable reference to self
       let weakSelf = self
        
        docRef.getDocument { [weak weakSelf] document, error in
            guard let weakSelf = weakSelf else { return }
            
            if let document = document, document.exists {
                let data = document.data()
                guard let encryptedData = data?["encryptedData"] as? Data,
                      let nonceData = data?["nonce"] as? Data,
                      let salt = data?["salt"] as? String else {
                    completion(nil, error)
                    return
                }
                let nonce = try? AES.GCM.Nonce(data: nonceData)
                let sealedBox = try? AES.GCM.SealedBox(combined: encryptedData)
                
                // Decrypt the sealed box using the symmetric key generated from the user's password, salt, and number of iterations
                let key = SymmetricKey(data: self.generateBcryptKey(from: password, salt: Data(salt.utf8)))
                
                let decryptedData = try! AES.GCM.open(sealedBox!, using: key)
                let decryptedString = String(data: decryptedData, encoding: .utf8)!
                let decryptedFields = decryptedString.components(separatedBy: ",")
                weakSelf.cache = SecuredData(email: email, url: decryptedFields[0], token: decryptedFields[1], password: password)
                
                //Call the completion handler with the data
                completion(self.cache, nil)
            } else {
                print("Document does not exist")
                completion(nil, error)
            }
        }
    }
    
    func generateBcryptKey(from password: String, salt: Data, rounds: Int = 12) -> Data {
        let passwordData = password.data(using: .utf8)!
        let keyLength  = 32
        let derivedKeyData = Data(count: keyLength)
        var result = Data(count: derivedKeyData.count)
       _ = derivedKeyData.withUnsafeBytes { derivedKeyPtr in
            passwordData.withUnsafeBytes { passwordPtr in
                salt.withUnsafeBytes { saltPtr in
                    CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2),
                                         passwordPtr.baseAddress!, passwordData.count,
                                         saltPtr.baseAddress!, salt.count,
                                         CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
                                         UInt32(rounds),
                                         result.withUnsafeMutableBytes { resultPtr in
                        resultPtr.baseAddress!
                    },
                                         derivedKeyData.count)
                }
            }
        }
        print(result.count)
        return result
    }
    
    
    
    
    
}
