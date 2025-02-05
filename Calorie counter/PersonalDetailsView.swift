//
//  PersonalDetailsView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/29/25.
//

import SwiftUI

struct PersonalDetailsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    @Binding var name: String
    @Binding var gender: String
    @Binding var birthDate: Date?
    @Binding var profilePicture: UIImage?
    @Binding var showDatePicker: Bool
    @Binding var hasPickedDate: Bool
    @Binding var showImagePicker: Bool
    @Binding var imagePickerSourceType: UIImagePickerController.SourceType
    @Binding var showActionSheet: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // Title and Subtitle
            VStack(spacing: 10) {
                Text("Personal Details")
                    .font(.largeTitle)
                    .foregroundColor(Styles.primaryText)
                    .fontWeight(.bold)
                
                Text("Please enter your information as accurately as possible")
                    .font(.subheadline)
                    .foregroundColor(Styles.secondaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
            }
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            
            // Shadow applied only to the container, with size tightly fitting content
            ZStack {
                Styles.secondaryBackground
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5) // Shadow applied here

                VStack(spacing: 20) {
                    // Name Input
                    FloatingTextField(placeholder: " First Name ", text: $name)
                    
                    // Gender Selection
                    HStack(spacing: 20) {
                        Button(action: { gender = "Man" }) {
                            Text("Man")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(gender == "Man" ? Color(red: 0.635, green: 0.824, blue: 1.0) : Styles.primaryBackground.opacity(0.3)) // #A2D2FF
                                .foregroundColor(gender == "Man" ? .gray : Styles.primaryText)  // Gray text when selected
                                .cornerRadius(2)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 2)
                                        .stroke(
                                            gender == "Man" ? Color.green : Styles.primaryText,  // Green stroke if "Man" is selected
                                            lineWidth: gender == "Man" ? 3 : 1                  // Thicker stroke when selected
                                        )
                                )
                        }
                        
                        Button(action: { gender = "Woman" }) {
                            Text("Woman")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(gender == "Woman" ? Color(red: 1.0, green: 0.686, blue: 0.8) : Styles.primaryBackground.opacity(0.3)) // #FFAFCC
                                .foregroundColor(gender == "Woman" ? .gray : Styles.primaryText)  // Gray text when selected
                                .cornerRadius(2)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 2)
                                        .stroke(
                                            gender == "Woman" ? Color.green : Styles.primaryText,  // Green stroke if "Woman" is selected
                                            lineWidth: gender == "Woman" ? 3 : 1                  // Thicker stroke when selected
                                        )
                                )
                        }
                    }

                    
                    // Birth Date Selection
                    FloatingInputWithAction(
                        placeholder: " Birthday ",
                        displayedText: birthDateFormatted,
                        action: { showDatePicker = true },
                        hasPickedValue: $hasPickedDate
                    )
                    
                    // Profile Picture Section
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Add Profile Picture")
                                .foregroundColor(Styles.primaryText)
                                .font(.headline)
                            
                            Text("Optional")
                                .font(.subheadline)
                                .foregroundColor(Styles.secondaryText)
                        }
                        
                        Spacer()
                        
                        ZStack {
                            // Border Circle
                            Circle()
                                .stroke(profilePicture != nil ? Color.green : Styles.primaryText, lineWidth: 3)
                                .frame(width: 100, height: 100)
                            
                            // Background Circle
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 100, height: 100)
                            
                            // Profile Picture
                            if let image = profilePicture {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else {
                                Image("Empty man PP")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            }
                            
                            // Semi-Transparent Overlay
                            Circle()
                                .fill(Color.black.opacity(0.1)) // Semi-transparent grey overlay
                                .frame(width: 100, height: 100)
                            
                            // Add Button with Larger Text
                            Button(action: {
                                showActionSheet = true // Show the action sheet
                            }) {
                                Text("Add")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .frame(width: 100, height: 100)
                                    .background(Color.clear)
                            }
                            .actionSheet(isPresented: $showActionSheet) {
                                ActionSheet(
                                    title: Text("Select Profile Picture"),
                                    buttons: [
                                        .default(Text("Take a Photo")) {
                                            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                                imagePickerSourceType = .camera
                                                showImagePicker = true // Open the image picker
                                            }
                                        },
                                        .default(Text("Choose from Library")) {
                                            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                                                imagePickerSourceType = .photoLibrary
                                                showImagePicker = true // Open the image picker
                                            }
                                        },
                                        .cancel()
                                    ]
                                )
                            }
                            .sheet(isPresented: $showImagePicker) {
                                ImagePicker(selectedImage: $profilePicture, sourceType: imagePickerSourceType)
                            }
                        }
                    }
                }
                .padding(20) // Keeps content spacing tight
            }
            .fixedSize(horizontal: false, vertical: true) // Ensures ZStack fits content tightly
            .padding(.horizontal, 40) // Positioning the container
            Spacer()

        }
    }
    
    // Date formatting for birthdate
    private var birthDateFormatted: String {
        guard let birthDate = birthDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: birthDate)
    }
}

