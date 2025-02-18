//
//  DiaryEntryView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 2/12/25.

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

            }

            Spacer()

            Text(entry.type == "Water" ? shortenWaterEntry(entry.detail) : entry.type == "Workout" ? "-\(entry.calories)" : "+\(entry.calories)")
            // ✅ Ensures workouts are negative, food is positive, and water displays properly
                .font(.subheadline)
                .foregroundColor(entry.type == "Food" ? .green : entry.type == "Workout" ? .red : .blue)
                .frame(width: 60, alignment: .trailing)
        }
        .padding(.vertical, 5)
    }

    // ✅ Function to shorten unit names inside diary water entries
    private func shortenWaterEntry(_ detail: String) -> String {
        return detail
            .replacingOccurrences(of: "Gallons", with: "gal")
            .replacingOccurrences(of: "Liters", with: "L")
            .replacingOccurrences(of: "Milliliters", with: "ml")
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



