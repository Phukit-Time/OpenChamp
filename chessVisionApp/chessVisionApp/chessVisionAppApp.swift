//
//  chessVisionAppApp.swift
//  chessVisionApp
//
//  Created by Phukit Santipiyakun on 8/5/2567 BE.
//

import SwiftUI
import Firebase

@main
struct chessVisionAppApp: App {
    
    init() {
        FirebaseApp.configure()
        print("Configured Firebase!")
    }
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
