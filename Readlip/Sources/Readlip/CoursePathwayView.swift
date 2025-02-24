

import SwiftUI

struct SelectedStage: Identifiable, Equatable {
    let id: Int
}

struct Stage {
    let title: String
    var isCompleted: Bool
    var isUnlocked: Bool
    let position: CGPoint
}

struct PathPoint {
    let x: Double
    let y: Double
}

struct CoursePathwayView: View {
    private let pathPoints: [PathPoint] = [
        PathPoint(x: 0.5, y: 0.9),   // Introduction
        PathPoint(x: 0.35, y: 0.75), // Vowel Basics
        PathPoint(x: 0.5, y: 0.6),   // Sound Shapes
        PathPoint(x: 0.65, y: 0.45), // Topic Talk
        PathPoint(x: 0.45, y: 0.3),  // Live Practice
        PathPoint(x: 0.65, y: 0.2),  // Advanced Skills
        PathPoint(x: 0.5, y: 0.1)    // Full Mastery
    ]
    
    @State private var stages = [
        Stage(title: "Introduction", isCompleted: false, isUnlocked: true, position: CGPoint(x: 0.5, y: 0.9)),
        Stage(title: "Vowel Basics", isCompleted: false, isUnlocked: false, position: CGPoint(x: 0.35, y: 0.75)),
        Stage(title: "Sound Shapes", isCompleted: false, isUnlocked: false, position: CGPoint(x: 0.5, y: 0.6)),
        Stage(title: "Topic Talk", isCompleted: false, isUnlocked: false, position: CGPoint(x: 0.65, y: 0.45)),
        Stage(title: "Live Practice", isCompleted: false, isUnlocked: false, position: CGPoint(x: 0.45, y: 0.3)),
        Stage(title: "Advanced Skills", isCompleted: false, isUnlocked: false, position: CGPoint(x: 0.65, y: 0.2)),
        Stage(title: "Full Mastery", isCompleted: false, isUnlocked: false, position: CGPoint(x: 0.5, y: 0.1))
    ]

    @State private var selectedStageIndex: SelectedStage?
    
    @AppStorage("isDarkModeEnabled") private var isDarkModeEnabled = false
    
    private func stageCircle(for index: Int, screenWidth: CGFloat) -> some View {
        let sizeFactor: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 0.12 : 0.2
        let baseSize: CGFloat = screenWidth * sizeFactor
        
        return Circle()
            .fill(stages[index].isCompleted ? Color.green : (stages[index].isUnlocked ? Color.blue : Color.gray))
            .frame(width: baseSize, height: baseSize)
            .overlay(
                Text(stages[index].title)
                    .foregroundColor(.white)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(8)
            )
    }

    private func drawPath(in geometry: GeometryProxy) -> Path {
        Path { path in
            for i in 0..<(pathPoints.count - 1) {
                let start = CGPoint(
                    x: pathPoints[i].x * geometry.size.width,
                    y: pathPoints[i].y * geometry.size.height
                )
                let end = CGPoint(
                    x: pathPoints[i + 1].x * geometry.size.width,
                    y: pathPoints[i + 1].y * geometry.size.height
                )
                
                if i == 0 {
                    path.move(to: start)
                }
                
                let controlOffset: CGFloat = 200
                let control1 = CGPoint(
                    x: start.x + (i % 2 == 0 ? controlOffset : -controlOffset),
                    y: (start.y + end.y) / 2 + (i % 2 == 0 ? -50 : 50)
                )
                let control2 = CGPoint(
                    x: end.x + (i % 2 == 0 ? -controlOffset : controlOffset),
                    y: (start.y + end.y) / 2 + (i % 2 == 0 ? 50 : -50)
                )
                
                path.addCurve(to: end, control1: control1, control2: control2)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    drawPath(in: geometry)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                        .foregroundColor(Color.blue)
                    
                    ForEach(stages.indices, id: \.self) { index in
                        stageCircle(for: index, screenWidth: geometry.size.width)
                            .onTapGesture {
                                if stages[index].isUnlocked {
                                    selectedStageIndex = SelectedStage(id: index)
                                }
                            }
                            .position(
                                x: pathPoints[index].x * geometry.size.width,
                                y: pathPoints[index].y * geometry.size.height
                            )
                            .scaleEffect(stages[index].isUnlocked ? 1.1 : 0.9)
                    }
                }
                .fullScreenCover(item: $selectedStageIndex) { selected in
                    NavigationView {
                        StageDetailView(stageIndex: selected.id, onComplete: {
                            stages[selected.id].isCompleted = true
                            if selected.id + 1 < stages.count {
                                stages[selected.id + 1].isUnlocked = true
                                selectedStageIndex = SelectedStage(id: selected.id + 1)
                            } else {
                                selectedStageIndex = nil
                            }
                        })
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .colorScheme(isDarkModeEnabled ? .dark : .light)
    }
}

struct StageDetailView: View {
    let stageIndex: Int
    let onComplete: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Group {
                switch stageIndex {
                    case 0: LevelZeroView(onComplete: onComplete)
                    case 1: LevelOneView(onComplete: onComplete)
                    case 2: LevelTwoView(onComplete: onComplete)
                    case 3: LevelThreeView(onComplete: onComplete)
                    case 4: LevelFourView(onComplete: onComplete)
                    case 5: LevelFiveView(onComplete: onComplete)
                    case 6: LevelSixView(onComplete: onComplete)
                default:
                    Text("This stage is yet to be added.")
                }
            }
            .padding()
            
            Button("Exit Stage") {
                dismiss()
            }
            .foregroundColor(.red)
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    CoursePathwayView()
}
