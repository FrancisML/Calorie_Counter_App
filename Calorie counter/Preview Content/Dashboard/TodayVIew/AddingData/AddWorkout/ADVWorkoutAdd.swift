import SwiftUI
import CoreData

struct ADVWorkoutAddView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var diaryEntries: [DiaryEntry]
    var closeAction: () -> Void
    
    @State private var selectedWorkout: ActivityModel? = nil
    @State private var showingFavorites: Bool = false
    @State private var showCustomPopup: Bool = false
    
    @State private var customName: String = "Activity Name"
    @State private var customMET: Double = 5.0
    @State private var metInput: String = "5.0"
    @State private var selectedImageName: String = "CustomActivity"
    @State private var showingImagePicker: Bool = false
    
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
                    closeAction: { selectedWorkout = nil },
                    fullCloseAction: closeAction,
                    diaryEntries: $diaryEntries
                )
            } else {
                workoutSelectionView()
                bottomNavBar()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Styles.primaryBackground)
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
            ScrollView(.vertical, showsIndicators: false) {
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
                                    workoutButton(activity: workout, backgroundColor: Styles.tertiaryBackground) // Already tertiaryBackground
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
                        .background(Styles.secondaryBackground) // Changed to secondaryBackground
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
                    if filtered.isEmpty {
                        Text(showingFavorites ? "No favorite workouts" : "No workouts available")
                            .font(.subheadline)
                            .foregroundColor(Styles.secondaryText)
                            .padding(.top, 20)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 4), spacing: 15) {
                            if !showingFavorites {
                                addCustomActivityButton()
                            }
                            ForEach(filtered, id: \.id) { workout in
                                workoutButton(activity: workout, backgroundColor: Styles.secondaryBackground)
                            }
                        }
                        .padding(.horizontal, 15)
                        .padding(.top, 10)
                        .padding(.bottom, 0)
                    }
                }
            }
            .frame(maxHeight: .infinity)
        }
    }
    
    private func bottomNavBar() -> some View {
        ZStack {
            Rectangle()
                .fill(Styles.secondaryBackground)
                .frame(height: 96)
                .shadow(radius: 5)

            HStack {
                Spacer()
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
                Spacer()
            }
            .padding(.horizontal, 30)
            .frame(maxWidth: .infinity)
            .offset(y: -36)
        }
        .frame(height: 96)
    }
    
    private func customActivityPopup() -> some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showCustomPopup = false
                    }
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    VStack(spacing: 25) {
                        Text("Add Custom Activity")
                            .font(.headline)
                            .foregroundColor(Styles.primaryText)
                            .padding(.bottom, 5)
                        
                        if showingImagePicker {
                            VStack(spacing: 25) {
                                Text("Choose image for custom activity")
                                    .font(.subheadline)
                                    .foregroundColor(Styles.primaryText)
                                    .padding(.bottom, 5)
                                
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
                            }
                        } else {
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
                                
                                TextField("", text: $customName)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .padding(8)
                                    .background(Styles.secondaryBackground)
                                    .foregroundColor(Styles.primaryText)
                                    .shadow(radius: 2)
                                    .onTapGesture {
                                        customName = ""
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
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Slider(value: $customMET, in: 1.0...15.0, step: 0.5)
                                    .accentColor(Styles.primaryText)
                                    .onChange(of: customMET) { newValue in
                                        metInput = String(format: "%.1f", newValue)
                                    }
                                    .shadow(radius: 2)
                                
                                Text(metExample(for: customMET))
                                    .font(.caption)
                                    .foregroundColor(Styles.secondaryText)
                                    .fixedSize(horizontal: false, vertical: true)
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
                    
                    Spacer()
                        .frame(height: geometry.size.height / 2 - 60)
                }
            }
        }
    }
    
    private func filteredWorkouts() -> [ActivityModel] {
        showingFavorites ? activities.filter { $0.isFavorite } : Array(activities)
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
                .stroke(backgroundColor == Styles.tertiaryBackground ? Color.gray.opacity(0.5) : Color.blue.opacity(selectedWorkout == activity ? 1 : 0), lineWidth: 2) // Border for tertiaryBackground
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
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.5), lineWidth: 2) // Kept outline
        )
        .onTapGesture {
            showCustomPopup = true
            customName = "Activity Name"
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
    
    private func imageButton(activity: ActivityModel) -> some View {
        Image(activity.imageName ?? "default_image")
            .resizable()
            .scaledToFit()
            .frame(width: 50, height: 50)
            .padding(8)
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
        case 1.0: return "Sitting quietly, resting"
        case 1.5: return "Standing still, light fidgeting"
        case 2.0: return "Slow walking (1-2 mph), light stretching"
        case 2.5: return "Casual walking (2-2.5 mph), light housework"
        case 3.0: return "Brisk walking (3 mph), vacuuming"
        case 3.5: return "Walking 3.5 mph, light gardening"
        case 4.0: return "Fast walking (4 mph), moderate cleaning"
        case 4.5: return "Walking 4.5 mph, dancing (slow)"
        case 5.0: return "Light cycling (10-12 mph), leisurely swimming"
        case 5.5: return "Moderate cycling (12-14 mph), doubles tennis"
        case 6.0: return "Brisk cycling (14-16 mph), jogging (5 mph)"
        case 6.5: return "Running (5.5 mph), singles tennis"
        case 7.0: return "Running (6 mph), heavy gardening"
        case 7.5: return "Running (6.5 mph), circuit training"
        case 8.0: return "Running (7 mph), heavy lifting"
        case 8.5: return "Running (7.5 mph), vigorous aerobics"
        case 9.0: return "Running (8 mph), competitive soccer"
        case 9.5: return "Running (8.5 mph), intense jump rope"
        case 10.0: return "Running (9 mph), heavy manual labor"
        case 10.5: return "Running (9.5 mph), fast swimming"
        case 11.0: return "Running (10 mph), intense cycling (20 mph)"
        case 11.5: return "Running (10.5 mph), competitive basketball"
        case 12.0: return "Running (11 mph), sprint cycling"
        case 12.5: return "Running (11.5 mph), intense martial arts"
        case 13.0: return "Running (12 mph), professional boxing"
        case 13.5: return "Running (12.5 mph), elite sprint training"
        case 14.0: return "Running (13 mph), competitive sprinting"
        case 14.5: return "Running (13.5 mph), extreme sports"
        case 15.0: return "Running (14 mph), maximal effort sprinting"
        default: return "Unknown effort level"
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
