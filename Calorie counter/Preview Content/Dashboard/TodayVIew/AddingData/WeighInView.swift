import SwiftUI

struct WeighInView: View {
    var closeAction: () -> Void
    var saveWeighIn: (String, String) -> Void
    @Binding var fadeOut: Bool // ✅ Accept fadeOut as a Binding

    @State private var weight: String
    @State private var isSaving: Bool = false
    @FocusState private var isKeyboardActive: Bool

    init(
        closeAction: @escaping () -> Void,
        saveWeighIn: @escaping (String, String) -> Void,
        fadeOut: Binding<Bool>, // ✅ Corrected to accept fadeOut as a Binding
        userWeight: Double = 200.0
    ) {
        self.closeAction = closeAction
        self.saveWeighIn = saveWeighIn
        self._fadeOut = fadeOut // ✅ Bind fadeOut correctly
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
                    Button(action: { adjustWeight(by: -0.1) }) {
                        Image(systemName: "triangle.fill")
                            .font(.system(size: 35))
                            .foregroundColor(Styles.primaryText)
                            .rotationEffect(.degrees(180))
                            .opacity(0.7)
                    }
                    .disabled(isSaving)

                    // ✅ Digital Weight Display (Switches to "SAVE" in Green)
                    Text(isSaving ? "SAVE" : weight)
                        .font(.custom("DS-Digital-Italic", size: 75))
                        .foregroundColor(isSaving ? .green : Styles.primaryText) // ✅ Turns green when saving
                        .frame(width: 280)
                        .background(Color.black.opacity(0.1))
                        .cornerRadius(10)
                        .opacity(fadeOut ? 0 : 1)

                    // 🔼 Increase Button
                    Button(action: { adjustWeight(by: 0.1) }) {
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
                        .onTapGesture { closeAction() }
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
            .opacity(fadeOut ? 0 : 1) // ✅ Apply fade-out animation
            .animation(.easeOut(duration: 0.7), value: fadeOut) // ✅ Smooth fade effect
            .onTapGesture {
                isKeyboardActive = false
            }
            .edgesIgnoringSafeArea(.all)
        }
    }

    // ✅ Function to Handle Save with Delay & Fade Animation
    private func startSaveProcess() {
        isSaving = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            withAnimation(.easeOut(duration: 0.5)) {
                fadeOut = true // ✅ Fade out both WeighInView and Overlay
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
            saveWeighIn(formattedCurrentTime(), weight)
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
}

