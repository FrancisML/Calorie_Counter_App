//
//  ProgressPicsView.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/14/25.
//

import SwiftUI
import CoreData

struct ProgressPicsView: View {
    @FetchRequest(
        entity: ProgressPicture.entity(),
        sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)]
    ) var progressPictures: FetchedResults<ProgressPicture>
    
    @ObservedObject var userProfile: UserProfile
    @State private var selectedPicture: ProgressPicture? = nil

    private var emptyProfilePlaceholder: UIImage {
        if let gender = userProfile.gender, gender.lowercased() == "woman" {
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

    var body: some View {
        NavigationView {
            VStack {
                Text("Progress Pics")
                    .font(.largeTitle)
                    .padding()
                
                // Display current and most recent pictures
                HStack(spacing: 20) {
                    ProgressImage(imageData: mostRecentSetupPicture, placeholder: emptyProfilePlaceholder)
                    ProgressImage(imageData: mostRecentProgressPicture, placeholder: emptyProfilePlaceholder)
                }
                .padding()
                
                Divider()
                
                // List of past pictures
                List {
                    ForEach(progressPictures) { picture in
                        Button {
                            selectedPicture = picture
                        } label: {
                            HStack {
                                if let data = picture.imageData, let image = UIImage(data: data) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                }
                                VStack(alignment: .leading) {
                                    Text(picture.date ?? Date(), style: .date)
                                        .font(.headline)
                                    Text("Weight: \(picture.weight) lbs")
                                        .font(.subheadline)
                                }
                            }
                        }
                    }
                }
            }
            .sheet(item: $selectedPicture) { picture in
                ProgressPictureDetailView(progressPicture: picture)
            }
        }
    }
}

