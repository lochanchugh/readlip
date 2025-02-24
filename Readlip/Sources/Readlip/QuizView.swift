//
//  QuizView.swift
//  lipread
//
//  Created by Lochan on 24/02/25.
//
import SwiftUI
import SpriteKit

struct QuizView: View {
    let level: String
    let words: [String]
    @State private var currentWordIndex = 0
    @State private var score = 0
    @State private var showResult = false
    @State private var isCorrect: Bool? = nil
    @State private var options: [String] = []

    @ObservedObject private var sceneHolder = SceneHolder()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Quiz: \(level)")
                    .font(.largeTitle)
                    .bold()

                if currentWordIndex < words.count {
                    SpriteView(scene: sceneHolder.scene)
                        .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 300 : UIScreen.main.bounds.width * 0.6,
                               height: UIDevice.current.userInterfaceIdiom == .pad ? 300 : UIScreen.main.bounds.width * 0.6)
                        .onAppear {
                            sceneHolder.scene.animateLipSync(for: words[currentWordIndex], durationMultiplier: 1)
                            generateOptions()
                        }

                    Text("Guess the word")
                        .font(.title2)

                    ForEach(options, id: \.self) { word in
                        Button(word) {
                            isCorrect = word == words[currentWordIndex]
                            if isCorrect == true {
                                score += 1
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                nextWord()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isCorrect == true && word == words[currentWordIndex] ? Color.green : isCorrect == false && word == words[currentWordIndex] ? Color.red : Color.blue.opacity(0.1))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                    }

                    Button(action: {
                        sceneHolder.scene.animateLipSync(for: words[currentWordIndex], durationMultiplier: 1)
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                } else {
                    Text("Quiz Complete")
                        .font(.title)
                        .bold()
                    Text("Your score: \(score)/\(words.count)")
                        .font(.title2)

                    Button("Restart") {
                        resetQuiz()
                    }
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

    private func nextWord() {
        if currentWordIndex < words.count - 1 {
            currentWordIndex += 1
            isCorrect = nil
            sceneHolder.scene.animateLipSync(for: words[currentWordIndex], durationMultiplier: 1)
            generateOptions()
        } else {
            showResult = true
        }
    }

    private func resetQuiz() {
        currentWordIndex = 0
        score = 0
        isCorrect = nil
        sceneHolder.scene.animateLipSync(for: words[currentWordIndex], durationMultiplier: 1)
        generateOptions()
    }

    private func generateOptions() {
        let correctWord = words[currentWordIndex]
        var optionsSet: Set<String> = [correctWord]

        while optionsSet.count < 4 {
            if let randomWord = words.randomElement(), randomWord != correctWord {
                optionsSet.insert(randomWord)
            }
        }

        options = Array(optionsSet).shuffled()
    }
}
