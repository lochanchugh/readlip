//
//  PractiseDetailView.swift
//  lipread
//
//  Created by Lochan on 24/02/25.
//
import SwiftUI
import SpriteKit

struct PractiseDetailView: View {
    let category: String
    let words: [String]

    @State private var searchText = ""
    @ObservedObject private var sceneHolder = SceneHolder()

    var filteredWords: [String] {
        searchText.isEmpty ? words : words.filter { $0.contains(searchText.uppercased()) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text(category)
                    .font(.largeTitle)
                    .bold()

                SpriteView(scene: sceneHolder.scene)
                    .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 300 : UIScreen.main.bounds.width * 0.6,
                           height: UIDevice.current.userInterfaceIdiom == .pad ? 300 : UIScreen.main.bounds.width * 0.6)

                TextField("Search words", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                List(filteredWords, id: \.self) { word in
                    Button(word) {
                        let duration = word.count == 1 ? 3 : 1
                        sceneHolder.scene.animateLipSync(for: word, durationMultiplier: TimeInterval(duration))
                    }
                    .foregroundColor(.primary)
                }
                .frame(height: UIDevice.current.userInterfaceIdiom == .pad ? 400 : 200)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 5)

                NavigationLink(destination: QuizView(level: category, words: words)) {
                    Text("Take Quiz")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            .safeAreaInset(edge: .bottom) {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    Spacer().frame(height: 20)
                }
            }
            .safeAreaInset(edge: .top) {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    Spacer().frame(height: 20)
                }
            }
        }
    }
}
