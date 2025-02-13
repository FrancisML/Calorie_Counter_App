//
//  WaterTracker.swift
//  Calorie counter
//
//  Created by frank lasalvia on 2/12/25.
//

import SwiftUI

struct WaterTrackerView: View {
    var diaryEntries: [DiaryEntry]
    @Binding var selectedUnit: String
    @Binding var waterGoal: CGFloat
    @Binding var isWaterPickerPresented: Bool
    
    var totalDailyWater: CGFloat {
        convertWaterUnit(amount: totalWaterIntake(), from: "fl oz", to: selectedUnit)
    }
    
    var body: some View {
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

                    // ✅ Display logic for text
                    Text(waterGoal == 0 ?
                        (selectedUnit == "Gallons" ? String(format: "%.2f", totalDailyWater) + " \(selectedUnit)" :
                        "\(Int(totalDailyWater)) \(selectedUnit)") :
                        (selectedUnit == "Gallons" ?
                            String(format: "%.2f", totalDailyWater) + " / " + formattedGallonGoal(waterGoal) + " \(selectedUnit)" :
                            "\(Int(totalDailyWater)) / \(Int(waterGoal)) \(selectedUnit)"
                        )
                    )
                    .font(.subheadline)
                    .foregroundColor(Styles.secondaryText)
                }

                // ✅ Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Styles.primaryText.opacity(0.2))
                            .frame(height: 20)

                        Rectangle()
                            .fill(Styles.primaryText)
                            .frame(
                                width: waterGoal == 0 ? geometry.size.width : // ✅ Full bar if no goal
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
    }
    
    // ✅ Convert total water intake to fl oz for calculations
    private func totalWaterIntake() -> CGFloat {
        var totalIntake: CGFloat = 0
        for entry in diaryEntries where entry.type == "Water" {
            let amount = extractWaterAmount(entry.detail)
            let unit = extractWaterUnit(entry.detail)
            let convertedAmount = convertWaterUnit(amount: amount, from: unit, to: "fl oz")
            totalIntake += convertedAmount
        }
        return totalIntake
    }
    
    // ✅ Extract numeric value from entry detail
    private func extractWaterAmount(_ detail: String) -> CGFloat {
        let numberString = detail.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return CGFloat(Double(numberString) ?? 0)
    }

    // ✅ Extract unit from water entry
    private func extractWaterUnit(_ detail: String) -> String {
        if detail.contains("ml") { return "ml" }
        if detail.contains("L") { return "L" }
        if detail.contains("gal") { return "gal" }
        if detail.contains("fl oz") { return "fl oz" }
        return "ml" // Default to ml if no unit found
    }

    // ✅ Format gallon goals as fractions
    private func formattedGallonGoal(_ goal: CGFloat) -> String {
        let fractionMap: [CGFloat: String] = [
            0.25: "1/4",
            0.5: "1/2",
            0.75: "3/4",
            1.0: "1"
        ]
        return fractionMap[goal] ?? String(format: "%.2f", goal)
    }

    // ✅ Convert between different water units
    private func convertWaterUnit(amount: CGFloat, from fromUnit: String, to toUnit: String) -> CGFloat {
        let mlPerFlOz: CGFloat = 29.5735
        let mlPerGallon: CGFloat = 3785.41
        let mlPerLiter: CGFloat = 1000

        var amountInMl: CGFloat
        switch fromUnit {
        case "Milliliters", "ml": amountInMl = amount
        case "Liters", "L": amountInMl = amount * mlPerLiter
        case "Gallons", "gal": amountInMl = amount * mlPerGallon
        case "fl oz": amountInMl = amount * mlPerFlOz
        default: return amount
        }

        switch toUnit {
        case "Milliliters", "ml": return amountInMl
        case "Liters", "L": return amountInMl / mlPerLiter
        case "Gallons", "gal": return amountInMl / mlPerGallon
        case "fl oz": return amountInMl / mlPerFlOz
        default: return amount
        }
    }
}
