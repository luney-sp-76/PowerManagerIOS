//
//  SecuredDataFetch.swift
//  powerManager
//
//  Created by Paul Olphert on 23/02/2023.
//

import Foundation
import FirebaseFirestore
import CryptoKit

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
        docRef.getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                let urlHashed = data?["url"] as? String ?? ""
                let tokenHashed = data?["token"] as? String ?? ""
                let salt = data?["salt"] as? String ?? ""
                
                // Decrypt the URL and token values using SHA256
                let url = SHA256Crypto.decryptString(urlHashed, salt: salt, password: password)
                let token = SHA256Crypto.decryptString(tokenHashed, salt: salt, password: password)
                
                // Store the data in the cache
                self.cache = SecuredData(email: email, url: url, token: token, password: password)
                
                // Call the completion handler with the data
                completion(self.cache, nil)
            } else {
                print("Document does not exist")
                completion(nil, error)
            }
        }
    }
}
