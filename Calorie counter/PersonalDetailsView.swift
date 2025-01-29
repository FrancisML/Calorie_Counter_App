//
//  PersonalDetailsView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/29/25.
//

import SwiftUI

struct PersonalDetailsView: View {
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
                    .fontWeight(.bold)
                
                Text("Please enter your information as accurately as possible")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
            }
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            
            // Input Fields
            VStack(spacing: 20) {
                // Name Input
                FloatingTextField(placeholder: " First Name ", text: $name)
                
                // Gender Selection
                HStack(spacing: 20) {
                    Button(action: { gender = "Man" }) {
                        Text("Man")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(gender == "Man" ? Color.blue : Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(gender == "Man" ? Color.green : Color.clear, lineWidth: 3)
                            )
                    }
                    
                    Button(action: { gender = "Woman" }) {
                        Text("Woman")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(gender == "Woman" ? Color.pink : Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(gender == "Woman" ? Color.green : Color.clear, lineWidth: 3)
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
                            .font(.headline)
                        
                        Text("Optional")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    ZStack {
                        // Border Circle
                        Circle()
                            .stroke(profilePicture != nil ? Color.green : Color.gray, lineWidth: 3)
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
                            .fill(Color.black.opacity(0.5)) // Semi-transparent grey overlay
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
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.customGray)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.white, lineWidth: 2)
            )
            .padding(.horizontal, 40)
        }
    }
    
    // ✅ Fixed: Moved inside `PersonalDetailsView`
    private var birthDateFormatted: String {
        guard let birthDate = birthDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: birthDate)
    }
}
