//
//  DashboardView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/12/25.
//

import SwiftUI

struct DashboardView: View {
    @State private var selectedTab: Tab = .today // Tracks the active tab
    @State private var isPlusButtonPressed: Bool = false // Tracks press state for "+" button

    enum Tab {
        case today, past, progress, settings
    }

    var body: some View {
        VStack {
            Spacer()

            // Content of the DashboardView
            Text("Welcome to Your Dashboard!") // Replace with views for each tab
                .font(.largeTitle)
                .foregroundColor(Styles.primaryText)
                .padding()

            Spacer()

            // Bottom Navigation Bar
            ZStack {
                // Background Bar
                Rectangle()
                    .fill(Styles.secondaryBackground)
                    .frame(height: 96)
                    .shadow(radius: 5)

                HStack {
                    // Left-side buttons
                    navButton(icon: "book", label: "Today", tab: .today)
                        .frame(maxWidth: .infinity)
                    navButton(icon: "clock", label: "Past", tab: .past)
                        .frame(maxWidth: .infinity)

                    Spacer()
                        .frame(width: 80) // Same width as the "+" button

                    // Right-side buttons
                    navButton(icon: "chart.bar", label: "Progress", tab: .progress)
                        .frame(maxWidth: .infinity)
                    navButton(icon: "gear", label: "Settings", tab: .settings)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 15)
                .frame(maxWidth: .infinity)
                .offset(y: -10) // Move buttons up by 30%

                // Center "+" Button (Sticking out)
                VStack {
                    ZStack {
                        Circle()
                            .fill(isPlusButtonPressed ? Styles.secondaryText : Styles.primaryText) // ✅ Uses primaryText and secondaryText
                            .frame(width: 80, height: 80)
                            .shadow(radius: 5)

                        Image(systemName: "plus")
                            .font(.largeTitle)
                            .foregroundColor(Styles.secondaryBackground) // Keeps contrast
                    }
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                withAnimation(nil) { isPlusButtonPressed = true } // ✅ Instantly switch to secondaryText
                            }
                            .onEnded { _ in
                                withAnimation(.easeOut(duration: 0.2)) { isPlusButtonPressed = false } // ✅ Smooth transition back
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

    // Navigation Button View with Active State (Now Orange When Active)
    private func navButton(icon: String, label: String, tab: Tab) -> some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.title) // 20% bigger icon
                .frame(width: 30, height: 30)
                .foregroundColor(selectedTab == tab ? .orange : Styles.secondaryText) // ✅ Active buttons are now ORANGE
            Text(label)
                .font(.caption2)
                .foregroundColor(selectedTab == tab ? .orange : Styles.secondaryText) // ✅ Text also turns orange when active
        }
        .onTapGesture {
            selectedTab = tab
        }
    }
}
