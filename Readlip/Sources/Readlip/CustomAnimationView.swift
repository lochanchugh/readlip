//
//  CustomAnimationView.swift
//  lipread
//
//  Created by Lochan on 24/02/25.
//

import SwiftUI
import SpriteKit


struct CustomAnimationView: View {
    @State private var inputText: String = ""
    @ObservedObject private var sceneHolder = SceneHolder()

    var body: some View {
        VStack(spacing: 20) {
            Text("Custom Animation")
                .font(.largeTitle)
                .bold()

            SpriteView(scene: sceneHolder.scene)
                .frame(width: 300, height: 300)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)

            TextField("Enter text...", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            HStack(spacing: 20) {
                Button("Play") {
                    if !inputText.isEmpty {
                        let durationMultiplier = inputText.count == 1 ? 3 : 1
                        sceneHolder.scene.animateLipSync(for: inputText.uppercased(), durationMultiplier: TimeInterval(durationMultiplier))
                    }
                }
                .buttonStyle(.borderedProminent)

                Button("Clear") {
                    inputText = ""
                }
                .buttonStyle(.bordered)
            }

            Spacer()
        }
        .padding()
    }
}
