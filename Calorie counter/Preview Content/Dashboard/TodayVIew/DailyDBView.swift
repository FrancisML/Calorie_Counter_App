//
//  DiaryEntriesView.swift
//  Calorie Counter
//
//  Created by Frank LaSalvia on 2/10/25.
//

import SwiftUI

struct DailyDBView: View {
    @Binding var selectedDate: Date
    @Binding var diaryEntries: [DiaryEntry]
    var highestStreak: Int32
    
    var calorieProgress: CGFloat {
        CGFloat(diaryEntries.reduce(0) { $0 + ($1.type == "Workout" ? -$1.calories : ($1.type == "Food" ? $1.calories : 0)) }) // ✅ Water excluded
    }
    
    var calorieGoal: CGFloat
    var useMetric: Bool
    
    @State private var isWaterPickerPresented: Bool = false
    @State private var waterGoal: CGFloat = 0
    @State private var selectedUnit: String = "fl oz" // ✅ Default to fl oz
    
    // ✅ Weigh-Ins
    @State private var isWeighInExpanded: Bool = false
    @Binding var weighIns: [(time: String, weight: String)] // ✅ Passed as Binding
    
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
                // ✅ Calories Progress Bar
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
                
                // ✅ Water Progress Bar
                WaterTrackerView(
                    diaryEntries: diaryEntries,
                    selectedUnit: $selectedUnit,
                    waterGoal: $waterGoal,
                    isWaterPickerPresented: $isWaterPickerPresented
                )
                
                Divider()
                
                // ✅ Daily Weigh-In Section with Delete Button
                // ✅ Daily Weigh-In Section with Delete Button
                VStack(alignment: .leading, spacing: 5) {
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
                                
                                if weighIns.count == 1, let latestWeighIn = weighIns.last {
                                    // ✅ Only one weigh-in: Show time + weight
                                    Text(" \(latestWeighIn.weight) \(useMetric ? "kg" : "lbs")")
                                        .font(.subheadline)
                                        .foregroundColor(Styles.secondaryText)
                                } else if weighIns.count > 1 {
                                    // ✅ Multiple weigh-ins: Show average weight instead of latest
                                    Button(action: {
                                        withAnimation {
                                            isWeighInExpanded.toggle()
                                        }
                                    }) {
                                        HStack {
                                            Text("\(averageWeight(), specifier: "%.1f") \(useMetric ? "kg" : "lbs")") // ✅ Average weight
                                                .font(.subheadline)
                                                .foregroundColor(Styles.secondaryText)

                                            Image(systemName: "chevron.down")
                                                .rotationEffect(.degrees(isWeighInExpanded ? 180 : 0))
                                                .foregroundColor(Styles.secondaryText)
                                        }
                                    }
                                } else {
                                    // ✅ No weigh-ins: Display default "0 lbs/kg"
                                    Text("0 \(useMetric ? "kg" : "lbs")")
                                        .font(.subheadline)
                                        .foregroundColor(Styles.secondaryText)
                                }

                            }
                        }
                    }
                    
                    // ✅ Dropdown List of Weigh-Ins with Delete Button
                    if isWeighInExpanded && weighIns.count > 1 {
                        VStack(spacing: 0) {
                            ForEach(Array(weighIns.enumerated()), id: \.offset) { index, entry in
                                HStack {
                                    Text(entry.time)
                                        .font(.subheadline)
                                        .foregroundColor(Styles.secondaryText)
                                        .frame(width: 80, alignment: .leading)
                                    
                                    Text("\(entry.weight) \(useMetric ? "kg" : "lbs")")
                                        .font(.subheadline)
                                        .foregroundColor(Styles.primaryText)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                    
                                    // ✅ Red "X" Button for Deleting Entry
                                    Button(action: {
                                        deleteWeighIn(at: index) // Call delete function
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                            .font(.title2)
                                    }
                                    .buttonStyle(BorderlessButtonStyle()) // ✅ Prevents row-wide button effect
                                }
                                .padding()
                                .background(index % 2 == 0 ? Styles.secondaryBackground : Styles.tertiaryBackground)
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                }
                
            }
            .padding(15)
            .background(Styles.secondaryBackground)
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 3)
            
            // ✅ Diary Section
            DiaryView(diaryEntries: $diaryEntries)
        }
        .overlay(
            isWaterPickerPresented ? WaterGoalPicker(
                useMetric: useMetric,
                selectedGoal: $waterGoal,
                isWaterPickerPresented: $isWaterPickerPresented,
                selectedUnit: $selectedUnit
            )
            .background(Color.clear) // ✅ Prevents dark background
            .zIndex(10) // ✅ Ensures it appears on top
            : nil
        )
        .animation(nil, value: isWaterPickerPresented) // ✅ Prevents transition effect

        .onAppear {
            loadWeighInsForDate(selectedDate)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
    private func deleteWeighIn(at index: Int) {
        withAnimation {
            if index >= 0 && index < weighIns.count {
                weighIns.remove(at: index) // ✅ Remove the selected weigh-in
            }
        }
    }
    private func averageWeight() -> Double {
        guard !weighIns.isEmpty else { return 0.0 } // ✅ Prevent division by zero
        let totalWeight = weighIns.compactMap { Double($0.weight) }.reduce(0, +) // ✅ Convert to Double & sum
        return totalWeight / Double(weighIns.count) // ✅ Calculate average
    }
    
    // ✅ Function to Load Weigh-Ins from Core Data or Storage
    private func loadWeighInsForDate(_ date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        
        $weighIns.wrappedValue = [
            (time: formatter.string(from: Date()), weight: "198.5"),
            (time: "7:30 AM", weight: "200.0"),
            (time: "6:00 AM", weight: "201.2")
        ]
    }
    
}
