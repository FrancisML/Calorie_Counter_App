import SwiftUI
import CoreData

struct ADVWorkoutAddView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var diaryEntries: [DiaryEntry] // ✅ Binding to update diary when saving workouts
    var closeAction: () -> Void // ✅ Function to close `WorkoutView`
    
    @State private var selectedWorkout: ActivityModel? = nil // ✅ Stores selected activity
    @State private var showingFavorites: Bool = false // ✅ Toggles favorite workouts view

    // ✅ Fetching all activities from Core Data
    @FetchRequest(
        entity: ActivityModel.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ActivityModel.name, ascending: true)]
    ) private var activities: FetchedResults<ActivityModel>

    var body: some View {
        VStack {
            // ✅ If a workout is selected, show `ActivityStatsView`
            if let workout = selectedWorkout {
                ActivityStatsView(
                    activityName: workout.name ?? "Unknown",
                    activityImage: workout.imageName ?? "default_image",
                    closeAction: closeAction, // ✅ Passes closeAction() from WorkoutView
                    diaryEntries: $diaryEntries
                )
            } else {
                workoutSelectionView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Styles.secondaryBackground)
    }

    // ✅ Workout Selection View
    private func workoutSelectionView() -> some View {
        VStack {
            // ✅ RECENTS SECTION
            VStack(alignment: .leading) {
                Text("Recents")
                    .font(.headline)
                    .foregroundColor(Styles.primaryText)
                    .padding(.leading, 15)
                    .padding(.top, 10)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 4), spacing: 15) {
                    ForEach(recentWorkouts(), id: \.id) { workout in
                        workoutButton(activity: workout, backgroundColor: Styles.tertiaryBackground)
                    }
                }
                .padding(.horizontal, 15)
                .padding(.bottom, 10)
            }

            // ✅ FAVORITES TOGGLE BUTTON
            Button(action: {
                showingFavorites.toggle() // ✅ Toggle favorites mode
            }) {
                HStack {
                    Image(systemName: showingFavorites ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                        .font(.title2)

                    Text("Favorites")
                        .font(.headline)
                        .foregroundColor(Styles.primaryText)

                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(showingFavorites ? Styles.tertiaryBackground : Styles.primaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 2)
            }
            .padding(.horizontal, 15)
            .padding(.top, 10)

            // ✅ WORKOUT LIST SECTION
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 4), spacing: 15) {
                    ForEach(filteredWorkouts(), id: \.id) { workout in
                        workoutButton(activity: workout, backgroundColor: Styles.primaryBackground)
                    }
                }
                .padding(.horizontal, 15)
                .padding(.top, 10)
            }
        }
    }

    // ✅ Filtered workouts based on favorites toggle
    private func filteredWorkouts() -> [ActivityModel] {
        return showingFavorites
            ? activities.filter { $0.isFavorite }
            : Array(activities)
    }

    // ✅ Workout Button (Grid Layout)
    private func workoutButton(activity: ActivityModel, backgroundColor: Color) -> some View {
        VStack {
            Image(activity.imageName ?? "default_image")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)

            Text(activity.name ?? "Unknown")
                .font(.caption)
                .foregroundColor(Styles.primaryText)
                .multilineTextAlignment(.center)
        }
        .frame(width: 90, height: 120)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(radius: 2)
        .onTapGesture {
            selectedWorkout = activity
        }
    }

    // ✅ Get recent workouts (sorted by `lastUsed` descending, limiting to 4)
    private func recentWorkouts() -> [ActivityModel] {
        return activities
            .filter { $0.lastUsed != nil }
            .sorted { $0.lastUsed! > $1.lastUsed! }
            .prefix(4)
            .map { $0 }
    }
}
