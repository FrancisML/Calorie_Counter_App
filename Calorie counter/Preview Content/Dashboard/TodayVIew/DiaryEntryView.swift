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
                .renderingMode(.original) // ✅ Ensures transparency in PNGs
                .scaledToFit() // ✅ Ensures the image fits without being cut off
                .frame(width: 50, height: 50)
                .background(Color.clear) // ✅ No background for transparent images
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .clipped() // ✅ Prevents overflow beyond the frame

            // ✅ VStack for Description & Detail (if needed)
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.description)
                    .font(.headline)
                    .foregroundColor(Styles.primaryText)

                // ✅ Only show duration for workouts & serving size for food
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
        } else if let imageName = entry.imageName, isADVWorkoutImage(imageName) {
            return Image(imageName) // ✅ Handles ADVWorkout images correctly
        } else if entry.type == "Food" {
            return Image("DefaultFood") // ✅ Default food image
        }
        return Image("DefaultWorkout") // ✅ Default workout image
    }

    // ✅ Checks if the image comes from ADVWorkoutAddView
    private func isADVWorkoutImage(_ imageName: String) -> Bool {
        let workoutImages = [
            "ABS", "ShuttleCock", "Baseball", "Basketball", "Boxing", "calisthenics",
            "XSkiing", "Bikeing", "Eliptical", "Golf", "Hiking", "Hockey",
            "Running", "MountainBike", "Paddle", "Pickle", "Pilates",
            "racquetball", "Rockclimbing", "Rowing", "Running", "scuba",
            "Skiing", "Snowboarding", "Soccer", "Spining", "Squash", "Swiming",
            "tennis", "volley", "Walking", "Weights", "Yoga", "Zumba"
        ]
        return workoutImages.contains(imageName)
    }

    // ✅ Function to Shorten Unit Names Inside Water Entries
    private func shortenWaterEntry(_ detail: String) -> String {
        return detail
            .replacingOccurrences(of: "Gallons", with: "gal")
            .replacingOccurrences(of: "Liters", with: "L")
            .replacingOccurrences(of: "Milliliters", with: "ml")
    }
}

import Foundation

struct DiaryEntry: Identifiable {
    let id = UUID()
    let time: String
    let iconName: String
    let description: String
    let detail: String
    let calories: Int
    let type: String
    let imageName: String?
    let imageData: Data?
    let fats: Double // New: grams of fat
    let carbs: Double // New: grams of carbs
    let protein: Double // New: grams of protein
    
    init(time: String, iconName: String, description: String, detail: String, calories: Int, type: String, imageName: String?, imageData: Data?, fats: Double = 0, carbs: Double = 0, protein: Double = 0) {
        self.time = time
        self.iconName = iconName
        self.description = description
        self.detail = detail
        self.calories = calories
        self.type = type
        self.imageName = imageName
        self.imageData = imageData
        self.fats = fats
        self.carbs = carbs
        self.protein = protein
    }
}

