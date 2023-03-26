//
//  FireStoreMocks.swift
//  powerManagerTests
//
//  Created by Paul Olphert on 21/03/2023.
//

import Foundation
import FirebaseFirestore

protocol FirestoreProtocol {
    func collection(_ collectionPath: String) -> CollectionReferenceProtocol
}

protocol CollectionReferenceProtocol {
    func document(_ documentPath: String) -> DocumentReferenceProtocol
}

protocol DocumentReferenceProtocol {
    func getDocumentWithCompletion(completion: @escaping (DocumentSnapshotProtocol?, Error?) -> Void)
}

protocol DocumentSnapshotProtocol {
    func data() -> [String: Any]?
    func get(_ field: String) -> Any?
}

extension Firestore: FirestoreProtocol {
    func collection(_ collectionPath: String) -> CollectionReferenceProtocol {
        return collection(collectionPath) as CollectionReference
    }
}

extension CollectionReference: CollectionReferenceProtocol {
    func document(_ documentPath: String) -> DocumentReferenceProtocol {
        return document(documentPath) as DocumentReference
    }
}

extension DocumentReference: DocumentReferenceProtocol {
    func getDocumentWithCompletion(completion: @escaping (DocumentSnapshotProtocol?, Error?) -> Void) {
        getDocument { (snapshot, error) in
            completion(snapshot as? DocumentSnapshotProtocol, error)
        }
    }
}

class FirestoreMock: FirestoreProtocol {
    
    var dno = 23
    var voltage = "LV"
    var userEmail = "user@example.com"
    
    func collection(_ collectionPath: String) -> CollectionReferenceProtocol {
        return CollectionReferenceMock()
    }
    
    class CollectionReferenceMock: CollectionReferenceProtocol {
        
        func document(_ documentPath: String) -> DocumentReferenceProtocol {
            return DocumentReferenceMock()
        }
    }
    
    class DocumentReferenceMock: DocumentReferenceProtocol {
        
        let dno = 23
        let voltage = "LV"
        let userEmail = "user@example.com"
        
        func getDocumentWithCompletion(completion: @escaping (DocumentSnapshotProtocol?, Error?) -> Void) {
            let mockData: [String: Any] = [
                "dno": dno,
                "voltage": voltage,
                "user": userEmail
            ]
            
            let mockSnapshot = MockDocumentSnapshot(data: mockData)
            completion(mockSnapshot, nil)
        }
    }
}

class MockDocumentSnapshot: DocumentSnapshotProtocol {
    private let mockData: [String: Any]
    
    init(data: [String: Any]) {
        self.mockData = data
    }
    
    func data() -> [String: Any]? {
        return mockData
    }
    
    func get(_ field: String) -> Any? {
        return mockData[field]
    }
}
