//
//  WeighIn.swift
//  Calorie counter
//
//  Created by frank lasalvia on 2/13/25.
//

import SwiftUI

struct WeighInView: View {
    var closeAction: () -> Void
    
    @State private var weight: String // ✅ Now a String to allow manual entry
    @State private var isEditing: Bool = false // ✅ Track if user is editing
    @FocusState private var isKeyboardActive: Bool // ✅ FocusState to control keyboard

    init(closeAction: @escaping () -> Void, userWeight: Double = 200.0) {
        self.closeAction = closeAction
        _weight = State(initialValue: String(format: "%.1f", userWeight)) // ✅ Start with user's weight
    }

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

                    Text("Weigh In")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Styles.primaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, safeAreaTopInset)

                Spacer().frame(height: 20) // 🔥 Space below title

                // ✅ Digital Scale Style Input
                HStack {
                    Spacer(minLength: 0) // 🔥 Ensures equal spacing on both sides

                    // 🔽 Decrease Button
                    Button(action: {
                        adjustWeight(by: -0.1)
                    }) {
                        Image(systemName: "triangle.fill")
                            .font(.system(size: 35)) // 🔥 Slightly smaller for balance
                            .foregroundColor(Styles.primaryText)
                            .rotationEffect(.degrees(180)) // 🔽 Rotates down
                            .opacity(0.7)
                    }
                    
                    // 🏆 Digital Weight Display (Editable)
                    TextField("", text: $weight, onEditingChanged: { editing in
                        isEditing = editing
                    })
                    .keyboardType(.decimalPad)
                    .focused($isKeyboardActive)
                    .multilineTextAlignment(.center)
                    .font(.custom("DS-Digital-Italic", size: 75)) // ✅ Custom digital font
                    .foregroundColor(Styles.primaryText)
                    .frame(width: 280) // 🔥 Adjust width for balance
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(10)
                    .onChange(of: weight) { _ in
                        validateWeightInput()
                    }
                    .onSubmit {
                        formatWeight()
                    }

                    // 🔼 Increase Button
                    Button(action: {
                        adjustWeight(by: 0.1)
                    }) {
                        Image(systemName: "triangle.fill")
                            .font(.system(size: 35)) // 🔥 Matches left button size
                            .foregroundColor(Styles.primaryText)
                            .opacity(0.7)
                    }

                    Spacer(minLength: 0) // 🔥 Ensures equal spacing on both sides
                }
                .padding(.horizontal, 10) // 🔥 Keeps everything inside the screen
                .padding(.vertical, 40)   // Maintains good vertical balance

                
                Divider()// 🔥 Pushes foot images down
                Spacer()

                // 🦶 Foot Images (Centered in Remaining Space)
                // 🦶 Foot Images (Centered in Remaining Space)
                HStack(spacing: 50) { // 🔥 Reduced spacing for closer images
                    Image("LeftFoot")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 250) // 🔥 Increased size
                        .foregroundColor(Styles.primaryText)

                    Image("RightFoot")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 250) // 🔥 Increased size
                        .foregroundColor(Styles.primaryText)
                }



                Spacer()

                // ✅ Bottom Navigation Bar
                ZStack {
                    Rectangle()
                        .fill(Styles.secondaryBackground)
                        .frame(height: 96)
                        .shadow(radius: 5)

                    HStack {
                        // 🔴 X Button (Closes View)
                        ZStack {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 80, height: 80)
                                .shadow(radius: 5)

                            Image(systemName: "xmark")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                        }
                        .onTapGesture {
                            closeAction()
                        }

                        Spacer().frame(width: 100)

                        // ➕ "+" Button (Same Style as Dashboard, But No Functionality)
                        ZStack {
                            Circle()
                                .fill(Styles.primaryText)
                                .frame(width: 80, height: 80)
                                .shadow(radius: 5)

                            Image(systemName: "plus")
                                .font(.largeTitle)
                                .foregroundColor(Styles.secondaryBackground)
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
            .onTapGesture {
                isKeyboardActive = false // ✅ Dismiss keyboard when tapping outside
            }
            .edgesIgnoringSafeArea(.all)
        }
    }

    // ✅ Adjusts weight by 0.1
    private func adjustWeight(by amount: Double) {
        if let currentWeight = Double(weight) {
            let newWeight = currentWeight + amount
            weight = String(format: "%.1f", newWeight)
        }
    }

    // ✅ Validates input (only allows numbers & one decimal)
    private func validateWeightInput() {
        let filtered = weight.filter { "0123456789.".contains($0) } // ✅ Keep only numbers & "."
        let components = filtered.split(separator: ".")

        if components.count > 2 {
            // ✅ Remove extra decimals (Keep only first one)
            if let lastDotIndex = filtered.lastIndex(of: ".") {
                let prefixIndex = filtered.distance(from: filtered.startIndex, to: lastDotIndex)
                weight = String(filtered.prefix(prefixIndex)) // ✅ Convert index to Int
            }
        } else if let dotIndex = filtered.firstIndex(of: "."), let decimalPart = components.last, decimalPart.count > 1 {
            // ✅ Limit to 1 decimal place
            let prefixIndex = filtered.distance(from: filtered.startIndex, to: dotIndex) + 2
            weight = String(filtered.prefix(prefixIndex)) // ✅ Convert index to Int
        } else {
            weight = filtered
        }
    }

    // ✅ Formats weight to always display 1 decimal place
    private func formatWeight() {
        if let value = Double(weight) {
            weight = String(format: "%.1f", value)
        }
    }
}
