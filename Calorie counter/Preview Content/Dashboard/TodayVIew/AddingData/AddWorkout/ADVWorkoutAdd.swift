//
//  ADVWorkoutAdd.swift
//  Calorie counter
//
//  Created by frank lasalvia on 2/18/25.
//
import SwiftUI

struct ADVWorkoutAddView: View {
    @State private var selectedCategory: WorkoutCategory? = nil // ✅ Tracks selected category
    

    enum WorkoutCategory {
        case sports, exercise, outdoors, custom
    }

    var body: some View {
        VStack {
            if let category = selectedCategory {
                if category == .custom {
                    // ✅ Custom Workout View (With "Create" Button in 4-Grid Layout)
                    CustomWorkoutView(goBack: { selectedCategory = nil })
                } else {
                    // ✅ Subcategory View (For Sports, Exercise, Outdoors)
                    SubcategoryView(category: category, goBack: { selectedCategory = nil })
                }
            } else {
                // ✅ Center the 4 Category Buttons on the Screen
                Spacer() // 🔹 Pushes the grid down
                
                GeometryReader { geometry in
                    let buttonSize = (geometry.size.width - 60) / 2  // 🔹 Calculates proper square size
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: 20) {
                        categoryButton(title: "Sports", category: .sports, size: buttonSize)
                        categoryButton(title: "Exercise", category: .exercise, size: buttonSize)
                        categoryButton(title: "Outdoors", category: .outdoors, size: buttonSize)
                        categoryButton(title: "Custom", category: .custom, size: buttonSize)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 20) // ✅ Keeps buttons from touching edges
                }
                .frame(height: 340) // ✅ Ensures GeometryReader has enough height
                
                Spacer() // 🔹 Pushes the grid up
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Styles.secondaryBackground)
        .animation(.easeInOut, value: selectedCategory) // ✅ Smooth transition
    }

    // ✅ Category Button (Perfectly Square & Centered)
    private func categoryButton(title: String, category: WorkoutCategory, size: CGFloat) -> some View {
        Button(action: {
            selectedCategory = category // ✅ Set selected category when tapped
        }) {
            VStack {
                Image("AL-3")
                    .resizable()
                    .scaledToFit()
                    .frame(width: size * 0.6, height: size * 0.6) // 🔹 Scale image properly

                Text(title)
                    .font(.headline)
                    .foregroundColor(Styles.primaryText)
            }
            .frame(width: size, height: size) // ✅ Now a perfect square
            .background(Styles.primaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: 3)
        }
    }
}

// ✅ Custom Workout View (Only "Create" Button in the Grid)
struct CustomWorkoutView: View {
    let goBack: () -> Void // ✅ Function to go back to main categories

    var body: some View {
        VStack {
            // 🔹 Back Button + "Custom Workouts" Title
            HStack {
                Button(action: goBack) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                }

                Spacer()

                Text("Custom Workouts")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Styles.primaryText)

                Spacer()

                // ✅ Empty spacer for alignment
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.clear)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)

            // 🔹 Custom Workout Buttons Layout (Only "Create" Button in the Grid)
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 4), spacing: 20) {
                    // ✅ "Create" Button (First in Row, Aligned for Future Custom Workouts)
                    Button(action: {
                        print("Create Custom Workout")
                    }) {
                        VStack {
                            Image(systemName: "plus")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(Styles.primaryText)

                            Text("Create")
                                .font(.caption)
                                .foregroundColor(Styles.primaryText)
                        }
                        .frame(width: 90, height: 130) // ✅ Matches the subcategory button size
                        .background(Styles.primaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .shadow(radius: 2)
                    }
                }
                .padding(.horizontal, 15) // ✅ Adds more space on sides
                .padding(.top, 10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Styles.secondaryBackground)
    }
}


// ✅ Subcategory View (Scrollable + Title & Back Button)
struct SubcategoryView: View {
    let category: ADVWorkoutAddView.WorkoutCategory
    let goBack: () -> Void // ✅ Function to go back to main categories

    var subcategories: [String] {
        switch category {
        case .sports:
            return ["Baseball", "Tennis", "Volleyball", "Soccer", "Basketball",
                    "Badminton", "Golf", "Hockey", "Pickle ball", "Racquetball",
                    "Squash", "Boxing"]
        case .exercise:
            return ["Walking", "Running", "Jogging", "Elliptical", "Cycling",
                    "Mountain Biking", "Weight Training", "Rowing", "Spinning",
                    "Zumba", "Pilates", "Yoga", "Abs", "Swimming", "Calisthenics"]
        case .outdoors:
            return ["Paddle Boarding", "Hiking", "Rock Climbing", "Cross-Country Skiing",
                    "Skiing", "Snowboarding", "Scuba Diving"]
        case .custom:
            return []
        }
    }

    var categoryTitle: String {
        switch category {
        case .sports: return "Sports"
        case .exercise: return "Exercise"
        case .outdoors: return "Outdoors"
        case .custom: return "Custom"
        }
    }

    var body: some View {
        VStack {
            // 🔹 Back Button + Category Title on the Same Line
            HStack {
                Button(action: goBack) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text(categoryTitle)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Styles.primaryText)
                
                Spacer()
                
                // ✅ Empty spacer for alignment
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.clear)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)

            // 🔹 Scrollable Grid of Subcategory Buttons
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 4), spacing: 20) {
                    ForEach(subcategories, id: \.self) { subcategory in
                        VStack {
                            Image("AL-3")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)

                            Text(subcategory)
                                .font(.caption)
                                .foregroundColor(Styles.primaryText)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: 90, height: 130)
                        .background(Styles.primaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .shadow(radius: 2)
                    }
                }
                .padding(.horizontal, 15) // ✅ Adds more space on sides
                .padding(.top, 10)
            }
        }
        .padding()
    }
}

