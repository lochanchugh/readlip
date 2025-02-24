import SwiftUI
import SpriteKit

struct PractiseView: View {
    @State private var selectedCategory: String? = nil
    @AppStorage("isDarkModeEnabled") private var isDarkModeEnabled = false
    let practiseCategories = [
        ("Basic Vowels", ["A", "E", "I", "O", "U", "AA", "EE", "OO", "AI", "AU"]),
        ("Common Consonants", ["M", "B", "P", "F", "V", "T", "D", "N", "S", "Z", "K", "G", "L", "R", "H"]),
        ("Simple Words", ["HELLO", "BYE", "YES", "NO", "PLEASE", "THANKS", "SORRY", "GOOD", "BAD", "OKAY", "WELCOME", "GOODBYE"]),
        ("Numbers", ["ONE", "TWO", "THREE", "FOUR", "FIVE", "SIX", "SEVEN", "EIGHT", "NINE", "TEN", "ELEVEN", "TWELVE", "TWENTY", "HUNDRED"]),
        ("Everyday Phrases", ["HOW ARE YOU", "I AM FINE", "GOOD MORNING", "GOOD NIGHT", "SEE YOU SOON", "TAKE CARE", "WHAT'S YOUR NAME", "NICE TO MEET YOU", "HAVE A GOOD DAY"]),
        ("Food and Drinks", ["WATER", "BREAD", "MILK", "APPLE", "BANANA", "COFFEE", "TEA", "RICE", "SOUP", "PIZZA", "BURGER", "PASTA", "ORANGE", "JUICE", "EGG"]),
        ("Emotions", ["HAPPY", "SAD", "ANGRY", "EXCITED", "NERVOUS", "CALM", "TIRED", "SURPRISED", "CONFUSED", "PROUD", "SCARED", "RELAXED"]),
        ("Custom Animation", [])
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Practise")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top)

                    ForEach(practiseCategories, id: \.0) { category, words in
                        NavigationLink(destination: category == "Custom Animation" ? AnyView(CustomAnimationView()) : AnyView(PractiseDetailView(category: category, words: words))) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(category)
                                    .font(.title2)
                                    .bold()
                                Text(category == "Custom Animation" ? "Enter any text to see its lip-sync animation." : "Explore the dictionary and test your skills with quizzes.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                    }
                }
            }
            .padding()
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .colorScheme(isDarkModeEnabled ? .dark : .light)
    }
}

#Preview {
    PractiseView()
}
