import SwiftUI

struct DashboardView: View {
    @State private var selectedTab: Tab = .today
    @State private var isPlusButtonPressed: Bool = false
    @State private var showSemiCircle: Bool = false
    @State private var currentRadius: CGFloat = 10
    @State private var activeView: ActiveView? = nil
    @State private var weighIns: [WeighIn] = [] // Updated to [WeighIn]
    @State private var fadeOut: Bool = false
    @State private var diaryEntries: [DiaryEntry] = []

    private let maxRadius: CGFloat = 160
    private let minRadius: CGFloat = 10

    enum Tab {
        case today, past, progress, settings
    }

    enum ActiveView {
        case addFood, addWater, weighIn, addWorkout
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ZStack {
                    switch selectedTab {
                    case .today:
                        TodayView(weighIns: $weighIns, diaryEntries: $diaryEntries) // Pass [WeighIn] binding
                    case .past:
                        PastView() // Assuming PastView doesn’t need weighIns; adjust if it does
                    case .progress:
                        ProgressView()
                    case .settings:
                        SettingsView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                ZStack {
                    GeometryReader { geometry in
                        let centerX = geometry.size.width / 2
                        let circleCenterY: CGFloat = geometry.size.height - 65

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
                            ("Running", "Workout", .addWorkout),
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
                            .offset(x: currentRadius * cos(angle.radians), y: currentRadius * sin(angle.radians))
                            .scaleEffect(showSemiCircle ? 1 : 0.1)
                            .opacity(showSemiCircle ? 1 : 0)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentRadius)
                            .onTapGesture {
                                withAnimation {
                                    showSemiCircle = false
                                    isPlusButtonPressed = false
                                    currentRadius = minRadius
                                }
                                activeView = buttonData[index].view
                            }
                        }
                    }
                    .frame(height: 96)

                    Rectangle()
                        .fill(Styles.secondaryBackground)
                        .frame(height: 96)
                        .shadow(radius: 5)

                    HStack {
                        navButton(icon: "book", label: "Today", tab: .today)
                        navButton(icon: "clock", label: "Past", tab: .past)
                        Spacer().frame(width: 80)
                        navButton(icon: "chart.bar", label: "Progress", tab: .progress)
                        navButton(icon: "gear", label: "Settings", tab: .settings)
                    }
                    .padding(.horizontal, 15)
                    .frame(maxWidth: .infinity)
                    .offset(y: -10)

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

            if let _ = activeView {
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
                    activeView: $activeView,
                    diaryEntries: $diaryEntries
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Styles.primaryBackground)
        .ignoresSafeArea(edges: .bottom)
    }

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

    private func saveWeighIn(time: String, weight: String) {
        DispatchQueue.main.async {
            weighIns.append(WeighIn(time: time, weight: weight)) // Updated to use WeighIn
        }
    }
}

struct FullScreenOverlay: View {
    let closeAction: () -> Void
    let saveWeighIn: (String, String) -> Void
    @Binding var isPlusButtonPressed: Bool
    @Binding var showSemiCircle: Bool
    @Binding var currentRadius: CGFloat
    @Binding var fadeOut: Bool
    @Binding var activeView: DashboardView.ActiveView?
    @Binding var diaryEntries: [DiaryEntry]
    
    var body: some View {
        ZStack {
            Color.black.opacity(fadeOut ? 0 : 0.5)
                .animation(.easeOut(duration: 0.5), value: fadeOut)
                .edgesIgnoringSafeArea(.all)

            if let activeView = activeView {
                VStack(spacing: 0) {
                    switch activeView {
                    case .addFood:
                        AddFoodView(closeAction: closeWithAnimation, diaryEntries: $diaryEntries)
                    case .addWater:
                        AddWaterView(closeAction: closeWithAnimation, diaryEntries: $diaryEntries)
                    case .weighIn:
                        WeighInView(closeAction: closeWithAnimation, saveWeighIn: saveWeighIn, fadeOut: $fadeOut)
                    case .addWorkout:
                        WorkoutView(closeAction: closeWithAnimation, diaryEntries: $diaryEntries)
                    }
                }
            }
        }
    }

    private func closeWithAnimation() {
        withAnimation {
            fadeOut = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                activeView = nil
                fadeOut = false
            }
        }
    }
}
