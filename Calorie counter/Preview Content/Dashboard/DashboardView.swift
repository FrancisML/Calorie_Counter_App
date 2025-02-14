import SwiftUI

struct DashboardView: View {
    @State private var selectedTab: Tab = .today // Default view is "Today"
    @State private var isPlusButtonPressed: Bool = false // Tracks press state for "+"
    @State private var showSemiCircle: Bool = false // Tracks visibility of the semi-circle
    @State private var currentRadius: CGFloat = 10 // Starts collapsed
    @State private var activeView: ActiveView? = nil // Tracks which view is active

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
            // ✅ Main Dashboard View
            VStack(spacing: 0) {
                // MAIN CONTENT AREA
                ZStack {
                    switch selectedTab {
                    case .today:
                        TodayView()
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
                                activeView = buttonData[index].view
                            }
                        }
                    } // Closing GeometryReader
                    .frame(height: 96)

                    // ✅ Navigation Bar
                    Rectangle()
                        .fill(Styles.secondaryBackground)
                        .frame(height: 96)
                        .shadow(radius: 5)

                    HStack {
                        // Left-side buttons
                        navButton(icon: "book", label: "Today", tab: .today)
                        navButton(icon: "clock", label: "Past", tab: .past)

                        Spacer().frame(width: 80) // Space for "+" button

                        // Right-side buttons
                        navButton(icon: "chart.bar", label: "Progress", tab: .progress)
                        navButton(icon: "gear", label: "Settings", tab: .settings)
                    }
                    .padding(.horizontal, 15)
                    .frame(maxWidth: .infinity)
                    .offset(y: -10)

                    // ✅ Center "+" Button
                    // ✅ Center "+" Button with Rotation & Color Transition
                    VStack {
                        ZStack {
                            Circle()
                                .fill(showSemiCircle ? Color.red : Styles.primaryText) // 🔥 Changes color based on state
                                .frame(width: 80, height: 80)
                                .shadow(radius: 5)

                            Image(systemName: "plus")
                                .font(.largeTitle)
                                .foregroundColor(Styles.secondaryBackground)
                                .rotationEffect(.degrees(showSemiCircle ? 45 : 0)) // 🔥 Rotates when expanded
                                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showSemiCircle) // 🔥 Smooth transition
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
            if let activeView = activeView {
                FullScreenOverlay(activeView: activeView, closeAction: {
                    withAnimation {
                        self.activeView = nil
                    }
                })
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Styles.primaryBackground)
        .ignoresSafeArea(edges: .bottom)
    }

    // ✅ Navigation Button View
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
}

// ✅ Full-Screen Overlay View for Add Food, Add Water, Weigh In, Add Workout
struct FullScreenOverlay: View {
    let activeView: DashboardView.ActiveView
    let closeAction: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                // ✅ Load the Correct Full-Screen View and Pass `closeAction`
                switch activeView {
                case .addFood:
                    AddFoodView(closeAction: closeAction)
                case .addWater:
                    AddWaterView(closeAction: closeAction)
                case .weighIn:
                    WeighInView(closeAction: closeAction)
                case .addWorkout:
                    WorkoutView(closeAction: closeAction)
                }
            }
        }
    }
}
