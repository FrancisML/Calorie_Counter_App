//
//  DashboardView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/11/25.
//




import SwiftUI
import CoreData
import PhotosUI

struct DashboardSetupView: View {
    @AppStorage("appState") private var appState: String = "dashboardSetup"
    @State private var name: String = ""
    @State private var profilePicture: UIImage? = nil
    @State private var isPickingProfilePicture = false
    @State private var startPicture: UIImage? = nil
    @State private var isPickingBeginningPicture = false
    @State private var currentStep = 0

    var body: some View {
        VStack {
            TabView(selection: $currentStep) {
                // Step 1: Ask for Name
                VStack(spacing: 20) {
                    Text("What is your name?")
                        .font(.title)
                        .padding()

                    TextField("Enter your name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    Spacer()

                    Button("Next") {
                        currentStep += 1
                    }
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
                }
                .tag(0)

                // Step 2: Upload Profile Picture
                VStack(spacing: 20) {
                    Text("Upload your profile picture")
                        .font(.title)
                        .padding()

                    if let profilePicture {
                        Image(uiImage: profilePicture)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 150, height: 150)
                            .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                    }

                    Button("Choose Picture") {
                        isPickingProfilePicture = true
                    }
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()

                    Spacer()

                    Button("Next") {
                        currentStep += 1
                    }
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
                }
                .tag(1)

                // Step 3: Upload Beginning Picture
                VStack(spacing: 20) {
                    Text("Would you like to upload a beginning picture to track progress?")
                        .font(.title)
                        .padding()

                    if let startPicture {
                        Image(uiImage: startPicture)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(10)
                    }

                    HStack(spacing: 20) {
                        Button("Yes") {
                            isPickingBeginningPicture = true
                        }
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)

                        Button("No") {
                            currentStep += 1
                        }
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding()

                    if startPicture != nil {
                        Button("Next") {
                            currentStep += 1
                        }
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                    }
                }
                .tag(2)

                // Final Step: Save Data and Transition
                VStack(spacing: 20) {
                    Text("Setup Complete!")
                        .font(.title)
                        .padding()

                    Button("Go to Dashboard") {
                        saveUserProfile()
                        appState = "dashboard"
                    }
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
                }
                .tag(3)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        }
        .sheet(isPresented: $isPickingProfilePicture) {
            ImagePicker { image in
                profilePicture = image
            }
        }
        .sheet(isPresented: $isPickingBeginningPicture) {
            ImagePicker { image in
                startPicture = image
            }
        }
    }

    // MARK: - Save User Profile
    private func saveUserProfile() {
        let fetchRequest: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()

        do {
            let userProfiles = try PersistenceController.shared.context.fetch(fetchRequest)
            let userProfile = userProfiles.first ?? UserProfile(context: PersistenceController.shared.context)

            userProfile.name = name
            userProfile.startDate = userProfile.startDate ?? Date() // Set startDate only if it hasn't been set before
            if let profileImageData = profilePicture?.jpegData(compressionQuality: 0.8) {
                userProfile.profilePicture = profileImageData
            }
            if let beginningImageData = startPicture?.jpegData(compressionQuality: 0.8) {
                userProfile.startPicture = beginningImageData
            }

            try PersistenceController.shared.context.save()
            print("User profile saved successfully.")
        } catch {
            print("Failed to save user profile: \(error)")
        }
    }

}

#Preview {
    DashboardSetupView()
}
