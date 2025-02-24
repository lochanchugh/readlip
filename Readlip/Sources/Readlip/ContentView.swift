//
//  ContentView.swift
//  lipsync
//
//  Created by Lochan on 19/02/25.
//
import SwiftUI
import SpriteKit

struct ContentView: View {
    @State private var inputText = ""
    
    @StateObject private var sceneHolder = SceneHolder()
    
    var body: some View {
        VStack(spacing: 20) {
            SpriteView(scene: sceneHolder.scene)
                .frame(width: 300, height: 300)
            
           
            Button("Animate") {
                sceneHolder.scene.animateLipSync(for: "Hello")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
//class SceneHolder: ObservableObject {
//    let scene: LipSyncScene
//    
//    init() {
//        scene = LipSyncScene()
//        scene.size = CGSize(width: 300, height: 300)
//        scene.scaleMode = .fill
//    }
//}

#Preview {
    ContentView()
}

