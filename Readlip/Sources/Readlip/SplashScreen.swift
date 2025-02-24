import SwiftUI

struct SplashScreen: View {
    @State private var isActive = false
    @State private var opacity = 0.3
    @AppStorage("isDarkModeEnabled") private var isDarkModeEnabled = false
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore: Bool = false 

    var body: some View {
        if isActive {
            if hasLaunchedBefore {
                MainView()
            } else {
                StoryView()
            }
        } else {
            VStack {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 350, height: 350)
                    .foregroundColor(.blue)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeIn(duration: 1.5)) {
                            opacity = 1.0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                isActive = true
                            }
                            
                            if !hasLaunchedBefore {
                                hasLaunchedBefore = true
                            }
                        }
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
            .colorScheme(isDarkModeEnabled ? .dark : .light)
        }
    }
}
