import SwiftUI

struct DashboardView: View {
    @State private var selectedTab: Tab = .today // Default view is "Today"
    @State private var isPlusButtonPressed: Bool = false // Tracks press state for "+"
    @State private var showSemiCircle: Bool = false // Tracks visibility of the semi-circle
    @State private var currentRadius: CGFloat = 10 // Starts collapsed
    @State private var activeView: ActiveView? = nil // Tracks which view is active
    @State private var weighIns: [(time: String, weight: String)] = [] // ✅ Store Weigh-Ins
    @State private var fadeOut: Bool = false // ✅ Added fadeOut state
    private let maxRadius: CGFloat = 160 // Max expansion
    private let minRadius: CGFloat = 10  // Min expansion

    enum Tab {
        case today, past, progress, settings
    }

    enum ActiveView {
        case addFood, addWater, weighIn, addWorkout
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // ✅ MAIN CONTENT AREA
                ZStack {
                    switch selectedTab {
                    case .today:
                        TodayView(weighIns: $weighIns) // ✅ Pass delete function
                    case .past:
                        PastView()
                    case .progress:
                        ProgressView()
                    case .settings:
                        SettingsView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // ✅ BOTTOM NAVIGATION BAR WITH SEMI-CIRCLE BACKDROP
                ZStack {
                    GeometryReader { geometry in
                        let centerX = geometry.size.width / 2
                        let circleCenterY: CGFloat = geometry.size.height - 65 // Align to top of nav bar

                        // ✅ RESTORED SEMI-CIRCLE
                        Circle()
                            .fill(Styles.primaryText)
                            .frame(width: showSemiCircle ? geometry.size.width * 2 : 10,
                                   height: showSemiCircle ? geometry.size.width : 10)
                            .position(x: centerX, y: showSemiCircle ? circleCenterY : geometry.size.height)
                            .scaleEffect(showSemiCircle ? 1 : 0.1, anchor: .center)
                            .opacity(showSemiCircle ? 1 : 0)
                            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showSemiCircle)

                        let angles: [Double] = [-32, -70, -108, -147]
                        let buttonData: [(image: String, text: String, view: ActiveView)] = [
                            ("AddWater", "Water", .addWater),
                            ("AddFood", "Food", .addFood),
                            ("SliderIcon", "Workout", .addWorkout),
                            ("AddWeight", "Weigh In", .weighIn)
                        ]

                        ForEach(0..<4) { index in
                            let angle = Angle(degrees: angles[index])

                            VStack(spacing: 5) {
                                Image(buttonData[index].image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)

                                Text(buttonData[index].text)
                                    .font(.caption)
                                    .foregroundColor(Styles.secondaryBackground)
                            }
                            .position(x: centerX, y: circleCenterY)
                            .offset(
                                x: currentRadius * cos(angle.radians),
                                y: currentRadius * sin(angle.radians)
                            )
                            .scaleEffect(showSemiCircle ? 1 : 0.1)
                            .opacity(showSemiCircle ? 1 : 0)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentRadius)
                            .onTapGesture {
                                withAnimation {
                                    // ✅ Close the semi-circle when a button is clicked
                                    showSemiCircle = false
                                    isPlusButtonPressed = false
                                    currentRadius = minRadius
                                }

                                // ✅ Set the active view based on button selection
                                activeView = buttonData[index].view
                            }
                        }

                    }
                    .frame(height: 96)

                    // ✅ Navigation Bar
                    Rectangle()
                        .fill(Styles.secondaryBackground)
                        .frame(height: 96)
                        .shadow(radius: 5)

                    HStack {
                        navButton(icon: "book", label: "Today", tab: .today)
                        navButton(icon: "clock", label: "Past", tab: .past)

                        Spacer().frame(width: 80) // Space for "+" button

                        navButton(icon: "chart.bar", label: "Progress", tab: .progress)
                        navButton(icon: "gear", label: "Settings", tab: .settings)
                    }
                    .padding(.horizontal, 15)
                    .frame(maxWidth: .infinity)
                    .offset(y: -10)

                    // ✅ Center "+" Button with Rotation & Color Transition
                    VStack {
                        ZStack {
                            Circle()
                                .fill(showSemiCircle ? Color.red : Styles.primaryText)
                                .frame(width: 80, height: 80)
                                .shadow(radius: 5)

                            Image(systemName: "plus")
                                .font(.largeTitle)
                                .foregroundColor(Styles.secondaryBackground)
                                .rotationEffect(.degrees(showSemiCircle ? 45 : 0))
                                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showSemiCircle)
                        }
                        .onTapGesture {
                            withAnimation {
                                isPlusButtonPressed.toggle()
                                showSemiCircle.toggle()
                                currentRadius = showSemiCircle ? maxRadius : minRadius
                            }
                        }
                        .offset(y: -36)
                    }
                }
                .frame(height: 96)
            }

            // ✅ Full-Screen Views
            if let _ = activeView { // ✅ Only show overlay if activeView is set
                FullScreenOverlay(
                    closeAction: {
                        withAnimation {
                            self.activeView = nil
                        }
                    },
                    saveWeighIn: saveWeighIn,
                    isPlusButtonPressed: $isPlusButtonPressed,
                    showSemiCircle: $showSemiCircle,
                    currentRadius: $currentRadius,
                    fadeOut: $fadeOut,
                    activeView: $activeView // ✅ Pass as a binding (Fix)
                )
            }


        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Styles.primaryBackground)
        .ignoresSafeArea(edges: .bottom)
    }

    // ✅ Navigation Button View (FULLY RESTORED)
    private func navButton(icon: String, label: String, tab: Tab) -> some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.title)
                .frame(width: 30, height: 30)
                .foregroundColor(selectedTab == tab ? .orange : Styles.secondaryText)

            Text(label)
                .font(.caption2)
                .foregroundColor(selectedTab == tab ? .orange : Styles.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .onTapGesture {
            selectedTab = tab
        }
    }

    
    // ✅ Function to Save Weigh-Ins & Close Semi-Circle
    private func saveWeighIn(time: String, weight: String) {
        DispatchQueue.main.async {
            weighIns.append((time: time, weight: weight)) // ✅ Add new entry

        }
    }



    // ✅ Function to Delete Weigh-Ins
    private func deleteWeighIn(index: Int) {
        DispatchQueue.main.async {
            if index >= 0 && index < weighIns.count {
                weighIns.remove(at: index) // ✅ Fully working delete function
            }
        }
    }
}

