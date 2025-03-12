import SwiftUI
import CoreData

struct ADVWorkoutAddView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var diaryEntries: [DiaryEntry]
    var closeAction: () -> Void
    
    @State private var selectedWorkout: ActivityModel? = nil
    @State private var showingFavorites: Bool = false
    @State private var searchText: String = ""
    @State private var showCustomPopup: Bool = false
    
    // Popup fields
    @State private var customName: String = ""
    @State private var customMET: Double = 5.0 // Slider value
    @State private var metInput: String = "5.0" // TextField value
    @State private var selectedImageName: String = "CustomActivity" // Default to CustomActivity
    @State private var showingImagePicker: Bool = false // Toggle image selection mode
    
    @FetchRequest(
        entity: ActivityModel.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ActivityModel.name, ascending: true)]
    ) private var activities: FetchedResults<ActivityModel>
    
    var body: some View {
        VStack(spacing: 0) {
            if let workout = selectedWorkout {
                ActivityStatsView(
                    activityName: workout.name ?? "Unknown",
                    activityImage: workout.imageName ?? "default_image",
                    closeAction: closeAction,
                    diaryEntries: $diaryEntries
                )
            } else {
                workoutSelectionView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Styles.secondaryBackground)
        .overlay(
            Group {
                if showCustomPopup {
                    customActivityPopup()
                }
            }
        )
    }
    
    private func workoutSelectionView() -> some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Styles.secondaryText)
                TextField("Search workouts...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(Styles.primaryText)
                    .submitLabel(.search)
            }
            .padding(12)
            .background(Styles.primaryBackground.opacity(0.3))
            .clipShape(Capsule())
            .padding(.horizontal, 15)
            .padding(.top, 10)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading) {
                        Text("Recents")
                            .font(.headline)
                            .foregroundColor(Styles.primaryText)
                            .padding(.leading, 15)
                            .padding(.top, 10)
                        
                        if recentWorkouts().isEmpty {
                            Text("No recent workouts")
                                .font(.subheadline)
                                .foregroundColor(Styles.secondaryText)
                                .padding(.leading, 15)
                                .padding(.bottom, 10)
                        } else {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 4), spacing: 15) {
                                ForEach(recentWorkouts(), id: \.id) { workout in
                                    workoutButton(activity: workout, backgroundColor: Styles.tertiaryBackground)
                                }
                            }
                            .padding(.horizontal, 15)
                            .padding(.bottom, 10)
                        }
                    }
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showingFavorites.toggle()
                        }
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
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(showingFavorites ? Color.yellow.opacity(0.5) : Color.clear, lineWidth: 2)
                        )
                    }
                    .padding(.horizontal, 15)
                    .padding(.top, 10)
                    .accessibilityLabel("Toggle favorite workouts")
                    
                    let filtered = filteredWorkouts()
                    if filtered.isEmpty && searchText.isEmpty {
                        Text(showingFavorites ? "No favorite workouts" : "No workouts available")
                            .font(.subheadline)
                            .foregroundColor(Styles.secondaryText)
                            .padding(.top, 20)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 4), spacing: 15) {
                            addCustomActivityButton()
                            ForEach(filtered, id: \.id) { workout in
                                workoutButton(activity: workout, backgroundColor: Styles.primaryBackground)
                            }
                        }
                        .padding(.horizontal, 15)
                        .padding(.top, 10)
                    }
                }
            }
        }
    }
    
    private func filteredWorkouts() -> [ActivityModel] {
        let filtered = showingFavorites ? activities.filter { $0.isFavorite } : Array(activities)
        if searchText.isEmpty {
            return filtered
        } else {
            return filtered.filter { $0.name?.lowercased().contains(searchText.lowercased()) ?? false }
        }
    }
    
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
                .lineLimit(2)
        }
        .frame(width: 90, height: 120)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(radius: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.blue.opacity(selectedWorkout == activity ? 1 : 0), lineWidth: 2)
        )
        .scaleEffect(selectedWorkout == activity ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: selectedWorkout)
        .onTapGesture {
            withAnimation {
                selectedWorkout = activity
            }
        }
        .accessibilityLabel("Workout: \(activity.name ?? "Unknown")")
    }
    
    private func addCustomActivityButton() -> some View {
        VStack {
            Image("AddCustom")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
            Text("Add Custom Activity")
                .font(.caption)
                .foregroundColor(Styles.primaryText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 90, height: 120)
        .background(Styles.tertiaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(radius: 2)
        .onTapGesture {
            showCustomPopup = true
            customName = ""
            customMET = 5.0
            metInput = "5.0"
            selectedImageName = "CustomActivity"
            showingImagePicker = false
        }
        .accessibilityLabel("Add Custom Activity")
    }
    
    private func recentWorkouts() -> [ActivityModel] {
        return activities
            .filter { $0.lastUsed != nil }
            .sorted { $0.lastUsed! > $1.lastUsed! }
            .prefix(4)
            .map { $0 }
    }
    
    private func customActivityPopup() -> some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    showCustomPopup = false
                }
            
            VStack(spacing: 25) {
                Text("Add Custom Activity")
                    .font(.headline)
                    .foregroundColor(Styles.primaryText)
                    .padding(.bottom, 5)
                
                if showingImagePicker {
                    // Image picker mode
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 4), spacing: 15) {
                            ForEach(activities.filter { !$0.isCustom }, id: \.id) { activity in
                                imageButton(activity: activity)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxHeight: 200)
                    
                    Button("Back") {
                        showingImagePicker = false
                    }
                    .foregroundColor(Styles.primaryText)
                    .padding()
                } else {
                    // Default popup content
                    HStack(spacing: 10) {
                        Image(selectedImageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .padding(8)
                            .background(Styles.secondaryBackground)
                            .shadow(radius: 2)
                            .onTapGesture {
                                showingImagePicker = true
                            }
                            .accessibilityLabel("Select activity image")
                        
                        ZStack(alignment: .leading) {
                            // Placeholder text
                            if customName.isEmpty {
                                Text("Activity Name")
                                    .foregroundColor(Styles.primaryText.opacity(0.7)) // Explicitly primaryText for placeholder
                                    .font(.body) // Match TextField font size
                                    .padding(.leading, 8)
                                    .allowsHitTesting(false) // Ensure it doesn’t block input
                            }
                            
                            // TextField with no placeholder string
                            TextField("", text: $customName)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(8)
                                .background(Styles.secondaryBackground)
                                .foregroundColor(Styles.primaryText) // Typed text color
                                .shadow(radius: 2)
                                .submitLabel(.done) // Optional: improves keyboard UX
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("MET Value")
                            .font(.subheadline)
                            .foregroundColor(Styles.primaryText)
                        
                        TextField(String(format: "%.1f", customMET), text: $metInput)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(8)
                            .background(Styles.secondaryBackground)
                            .foregroundColor(Styles.primaryText)
                            .keyboardType(.decimalPad)
                            .shadow(radius: 2)
                            .onChange(of: metInput) { newValue in
                                if let value = Double(newValue), value >= 1.0, value <= 15.0 {
                                    customMET = value
                                }
                            }
                        
                        Text("Metabolic Equivalent of Task (MET) measures energy cost. 1 MET is resting; higher values mean more effort.")
                            .font(.caption)
                            .foregroundColor(Styles.secondaryText)
                        
                        Slider(value: $customMET, in: 1.0...15.0, step: 0.5)
                            .accentColor(Styles.primaryText)
                            .onChange(of: customMET) { newValue in
                                metInput = String(format: "%.1f", newValue)
                            }
                            .shadow(radius: 2)
                        
                        Text(metExample(for: customMET))
                            .font(.caption)
                            .foregroundColor(Styles.secondaryText)
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .shadow(radius: 2)
                    
                    HStack(spacing: 0) {
                        Button("Cancel") {
                            showCustomPopup = false
                        }
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        
                        Rectangle()
                            .frame(width: 1, height: 20)
                            .foregroundColor(Styles.secondaryText.opacity(0.5))
                            .shadow(radius: 2)
                        
                        Button("Save") {
                            saveCustomActivity()
                            showCustomPopup = false
                        }
                        .foregroundColor(customName.isEmpty || metInput.isEmpty ? Color.gray : Styles.primaryText)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .disabled(customName.isEmpty || metInput.isEmpty)
                    }
                }
            }
            .padding()
            .background(Styles.primaryBackground)
            .shadow(radius: 5)
            .frame(maxWidth: 350)
        }
    }
    
    private func imageButton(activity: ActivityModel) -> some View {
        Image(activity.imageName ?? "default_image")
            .resizable()
            .scaledToFit()
            .frame(width: 50, height: 50)
            .padding(8) // Consistent padding
            .background(Styles.primaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(radius: 2)
            .onTapGesture {
                selectedImageName = activity.imageName ?? "CustomActivity"
                showingImagePicker = false
            }
            .accessibilityLabel("Select \(activity.name ?? "unknown") image")
    }
    
    private func metExample(for met: Double) -> String {
        switch met {
        case 1.0..<2.0: return "Resting, sitting quietly"
        case 2.0..<3.0: return "Light walking, stretching"
        case 3.0..<4.0: return "Brisk walking, light cleaning"
        case 4.0..<6.0: return "Moderate cycling, dancing"
        case 6.0..<8.0: return "Jogging, swimming"
        case 8.0..<10.0: return "Running, heavy lifting"
        case 10.0..<15.0: return "Sprint running, intense sports"
        default: return "Extreme effort (e.g., competitive sprinting)"
        }
    }
    
    private func saveCustomActivity() {
        guard !customName.isEmpty, let metValue = Double(metInput), metValue > 0 else { return }
        
        let newActivity = ActivityModel(context: viewContext)
        newActivity.id = UUID()
        newActivity.name = customName
        newActivity.imageName = selectedImageName
        newActivity.isFavorite = false
        newActivity.lastUsed = nil
        newActivity.isCustom = true
        newActivity.metValue = metValue
        
        do {
            try viewContext.save()
            selectedWorkout = newActivity
            print("✅ Saved custom activity: \(customName) with MET: \(metValue) and image: \(selectedImageName)")
        } catch {
            print("❌ Error saving custom activity: \(error)")
        }
    }
}

struct ADVWorkoutAddView_Previews: PreviewProvider {
    static var previews: some View {
        ADVWorkoutAddView(diaryEntries: .constant([]), closeAction: {})
            .environment(\.managedObjectContext, PersistenceController.shared.context)
    }
}
