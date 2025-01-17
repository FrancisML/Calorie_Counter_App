//
//  ProgressImage.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/14/25.
//


import SwiftUI

struct ProgressImage: View {
    let imageData: Data?
    let placeholder: UIImage

    var body: some View {
        GeometryReader { geometry in
            if let data = imageData, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill) // Fills the space while retaining aspect ratio
                    .frame(width: geometry.size.width, height: 150) // Fills width and fixes height
                    .clipped() // Ensures no overflow outside the frame
            } else {
                Image(uiImage: placeholder)
                    .resizable()
                    .aspectRatio(contentMode: .fill) // Fills the space while retaining aspect ratio
                    .frame(width: geometry.size.width, height: 150) // Fills width and fixes height
                    .clipped() // Ensures no overflow outside the frame
            }
        }
        .frame(height: 150) // Ensures consistent height for the view
    }
}

