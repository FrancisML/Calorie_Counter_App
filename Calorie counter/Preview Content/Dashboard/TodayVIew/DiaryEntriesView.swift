//
//  DiaryEntriesView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 2/10/25.
//

import SwiftUI

struct DiaryEntriesView: View {
    @Binding var selectedDate: Date
    var diaryEntries: [DiaryEntry]
    var highestStreak: Int32
    var calorieProgress: CGFloat
    var calorieGoal: CGFloat
    var waterProgress: CGFloat
    var waterGoal: CGFloat
    var useMetric: Bool

    var body: some View {
        VStack(spacing: 0) { // ✅ Forces sections to touch
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
            .zIndex(1) // ✅ Ensures shadow overlaps progress bar
            
            // 🔹 PROGRESS BARS SECTION (Full Width with Internal Padding)
            VStack(spacing: 15) {
                HStack(spacing: 10) {
                    Image("bolt")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
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
                                    .frame(width: (calorieProgress / calorieGoal) * geometry.size.width, height: 20)
                                    .animation(.easeInOut(duration: 0.3), value: calorieProgress)
                            }
                        }
                        .frame(height: 20)
                    }
                }

                HStack(spacing: 10) {
                    Image("drop")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
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
                                    .fill(Styles.primaryText.opacity(0.2))
                                    .frame(height: 20)
                                
                                Rectangle()
                                    .fill(Styles.primaryText)
                                    .frame(width: (waterProgress / waterGoal) * geometry.size.width, height: 20)
                                    .animation(.easeInOut(duration: 0.3), value: waterProgress)
                            }
                        }
                        .frame(height: 20)
                    }
                }

                HStack(spacing: 10) {
                    Image("CalW")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
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
            .padding(15) // ✅ Internal padding for elements
            .background(Styles.secondaryBackground)
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 3) // ✅ Drop shadow remains
            
            // 🔹 DIARY LABEL BAR (SEPARATE HSTACK, MATCHING NAV BAR STYLE)
            HStack {
                Text("Diary")
                    .font(.title2) // ✅ Increased text size
                    .foregroundColor(Styles.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Styles.secondaryBackground)
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 0) // ✅ Equal shadow on top and bottom
            .zIndex(1) // ✅ Ensures shadow overlaps content below


            // 🔹 DIARY ENTRIES SECTION (Fills Remaining Space, Justified at Top)
            VStack(alignment: .leading) {
                if diaryEntries.isEmpty {
                    Text("No Entries Yet")
                        .font(.subheadline)
                        .foregroundColor(Styles.secondaryText)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    VStack {
                        ForEach(diaryEntries, id: \.id) { entry in
                            HStack {
                                Text(entry.time)
                                    .font(.subheadline)
                                    .foregroundColor(Styles.secondaryText)
                                    .frame(width: 70, alignment: .leading)
                                
                                Image(systemName: entry.icon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(entry.type == "Food" ? .green : .red)
                                
                                Text(entry.description)
                                    .font(.subheadline)
                                    .foregroundColor(Styles.primaryText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text("\(entry.type == "Food" ? "+" : "-")\(entry.calories)")
                                    .font(.subheadline)
                                    .foregroundColor(entry.type == "Food" ? .green : .red)
                                    .frame(width: 60, alignment: .trailing)
                            }
                            .padding(.vertical, 5)
                        }
                    }
                    .padding(15) // ✅ Internal padding for diary entries
                    .frame(maxWidth: .infinity, alignment: .top) // ✅ Justifies entries at the top
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Styles.secondaryBackground)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}

struct DiaryEntry: Identifiable {
    let id = UUID()
    let time: String
    let icon: String
    let description: String
    let calories: Int
    let type: String // "Food" or "Workout"
}
