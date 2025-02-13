//
//  DiaryEntryView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 2/12/25.
//
import SwiftUI

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

// 🔹 SAMPLE DATA FOR TESTING
let sampleDiaryEntries = [
    DiaryEntry(time: "8:00 AM", iconName: "food", description: "Oatmeal", detail: "1 cup", calories: 250, type: "Food"),
    DiaryEntry(time: "10:00 AM", iconName: "workout", description: "Cycling", detail: "30 min", calories: 300, type: "Workout"),
    DiaryEntry(time: "12:30 PM", iconName: "food", description: "Chicken Breast", detail: "200g", calories: 500, type: "Food"),
    DiaryEntry(time: "2:00 PM", iconName: "water", description: "Water", detail: "500ml", calories: 0, type: "Water")
]

