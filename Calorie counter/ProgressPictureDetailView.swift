//
//  ProgressPictureDetailView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/14/25.
//

import SwiftUI

struct ProgressPictureDetailView: View {
    let progressPicture: ProgressPicture
    
    var body: some View {
        VStack {
            if let data = progressPicture.imageData, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Text("No Image")
                    .font(.headline)
            }
            
            if let date = progressPicture.date {
                Text(date, style: .date)
                    .font(.headline)
            } else {
                Text("Unknown Date")
                    .font(.headline)
            }
            
            Text("Weight: \(progressPicture.weight) lbs")
                .font(.subheadline)
        }
        .padding()
    }
}

