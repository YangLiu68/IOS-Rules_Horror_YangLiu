//
//  AuthManager.swift
//  Rules Horror
//
//  Created by Tensorcraft on 14/05/2025.
//


import FirebaseAuth
import Combine

final class AuthManager: ObservableObject {
    @Published private(set) var uid: String?      // 给外部只读
    private var handle: AuthStateDidChangeListenerHandle?

    static let shared = AuthManager()             // 简单单例

    private init() {
        handle = Auth.auth().addStateDidChangeListener { _, user in
            self.uid = user?.uid
            print("🔥 User state changed. UID: \(user?.uid ?? "nil")")
        }

        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously { authResult, error in
                if let error = error {
                    print("❌ Anonymous sign-in failed:", error.localizedDescription)
                    return
                }
                print("✅ Anonymous sign-in succeeded. UID:", authResult?.user.uid ?? "nil")
                // uid 会自动通过 state listener 设置
            }
        } else {
            print("Already signed in. UID:", Auth.auth().currentUser?.uid ?? "nil")
        }
    }

}
