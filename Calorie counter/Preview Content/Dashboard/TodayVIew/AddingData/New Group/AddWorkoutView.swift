//
//  AddWorkout.swift
//  Calorie counter
//
//  Created by frank lasalvia on 2/13/25.
//
import SwiftUI

struct WorkoutView: View {
    var closeAction: () -> Void
    @State private var searchText: String = "" // ✅ Search text state
    @State private var selectedTab: WorkoutTab = .quickAdd // ✅ Default to Quick Add

    enum WorkoutTab {
        case quickAdd, advancedAdd
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

                    Text("Add Workout")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Styles.primaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, safeAreaTopInset)

                // ✅ Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Styles.secondaryText)

                    TextField("Search workouts...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(Styles.primaryText)
                }
                .padding(14)
                .frame(maxWidth: .infinity)
                .background(Styles.primaryBackground.opacity(0.3))
                .clipShape(Capsule())
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 16)

                // ✅ Tabs Section
                ZStack {
                    Rectangle()
                        .fill(Styles.secondaryBackground)
                        .frame(width: geometry.size.width, height: 50)
                        .shadow(radius: 2)

                    HStack(spacing: 0) {
                        tabButton(title: "Quick Add", selected: selectedTab == .quickAdd) {
                            selectedTab = .quickAdd
                        }
                        tabButton(title: "Advanced Add", selected: selectedTab == .advancedAdd) {
                            selectedTab = .advancedAdd
                        }
                    }
                    .frame(width: geometry.size.width, height: 50)
                }

                // ✅ Content Area
                VStack {
                    if selectedTab == .quickAdd {
                        QuickWKAddView()
                    } else {
                        ADVWorkoutAddView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // ✅ Final Fixed Bottom Navigation Bar
                bottomNavBar()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Styles.secondaryBackground)
            .edgesIgnoringSafeArea(.all)
        }
    }

    // ✅ Tab Button Component
    private func tabButton(title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Text(title)
            .font(.headline)
            .foregroundColor(selected ? .orange : Styles.primaryText)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(selected ? Color.clear : Styles.primaryBackground.opacity(0.3))
            .onTapGesture {
                withAnimation {
                    action()
                }
            }
    }

    // ✅ Bottom Navigation Bar with Perfected Spacing
    private func bottomNavBar() -> some View {
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

                Spacer().frame(width: 100) // ✅ Adjusted spacing to a sweet spot

                // ➕ "+" Button (Matches Dashboard)
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
            .padding(.horizontal, 30) // ✅ Ensures balanced button spacing
            .frame(maxWidth: .infinity)
            .offset(y: -36) // ✅ Matches dashboard "+" button's position
        }
        .frame(height: 96)
    }
}
