
//
//  BodyMeasurementView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 2/26/25.
//
// BodyMeasurementView.swift
// Calorie counter
// Created by frank lasalvia on 2/26/25.

// BodyMeasurementView.swift
// Calorie counter
// Created by frank lasalvia on 2/26/25.

import SwiftUI

struct BodyMeasurementView: View {
    @Binding var userProfile: UserProfile?
    @Binding var bodyMeasurements: [BodyMeasurement]
    @Binding var showBodyMeasurementView: Bool
    
    // Simulated Date Logic (consistent with DailyDBView.swift)
    private var simulatedCurrentDate: Date {
        if let savedDate = UserDefaults.standard.object(forKey: "simulatedCurrentDate") as? Date {
            return Calendar.current.startOfDay(for: savedDate)
        }
        return Calendar.current.startOfDay(for: Date())
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 15) {
                let hasMultipleEntries = bodyMeasurements.count > 1
                let latestMeasurement = bodyMeasurements.last
                let earliestMeasurement = bodyMeasurements.first
                let allZero = latestMeasurement.map { $0.chest == 0 && $0.waist == 0 && $0.hips == 0 && $0.leftArm == 0 && $0.rightArm == 0 && $0.leftThigh == 0 && $0.rightThigh == 0 } ?? true
                
                // Main content container
                HStack(spacing: 15) {
                    Image("BMDefault")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 263)
                    VStack(alignment: .leading, spacing: 8) {
                        MeasurementRow(
                            label: "",
                            value: 0,
                            difference: nil,
                            showDifference: false,
                            useMetric: false,
                            customText: dateString(for: latestMeasurement?.date)
                        )
                        MeasurementRow(
                            label: "Chest",
                            value: latestMeasurement?.chest ?? 0,
                            difference: calculateDifference(earliest: earliestMeasurement?.chest, latest: latestMeasurement?.chest),
                            showDifference: hasMultipleEntries,
                            useMetric: userProfile?.useMetric ?? false
                        )
                        MeasurementRow(
                            label: "Waist",
                            value: latestMeasurement?.waist ?? 0,
                            difference: calculateDifference(earliest: earliestMeasurement?.waist, latest: latestMeasurement?.waist),
                            showDifference: hasMultipleEntries,
                            useMetric: userProfile?.useMetric ?? false
                        )
                        MeasurementRow(
                            label: "Hips",
                            value: latestMeasurement?.hips ?? 0,
                            difference: calculateDifference(earliest: earliestMeasurement?.hips, latest: latestMeasurement?.hips),
                            showDifference: hasMultipleEntries,
                            useMetric: userProfile?.useMetric ?? false
                        )
                        MeasurementRow(
                            label: "Arms (L)",
                            value: latestMeasurement?.leftArm ?? 0,
                            difference: calculateDifference(earliest: earliestMeasurement?.leftArm, latest: latestMeasurement?.leftArm),
                            showDifference: hasMultipleEntries,
                            useMetric: userProfile?.useMetric ?? false
                        )
                        MeasurementRow(
                            label: "Arms (R)",
                            value: latestMeasurement?.rightArm ?? 0,
                            difference: calculateDifference(earliest: earliestMeasurement?.rightArm, latest: latestMeasurement?.rightArm),
                            showDifference: hasMultipleEntries,
                            useMetric: userProfile?.useMetric ?? false
                        )
                        MeasurementRow(
                            label: "Thighs (L)",
                            value: latestMeasurement?.leftThigh ?? 0,
                            difference: calculateDifference(earliest: earliestMeasurement?.leftThigh, latest: latestMeasurement?.leftThigh),
                            showDifference: hasMultipleEntries,
                            useMetric: userProfile?.useMetric ?? false
                        )
                        MeasurementRow(
                            label: "Thighs (R)",
                            value: latestMeasurement?.rightThigh ?? 0,
                            difference: calculateDifference(earliest: earliestMeasurement?.rightThigh, latest: latestMeasurement?.rightThigh),
                            showDifference: hasMultipleEntries,
                            useMetric: userProfile?.useMetric ?? false
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Styles.primaryBackground)
                .cornerRadius(8)
                .onTapGesture { showBodyMeasurementView = true }
                // Center the container and limit its width to content
                .frame(maxWidth: 340) // Approx width: image (100) + spacing (15) + text (label 80 + value ~145) = ~340
                .padding(.top, 40) // Push content down from top label bar
                
                if allZero {
                    Text("Enter your measurements")
                        .font(.subheadline)
                        .foregroundColor(Styles.secondaryText)
                        .padding(.bottom, 5)
                }
            }
            .frame(maxWidth: .infinity) // Ensure VStack fills available width for centering
            
            // Top label bar
            HStack {
                Text("Body Measurements")
                    .font(.headline)
                    .foregroundColor(Styles.primaryText)
                Spacer()
                Button(action: { showBodyMeasurementView = true }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(Styles.primaryText)
                }
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 15)
            .background(Styles.secondaryBackground)
            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 5)
            .zIndex(1)
        }
    }
    
    private func dateString(for date: Date?) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date ?? simulatedCurrentDate)
    }
    
    private func calculateDifference(earliest: Double?, latest: Double?) -> Double? {
        guard let earliest = earliest, let latest = latest else { return nil }
        return latest - earliest
    }
}

struct MeasurementRow: View {
    let label: String
    let value: Double
    let difference: Double?
    let showDifference: Bool
    let useMetric: Bool
    var customText: String? // Optional custom text for date row
    
    var body: some View {
        HStack(spacing: 10) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(Styles.secondaryText)
                .frame(width: 80, alignment: .leading)
            if let customText = customText {
                Text(customText)
                    .font(.subheadline)
                    .foregroundColor(Styles.primaryText)
            } else {
                Text(String(format: "%.1f%@", value, useMetric ? "cm" : "in"))
                    .font(.subheadline)
                    .foregroundColor(Styles.primaryText)
            }
            if showDifference, let diff = difference {
                Text(diff > 0 ? "+\(String(format: "%.1f", diff))" : String(format: "%.1f", diff))
                    .font(.subheadline)
                    .foregroundColor(diff > 0 ? .red : .green)
            }
        }
    }
}
