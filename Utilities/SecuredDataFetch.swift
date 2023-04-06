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
    static var shared = APIState()
    var url: String?
    var token: String?
    private init() {}
}

class SecuredDataFetcher {
    private let db = Firestore.firestore()
    private var cachedData: [String: (url: String, token: String)] = [:]

    // Fetches encrypted data from Firestore and decrypts it using the user's password
    //The fetchSecureData function will first check if the cached data exists in the cachedData dictionary, and return the cached data if it does. If the cached data does not exist, it will fetch the encrypted data from Firestore and decrypt it using the user's password, and store the decrypted data in the cachedData dictionary for future use.
    func fetchSecureData(for email: String, password: String, completion: @escaping (String?, String?, Error?) -> Void) {
        if let email = Auth.auth().currentUser?.email {
            if let cached = cachedData[email] {
                APIState.shared.url = cached.url
                APIState.shared.token = cached.token
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
                            APIState.shared.url = components[0]
                            APIState.shared.token = components[1]
                            self.cachedData[email] = (APIState.shared.url!, APIState.shared.token!)
                            completion(APIState.shared.url, APIState.shared.token, nil)
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

