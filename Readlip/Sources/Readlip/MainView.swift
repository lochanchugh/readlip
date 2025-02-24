//
//  MainView.swift
//  lipsync
//
//  Created by Lochan on 08/02/25.
//


import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            
            
            CoursePathwayView()
                .tabItem {
                    Label("Learn", systemImage: "book.fill")
                }
            
            PractiseView()
                .tabItem {
                    Label("Practise", systemImage: "gamecontroller.fill")
                }
            
            LiveView()
                .tabItem {
                    Label("Analyze", systemImage: "camera.fill")
                }
            MoreView()
                .tabItem {
                    Label("More", systemImage: "ellipsis.circle.fill")
                }
        }
    }
}

#Preview {
    MainView()
}
