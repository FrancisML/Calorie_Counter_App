//
//  DiaryEntriesView.swift
//  Calorie Counter
//
//  Created by Frank LaSalvia on 2/10/25.
//

//
//  DiaryEntriesView.swift
//  Calorie Counter
//
//  Created by Frank LaSalvia on 2/10/25.
//

import SwiftUI

struct DailyDBView: View {
    @Binding var selectedDate: Date
    var diaryEntries: [DiaryEntry]
    var highestStreak: Int32

    var calorieProgress: CGFloat {
        CGFloat(diaryEntries.reduce(0) { $0 + ($1.type == "Workout" ? -$1.calories : ($1.type == "Food" ? $1.calories : 0)) }) // ✅ Water excluded
    }

    var calorieGoal: CGFloat

    var useMetric: Bool
    @State private var isWaterPickerPresented: Bool = false
    @State private var waterGoal: CGFloat = 0
    @State private var selectedUnit: String = "fl oz" // ✅ Default to fl oz

    var body: some View {
        VStack(spacing: 0) {
            // 🔹 NAVIGATION BAR
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

            // 🔹 PROGRESS BARS
            VStack(spacing: 15) {
                // ✅ Calories Progress Bar (Restored)
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
                            Text("\(Int(calorieProgress))/\(Int(calorieGoal))")
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

                // ✅ Water Progress Bar (Using `WaterTrackerView`)
                WaterTrackerView(
                    diaryEntries: diaryEntries,
                    selectedUnit: $selectedUnit,
                    waterGoal: $waterGoal,
                    isWaterPickerPresented: $isWaterPickerPresented
                )

                Divider()

                // ✅ Daily Weigh-In Section (Restored)
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
                            Text("0 \(useMetric ? "kg" : "lbs")") // ✅ Replace 0 with actual weight variable if needed
                                .font(.subheadline)
                                .foregroundColor(Styles.secondaryText)
                        }
                    }
                }
            }
            .padding(15)
            .background(Styles.secondaryBackground)
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 3)

            // ✅ Diary Section (Uses `DiaryView`)
            DiaryView(diaryEntries: diaryEntries)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}
