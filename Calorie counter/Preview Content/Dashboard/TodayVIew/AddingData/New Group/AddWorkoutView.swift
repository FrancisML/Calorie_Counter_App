//
//  AddWorkout.swift
//  Calorie counter
//
//  Created by frank lasalvia on 2/13/25.
//
import SwiftUI

struct WorkoutView: View {
    var closeAction: () -> Void // ✅ Function to close the entire WorkoutView
    @State private var searchText: String = "" // ✅ Search text state
    @State private var selectedTab: WorkoutTab = .quickAdd // ✅ Default to Quick Add
    @Binding var diaryEntries: [DiaryEntry] // ✅ Ensure this is a binding to update diary

    @State private var isClosing: Bool = false // ✅ Tracks fade-out animation state

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
                        QuickWKAddView(
                            diaryEntries: $diaryEntries,
                            closeAction: triggerClose // ✅ Triggers fade-out before closing
                        )
                    } else {
                        ADVWorkoutAddView(
                            diaryEntries: $diaryEntries,
                            closeAction: triggerClose // ✅ Triggers fade-out before closing
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Styles.secondaryBackground)
            .edgesIgnoringSafeArea(.all)
            .opacity(isClosing ? 0 : 1) // ✅ Smooth fade-out effect
            .animation(.easeOut(duration: 0.25), value: isClosing) // ✅ Faster fade transition
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

   
    // ✅ Helper Function to Format Duration Correctly
    private func formatDuration(_ duration: String) -> String {
        if let minutes = Int(duration), minutes >= 60 {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return remainingMinutes == 0 ? "\(hours) hr" : "\(hours) hr \(remainingMinutes) min"
        }
        return "\(duration) min"
    }

    // ✅ Triggers a **Fast & Continuous Fade-Out** Before Closing
    private func triggerClose() {
        withAnimation {
            isClosing = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { // ✅ Matches fade duration
            closeAction() // ✅ Instantly disappears after fade
        }
    }
}
