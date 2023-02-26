//
//  SecuredDataFetch.swift
//  powerManager
//
//  Created by Paul Olphert on 23/02/2023.
//
//
import Foundation
import FirebaseFirestore
import FirebaseAuth
import CryptoKit
import CommonCrypto
import RNCryptor

struct SecuredData {
    let email: String
    let url: String
    let token: String
    let password: String
}

struct APIState {
    var url: String?
    var token: String?
}

class SecuredDataFetcher {
    private let db = Firestore.firestore()
    private var cachedData: [String: (url: String, token: String)] = [:]
    var apiState = APIState()
    // Fetches encrypted data from Firestore and decrypts it using the user's password
    //The fetchSecureData function will first check if the cached data exists in the cachedData dictionary, and return the cached data if it does. If the cached data does not exist, it will fetch the encrypted data from Firestore and decrypt it using the user's password, and store the decrypted data in the cachedData dictionary for future use.
    func fetchSecureData(for email: String, password: String, completion: @escaping (String?, String?, Error?) -> Void) {
        if let email = Auth.auth().currentUser?.email {
            if let cached = cachedData[email] {
                self.apiState.url = cached.url
                self.apiState.token = cached.token
                completion(cached.url, cached.token, nil)
            } else {
                let securedDataRef = db.collection("securedData").document(email)
                securedDataRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        guard let data = document.data(),
                              let encryptedData = data["encryptedData"] as? Data else {
                            completion(nil, nil, NSError(domain: "MyApp", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid data in document"]))
                            return
                        }
                        
                        let key = password
                        do {
                            let decryptedData = try RNCryptor.decrypt(data: encryptedData, withPassword: key)
                            guard let decryptedString = String(data: decryptedData, encoding: .utf8) else {
                                completion(nil, nil, NSError(domain: "MyApp", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to decode decrypted data"]))
                                return
                            }
                            let components = decryptedString.components(separatedBy: ",")
                            self.apiState.url = components[0]
                            self.apiState.token = components[1]
                            self.cachedData[email] = (self.apiState.url!, self.apiState.token!)
                            completion(self.apiState.url, self.apiState.token, nil)
                            guard components.count >= 2 else {
                                completion(nil, nil, NSError(domain: "MyApp", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid decrypted data format"]))
                                return
                            }
                            completion(components[0], components[1], nil)
                        } catch {
                            completion(nil, nil, error)
                        }
                    } else if let error = error {
                        completion(nil, nil, error)
                    } else {
                        completion(nil, nil, NSError(domain: "MyApp", code: 1, userInfo: [NSLocalizedDescriptionKey: "Document does not exist"]))
                    }
                }
            }
        }
    }
}

//    func fetch(email: String, password: String, completion: @escaping (SecuredData?, Error?) -> Void) {
//        // Check if the data is already in the cache
//        if let data = cache {
//            completion(data, nil)
//            return
//        }
//
//        // Retrieve the document from Firestore
//        let docRef = db.collection("securedData").document(email)
//
//        docRef.getDocument { [weak self] document, error in
//            guard let self = self else { return }
//
//            if let document = document, document.exists {
//                let data = document.data()
//                guard let encryptedData = data?["encryptedData"] as? Data,
//                      let nonceData = data?["nonce"] as? Data,
//                      let salt = data?["salt"] as? String else {
//                    completion(nil, error)
//                    return
//                }
//
//                guard let nonce = try? AES.GCM.Nonce(data: nonceData) else {
//                    print("Invalid nonce")
//                    completion(nil, error)
//                    return
//                }
//                print("Encrypted Data: \(encryptedData.count) bytes")
//                print("nonceData Data: \(nonceData.count) bytes")
//                print("salt Data: \(salt)")
//                print("nonce: \(nonce)")
//                print("password: \(password)")
//                do {
//                    let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
//                    print("sealedBox cipherText: \(sealedBox.ciphertext)")
//                    print("sealedBox tag: \(sealedBox.tag)")
//                    let key = self.generateBcryptKey(from: password, salt: Data(salt.utf8))
//                    print("key: \(key)")
//                    let symmetricKey = SymmetricKey(data: key)
//                    print("Symmetric Key: \(symmetricKey)")
//                    let keyData = symmetricKey.withUnsafeBytes {
//                        Data(Array($0)).suffix(32) // limit to 32 bytes since the key is 256 bits
//                    }
//                    print("Symmetric Key Data: \(keyData)")
//                    let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)
//                    print("decryptedData: \(decryptedData)")
//                    let decryptedString = String(data: decryptedData, encoding: .utf8)!
//                    print("decryptedString: \(decryptedString)")
//                    let decryptedFields = decryptedString.components(separatedBy: ",")
//                    print("decryptedFields: \(decryptedFields)")
//                    self.cache = SecuredData(email: email, url: decryptedFields[0], token: decryptedFields[1], password: password)
//                    let securedData = SecuredData(email: email, url: decryptedFields[0], token: decryptedFields[1], password: password)
//
//                    // Check the size of the decrypted data
//                                   print("Decrypted data size: \(decryptedData.count)")
//
//                                   // Compare the decrypted data with the original plaintext
//                                   let originalData = self.createOriginalData(from: data!)
//                                   if decryptedData == originalData {
//                                       print("Decryption successful")
//                                   } else {
//                                       print("Decryption failed")
//                                   }
//
//                    // Call the completion handler with the data
//                    completion(self.cache, nil)
//                } catch {
//                    print("Error decrypting data: \(error)")
//                    completion(nil, error)
//                }
//            } else {
//                print("Document does not exist")
//                completion(nil, error)
//            }
//        }
//    }

    func createOriginalData(from data: [String: Any]) -> Data {
        let url = data["url"] as! String
        let token = data["token"] as! String
        let password = data["password"] as! String
        let plaintext = "\(url),\(token),\(password)"
        return plaintext.data(using: .utf8)!
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
        print("Iterations \(result.count)")
        return result
}

//import Foundation
//import FirebaseFirestore
//import CryptoKit
//import CommonCrypto
//
//
//struct SecuredData {
//    let email: String
//    let url: String
//    let token: String
//    let password: String
//}
//
//class SecuredDataFetcher {
//    let db = Firestore.firestore()
//    var cache: SecuredData?
//
//    func fetch(email: String, password: String, completion: @escaping (SecuredData?, Error?) -> Void) {
//        // Check if the data is already in the cache
//        if let data = cache {
//            completion(data, nil)
//            return
//        }
//
//        // Retrieve the document from Firestore
//        let docRef = db.collection("securedData").document(email)
//
//        // Capture a mutable reference to self
//        let weakSelf = self
//
//        docRef.getDocument { [weak weakSelf] document, error in
//            guard let weakSelf = weakSelf else { return }
//
//            if let document = document, document.exists {
//                let data = document.data()
//                guard let encryptedData = data?["encryptedData"] as? Data,
//                      let nonceData = data?["nonce"] as? Data,
//                      let salt = data?["salt"] as? String else {
//                    completion(nil, error)
//                    return
//                }
//                guard let nonce = try? AES.GCM.Nonce(data: nonceData) else {
//                    print("Invalid nonce")
//                    completion(nil, error)
//                    return
//                }
//                let sealedBox = try? AES.GCM.SealedBox(combined: encryptedData)
//
//                // Decrypt the sealed box using the symmetric key generated from the user's password, salt, and number of iterations
//                let key = self.generateBcryptKey(from: password, salt: Data(salt.utf8))
//
//                var cryptor: CCCryptorRef?
//                let status = CCCryptorCreateWithMode(kCCDecrypt, // operation
//                                                                 kCCModeGCM, // mode
//                                                                 kCCAlgorithmAES, // algorithm
//                                                                 ccNoPadding, // padding
//                                                                 nonce.bytes, // iv
//                                                                 key.bytes, key.count, // key
//                                                                 nil, 0, // tweaks
//                                                                 0, // num of rounds
//                                                                 kCCModeOptionTagLength128, // tag length
//                                                                 0, // data size
//                                                                 &cryptor)
//                            guard status == kCCSuccess else {
//                                print("Error creating GCM cryptor: \(status)")
//                                completion(nil, error)
//                                return
//                            }
//
//                var plaintext = [UInt8](repeating: 0, count: sealedBox.ciphertext.count)
//                var plaintextLength = 0
//                let updateStatus = CCCryptorUpdate(cryptor, sealedBox.ciphertext.bytes, sealedBox.ciphertext.count, &plaintext, plaintext.count, &plaintextLength)
//                guard updateStatus == kCCSuccess else {
//                    print("Error decrypting data: \(updateStatus)")
//                    completion(nil, error)
//                    return
//                }
//
//                var tag = [UInt8](repeating: 0, count: AES.GCM.tagSize)
//                let finalStatus = CCCryptorFinal(cryptor, &tag, &AES.GCM.tagSize)
//                guard finalStatus == kCCSuccess else {
//                    print("Error finalizing GCM cryptor: \(finalStatus)")
//                    completion(nil, error)
//                    return
//                }
//
//                CCCryptorRelease(cryptor)
//
//                let decryptedData = Data(bytes: &plaintext, count: plaintextLength)
//                let decryptedString = String(data: decryptedData, encoding: .utf8)!
//                let decryptedFields = decryptedString.components(separatedBy: ",")
//                weakSelf.cache = SecuredData(email: email, url: decryptedFields[0], token: decryptedFields[1], password: password)
//
//                //Call the completion handler with the data
//                completion(self.cache, nil)
//
//            } else {
//                print("Document does not exist")
//                completion(nil, error)
//            }
//        }
//
//    }
//
//
//    //The generateBcryptKey function takes a password string and a salt Data object as input and returns a Data object containing the derived key. The function also has a default value of 12 for the rounds parameter, which is used to control the number of iterations in the key derivation process.
    

//
//
//
//
//}
