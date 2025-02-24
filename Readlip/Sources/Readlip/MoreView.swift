//
//  MoreView.swift
//  lipread
//
//  Created by Lochan on 23/02/25.
//

import SwiftUI
import UserNotifications

struct MoreView: View {
    @AppStorage("dailyReminderTime") private var dailyReminderTime: Date = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date())!
    @AppStorage("isDailyReminderEnabled") private var isDailyReminderEnabled: Bool = false
    @AppStorage("timeSpentToday") private var timeSpentToday: TimeInterval = 0
    @AppStorage("lastResetDate") private var lastResetDate: String = ""
    @AppStorage("isDarkModeEnabled") private var isDarkModeEnabled: Bool = false

    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) private var colorScheme

    @State private var showTips = false
    @State private var showDeveloper = false
    @State private var timer: Timer?

    var body: some View {
        Form {
            Section(header: Text("Daily Reminder")) {
                Toggle("Enable Reminder", isOn: $isDailyReminderEnabled)
                if isDailyReminderEnabled {
                    DatePicker("Reminder Time", selection: $dailyReminderTime, displayedComponents: .hourAndMinute)
                        .onChange(of: dailyReminderTime) { _ in
                            scheduleReminder()
                        }
                }
            }

            Section(header: Text("App Usage")) {
                Text("Time Spent Today: \(formattedTime(timeSpentToday))")
            }

            Section(header: Text("Appearance")) {
                Toggle("Dark Mode", isOn: $isDarkModeEnabled)
                    .onChange(of: isDarkModeEnabled) { newValue in
                        updateAppAppearance(darkMode: newValue)
                    }
            }

            Section(header: Text("Tips")) {
                Button("View Lip Reading Tips") {
                    showTips = true
                }
            }

            Section(header: Text("About LipRead")) {
                Button("Developer Information") {
                    showDeveloper = true
                }
            }
        }
        .sheet(isPresented: $showTips) {
            TipsView()
        }
        .sheet(isPresented: $showDeveloper) {
            DeveloperView()
        }
        .onAppear {
            requestNotificationPermissions()
            if isDailyReminderEnabled {
                scheduleReminder()
            }
            checkDailyReset()
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .onChange(of: scenePhase) { newPhase in
            handleScenePhaseChange(newPhase: newPhase)
        }
        .preferredColorScheme(isDarkModeEnabled ? .dark : .light)
    }

    // MARK: - Timer Logic
    private func startTimer() {
        stopTimer() // Ensure no duplicate timers
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            DispatchQueue.main.async {
                timeSpentToday += 1
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Daily Reset Logic
    private func checkDailyReset() {
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        if formatter.string(from: today) != lastResetDate {
            timeSpentToday = 0
            lastResetDate = formatter.string(from: today)
        }
    }

    private func handleScenePhaseChange(newPhase: ScenePhase) {
        let now = Date()
        if newPhase == .active {
            checkDailyReset()
            UserDefaults.standard.set(now, forKey: "lastStartTime")
            startTimer()
        } else {
            stopTimer()
            if let lastStartTime = UserDefaults.standard.object(forKey: "lastStartTime") as? Date {
                timeSpentToday += now.timeIntervalSince(lastStartTime)
                UserDefaults.standard.removeObject(forKey: "lastStartTime")
            }
        }
    }

    // MARK: - Notifications
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Notifications authorized")
            } else if let error = error {
                print("Notification authorization error: \(error)")
            }
        }
    }

    private func scheduleReminder() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        if isDailyReminderEnabled {
            let content = UNMutableNotificationContent()
            content.title = "Lip Reading Practice"
            content.body = "Time for your daily lip reading practice!"
            content.sound = .default

            let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: dailyReminderTime)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling reminder: \(error)")
                } else {
                    print("Reminder scheduled")
                }
            }
        }
    }

    // MARK: - Formatting
    private func formattedTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval / 3600)
        let minutes = Int((timeInterval.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds = Int(timeInterval.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    // MARK: - Appearance
    private func updateAppAppearance(darkMode: Bool) {
        isDarkModeEnabled = darkMode
        UIApplication.shared.windows.first?.overrideUserInterfaceStyle = darkMode ? .dark : .light
    }
}


struct TipsView: View {
    let tips = [
        "Focus on the Shape of the Mouth: Pay attention to the overall shape of the mouth as the person speaks.": "Observe how the mouth opens and closes, and how the lips move.",
        "Look for Key Movements: Certain lip movements are more pronounced and easier to recognize.": "Watch for movements like the corners of the mouth pulling back for 'ee' sounds or the lips pressing together for 'p,' 'b,' and 'm' sounds.",
        "Consider Context: Use surrounding information and context to help you understand what's being said.": "If you're in a restaurant, you're more likely to hear words related to food.",
        "Practice in Varied Lighting: Practice lip reading in different lighting conditions to improve your skills.": "Try practicing in both bright and dim lighting to adapt to different environments.",
        "Reduce Background Noise: A quiet environment makes lip reading easier.": "Minimize distractions to focus on the speaker's lips.",
        "Pay Attention to Facial Expressions: Facial expressions can provide additional clues.": "A smile can indicate happiness, while a frown can suggest sadness.",
        "Don't Guess: If you're unsure, ask for clarification.": "Don't be afraid to ask the speaker to repeat themselves or rephrase what they said.",
        "Practice Regularly: Consistent practice is key to improving lip reading skills.": "Set aside time each day to practice lip reading.",
        "Use Visual Aids: Use the app's visual feedback to understand the lip movements.": "Pay close attention to the app's analysis of lip movements.",
        "Keep the Camera Steady: A stable camera feed improves the app's accuracy.": "Use a tripod or prop up your device to keep the camera steady.",
        "Learn Common Word Patterns: Many words have similar lip movements.": "Familiarize yourself with common word patterns to improve recognition.",
        "Focus on Key Words: Pay attention to key words that convey the main message.": "Key words are often nouns, verbs, or adjectives.",
        "Practice with Different Speakers: Practice lip reading with different speakers to adapt to various speaking styles.": "Everyone has a unique way of speaking.",
        "Use Mirrors: Practice lip reading by observing your own lip movements in a mirror.": "This can help you understand how your lips move when you speak.",
        "Learn the Alphabet: Familiarize yourself with how each letter of the alphabet looks on the lips.": "This can help you decipher individual words.",
        "Watch for Tongue Movements: The tongue plays a role in forming certain sounds.": "Observe how the tongue moves behind the lips.",
        "Practice in Short Bursts: Break up your practice sessions into short, focused intervals.": "This can help you stay engaged and avoid fatigue.",
        "Use Closed Captioning: Watch videos with closed captioning to compare the spoken words with the written text.": "This can help you improve your lip reading accuracy.",
        "Join a Lip Reading Class: Consider joining a lip reading class for structured learning and support.": "Learning with others can be motivating and beneficial.",
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(tips.sorted(by: { $0.key < $1.key }), id: \.key) { tip, description in
                        VStack(alignment: .leading) {
                            Text(tip)
                                .font(.headline)
                                .padding(.bottom, 5)
                            Text(description)
                                .font(.body)
                                .padding(.leading, 10)
                                .padding(.bottom)
                        }
                        .padding()
                        Divider()
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Lip Reading Tips")
        }
    }
}


    struct DeveloperView: View {
           let resources = [
               ("Lip Reading Lessons", "https://www.lipreading.org/lipreading-lessons"),
               ("Rhubarb Lip Sync", "https://github.com/DanielSWolf/rhubarb-lip-sync"),
               
           ]

           var body: some View {
               NavigationView {
                   ScrollView {
                       VStack(alignment: .leading, spacing: 10) {
//                           Image(systemName: "mic.fill")
//                               .font(.system(size: 60))
//                               .foregroundColor(.blue)
                           Text("Read Lip")
                               .font(.title)
                               .fontWeight(.bold)
                           Text("Version 1.0")
                               .font(.subheadline)
                           Text("Developed by Lochan from India for the Swift Student Challenge 2025.")

                           Text("Sources:")
                               .font(.headline)
                           ForEach(resources, id: \.0) { name, url in
                               Link(name, destination: URL(string: url)!)
//                                   .padding(.leading, 0)
                           }
                           Spacer()
                           HStack {
                               Text("© 2025 Lochan")
                                   .font(.caption)
                                   .frame(alignment: .center)
                           }
                       }
                       .padding()
                       .frame(maxWidth: .infinity, alignment: .center)
                   }
                   .navigationTitle("Developer Information")
               }
           }
       }
