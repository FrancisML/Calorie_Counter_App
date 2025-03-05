import SwiftUI

struct WeighInView: View {
    var closeAction: () -> Void
        var saveWeighIn: (String, String) -> Void // Type remains the same, but matches DashboardView
        @Binding var fadeOut: Bool

    @State private var weight: String
    @State private var isSaving: Bool = false
    @FocusState private var isKeyboardActive: Bool
    @State private var hasEdited: Bool = false
    @State private var isEditing: Bool = false
    @State private var isManualEdit: Bool = false
    private var userWeight: Double

    init(
        closeAction: @escaping () -> Void,
        saveWeighIn: @escaping (String, String) -> Void,
        fadeOut: Binding<Bool>,
        userWeight: Double = 200.0
    ) {
        self.closeAction = closeAction
        self.saveWeighIn = saveWeighIn
        self._fadeOut = fadeOut
        self.userWeight = userWeight
        _weight = State(initialValue: String(format: "%.1f", userWeight))
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

                Spacer().frame(height: 20)

                // ✅ Digital Scale Style Input
                HStack {
                    Spacer()

                    // 🔽 Decrease Button
                    Button(action: {
                        isManualEdit = false // Prevent clearing input when using buttons
                        adjustWeight(by: -0.1)
                    }) {
                        Image(systemName: "triangle.fill")
                            .font(.system(size: 35))
                            .foregroundColor(Styles.primaryText)
                            .rotationEffect(.degrees(180))
                            .opacity(0.7)
                    }
                    .disabled(isSaving)
                    .disabled(isSaving)

                    // ✅ Editable Weight Display
                    TextField("", text: $weight)
                        .font(.custom("DS-Digital-Italic", size: 75))
                        .foregroundColor(isSaving ? .green : Styles.primaryText)
                        .frame(width: 280)
                        .background(Color.black.opacity(0.1))
                        .cornerRadius(10)
                        .opacity(fadeOut ? 0 : 1)
                        .multilineTextAlignment(.center)
                        .keyboardType(.decimalPad)
                        .focused($isKeyboardActive)
                        .onTapGesture {
                            isManualEdit = true // Only clear if manually editing
                            hasEdited = false
                        }
                        .onChange(of: weight) { newValue in
                            if isManualEdit && !hasEdited {
                                weight = "" // Clear field ONLY when manually typing for the first time
                                hasEdited = true
                            }
                            validateWeightInput()
                            isSaving = false
                        }


                    // 🔼 Increase Button
                    Button(action: {
                        isManualEdit = false // Prevent clearing input when using buttons
                        adjustWeight(by: 0.1)
                    }) {
                        Image(systemName: "triangle.fill")
                            .font(.system(size: 35))
                            .foregroundColor(Styles.primaryText)
                            .opacity(0.7)
                    }
                    .disabled(isSaving)

                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 40)

                Divider()
                Spacer()

                // ✅ Foot Images
                HStack(spacing: 50) {
                    Image("LeftFoot")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 250)
                        .foregroundColor(Styles.primaryText)

                    Image("RightFoot")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 250)
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
                        .onTapGesture { closeWeighIn() }
                        .disabled(isSaving)

                        Spacer().frame(width: 100)

                        // ✅ Save Button (Triggers Fade & Close)
                        ZStack {
                            Circle()
                                .fill(isSaving ? Color.green : Styles.primaryText)
                                .frame(width: 80, height: 80)
                                .shadow(radius: 5)

                            Image(systemName: "plus")
                                .font(.largeTitle)
                                .foregroundColor(Styles.secondaryBackground)
                        }
                        .onTapGesture {
                            if !isSaving {
                                startSaveProcess()
                            }
                        }
                        .disabled(isSaving)
                    }
                    .padding(.horizontal, 30)
                    .frame(maxWidth: .infinity)
                    .offset(y: -36)
                }
                .frame(height: 96)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Styles.secondaryBackground)
            .opacity(fadeOut ? 0 : 1)
            .animation(.easeOut(duration: 0.7), value: fadeOut)
            .onTapGesture {
                isKeyboardActive = false
            }
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                fadeOut = false // Only reset fadeOut when the view fully reopens
                weight = String(format: "%.1f", userWeight) // Ensure weight is always set on view appear
                if !fadeOut {
                    resetView()
                }
            
            }
        }
    }

    // ✅ Ensures the fade-out completes before resetting
    private func closeWeighIn() {
        withAnimation(.easeOut(duration: 0.7)) {
            fadeOut = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            resetView()
            closeAction()
        }
    }

    private func resetView() {
        isSaving = false
        hasEdited = false
        weight = String(format: "%.1f", userWeight) // Keep weight consistent
    }



    // ✅ Function to Handle Save with Delay & Fade Animation
    private func startSaveProcess() {
        isSaving = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            withAnimation(.easeOut(duration: 0.5)) {
                fadeOut = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            saveWeighIn(formattedCurrentTime(), weight)
            resetView()
            closeAction()
        }
    }

    // ✅ Adjusts weight by 0.1
    private func adjustWeight(by amount: Double) {
        if let currentWeight = Double(weight) {
            let newWeight = currentWeight + amount
            weight = String(format: "%.1f", newWeight)
        }
    }

    // ✅ Returns formatted time (8:00 AM/PM)
    private func formattedCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: Date())
    }

    // ✅ Limits input to 3 digits before decimal and 1 digit after
    private func validateWeightInput() {
        // Allow only numbers and a single decimal point
        let filteredWeight = weight.filter { "0123456789.".contains($0) }
        
        // Ensure only one decimal exists
        let components = filteredWeight.split(separator: ".")
        var beforeDecimal = String(components.first ?? "") // Convert to String
        var afterDecimal = components.count > 1 ? String(components[1]) : "" // Convert to String

        if beforeDecimal.count > 3 && !filteredWeight.contains(".") {
            // If user enters 4 digits without a decimal, auto-insert the decimal
            let adjustedBeforeDecimal = String(beforeDecimal.prefix(3))
            let adjustedAfterDecimal = String(beforeDecimal.suffix(1))
            beforeDecimal = adjustedBeforeDecimal
            afterDecimal = adjustedAfterDecimal
        }

        // If a decimal is manually entered, keep it
        if filteredWeight.contains(".") || !afterDecimal.isEmpty {
            weight = "\(beforeDecimal).\(afterDecimal.prefix(1))"
        } else {
            weight = beforeDecimal
        }
    }


}
