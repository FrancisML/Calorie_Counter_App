//
//  QuickAddView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 2/13/25.
//

//
//  QuickFoodAddView.swift
//  Calorie Counter
//
//  Created by Frank LaSalvia on 2/13/25.
//

import SwiftUI

struct QuickFoodAddView: View {
    @Binding var diaryEntries: [DiaryEntry] // ✅ Binding to update the diary
    var closeAction: () -> Void // ✅ Function to close the view

    @State private var foodImage: UIImage? = UIImage(named: "DefaultFood") // ✅ Default image
    @State private var foodName: String = ""
    @State private var servingSize: String = ""
    @State private var calories: String = ""

    @State private var selectedHour: Int = Calendar.current.component(.hour, from: Date()) % 12
    @State private var selectedMinute: Int = Calendar.current.component(.minute, from: Date())
    @State private var selectedPeriod: String = Calendar.current.component(.hour, from: Date()) >= 12 ? "PM" : "AM"
    @State private var showTimePicker: Bool = false // ✅ Toggles picker visibility

    @State private var showImagePicker: Bool = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showActionSheet: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            // ✅ Top Row: Image + Name Input
            HStack(spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(foodImage != UIImage(named: "DefaultFood") ? Color.green : Styles.primaryText, lineWidth: 3)
                        .frame(width: 100, height: 100)

                    Image(uiImage: foodImage ?? UIImage(named: "DefaultFood")!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    Button(action: {
                        showActionSheet = true
                    }) {
                        Text("Add")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 100, height: 100)
                    }
                    .actionSheet(isPresented: $showActionSheet) {
                        ActionSheet(
                            title: Text("Select Image"),
                            buttons: [
                                .default(Text("Take a Photo")) {
                                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                        imagePickerSourceType = .camera
                                        showImagePicker = true
                                    }
                                },
                                .default(Text("Choose from Library")) {
                                    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                                        imagePickerSourceType = .photoLibrary
                                        showImagePicker = true
                                    }
                                },
                                .destructive(Text("Remove Image")) {
                                    foodImage = UIImage(named: "DefaultFood") // ✅ Reset to default
                                },
                                .cancel()
                            ]
                        )
                    }
                    .sheet(isPresented: $showImagePicker) {
                        ImagePicker(selectedImage: $foodImage, sourceType: imagePickerSourceType)
                    }
                }

                FloatingTextField(placeholder: " Food Name ", text: $foodName)
            }
            .padding(.horizontal)
            .padding(.top, 20)

            // ✅ Other Inputs (Below Image & Name)
            VStack(spacing: 15) {
                FloatingTextField(placeholder: " Serving Size ", text: $servingSize)

                FloatingTextField(placeholder: " Calories ", text: $calories)
                    .keyboardType(.numberPad)
                    .onReceive(calories.publisher.collect()) { newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        let trimmed = String(filtered.prefix(4)) // ✅ Limit to 4 digits (9999 max)
                        if calories != trimmed { calories = trimmed }
                    }

                FloatingInputWithAction(
                    placeholder: " Time ",
                    displayedText: formattedTime,
                    action: { showTimePicker = true },
                    hasPickedValue: .constant(true)
                )
            }
            .padding(.horizontal)

            Spacer()

            // ✅ Bottom Navigation Bar
            bottomNavBar()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Styles.secondaryBackground)
    }

    // ✅ Save Food Entry to Diary
    private func saveFoodToDiary() {
        guard !foodName.isEmpty, !servingSize.isEmpty, !calories.isEmpty else {
            print("⚠️ Missing required fields")
            return
        }
        
        let caloriesValue = Int(calories) ?? 0
        
        let newEntry = DiaryEntry(
            time: formattedTime,
            iconName: foodImage != UIImage(named: "DefaultFood") ? "CustomFood" : "DefaultFood",
            description: foodName,
            detail: servingSize,
            calories: caloriesValue,
            type: "Food",
            imageName: "DefaultFood",
            imageData: foodImage?.jpegData(compressionQuality: 0.8)
        )
        
        DispatchQueue.main.async {
            diaryEntries.append(newEntry)
        }
        
        print("✅ Food Saved: \(newEntry)")
        closeAction()
    }

    // ✅ Automatically sets the current time
    private func setCurrentTime() {
        let currentHour = Calendar.current.component(.hour, from: Date())
        selectedHour = currentHour % 12 == 0 ? 12 : currentHour % 12
        selectedMinute = Calendar.current.component(.minute, from: Date())
        selectedPeriod = currentHour >= 12 ? "PM" : "AM"
    }

    // ✅ Time Formatting for Display
    private var formattedTime: String {
        return "\(selectedHour):\(String(format: "%02d", selectedMinute)) \(selectedPeriod)"
    }

    // ✅ Time Picker (3 Columns: Hours, Minutes, AM/PM)
    private var timePicker: some View {
        HStack {
            Picker("Hour", selection: $selectedHour) {
                ForEach(1...12, id: \.self) { hour in
                    Text("\(hour)")
                        .foregroundColor(Styles.primaryText)
                        .tag(hour)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(width: UIScreen.main.bounds.width * 0.2)
            .clipped()

            Picker("Minutes", selection: $selectedMinute) {
                ForEach(0..<60, id: \.self) { minute in
                    Text("\(String(format: "%02d", minute))")
                        .foregroundColor(Styles.primaryText)
                        .tag(minute)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(width: UIScreen.main.bounds.width * 0.2)
            .clipped()

            Picker("AM/PM", selection: $selectedPeriod) {
                Text("AM")
                    .foregroundColor(Styles.primaryText)
                    .tag("AM")
                Text("PM")
                    .foregroundColor(Styles.primaryText)
                    .tag("PM")
            }
            .pickerStyle(WheelPickerStyle())
            .frame(width: UIScreen.main.bounds.width * 0.2)
            .clipped()
        }
    }
    
    private func bottomNavBar() -> some View {
        ZStack {
            Rectangle()
                .fill(Styles.secondaryBackground)
                .frame(height: 96)
                .shadow(radius: 5)

            HStack(spacing: 0) {
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

                ZStack {
                    Circle()
                        .fill(Styles.primaryText)
                        .frame(width: 80, height: 80)
                        .shadow(radius: 5)

                    Image("BarCode")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                }
                .onTapGesture {
                    print("Barcode Scanner Tapped!") // Replace with functionality
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(Styles.primaryText)
                        .frame(width: 80, height: 80)
                        .shadow(radius: 5)

                    Image(systemName: "plus")
                        .font(.largeTitle)
                        .foregroundColor(Styles.secondaryBackground)
                }
                .onTapGesture {
                    saveFoodToDiary()
                }
            }
            .padding(.horizontal, 30)
            .frame(maxWidth: .infinity)
            .offset(y: -36)
        }
        .frame(height: 96)
    }
}
