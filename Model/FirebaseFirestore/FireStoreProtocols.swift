//
//  FireStoreProtocols.swift
//  powerManager
//
//  Created by Paul Olphert on 21/03/2023.
//

//import Foundation
//import FirebaseFirestore
//
//protocol FirestoreProtocol {
//    func collection(_ collectionPath: String) -> CollectionReferenceProtocol
//}
//
//protocol CollectionReferenceProtocol {
//    func document(_ documentPath: String) -> DocumentReferenceProtocol
//}
//
//protocol DocumentReferenceProtocol {
//    func getDocumentWithCompletion(completion: @escaping (DocumentSnapshotProtocol?, Error?) -> Void)
//}
//
//protocol DocumentSnapshotProtocol {
//    func data() -> [String: Any]?
//    func get(_ field: String) -> Any?
//}
//extension Firestore: FirestoreProtocol {
//    func collection(_ collectionPath: String) -> CollectionReferenceProtocol {
//        return collection(collectionPath) as CollectionReference
//    }
//}

//extension CollectionReference: CollectionReferenceProtocol {
//    func document(_ documentPath: String) -> DocumentReferenceProtocol {
//        return document(documentPath) as DocumentReference
//    }
//}

//extension DocumentReference: DocumentReferenceProtocol {
//    func getDocumentWithCompletion(completion: @escaping (DocumentSnapshotProtocol?, Error?) -> Void) {
//        getDocument { (snapshot, error) in
//            completion(snapshot, error)
//        }
//    }
//}

//extension DocumentSnapshot: DocumentSnapshotProtocol {
//    func get(_ field: String) -> Any? {
//        <#code#>
//    }
//}
