//
//  DiaryEntriesView.swift
//  Calorie Counter
//
//  Created by Frank LaSalvia on 2/10/25.
//

import SwiftUI

struct DiaryEntriesView: View {
    @Binding var selectedDate: Date
    var diaryEntries: [DiaryEntry]
    var highestStreak: Int32
    var calorieProgress: CGFloat
    var calorieGoal: CGFloat
    var waterProgress: CGFloat
    var useMetric: Bool
    @State private var isWaterPickerPresented: Bool = false // ✅ Controls picker visibility
    @State private var waterGoal: CGFloat = 0



    var body: some View {
        VStack(spacing: 0) {
            // 🔹 NAVIGATION BAR BELOW PROFILE (With Drop Shadow)
            HStack {
                Button(action: {
                    selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(Styles.primaryText)
                }

                Spacer()

                VStack {
                    Text("Today")
                        .font(.headline)
                        .foregroundColor(Styles.secondaryText)
                    Text(formattedDate(selectedDate))
                        .font(.subheadline)
                        .foregroundColor(Styles.primaryText)
                }

                Spacer()

                Button(action: {
                    selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                }) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(Styles.primaryText)
                }

                Spacer()

                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("Streak: \(highestStreak)")
                        .font(.headline)
                        .foregroundColor(Styles.primaryText)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Styles.secondaryBackground)
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 3)
            .zIndex(1)

            // 🔹 PROGRESS BARS SECTION (Full Width with Internal Padding)
            VStack(spacing: 15) {
                // Calories Progress Bar
                // Calories Progress Bar (Updated)
                HStack(spacing: 10) {
                    Image("bolt")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 40)
                        .padding(.trailing, 5)

                    VStack(alignment: .leading) {
                        HStack {
                            Text("Calories")
                                .font(.headline)
                                .foregroundColor(Styles.primaryText)
                            Spacer()
                            Text("\(Int(calorieProgress))/\(Int(calorieGoal))") // ✅ Dynamic values
                                .font(.subheadline)
                                .foregroundColor(Styles.secondaryText)
                        }

                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Styles.primaryText.opacity(0.2))
                                    .frame(height: 20)

                                Rectangle()
                                    .fill(Styles.primaryText)
                                    .frame(width: min((calorieProgress / calorieGoal) * geometry.size.width, geometry.size.width), height: 20)
                                    .animation(.easeInOut(duration: 0.3), value: calorieProgress)
                            }
                        }
                        .frame(height: 20)
                    }
                }
                Divider()


                // Water Progress Bar
                // 🔹 WATER PROGRESS BAR (Now Clickable)
                HStack(spacing: 10) {
                    Image("drop")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 40)
                        .padding(.trailing, 5)

                    VStack(alignment: .leading) {
                        HStack {
                            Text("Water")
                                .font(.headline)
                                .foregroundColor(Styles.primaryText)
                            Spacer()
                            Text("\(Int(waterProgress))/\(Int(waterGoal))")
                                .font(.subheadline)
                                .foregroundColor(Styles.secondaryText)
                        }

                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(isWaterPickerPresented ? Styles.tertiaryBackground : Styles.primaryText.opacity(0.2)) // ✅ Background changes when clicked
                                    .frame(height: 20)

                                Rectangle()
                                    .fill(Styles.primaryText)
                                    .frame(
                                        width: min((waterProgress / max(waterGoal, 1)) * geometry.size.width, geometry.size.width), // ✅ Stops at max width
                                        height: 20
                                    )
                                    .animation(.easeInOut(duration: 0.3), value: waterProgress)
                            }
                        }
                        .frame(height: 20)
                    }
                }
                .contentShape(Rectangle()) // ✅ Makes the entire row clickable
                .onTapGesture {
                    isWaterPickerPresented = true // ✅ Opens picker when tapped
                }

                Divider()

                // 🔹 DAILY WEIGH-IN SECTION (Fully Restored)
                HStack(spacing: 10) {
                    Image("CalW")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 40)
                        .padding(.trailing, 5)

                    VStack(alignment: .leading) {
                        HStack {
                            Text("Daily Weigh-In:")
                                .font(.headline)
                                .foregroundColor(Styles.primaryText)
                            Spacer()
                            Text("0 \(useMetric ? "kg" : "lbs")")
                                .font(.subheadline)
                                .foregroundColor(Styles.secondaryText)
                        }
                    }
                }
            }
            .padding(15)
            .background(Styles.secondaryBackground)
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 3)

            // 🔹 DIARY LABEL BAR
            HStack {
                Text("Diary")
                    .font(.title2)
                    .foregroundColor(Styles.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Styles.secondaryBackground)
            // ✅ Apply two shadows: one on top and one on bottom
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 3)  // Bottom shadow
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: -3) // Top shadow (inverted)
            .zIndex(1)


            // 🔹 DIARY ENTRIES LIST (Scrolls Independently, Alternating Row Colors, Timestamp Added)
            ScrollView {
                VStack(spacing: 0) {
                    if diaryEntries.isEmpty {
                        Text("No Entries Yet")
                            .font(.subheadline)
                            .foregroundColor(Styles.secondaryText)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    } else {
                        ForEach(Array(diaryEntries.enumerated()), id: \.element.id) { index, entry in
                            DiaryEntryRow(entry: entry)
                                .frame(maxWidth: .infinity) // ✅ Makes the background extend fully to the sides
                                .padding(.horizontal, 15) // ✅ Internal padding to keep content away from the edges
                                .background(index.isMultiple(of: 2) ? Styles.tertiaryBackground : Styles.secondaryBackground) // ✅ Alternating row colors
                        }

                        
                    }
                }
                .padding(15)
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Styles.secondaryBackground)
        }
        .sheet(isPresented: $isWaterPickerPresented) {
            WaterGoalPicker(
                useMetric: useMetric,
                selectedGoal: $waterGoal
            )
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}

