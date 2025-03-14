//
//  AddWorkout.swift
//  Calorie counter
//
//  Created by frank lasalvia on 2/13/25.
//
import SwiftUI
import CoreData

struct WorkoutView: View {
    var closeAction: () -> Void
    @State private var searchText: String = ""
    @State private var selectedTab: WorkoutTab = .quickAdd
    @Binding var diaryEntries: [DiaryEntry]
    @State private var isClosing: Bool = false
    @State private var selectedActivity: ActivityModel? = nil
    @FocusState private var isSearchFocused: Bool

    enum WorkoutTab {
        case quickAdd, advancedAdd
    }

    @FetchRequest(
        entity: ActivityModel.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ActivityModel.name, ascending: true)]
    ) private var activities: FetchedResults<ActivityModel>

    var body: some View {
        GeometryReader { geometry in
            let safeAreaTopInset = geometry.safeAreaInsets.top
            
            VStack(spacing: 0) {
                // Title Bar
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
                
                // Search Bar Section
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Styles.secondaryText)
                        
                        TextField("", text: $searchText, prompt: Text("Search workouts...").foregroundColor(Styles.secondaryText))
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(Styles.primaryText)
                            .submitLabel(.search)
                            .focused($isSearchFocused)
                            .onChange(of: isSearchFocused) { focused in
                                if !focused {
                                    searchText = ""
                                }
                            }
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Styles.secondaryBackground)
                    .clipShape(Capsule())
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 16)
                    
                    // Search Results
                    if !searchText.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Search Results")
                                .font(.headline)
                                .foregroundColor(Styles.primaryText)
                                .padding(.leading, 20)
                                .padding(.top, 10)
                            
                            let filteredActivities = filteredActivities()
                            if filteredActivities.isEmpty {
                                Text("No matching workouts")
                                    .font(.subheadline)
                                    .foregroundColor(Styles.secondaryText)
                                    .padding(.leading, 20)
                                    .padding(.bottom, 10)
                            } else {
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 4), spacing: 15) {
                                    ForEach(filteredActivities.prefix(4), id: \.id) { activity in
                                        workoutButton(activity: activity)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 10)
                            }
                        }
                    }
                }
                .background(Styles.primaryBackground)
                
                // Tabs Section
                ZStack {
                    Rectangle()
                        .fill(Styles.secondaryBackground)
                        .frame(width: geometry.size.width, height: 50)
                        .shadow(radius: 2)
                    
                    HStack(spacing: 0) {
                        tabButton(title: "Quick Add", selected: selectedTab == .quickAdd) {
                            selectedTab = .quickAdd // Instant update
                            withAnimation {
                                selectedActivity = nil
                                searchText = ""
                            }
                        }
                        tabButton(title: "Advanced Add", selected: selectedTab == .advancedAdd) {
                            selectedTab = .advancedAdd // Instant update
                            withAnimation {
                                selectedActivity = nil
                                searchText = ""
                            }
                        }
                    }
                    .frame(width: geometry.size.width, height: 50)
                }

                // Content Area
                VStack {
                    if let activity = selectedActivity {
                        ActivityStatsView(
                            activityName: activity.name ?? "Unknown",
                            activityImage: activity.imageName ?? "default_image",
                            closeAction: { selectedActivity = nil },
                            fullCloseAction: triggerClose,
                            diaryEntries: $diaryEntries
                        )
                    } else if selectedTab == .quickAdd {
                        QuickWKAddView(
                            diaryEntries: $diaryEntries,
                            closeAction: triggerClose
                        )
                    } else {
                        ADVWorkoutAddView(
                            diaryEntries: $diaryEntries,
                            closeAction: triggerClose
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Styles.secondaryBackground)
            .edgesIgnoringSafeArea(.all)
            .opacity(isClosing ? 0 : 1)
            .animation(.easeOut(duration: 0.25), value: isClosing)
            .onTapGesture {
                isSearchFocused = false
            }
        }
    }

    private func tabButton(title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Text(title)
            .font(.headline)
            .fontWeight(selected ? .bold : .regular)
            .foregroundColor(selected ? Styles.primaryText : Styles.secondaryText)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(selected ? Styles.primaryBackground : Styles.secondaryBackground)
            .onTapGesture {
                action()
            }
    }

    private func workoutButton(activity: ActivityModel) -> some View {
        VStack {
            Image(activity.imageName ?? "default_image")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
            Text(activity.name ?? "Unknown")
                .font(.caption)
                .foregroundColor(Styles.primaryText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 90, height: 120)
        .background(Styles.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(radius: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.5), lineWidth: 2)
        )
        .onTapGesture {
            withAnimation {
                selectedActivity = activity
                searchText = ""
                isSearchFocused = false
            }
        }
        .accessibilityLabel("Workout: \(activity.name ?? "Unknown")")
    }

    private func filteredActivities() -> [ActivityModel] {
        if searchText.isEmpty {
            return []
        } else {
            return activities.filter { activity in
                activity.name?.lowercased().contains(searchText.lowercased()) ?? false
            }
        }
    }

    private func formatDuration(_ duration: String) -> String {
        if let minutes = Int(duration), minutes >= 60 {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return remainingMinutes == 0 ? "\(hours) hr" : "\(hours) hr \(remainingMinutes) min"
        }
        return "\(duration) min"
    }

    private func triggerClose() {
        withAnimation {
            isClosing = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            closeAction()
        }
    }
}

struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutView(closeAction: {}, diaryEntries: .constant([]))
            .environment(\.managedObjectContext, PersistenceController.shared.context)
    }
}
