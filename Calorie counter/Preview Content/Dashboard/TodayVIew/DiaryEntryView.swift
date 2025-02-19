//
//  DiaryEntryView.swift
//  Calorie Counter
//
//  Created by Frank LaSalvia on 2/12/25.
//

import SwiftUI

struct DiaryEntryRow: View {
    var entry: DiaryEntry

    var body: some View {
        HStack(spacing: 10) {
            // ✅ Timestamp
            Text(entry.time)
                .font(.subheadline)
                .foregroundColor(Styles.secondaryText)
                .frame(width: 70, alignment: .leading)

            // ✅ Entry Image (Resizes Properly)
            getImage(for: entry)
                .resizable()
                .scaledToFill() // ✅ Ensures image fills square while maintaining aspect ratio
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .clipped() // ✅ Prevents overflow beyond the frame

            // ✅ VStack for Description & Detail (if needed)
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.description)
                    .font(.headline)
                    .foregroundColor(Styles.primaryText)

                // ✅ Only show serving size for food & duration for workouts
                if entry.type == "Workout" || entry.type == "Food" {
                    Text(entry.detail)
                        .font(.subheadline)
                        .foregroundColor(Styles.secondaryText)
                }
            }

            Spacer()

            // ✅ Ensure Calories Display Correctly (No Extra "-")
            Text(entry.type == "Workout" ? "-\(abs(entry.calories))" : entry.type == "Food" ? "+\(entry.calories)" : shortenWaterEntry(entry.detail))
                .font(.subheadline)
                .foregroundColor(entry.type == "Food" ? .green : entry.type == "Workout" ? .red : .blue)
                .frame(width: 60, alignment: .trailing)
        }
        .padding(.vertical, 5)
    }

    // ✅ Function to Retrieve the Correct Image
    private func getImage(for entry: DiaryEntry) -> Image {
        if entry.type == "Water" {
            return Image("water") // ✅ Always use "water" for water entries
        } else if let imageData = entry.imageData, let uiImage = UIImage(data: imageData) {
            return Image(uiImage: uiImage) // ✅ Use user-selected image if available
        } else if entry.type == "Food" {
            return Image("DefaultFood") // ✅ Default food image
        }
        return Image("DefaultWorkout") // ✅ Default workout image
    }

    // ✅ Function to Shorten Unit Names Inside Water Entries
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
    let imageData: Data? // ✅ Stores the image (for food & workout)
}