// ✅ Full-Screen Overlay View for Add Food, Add Water, Weigh In, Add Workout
// ✅ Full-Screen Overlay View for Add Food, Add Water, Weigh In, Add Workout
// ✅ Full-Screen Overlay View for Add Food, Add Water, Weigh In, Add Workout
struct FullScreenOverlay: View {
    let closeAction: () -> Void
    let saveWeighIn: (String, String) -> Void

    @Binding var isPlusButtonPressed: Bool
    @Binding var showSemiCircle: Bool
    @Binding var currentRadius: CGFloat
    @Binding var fadeOut: Bool
    @Binding var activeView: DashboardView.ActiveView? // ✅ Make it optional to handle closing properly

    var body: some View {
        ZStack {
            Color.black.opacity(fadeOut ? 0 : 0.5) // ✅ Sync fade with WeighInView
                .animation(.easeOut(duration: 0.5), value: fadeOut)
                .edgesIgnoringSafeArea(.all)

            if let activeView = activeView { // ✅ Ensure it only shows when non-nil
                VStack(spacing: 0) {
                    switch activeView {
                    case .addFood:
                        AddFoodView(closeAction: closeWithAnimation)
                    case .addWater:
                        AddWaterView(closeAction: closeWithAnimation)
                    case .weighIn:
                        WeighInView(
                            closeAction: closeWithAnimation,
                            saveWeighIn: { time, weight in
                                saveWeighIn(time, weight)

                                // ✅ Close the semi-circle after saving
                                isPlusButtonPressed = false
                                showSemiCircle = false
                                currentRadius = 10
                            },
                            fadeOut: $fadeOut
                        )
                    case .addWorkout:
                        WorkoutView(closeAction: closeWithAnimation)
                    }
                }
            }
        }
    }

    private func closeWithAnimation() {
        withAnimation {
            fadeOut = true // ✅ Start fade-out animation
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                activeView = nil // ✅ Reset active view AFTER fade completes
                fadeOut = false  // ✅ Reset fade state for next opening
            }
        }
    }
}
