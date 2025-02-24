//
//  StoryView.swift
//  lipsync
//
//  Created by Lochan on 08/02/25.
//
//
//import SwiftUI
//
//struct StoryView: View {
//    var body: some View {
//        NavigationStack {
//            VStack {
//                Text("Imagine a world where you can understand speech without hearing it...")
//                    .font(.title2)
//                    .padding()
//                    .multilineTextAlignment(.center)
//                
//                Spacer()
//                
//                Image(systemName: "book.fill") 
//                    .resizable()
//                    .scaledToFit()
//                    .frame(height: 200)
//                    .padding()
//                
//                Spacer()
//                
//                NavigationLink(destination: MainView()) {
//                    Text("Continue")
//                        .font(.title2)
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                        .padding()
//                }
//            }
//            .navigationBarBackButtonHidden(true) // Hides back button
//        }
//    }
//}
//
//#Preview {
//    StoryView()
//}


// LipReadingStory.swift
// Animated introduction using SwiftUI
// SwiftUI code for Lipread Story Intro with character in corner and speech bubbles


// SwiftUI code for Lipread Story Intro with character in corner and cloud speech bubbles
// SwiftUI code for Lipread Story Intro with full character in right bottom and thought clouds
// SwiftUI code for Lipread Story Intro using character image from assets and thought clouds
// SwiftUI code for Lipread Story Intro with larger character and bigger thought clouds
import SwiftUI

struct StoryView: View {
    @State private var dialogueIndex = 0
    let dialogues = [
        "Welcome to LipRead! This app is designed to help you learn lip sync through interactive lessons and fun games.",
        "With LipRead, you can enhance your ability to lip read by practicing with real-life scenarios, interactive characters, and easy-to-follow guides.",
        "Let's dive in! Ready to explore the world of lip syncing and communication?",
        "Tap to start and begin your journey to mastering lip reading. Every word is a step towards better understanding.",
        "Join us in making communication easier and more enjoyable for everyone, especially for people with hearing disabilities.",
        "We are excited to have you with us. Let's get started!"
    ]
    
    @State private var displayedText = ""
    @State private var characterIndex = 0
    @State private var timer: Timer?
    @State private var autoAdvanceTimer: Timer?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                
                Image("character")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 420)
                    .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 220)
                    .animation(.spring(), value: dialogueIndex)
                
                VStack {
                    Spacer()
                    if dialogueIndex < dialogues.count {
                        ThoughtCloud(text: displayedText)
                            .transition(.opacity)
                            .animation(.easeInOut, value: dialogueIndex)
                            .padding(.bottom, 400) // Adjusted padding for better positioning
                    }
                }
            }
            .onTapGesture {
                moveToNextDialogue()
            }
            .onAppear {
                startTypewriterEffect()
            }
        }
    }
    
    // MARK: - Typewriter Effect
    private func startTypewriterEffect() {
        displayedText = ""
        characterIndex = 0
        timer?.invalidate()
        autoAdvanceTimer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.06, repeats: true) { _ in
            if characterIndex < dialogues[dialogueIndex].count {
                displayedText.append(dialogues[dialogueIndex][dialogues[dialogueIndex].index(dialogues[dialogueIndex].startIndex, offsetBy: characterIndex)])
                characterIndex += 1
            } else {
                // Start auto-advance timer once typewriter effect finishes
                autoAdvanceTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
                    moveToNextDialogue()
                }
                timer?.invalidate()
            }
        }
    }
    
    // MARK: - Dialogue Navigation
    private func moveToNextDialogue() {
        timer?.invalidate()
        autoAdvanceTimer?.invalidate()
        
        if dialogueIndex < dialogues.count - 1 {
            dialogueIndex += 1
            startTypewriterEffect()
        } else {
            navigateToMainView()
        }
    }
    
    private func navigateToMainView() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = UIHostingController(rootView: MainView())
            window.makeKeyAndVisible()
        }
    }
}

struct ThoughtCloud: View {
    var text: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .shadow(radius: 8)
                .frame(width: 350, height: 150)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.gray, lineWidth: 1)
                )
            
            Path { path in
                path.move(to: CGPoint(x: 160, y: 150))
                path.addLine(to: CGPoint(x: 180, y: 180))
                path.addLine(to: CGPoint(x: 200, y: 150))
            }
            .fill(Color.white)
            .offset(x: -40, y: 70)
            
            Text(text)
                .font(.system(size: 18, weight: .medium))
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .padding(16)
        }
        .foregroundColor(.black)
    }
}

#Preview {
    StoryView()
}