// 🔹 DIARY ENTRY ROW COMPONENT (With Timestamp & Alternating Colors)
struct DiaryEntryRow: View {
    var entry: DiaryEntry

    var body: some View {
        HStack(spacing: 10) {
            Text(entry.time) // ✅ Adds timestamp before the image
                .font(.subheadline)
                .foregroundColor(Styles.secondaryText)
                .frame(width: 70, alignment: .leading)

            Image(entry.iconName) // ✅ Uses custom image for "food", "workout", "water"
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 5))

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.description)
                    .font(.headline)
                    .foregroundColor(Styles.primaryText)

                Text(entry.detail)
                    .font(.subheadline)
                    .foregroundColor(Styles.secondaryText)
            }

            Spacer()

            Text(entry.type == "Water" ? "0" : entry.type == "Workout" ? "-\(entry.calories)" : "+\(entry.calories)") // ✅ Ensures workouts are negative, water is 0
                .font(.subheadline)
                .foregroundColor(entry.type == "Food" ? .green : entry.type == "Workout" ? .red : .blue)
                .frame(width: 60, alignment: .trailing)
        }
        .padding(.vertical, 5)

    }
}


// 🔹 DIARY ENTRY MODEL
struct DiaryEntry: Identifiable {
    let id = UUID()
    let time: String
    let iconName: String
    let description: String
    let detail: String
    let calories: Int
    let type: String // "Food", "Workout", "Water"
}

// 🔹 UPDATED DUMMY DATA
let sampleDiaryEntries = [
    DiaryEntry(time: "8:00 AM", iconName: "food", description: "Oatmeal", detail: "1 cup", calories: 250, type: "Food"),
    DiaryEntry(time: "10:00 AM", iconName: "workout", description: "Cycling", detail: "30 min", calories: 300, type: "Workout"),
    DiaryEntry(time: "12:30 PM", iconName: "food", description: "Chicken Breast", detail: "200g", calories: 500, type: "Food"),
    DiaryEntry(time: "2:00 PM", iconName: "water", description: "Water", detail: "500ml", calories: 0, type: "Water")
]
