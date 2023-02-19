//
//  FireBaseService.swift
//  powerManager
//
//  Created by Paul Olphert on 09/02/2023.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class MyFirestoreService {
    
    private static let db = Firestore.firestore()
    
    // fetch data from firebase from a collection and orderBy returns an array of HomeAssistantData type
    static func fetchOrderedItems(collectionName:String, orderBy: String, completion: @escaping ([HomeAssistantData]) -> Void) {
            db.collection(collectionName).order(by: orderBy).getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                
                    return
                }
                var items = [HomeAssistantData]()
                for document in querySnapshot!.documents {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: document.data(), options: [])
                        let item = try JSONDecoder().decode(HomeAssistantData.self, from: data)
                        items.append(item)
                    } catch let error {
                        print("Error decoding item: \(error)")
                    }
                }
                completion(items)
            }
        }
    
    // fetch data from firebase from a collection and orderBy, where, is equal to
    static func fetchOrderedItemsWhere(collectionName: String, orderBy: String, whereField: String, isEqualTo: Any, completion: @escaping ([HomeAssistantData]) -> Void) {
        db.collection(collectionName).whereField(whereField, isEqualTo: isEqualTo).order(by: orderBy).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            var items = [HomeAssistantData]()
            for document in querySnapshot!.documents {
                do {
                    let data = try JSONSerialization.data(withJSONObject: document.data(), options: [])
                    let item = try JSONDecoder().decode(HomeAssistantData.self, from: data)
                    items.append(item)
                } catch let error {
                    print("Error decoding item: \(error)")
                }
            }
            completion(items)
        }
    }
}
