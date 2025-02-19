//
//  DiaryEntryView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 2/12/25.

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

            // ✅ Workout images scale to fill while maintaining aspect ratio
            getImage(for: entry)
                .resizable()
                .scaledToFill() // ✅ Ensures the image fills the square
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .clipped() // ✅ Ensures no overflow beyond the frame

            // ✅ VStack for Description & Detail (if needed)
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.description)
                    .font(.headline)
                    .foregroundColor(Styles.primaryText)

                // ✅ Only show duration for workouts, not water
                if entry.type == "Workout" {
                    Text(entry.detail)
                        .font(.subheadline)
                        .foregroundColor(Styles.secondaryText)
                }
            }

            Spacer()

            // ✅ Ensure Calories Show Correctly (No Extra "-")
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
            return Image(uiImage: uiImage) // ✅ Returns UIImage as SwiftUI Image
        }
        return Image("DefaultWorkout") // ✅ Fallback for workouts without an image
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
    let imageData: Data? // ✅ Stores the image
}




