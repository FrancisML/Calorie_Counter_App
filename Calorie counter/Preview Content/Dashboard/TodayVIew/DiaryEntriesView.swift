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

    var calorieProgress: CGFloat {
        CGFloat(diaryEntries.reduce(0) { $0 + ($1.type == "Workout" ? -$1.calories : ($1.type == "Food" ? $1.calories : 0)) }) // ✅ Water excluded
    }
    var totalDailyWater: CGFloat {
        convertWaterUnit(amount: totalWaterIntake(), from: "fl oz", to: selectedUnit)
    }


    var calorieGoal: CGFloat
    var waterProgress: CGFloat {
        totalWaterIntake() // ✅ Always reflects the latest water intake
    }
// ✅ Automatically updates with entries

    var useMetric: Bool
    @State private var isWaterPickerPresented: Bool = false
    @State private var waterGoal: CGFloat = 0
    @State private var selectedUnit: String = "fl oz" // ✅ Default to fl oz

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

                // 🔹 WATER PROGRESS BAR
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

                            // ✅ Use totalDailyWater + waterGoal directly
                            Text(waterGoal == 0 ?
                                (selectedUnit == "Gallons" ? String(format: "%.2f", totalDailyWater) + " \(selectedUnit)" : // ✅ Show correct value in gallons
                                "\(Int(totalDailyWater)) \(selectedUnit)") :
                                (selectedUnit == "Gallons" ?
                                    String(format: "%.2f", totalDailyWater) + " / " + formattedGallonGoal(waterGoal) + " \(selectedUnit)" :
                                    "\(Int(totalDailyWater)) / \(Int(waterGoal)) \(selectedUnit)"
                                )
                            )


                            .font(.subheadline)
                            .foregroundColor(Styles.secondaryText)
                        }

                        // ✅ Progress Bar Section
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Styles.primaryText.opacity(0.2))
                                    .frame(height: 20)

                                Rectangle()
                                    .fill(Styles.primaryText)
                                    .frame(
                                        width: waterGoal == 0 ? geometry.size.width : // ✅ Full bar if no goal is set
                                            min((totalDailyWater / max(waterGoal, 0.01)) * geometry.size.width, geometry.size.width),
                                        height: 20
                                    )
                                    .animation(.easeInOut(duration: 0.3), value: totalDailyWater)
                            }
                        }
                        .frame(height: 20)

                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    isWaterPickerPresented = true
                }


                Divider()

                // 🔹 DAILY WEIGH-IN SECTION
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
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 3)
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: -3)
            .zIndex(1)

            // 🔹 DIARY ENTRIES LIST
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
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 15)
                                .background(index.isMultiple(of: 2) ? Styles.tertiaryBackground : Styles.secondaryBackground)
                        }
                    }
                }
                .padding(15)
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Styles.secondaryBackground)
        }
      .overlay(
                    Group {
                        if isWaterPickerPresented {
                            WaterGoalPicker(
                                useMetric: useMetric,
                                selectedGoal: $waterGoal, // ✅ Binding ensures updates
                                isWaterPickerPresented: $isWaterPickerPresented,
                                selectedUnit: $selectedUnit
                            )
                        }
            }
        )
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
   /// ✅ Converts gallon values to fractions (1/4, 1/2, 3/4) & keeps other units unchanged
    private func formattedWaterProgress(_ progress: CGFloat, _ goal: CGFloat, _ unit: String) -> String {
        let progressInSelectedUnit = convertWaterUnit(amount: progress, from: "fl oz", to: unit) // ✅ Convert progress to match goal

        print("🔹 Water Progress (Converted):", progressInSelectedUnit)
        print("🔹 Goal (Unchanged):", goal)

        // ✅ If no goal is set, just display total intake in fl oz
        if goal == 0 {
            return "\(Int(progressInSelectedUnit)) fl oz"
        }

        // ✅ Handle Gallons as Fractions (1/4, 1/2, 3/4, 1 gallon)
        if unit == "Gallons" {
            let fractionMap: [Double: String] = [
                0.25: "1/4",
                0.5: "1/2",
                0.75: "3/4",
                1.0: "1"
            ]

            let formattedProgress = fractionMap[progressInSelectedUnit] ?? String(format: "%.2f", progressInSelectedUnit)
            let formattedGoal = fractionMap[goal] ?? String(format: "%.2f", goal) // ✅ Do not convert goal

            return "\(formattedProgress)/\(formattedGoal) gal"
        }

        // ✅ Default for all other units
        return "\(Int(progressInSelectedUnit))/\(Int(goal)) \(unit)"
    }


    
    /// Extracts numeric value from a water entry detail (e.g., "500ml" → 500, "1L" → 1)
    private func extractWaterAmount(_ detail: String) -> CGFloat {
        let numberString = detail.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return CGFloat(Double(numberString) ?? 0) // ✅ Convert safely to CGFloat
    }






    private func totalWaterIntake() -> CGFloat {
        var totalIntake: CGFloat = 0

        for entry in diaryEntries where entry.type == "Water" {
            let amount = extractWaterAmount(entry.detail) // Extract numeric value
            let unit = extractWaterUnit(entry.detail) // Extract unit (e.g., "ml", "L", "fl oz")
            let convertedAmount = convertWaterUnit(amount: amount, from: unit, to: "fl oz") // ✅ Always convert to fl oz
            totalIntake += convertedAmount
        }

        print("💧 Total Water Intake in fl oz (Converted):", totalIntake) // Debugging
        return totalIntake // Always in fl oz
    }






    /// Extracts numeric value from water entry detail (e.g., "500ml" → 500)
    private func extractWaterUnit(_ detail: String) -> String {
        if detail.contains("ml") { return "ml" }
        if detail.contains("L") { return "L" }
        if detail.contains("gal") { return "gal" }
        if detail.contains("fl oz") { return "fl oz" }
        return "ml" // Default to mL if no unit is found
    }
    private func formattedGallonGoal(_ goal: CGFloat) -> String {
        let fractionMap: [CGFloat: String] = [
            0.25: "1/4",
            0.5: "1/2",
            0.75: "3/4",
            1.0: "1"
        ]
        return fractionMap[goal] ?? String(format: "%.2f", goal) // ✅ Use fraction map or fallback to decimal
    }



    /// Converts any water unit into the selected goal unit (fl oz, gal, L, mL)
    /// Converts any water unit into the selected goal unit (fl oz, gal, L, mL)
    /// Converts any water unit into the selected goal unit (fl oz, gal, L, mL)
    /// Converts water between ml, Liters, Gallons, and fl oz
    /// Converts water between ml, Liters, Gallons, and fl oz
    private func convertWaterUnit(amount: CGFloat, from fromUnit: String, to toUnit: String) -> CGFloat {
        let mlPerFlOz: CGFloat = 29.5735
        let mlPerGallon: CGFloat = 3785.41
        let mlPerLiter: CGFloat = 1000

        // Convert source unit to milliliters (mL) first
        var amountInMl: CGFloat
        switch fromUnit {
        case "Milliliters", "ml":
            amountInMl = amount
        case "Liters", "L":
            amountInMl = amount * mlPerLiter
        case "Gallons", "gal":
            amountInMl = amount * mlPerGallon
        case "fl oz":
            amountInMl = amount * mlPerFlOz
        default:
            return amount // If unit is unrecognized, return original value
        }

        // Convert from milliliters (mL) to the target unit
        switch toUnit {
        case "Milliliters", "ml":
            return amountInMl
        case "Liters", "L":
            return amountInMl / mlPerLiter
        case "Gallons", "gal":
            return amountInMl / mlPerGallon // ✅ Ensures fraction values match 1/4, 1/2, etc.
        case "fl oz":
            return amountInMl / mlPerFlOz
        default:
            return amount // If target unit is unrecognized, return original value
        }
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

            Text(entry.type == "Water" ? entry.detail : entry.type == "Workout" ? "-\(entry.calories)" : "+\(entry.calories)")
// ✅ Ensures workouts are negative, water is 0
                .font(.subheadline)
                .foregroundColor(entry.type == "Food" ? .green : entry.type == "Workout" ? .red : .blue)
                .frame(width: 60, alignment: .trailing)
        }
        .padding(.vertical, 5)

    }
    /// Converts water entries into a standardized unit for the progress bar
   
}


// 🔹 DIARY ENTRY MODEL
struct DiaryEntry: Identifiable {
    let id = UUID()
    let time: String
    let iconName: String
    let description: String
    let detail: String
    let calories: Int
    let type: String
}

// 🔹 UPDATED DUMMY DATA
let sampleDiaryEntries = [
    DiaryEntry(time: "8:00 AM", iconName: "food", description: "Oatmeal", detail: "1 cup", calories: 250, type: "Food"),
    DiaryEntry(time: "10:00 AM", iconName: "workout", description: "Cycling", detail: "30 min", calories: 300, type: "Workout"),
    DiaryEntry(time: "12:30 PM", iconName: "food", description: "Chicken Breast", detail: "200g", calories: 500, type: "Food"),
    DiaryEntry(time: "2:00 PM", iconName: "water", description: "Water", detail: "500ml", calories: 0, type: "Water")
]
