////
////  PastLedgerView.swift
////  Calorie counter
////
////  Created by frank lasalvia on 1/13/25.
////
//import Charts
//import SwiftUI
//import CoreData
//
//struct WeightData: Identifiable {
//    let id = UUID()
//    let day: Int
//    let weight: Int
//}
//
//struct PastLedgerView: View {
//    @FetchRequest(
//        entity: DailyProgress.entity(),
//        sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)]
//    ) var dailyProgresses: FetchedResults<DailyProgress>
//    
//    @FetchRequest(
//        entity: ProgressPicture.entity(),
//        sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)]
//    ) var progressPictures: FetchedResults<ProgressPicture>
//    
//    @State private var selectedProgress: DailyProgress? = nil
//    @State private var selectedProgressPicture: ProgressPicture? = nil
//    @State private var isAddingNewPicture = false
//    @ObservedObject var userProfile: UserProfile
//    
//    private var totalCalories: Int {
//        dailyProgresses.reduce(0) { $0 + Int($1.dailyCalDeficit) }
//    }
//    
//    private var progress: CGFloat {
//        guard userProfile.goalCalories > 0 else { return 0 }
//        return min(CGFloat(totalCalories) / CGFloat(userProfile.goalCalories), 1.0)
//    }
//    
//    private var weightData: [WeightData] {
//        dailyProgresses.map { progress in
//            WeightData(day: Int(progress.dayNumber), weight: Int(progress.dailyWeight > 0 ? progress.dailyWeight : userProfile.weight))
//        }
//    }
//    
//    private var weightDomain: ClosedRange<Double> {
//        let minWeight = weightData.map(\.weight).min() ?? 0
//        let maxWeight = weightData.map(\.weight).max() ?? 0
//        return Double(minWeight)...Double(maxWeight)
//    }
//    
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                VStack {
//                    VStack(alignment: .leading) {
//                        Text("Weight Over Time")
//                            .font(.headline)
//                            .padding(.leading, 20)
//                        
//                        Chart {
//                            ForEach(weightData) { data in
//                                LineMark(
//                                    x: .value("Day", data.day),
//                                    y: .value("Weight", data.weight)
//                                )
//                                .symbol(Circle())
//                                .foregroundStyle(.blue)
//                            }
//                        }
//                        .chartYScale(domain: weightDomain)
//                        .chartXAxisLabel("Day")
//                        .chartYAxisLabel("Weight")
//                        .padding(.horizontal)
//                        .frame(height: 200)
//                    }
//                    .padding(.bottom, 20)
//                    
//                    Divider()
//                    
//                    VStack {
//                        HStack {
//                            Text("Total Calories Burned")
//                                .padding([.top, .leading, .bottom], 20)
//                            Spacer()
//                        }
//                        
//                        ZStack(alignment: .leading) {
//                            GeometryReader { geometry in
//                                let barWidth = geometry.size.width
//                                
//                                Rectangle()
//                                    .fill(Color.gray.opacity(0.2))
//                                    .frame(height: 40)
//                                    .cornerRadius(10)
//                                
//                                Rectangle()
//                                    .fill(progress >= 1.0 ? Color.green : Color.blue)
//                                    .frame(width: min(CGFloat(progress) * barWidth, barWidth), height: 40)
//                                    .cornerRadius(10)
//                            }
//                            .frame(height: 40)
//                        }
//                        .padding(.horizontal)
//                        
//                        HStack {
//                            Spacer()
//                            Text("\(totalCalories) / \(userProfile.goalCalories) cal")
//                                .font(.subheadline)
//                                .foregroundColor(.gray)
//                        }
//                        .padding(.horizontal)
//                    }
//                    .padding(.bottom, 10)
//                    
//                    VStack {
//                        HStack(spacing: 0) {
//                            ProgressImage(imageData: mostRecentSetupPicture, placeholder: emptyProfilePlaceholder)
//                            ProgressImage(imageData: mostRecentProgressPicture, placeholder: emptyProfilePlaceholder)
//                        }
//                        
//                        HStack {
//                            Button("+ New Progress Pic") {
//                                isAddingNewPicture = true
//                            }
//                            .buttonStyle(PrimaryButtonStyle())
//                            
//                            Button("Past Progress") {
//                                selectedProgressPicture = nil
//                            }
//                            .buttonStyle(PrimaryButtonStyle())
//                        }
//                    }
//                    .padding()
//                    
//                    Divider()
//                    
//                    VStack(alignment: .leading, spacing: 10) {
//                        if dailyProgresses.isEmpty {
//                            Text("No past records yet.")
//                                .font(.headline)
//                                .foregroundColor(.gray)
//                                .padding()
//                            Divider()
//                        } else {
//                            Text("Previous Days")
//                                .font(.headline)
//                                .foregroundColor(.white)
//                                .padding()
//                            Divider()
//                            
//                            ForEach(dailyProgresses) { progress in
//                                Button(action: {
//                                    selectedProgress = progress
//                                }) {
//                                    HStack(alignment: .center, spacing: 15) {
//                                        VStack(alignment: .leading, spacing: 5) {
//                                            Text("Day \(progress.dayNumber)")
//                                                .font(.title)
//                                                .foregroundColor(.white)
//                                                .fontWeight(.bold)
//                                                .padding()
//                                            Text(progress.date?.formatted(.dateTime.year().month().day()) ?? "Unknown Date")
//                                                .font(.subheadline)
//                                                .foregroundColor(.gray)
//                                        }
//                                        
//                                        VStack(alignment: .center, spacing: 5) {
//                                            Text("Calories: \(progress.calorieIntake) / \(progress.dailyLimit)")
//                                                .font(.caption)
//                                            Text("Calorie Deficit: \(progress.dailyCalDeficit)")
//                                                .font(.caption)
//                                                .foregroundColor(progress.dailyCalDeficit < 0 ? .red : .blue)
//                                            Text("Weight: \(progress.dailyWeight > 0 ? progress.dailyWeight : userProfile.weight) lbs")
//                                                .font(.caption)
//                                                .foregroundColor(.gray)
//                                        }
//                                        .frame(maxWidth: .infinity, alignment: .center)
//                                        .multilineTextAlignment(.center)
//                                        
//                                        VStack {
//                                            Text(progress.passOrFail ?? "Fail")
//                                                .font(.title)
//                                                .fontWeight(.bold)
//                                                .foregroundColor(progress.passOrFail == "Pass" ? .green : .red)
//                                                .padding()
//                                        }
//                                        .frame(maxHeight: .infinity)
//                                    }
//                                    .padding(.vertical, 10)
//                                    .background(progress.passOrFail == "Pass" ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
//                                    .cornerRadius(10)
//                                }
//                            }
//                        }
//                    }
//                    .padding(.horizontal)
//                }
//            }
//            .toolbar {
//                ToolbarItem(placement: .principal) {
//                    Text("Progress")
//                        .font(.system(size: 30, weight: .bold))
//                        .accessibilityAddTraits(.isHeader)
//                }
//            }
//            .sheet(isPresented: $isAddingNewPicture) {
//                AddProgressPictureView()
//            }
//            .sheet(item: $selectedProgress) { progress in
//                PastDailyLedgerView(dailyProgress: progress)
//            }
//            .sheet(item: $selectedProgressPicture) { picture in
//                ProgressPictureDetailView(progressPicture: picture)
//            }
//        }
//    }
//    
//    private var emptyProfilePlaceholder: UIImage {
//        if let gender = userProfile.gender?.lowercased(), gender == "woman" {
//            return UIImage(named: "Empty woman PP") ?? UIImage()
//        } else {
//            return UIImage(named: "Empty man PP") ?? UIImage()
//        }
//    }
//    
//    private var mostRecentSetupPicture: Data? {
//        userProfile.startPicture
//    }
//    
//    private var mostRecentProgressPicture: Data? {
//        progressPictures.first?.imageData
//    }
//}
//
//struct PrimaryButtonStyle: ButtonStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .padding()
//            .frame(maxWidth: .infinity)
//            .background(configuration.isPressed ? Color.blue.opacity(0.7) : Color.blue)
//            .foregroundColor(.white)
//            .cornerRadius(10)
//            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
//    }
//}
//
//
//
