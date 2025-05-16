//
//  RemoteSyncService.swift
//  Rules Horror
//
//  Created by Tensorcraft on 14/05/2025.
//


import FirebaseFirestore
import Foundation

actor RemoteSyncService {
    private let db = Firestore.firestore()
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    struct Snapshot: Codable {
        var updatedAt: Date
        var engine: Data        // NovelEngine 的序列化数据
        var session: Data       // ChatSession 的序列化数据
    }

    // 下载远程存档（若存在）
    func fetch(uid: String) async throws -> Snapshot? {
        let doc = try await db.collection("users").document(uid).getDocument()
        guard let data = doc.data() else { return nil }
        let json = try JSONSerialization.data(withJSONObject: data)
        return try decoder.decode(Snapshot.self, from: json)
    }

    // 上传存档
    func push(uid: String,
              engineData: Data,
              sessionData: Data) async throws {
        let snapshot = Snapshot(updatedAt: Date(),
                                engine: engineData,
                                session: sessionData)
        let json = try encoder.encode(snapshot)
        let map = try JSONSerialization.jsonObject(with: json) as! [String: Any]
        try await db.collection("users").document(uid).setData(map, merge: true)
    }
    
    func deleteRemoteCache(uid: String) async throws {
        try await db.collection("users").document(uid).updateData([
            "engine": FieldValue.delete(),
            "session": FieldValue.delete(),
            "updatedAt": FieldValue.delete()
        ])
    }
}
