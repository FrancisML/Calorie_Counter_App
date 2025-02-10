//
//  DashboardView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/12/25.
//

import SwiftUI

struct DashboardView: View {
    @State private var selectedTab: Tab = .today // Default view is "Today"
    @State private var isPlusButtonPressed: Bool = false // Tracks press state for "+" button

    enum Tab {
        case today, past, progress, settings
    }

    var body: some View {
        VStack(spacing: 0) {
            // MAIN CONTENT AREA (FULL SCREEN EXCEPT NAV BAR)
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
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Takes up full screen except nav

            // BOTTOM NAVIGATION BAR
            ZStack {
                // Background Bar
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
                .offset(y: -10) // Moves buttons up by 30%

                // Center "+" Button (Sticking out)
                VStack {
                    ZStack {
                        Circle()
                            .fill(isPlusButtonPressed ? Styles.secondaryText : Styles.primaryText)
                            .frame(width: 80, height: 80)
                            .shadow(radius: 5)

                        Image(systemName: "plus")
                            .font(.largeTitle)
                            .foregroundColor(Styles.secondaryBackground)
                    }
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                withAnimation(nil) { isPlusButtonPressed = true }
                            }
                            .onEnded { _ in
                                withAnimation(.easeOut(duration: 0.2)) { isPlusButtonPressed = false }
                                selectedTab = .today
                            }
                    )
                    .offset(y: -36) // Adjusted to fit new bar height
                }
            }
            .frame(height: 96)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Styles.primaryBackground)
        .ignoresSafeArea(edges: .bottom)
    }

    // Navigation Button View (Now switches views)
    private func navButton(icon: String, label: String, tab: Tab) -> some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.title)
                .frame(width: 30, height: 30)
                .foregroundColor(selectedTab == tab ? .orange : Styles.secondaryText) // Active tab turns orange

            Text(label)
                .font(.caption2)
                .foregroundColor(selectedTab == tab ? .orange : Styles.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .onTapGesture {
            selectedTab = tab // ✅ Switch to selected tab's view
        }
    }
}
