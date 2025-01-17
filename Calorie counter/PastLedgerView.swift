//
//  PastLedgerView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/13/25.
//

import SwiftUI
import CoreData

struct PastLedgerView: View {
    @FetchRequest(
        entity: DailyProgress.entity(),
        sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)]
    ) var dailyProgresses: FetchedResults<DailyProgress>

    @FetchRequest(
        entity: ProgressPicture.entity(),
        sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)]
    ) var progressPictures: FetchedResults<ProgressPicture>
    
    @State private var selectedProgress: DailyProgress? = nil
    @State private var selectedProgressPicture: ProgressPicture? = nil
    @State private var isAddingNewPicture = false
    @ObservedObject var userProfile: UserProfile

    private var totalCalories: Int {
        dailyProgresses.reduce(0) { $0 + Int($1.calorieIntake) }
    }

    private var progress: CGFloat {
        guard userProfile.goalCalories > 0 else { return 0 }
        return min(CGFloat(totalCalories) / CGFloat(userProfile.goalCalories), 1.0)
    }

    var body: some View {
        NavigationView {
            VStack {
                
                VStack {
                    HStack{
                        Text("Calories burned")
                        .padding([.leading, .bottom], 20)
                        Spacer()
                    }
                    
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 20)
                            .cornerRadius(10)

                        Rectangle()
                            .fill(progress >= 1.0 ? Color.green : Color.blue)
                            .frame(width: UIScreen.main.bounds.width * progress, height: 20)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    HStack {
                        Spacer()
                        Text("\(totalCalories) / \(userProfile.goalCalories) cal")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 10)

                // Progress Pictures Component
                VStack {
                    HStack(spacing: 0) {
                        ProgressImage(imageData: mostRecentSetupPicture, placeholder: emptyProfilePlaceholder)
                        ProgressImage(imageData: mostRecentProgressPicture, placeholder: emptyProfilePlaceholder)
                    }

                    HStack {
                        Button("+ New Progress Pic") {
                            isAddingNewPicture = true
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        
                        Button("Past Progress") {
                            selectedProgressPicture = nil // Reset before navigating
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                }
                .padding()
                
                Divider()
                
                // Daily Progress List
                if dailyProgresses.isEmpty {
                    Text("No past records yet.")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(dailyProgresses) { progress in
                            Button(action: {
                                selectedProgress = progress
                            }) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Day \(progress.dayNumber)")
                                        .font(.headline)
                                    Text(progress.date?.formatted() ?? "Unknown Date")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text("Calories: \(progress.calorieIntake) / \(progress.dailyLimit)")
                                        .font(.caption)
                                    Text("Status: \(progress.passOrFail ?? "N/A")")
                                        .font(.caption)
                                        .foregroundColor(progress.passOrFail == "Pass" ? .green : .red)
                                }
                                .padding(.vertical, 5)
                            }
                            .listRowBackground(progress.passOrFail == "Pass" ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                        }
                    }
                    .listStyle(PlainListStyle())
                        .onAppear {
                            print("Fetched Daily Progresses:")
                            for progress in dailyProgresses {
                                print("""
                                    Day: \(progress.dayNumber)
                                    Date: \(progress.date?.formatted() ?? "Unknown Date")
                                    Calorie Intake: \(progress.calorieIntake)
                                    Daily Limit: \(progress.dailyLimit)
                                    Pass/Fail: \(progress.passOrFail ?? "N/A")
                                    """)
                            }
                        }
                    }

            }
            .navigationTitle("Progress")
            .sheet(isPresented: $isAddingNewPicture) {
                AddProgressPictureView()
            }
            .sheet(item: $selectedProgress) { progress in
                PastDailyLedgerView(dailyProgress: progress)
            }
            .sheet(item: $selectedProgressPicture) { picture in
                ProgressPictureDetailView(progressPicture: picture)
            }
        }
    }
    
    // Placeholder and Progress Picture Logic
    private var emptyProfilePlaceholder: UIImage {
        if let gender = userProfile.gender?.lowercased(), gender == "woman" {
            return UIImage(named: "Empty woman PP") ?? UIImage()
        } else {
            return UIImage(named: "Empty man PP") ?? UIImage()
        }
    }
    
    private var mostRecentSetupPicture: Data? {
        userProfile.startPicture
    }
    
    private var mostRecentProgressPicture: Data? {
        progressPictures.first?.imageData
    }
}

// MARK: - PrimaryButtonStyle
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(configuration.isPressed ? Color.blue.opacity(0.7) : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}



