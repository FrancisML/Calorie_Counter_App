import SwiftUI

struct ADVWorkoutAddView: View {
    @Binding var diaryEntries: [DiaryEntry] // ✅ Binding to update diary when saving workouts
    var closeAction: () -> Void // ✅ Function to close `WorkoutView`

    @State private var selectedWorkout: (name: String, image: String)? = nil // ✅ Tracks selected workout
    
    @State private var recentWorkouts: [(name: String, image: String)] = [
        ("Running", "Running"),
        ("Weight Training", "Weights"),
        ("Swimming", "Swiming"),
        ("Cycling", "Bikeing")
    ] // ✅ Example recent workouts (Can be dynamically updated)

    let workoutOptions: [(name: String, image: String)] = [
        ("Abs", "ABS"), ("Badminton", "ShuttleCock"), ("Baseball", "Baseball"),
        ("Basketball", "Basketball"), ("Boxing", "Boxing"), ("Calisthenics", "calisthenics"),
        ("Cross-Country Skiing", "XSkiing"), ("Cycling", "Bikeing"), ("Elliptical", "Eliptical"),
        ("Golf", "Golf"), ("Hiking", "Hiking"), ("Hockey", "Hockey"),
        ("Jogging", "Running"), ("Mountain Biking", "MountainBike"),
        ("Paddle Boarding", "Paddle"), ("Pickleball", "Pickle"), ("Pilates", "Pilates"),
        ("Racquetball", "racquetball"), ("Rock Climbing", "Rockclimbing"),
        ("Rowing", "Rowing"), ("Running", "Running"), ("Scuba Diving", "scuba"),
        ("Skiing", "Skiing"), ("Snowboarding", "Snowboarding"), ("Soccer", "Soccer"),
        ("Spinning", "Spining"), ("Squash", "racquetball"), ("Swimming", "Swiming"),
        ("Tennis", "tennis"), ("Volleyball", "volley"), ("Walking", "Walking"),
        ("Weight Training", "Weights"), ("Yoga", "Yoga"), ("Zumba", "Zumba")
    ].sorted { $0.name < $1.name } // ✅ Sorted alphabetically

    var body: some View {
        VStack {
            // ✅ If a workout is selected, show `ActivityStatsView`
            if let workout = selectedWorkout {
                ActivityStatsView(
                    activityName: workout.name,
                    activityImage: workout.image,
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

                // ✅ Recent Workouts Row (4 per row)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 4), spacing: 15) {
                    ForEach(recentWorkouts, id: \.name) { workout in
                        workoutButton(name: workout.name, image: workout.image, backgroundColor: Styles.tertiaryBackground)
                    }
                }
                .padding(.horizontal, 15)
                .padding(.bottom, 10)
            }

            // ✅ FAVORITES BUTTON
            Button(action: {
                print("Favorites tapped!") // ✅ Replace with action
            }) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow) // ✅ Star icon
                        .font(.title2)

                    Text("Favorites")
                        .font(.headline)
                        .foregroundColor(Styles.primaryText)

                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Styles.primaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 2)
            }
            .padding(.horizontal, 15)
            .padding(.top, 10)

            // ✅ WORKOUT LIST SECTION
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 4), spacing: 15) {
                    ForEach(workoutOptions, id: \.name) { workout in
                        workoutButton(name: workout.name, image: workout.image, backgroundColor: Styles.primaryBackground)
                    }
                }
                .padding(.horizontal, 15)
                .padding(.top, 10)
            }
        }
    }

    // ✅ Workout Button (Grid Layout)
    private func workoutButton(name: String, image: String, backgroundColor: Color) -> some View {
        VStack {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)

            Text(name)
                .font(.caption)
                .foregroundColor(Styles.primaryText)
                .multilineTextAlignment(.center)
        }
        .frame(width: 90, height: 120)
        .background(backgroundColor) // ✅ Recents have tertiary background, others have primary
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(radius: 2)
        .onTapGesture {
            selectedWorkout = (name, image) // ✅ Set the selected workout
        }
    }
}
