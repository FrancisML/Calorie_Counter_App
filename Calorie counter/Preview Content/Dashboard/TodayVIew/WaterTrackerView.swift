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
        totalWaterIntake()
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

                    // ✅ Display text with shortened unit names
                    Text(displayWaterText())
                        .font(.subheadline)
                        .foregroundColor(Styles.secondaryText)
                }

                // ✅ Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Styles.primaryText.opacity(0.2))
                            .frame(height: 20)

                        if shouldShowProgressBar() {
                            Rectangle()
                                .fill(Styles.primaryText)
                                .frame(
                                    width: min((totalDailyWater / max(waterGoal, 0.01)) * geometry.size.width, geometry.size.width),
                                    height: 20
                                )
                                .animation(.easeInOut(duration: 0.3), value: totalDailyWater)
                        }
                    }
                }
                .frame(height: 20)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            print("🚀 Water progress bar tapped!")
            isWaterPickerPresented = true
        }
    }
    
    // ✅ Fix for progress bar being full at app launch
    private func shouldShowProgressBar() -> Bool {
        return waterGoal > 0 || totalDailyWater > 0
    }

    // ✅ Convert total water intake to match the user’s selected unit
    private func totalWaterIntake() -> CGFloat {
        var totalIntake: CGFloat = 0
        for entry in diaryEntries where entry.type == "Water" {
            let (amount, unit) = extractWaterAmountAndUnit(entry.detail)
            let convertedAmount = convertWaterUnit(amount: amount, from: unit, to: selectedUnit)
            totalIntake += convertedAmount
        }
        return totalIntake
    }
    
    // ✅ Extract numeric value and unit from entry detail (Handles Fractions & fl oz)
    private func extractWaterAmountAndUnit(_ detail: String) -> (CGFloat, String) {
        let fractionMap: [String: CGFloat] = [
            "1/4": 0.25,
            "1/2": 0.5,
            "3/4": 0.75,
            "1": 1.0
        ]
        
        let components = detail.split(separator: " ")
        if components.count == 2 {
            let amountString = String(components[0])
            let unit = String(components[1])

            if let fractionValue = fractionMap[amountString] {
                return (fractionValue, unit)
            } else if let amount = Double(amountString) {
                return (CGFloat(amount), unit)
            }
        } else if detail.contains("fl oz") {
            let numberString = detail.replacingOccurrences(of: "fl oz", with: "").trimmingCharacters(in: .whitespaces)
            if let amount = Double(numberString) {
                return (CGFloat(amount), "fl oz")
            }
        }

        return (0, "ml") // Default to ml if extraction fails
    }

    // ✅ Format number display for water amounts
    private func formattedAmount(_ amount: CGFloat) -> String {
        return selectedUnit == "Gallons" ? String(format: "%.2f", amount) : "\(Int(amount))"
    }

    // ✅ Convert unit names for display in the progress bar & diary entries
    private func shortenUnit(_ unit: String) -> String {
        switch unit {
        case "Gallons": return "gal"
        case "Liters": return "L"
        case "Milliliters": return "ml"
        default: return unit // "fl oz" remains unchanged
        }
    }

    // ✅ Display text logic for Water Progress Bar
    private func displayWaterText() -> String {
        if waterGoal == 0 && totalDailyWater == 0 {
            return "0 \(shortenUnit(selectedUnit))" // ✅ Empty when there's no data
        }
        return waterGoal == 0
            ? "\(formattedAmount(totalDailyWater)) \(shortenUnit(selectedUnit))"
            : "\(formattedAmount(totalDailyWater)) / \(formattedAmount(waterGoal)) \(shortenUnit(selectedUnit))"
    }

    // ✅ Convert between different water units
    private func convertWaterUnit(amount: CGFloat, from fromUnit: String, to toUnit: String) -> CGFloat {
        let mlPerFlOz: CGFloat = 29.5735
        let mlPerGallon: CGFloat = 3785.41
        let mlPerLiter: CGFloat = 1000

        var amountInMl: CGFloat
        switch fromUnit.lowercased() {
        case "milliliters", "ml": amountInMl = amount
        case "liters", "l": amountInMl = amount * mlPerLiter
        case "gallons", "gal": amountInMl = amount * mlPerGallon
        case "fl", "fl oz": amountInMl = amount * mlPerFlOz
        default: return amount
        }

        switch toUnit.lowercased() {
        case "milliliters", "ml": return amountInMl
        case "liters", "l": return amountInMl / mlPerLiter
        case "gallons", "gal": return amountInMl / mlPerGallon
        case "fl", "fl oz": return amountInMl / mlPerFlOz
        default: return amount
        }
    }
}
