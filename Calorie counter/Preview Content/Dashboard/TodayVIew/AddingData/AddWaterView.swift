import SwiftUI

struct AddWaterView: View {
    var closeAction: () -> Void
    @Binding var diaryEntries: [DiaryEntry]

    @State private var selectedUnit: String = "fl oz"
    @State private var selectedAmount: String = "8"

    var body: some View {
        GeometryReader { geometry in
            let safeAreaTopInset = geometry.safeAreaInsets.top
            
            VStack(spacing: 0) {
                // ✅ Title Bar
                ZStack {
                    Rectangle()
                        .fill(Styles.secondaryBackground)
                        .frame(height: 80)
                        .shadow(color: Color.black.opacity(0.2), radius: 4, y: 4)

                    Text("Add Water")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Styles.primaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, safeAreaTopInset)

                Spacer().frame(height: 20)

                // ✅ Inline Water Picker
                VStack(spacing: 20) {
                    Text("Select Water Intake")
                        .font(.title)
                        .foregroundColor(Styles.primaryText)

                    HStack {
                        // Amount Picker
                        Picker("Amount", selection: $selectedAmount) {
                            ForEach(amountsForSelectedUnit(), id: \.self) { amount in
                                Text(amount)
                                    .foregroundColor(Styles.primaryText)
                                    .font(.system(size: 36, weight: .medium))
                                    .frame(height: 60)
                                    .tag(amount)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(maxWidth: .infinity)

                        // Unit Picker
                        Picker("Unit", selection: $selectedUnit) {
                            ForEach(["Gallons", "Liters", "Milliliters", "fl oz"], id: \.self) { unit in
                                Text(unit)
                                    .foregroundColor(Styles.primaryText)
                                    .font(.system(size: 36, weight: .medium))
                                    .frame(height: 60)
                                    .tag(unit)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(maxWidth: .infinity)
                    }
                    .frame(height: 200)
                    .padding(.horizontal, 20)
                    .onChange(of: selectedUnit) { newUnit in
                        // ✅ When unit changes, update selectedAmount to the first valid option
                        selectedAmount = amountsForSelectedUnit().first ?? "8"
                    }

                    // ✅ Added WaterInput Image Below Picker
                    Image("WaterInput")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.8)
                        .padding(.top, 20)
                        .shadow(radius: 5)
                }
                .frame(maxWidth: .infinity)

                Spacer()

                // ✅ Bottom Navigation Bar
                ZStack {
                    Rectangle()
                        .fill(Styles.secondaryBackground)
                        .frame(height: 96)
                        .shadow(radius: 5)

                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 80, height: 80)
                                .shadow(radius: 5)

                            Image(systemName: "xmark")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                        }
                        .onTapGesture { closeAction() }

                        Spacer().frame(width: 100)

                        ZStack {
                            Circle()
                                .fill(Styles.primaryText)
                                .frame(width: 80, height: 80)
                                .shadow(radius: 5)

                            Image(systemName: "plus") // ✅ "+" button now saves entry
                                .font(.largeTitle)
                                .foregroundColor(Styles.secondaryBackground)
                        }
                        .onTapGesture {
                            saveWaterEntry()
                        }
                    }
                    .padding(.horizontal, 30)
                    .frame(maxWidth: .infinity)
                    .offset(y: -36)
                }
                .frame(height: 96)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Styles.secondaryBackground)
            .edgesIgnoringSafeArea(.all)
        }
    }

    // ✅ Function to Save Water Entry
    private func saveWaterEntry() {
        let newEntry = DiaryEntry(
            time: formattedCurrentTime(),
            iconName: "water", // ✅ Always use the "water" image
            description: "Water",
            detail: "\(selectedAmount) \(selectedUnit)", // ✅ Correctly formatted detail
            calories: 0,
            type: "Water",
            imageName: "water", // ✅ **FIXED**: Added missing argument
            imageData: nil // ✅ Water entries don't need a custom image
        )

        DispatchQueue.main.async {
            diaryEntries.append(newEntry) // ✅ Works properly
            print("✅ Water Entry Added: \(diaryEntries.count) total entries")
        }

        closeAction()
    }


    // ✅ Returns available amounts based on selected unit
    private func amountsForSelectedUnit() -> [String] {
        switch selectedUnit {
        case "Gallons":
            return ["1/4", "1/2", "3/4", "1"]
        case "Liters":
            return stride(from: 0.25, through: 4.0, by: 0.25).map { String(format: "%.2f", $0) }
        case "Milliliters":
            return stride(from: 30, through: 3750, by: 30).map { "\($0)" }
        case "fl oz":
            return (1...128).map { "\($0)" }
        default:
            return []
        }
    }

    // ✅ Function to get the current time in "h:mm a" format
    private func formattedCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: Date())
    }
}
