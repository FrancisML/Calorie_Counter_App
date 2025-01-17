//
//  AddProgressPictureView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/14/25.
//

import SwiftUI
import CoreData

struct AddProgressPictureView: View {
    @Environment(\.managedObjectContext) private var context
    @State private var selectedImage: UIImage? = nil
    @State private var weight: Int32 = 0
    @State private var showImagePicker = false

    var body: some View {
        VStack {
            Text("Add Progress Picture")
                .font(.largeTitle)
                .padding()

            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .padding()
            } else {
                Button("Choose Picture") {
                    showImagePicker = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }

            TextField("Enter Weight", value: $weight, formatter: NumberFormatter())
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .padding()

            Button("Save") {
                let progressPicture = ProgressPicture(context: context)
                progressPicture.date = Date()
                progressPicture.weight = weight
                progressPicture.imageData = selectedImage?.jpegData(compressionQuality: 0.8)

                do {
                    try context.save()
                } catch {
                    print("Error saving progress picture: \(error)")
                }
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker { image in
                selectedImage = image
                showImagePicker = false
            }
        }
        .padding()
    }
}

