// ProgressPictureView.swift
// Calorie counter
// Created by frank lasalvia on 3/7/25.

import SwiftUI
import CoreData
import PhotosUI

// Extension for CGContext to support rounded corners
extension CGContext {
    func fill(_ rect: CGRect, withCornerRadius radius: CGFloat) {
        let path = UIBezierPath(roundedRect: rect, cornerRadius: radius)
        self.addPath(path.cgPath)
        self.fillPath()
    }
}

struct ProgressPictureView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var userProfile: UserProfile?
    @Binding var showDeleteOptions: Bool
    let onDeletePicture: (ProgressPicture) -> Void
    
    @FetchRequest private var progressPictures: FetchedResults<ProgressPicture>
    
    @State private var isPhotoPickerPresented = false
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var isExpanded = false
    @State private var temporaryLatestPicture: ProgressPicture? = nil
    @State private var showShareSheet = false
    @State private var localUserProfile: UserProfile?
    
    init(userProfile: Binding<UserProfile?>, showDeleteOptions: Binding<Bool>, onDeletePicture: @escaping (ProgressPicture) -> Void) {
        self._userProfile = userProfile
        self._showDeleteOptions = showDeleteOptions
        self.onDeletePicture = onDeletePicture
        
        if let profile = userProfile.wrappedValue {
            let predicate = NSPredicate(format: "userProfile == %@", profile)
            let sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
            _progressPictures = FetchRequest<ProgressPicture>(
                entity: ProgressPicture.entity(),
                sortDescriptors: sortDescriptors,
                predicate: predicate
            )
        } else {
            _progressPictures = FetchRequest<ProgressPicture>(
                entity: ProgressPicture.entity(),
                sortDescriptors: [],
                predicate: NSPredicate(value: false)
            )
        }
    }
    
    // Progress Picture Computed Properties
    private var startPicture: UIImage? {
        if let startData = effectiveUserProfile?.startPicture, let image = UIImage(data: startData) {
            return image
        }
        return nil
    }
    
    private var latestPicture: UIImage? {
        print("🔍 Evaluating latestPicture - temporaryLatestPicture: \(temporaryLatestPicture?.date?.description ?? "nil"), progressPictures.count: \(progressPictures.count)")
        if let temp = temporaryLatestPicture, let imageData = temp.imageData, let image = UIImage(data: imageData) {
            print("🔍 Returning temporaryLatestPicture: \(temp.date?.description ?? "nil")")
            return image
        }
        if let latest = progressPictures.last, let imageData = latest.imageData, let image = UIImage(data: imageData) {
            print("🔍 Returning progressPictures.last: \(latest.date?.description ?? "nil")")
            return image
        }
        print("🔍 Returning nil for latestPicture")
        return nil
    }
    
    private var defaultPicture: UIImage {
        let gender = effectiveUserProfile?.gender ?? "woman"
        if gender == "man" {
            if let image = UIImage(named: "Empty man PP") {
                return image
            } else {
                print("❌ Error: 'Empty man PP' image not found in asset catalog")
                return UIImage(systemName: "person.fill") ?? UIImage()
            }
        } else {
            if let image = UIImage(named: "Empty woman PP") {
                return image
            } else {
                print("❌ Error: 'Empty woman PP' image not found in asset catalog")
                return UIImage(systemName: "person.fill") ?? UIImage()
            }
        }
    }
    
    private var effectiveUserProfile: UserProfile? {
        userProfile ?? localUserProfile
    }
    
    private var startDateOverlay: String {
        effectiveUserProfile?.startDate != nil ? DateFormatter.mediumDate.string(from: effectiveUserProfile!.startDate!) : ""
    }
    
    private var startWeightOverlay: String {
        effectiveUserProfile?.startWeight ?? 0 > 0 ? "\(effectiveUserProfile!.startWeight) \(effectiveUserProfile!.useMetric ? "kg" : "lbs")" : ""
    }
    
    private var latestDateOverlay: String {
        if let temp = temporaryLatestPicture, let date = temp.date {
            return DateFormatter.mediumDate.string(from: date)
        }
        return progressPictures.last?.date != nil ? DateFormatter.mediumDate.string(from: progressPictures.last!.date!) : ""
    }
    
    private var latestWeightOverlay: String {
        if let temp = temporaryLatestPicture {
            return temp.weight > 0 ? "\(temp.weight) \(effectiveUserProfile?.useMetric ?? false ? "kg" : "lbs")" : ""
        }
        return progressPictures.last?.weight ?? 0 > 0 ? "\(progressPictures.last!.weight) \(effectiveUserProfile?.useMetric ?? false ? "kg" : "lbs")" : ""
    }
    
    private var simulatedCurrentDate: Date {
        if let savedDate = UserDefaults.standard.object(forKey: "simulatedCurrentDate") as? Date {
            return Calendar.current.startOfDay(for: savedDate)
        }
        return Calendar.current.startOfDay(for: Date())
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    Text("Progress Pics")
                        .font(.headline)
                        .foregroundColor(Styles.primaryText)
                    Spacer()
                    HStack(spacing: 15) {
                        Button(action: { isPhotoPickerPresented = true }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(Styles.primaryText)
                        }
                        Button(action: { showShareSheet = true }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title2)
                                .foregroundColor(Styles.primaryText)
                        }
                    }
                }
                .padding(.vertical, 15)
                .padding(.horizontal, 15)
                .background(Styles.secondaryBackground)
                .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 5)
            }
            .zIndex(1)
            
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Image(uiImage: startPicture ?? defaultPicture)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: 200)
                        .clipped()
                        .overlay(
                            startPicture != nil ?
                                HStack {
                                    Spacer()
                                    Text("\(startDateOverlay) \(startWeightOverlay)")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .padding(5)
                                        .background(Color.black.opacity(0.6))
                                }
                                .padding(.bottom, 10)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                : nil,
                            alignment: .bottom
                        )
                    
                    Image(uiImage: latestPicture ?? defaultPicture)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: 200)
                        .clipped()
                        .overlay(
                            latestPicture != nil ?
                                HStack {
                                    Spacer()
                                    Text("\(latestDateOverlay) \(latestWeightOverlay)")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .padding(5)
                                        .background(Color.black.opacity(0.6))
                                }
                                .padding(.bottom, 10)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                : nil,
                            alignment: .bottom
                        )
                }
                .frame(height: 200)
                .clipped()
                .onTapGesture {
                    if startPicture != nil || !progressPictures.isEmpty {
                        withAnimation {
                            isExpanded.toggle()
                            if !isExpanded { showDeleteOptions = false }
                        }
                    }
                }
                
                if isExpanded && (startPicture != nil || !progressPictures.isEmpty) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            if let startImage = startPicture {
                                ProgressPictureItem(
                                    image: startImage,
                                    date: effectiveUserProfile?.startDate ?? Date(),
                                    weight: effectiveUserProfile?.startWeight ?? 0.0,
                                    useMetric: effectiveUserProfile?.useMetric ?? false,
                                    showDelete: showDeleteOptions,
                                    onTap: {
                                        let tempPicture = ProgressPicture(context: viewContext)
                                        tempPicture.imageData = effectiveUserProfile?.startPicture
                                        tempPicture.date = effectiveUserProfile?.startDate ?? Date()
                                        tempPicture.weight = effectiveUserProfile?.startWeight ?? 0.0
                                        tempPicture.userProfile = effectiveUserProfile
                                        temporaryLatestPicture = tempPicture
                                    },
                                    onDelete: { /* Start picture can't be deleted */ }
                                )
                            }
                            ForEach(progressPictures) { picture in
                                if let imageData = picture.imageData, let image = UIImage(data: imageData) {
                                    ProgressPictureItem(
                                        image: image,
                                        date: picture.date ?? Date(),
                                        weight: picture.weight,
                                        useMetric: effectiveUserProfile?.useMetric ?? false,
                                        showDelete: showDeleteOptions,
                                        onTap: { temporaryLatestPicture = picture },
                                        onDelete: {
                                            print("🔍 Deleting picture: \(picture.date?.description ?? "nil")")
                                            temporaryLatestPicture = nil
                                            onDeletePicture(picture)
                                        }
                                    )
                                    .onLongPressGesture {
                                        withAnimation { showDeleteOptions.toggle() }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                    }
                    .background(Styles.secondaryBackground)
                    .cornerRadius(8)
                }
            }
        }
        .photosPicker(isPresented: $isPhotoPickerPresented, selection: $selectedPhoto, matching: .images)
        .onChange(of: selectedPhoto) { newPhoto in
            saveProgressPicture(from: newPhoto)
        }
        .onAppear {
            print("🔍 ProgressPictureView appeared")
            if userProfile == nil {
                fetchLocalUserProfile()
            }
            temporaryLatestPicture = nil
        }
        .onChange(of: userProfile) { newProfile in
            if let profile = newProfile {
                progressPictures.nsPredicate = NSPredicate(format: "userProfile == %@", profile)
            } else {
                progressPictures.nsPredicate = NSPredicate(value: false)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [generateShareImage()])
        }
    }
    
    private func fetchLocalUserProfile() {
        let fetchRequest: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        fetchRequest.fetchLimit = 1
        do {
            let profiles = try viewContext.fetch(fetchRequest)
            if let profile = profiles.first {
                localUserProfile = profile
                userProfile = profile
                print("✅ Fetched local user profile: \(profile.name ?? "Unknown")")
            } else {
                print("⚠️ No UserProfile found in Core Data")
            }
        } catch {
            print("❌ Error fetching local user profile: \(error.localizedDescription)")
        }
    }
    
    private func saveProgressPicture(from photoItem: PhotosPickerItem?) {
        guard let photoItem = photoItem, let profile = effectiveUserProfile else {
            print("❌ No photo item or effective user profile available")
            return
        }
        Task {
            do {
                if let data = try await photoItem.loadTransferable(type: Data.self),
                   let _ = UIImage(data: data) {
                    let currentDate = simulatedCurrentDate
                    let currentWeight = profile.currentWeight
                    if profile.startPicture == nil {
                        profile.startPicture = data
                        profile.startDate = currentDate
                        profile.startWeight = currentWeight
                        print("✅ Saved start picture for \(profile.name ?? "Unknown")")
                    } else {
                        let newPicture = ProgressPicture(context: viewContext)
                        newPicture.imageData = data
                        newPicture.date = currentDate
                        newPicture.weight = currentWeight
                        newPicture.userProfile = profile
                        print("✅ Saved new progress picture - Date: \(currentDate), Weight: \(currentWeight)")
                    }
                    try viewContext.save()
                    print("✅ Context saved after adding picture")
                }
            } catch {
                print("❌ Error saving progress picture: \(error.localizedDescription)")
            }
        }
    }
    
    // Helper function to crop an image to a square
    private func cropToSquare(_ image: UIImage, size: CGFloat) -> UIImage {
        let originalSize = image.size
        let shortestSide = min(originalSize.width, originalSize.height)
        let scaleFactor = size / shortestSide
        
        let newWidth = originalSize.width * scaleFactor
        let newHeight = originalSize.height * scaleFactor
        let cropSize = min(newWidth, newHeight)
        
        let xOffset = (newWidth - cropSize) / 2
        let yOffset = (newHeight - cropSize) / 2
        
        let cropRect = CGRect(x: xOffset, y: yOffset, width: cropSize, height: cropSize)
        
        // Use UIGraphicsImageRenderer for modern cropping
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        let croppedImage = renderer.image { _ in
            image.draw(in: CGRect(x: -xOffset, y: -yOffset, width: newWidth, height: newHeight))
        }
        
        return croppedImage
    }

    private func generateShareImage() -> UIImage {
        let canvasSize: CGFloat = 600
        let imageSize: CGFloat = 300 // Square size for images (half canvas width)
        let padding: CGFloat = 20
        let logoHeight: CGFloat = 80 // Increased logo section height
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: canvasSize, height: canvasSize))
        
        let image = renderer.image { context in
            // Background (Convert Styles.primaryBackground to UIColor)
            UIColor(Styles.primaryBackground).setFill()
            context.fill(CGRect(x: 0, y: 0, width: canvasSize, height: canvasSize))
            
            // Logo and Title (Centered Above Images, Dynamic Width)
            let logoWidth: CGFloat = 60 // Larger logo
            let titleText = "Calorie Counter"
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20, weight: .medium),
                .foregroundColor: UIColor.white
            ]
            let titleSize = titleText.size(withAttributes: titleAttributes)
            let overlayWidth = logoWidth + 10 + titleSize.width + 20 // Icon + spacing + title + padding
            let overlayRect = CGRect(
                x: (canvasSize - overlayWidth) / 2,
                y: padding,
                width: overlayWidth,
                height: logoHeight
            )
            UIColor.black.withAlphaComponent(0.6).setFill()
            context.fill(overlayRect) // Standard fill without rounded corners
            
            if let appIcon = UIImage(named: "AppIcon")?.withRenderingMode(.alwaysOriginal) {
                let iconRect = CGRect(
                    x: (canvasSize - overlayWidth) / 2 + 10,
                    y: padding + 10,
                    width: logoWidth,
                    height: logoWidth
                )
                appIcon.draw(in: iconRect)
            }
            
            let titleRect = CGRect(
                x: (canvasSize - overlayWidth) / 2 + logoWidth + 20,
                y: padding + (logoHeight - titleSize.height) / 2,
                width: titleSize.width,
                height: titleSize.height
            )
            titleText.draw(in: titleRect, withAttributes: titleAttributes)
            
            // Images (Shifted Down, Cropped to Square, No Space Between)
            let imageYPosition = padding + logoHeight + padding // Top of images after logo
            let leftImage = cropToSquare(startPicture ?? defaultPicture, size: imageSize)
            let leftRect = CGRect(
                x: 0,
                y: imageYPosition,
                width: imageSize,
                height: imageSize
            )
            leftImage.draw(in: leftRect, blendMode: .normal, alpha: 1.0)
            
            let rightImage = cropToSquare(latestPicture ?? defaultPicture, size: imageSize)
            let rightRect = CGRect(
                x: imageSize, // Directly adjacent to left image
                y: imageYPosition,
                width: imageSize,
                height: imageSize
            )
            rightImage.draw(in: rightRect, blendMode: .normal, alpha: 1.0)
            
            // Calculate Days Between (Left Below Images)
            let startDate = effectiveUserProfile?.startDate ?? Date()
            let latestDate = temporaryLatestPicture?.date ?? progressPictures.last?.date ?? Date()
            let daysBetween = Calendar.current.dateComponents([.day], from: startDate, to: latestDate).day ?? 0
            let daysText = "\(daysBetween) Days"
            let daysAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 48, weight: .regular),
                .foregroundColor: UIColor.black
            ]
            let daysSize = daysText.size(withAttributes: daysAttributes)
            let daysRect = CGRect(
                x: padding,
                y: imageYPosition + imageSize + padding,
                width: daysSize.width,
                height: daysSize.height
            )
            daysText.draw(in: daysRect, withAttributes: daysAttributes)
            
            // Calculate Weight Difference (Right Below Images)
            let startWeight = effectiveUserProfile?.startWeight ?? 0.0
            let latestWeight = temporaryLatestPicture?.weight ?? progressPictures.last?.weight ?? effectiveUserProfile?.currentWeight ?? 0.0
            let weightDifference = latestWeight - startWeight
            let isLoseGoal = (effectiveUserProfile?.weekGoal ?? 0 < 0) || (effectiveUserProfile?.goalWeight ?? 0 < startWeight)
            let weightColor: UIColor = weightDifference == 0 ? .gray : (isLoseGoal ? (weightDifference > 0 ? .red : .green) : (weightDifference > 0 ? .green : .red))
            let weightText = String(format: "%@%.1f %@", weightDifference > 0 ? "+" : "", weightDifference, effectiveUserProfile?.useMetric ?? false ? "kg" : "lbs")
            let weightAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 48, weight: .bold),
                .foregroundColor: weightColor
            ]
            let weightSize = weightText.size(withAttributes: weightAttributes)
            let weightRect = CGRect(
                x: canvasSize - padding - weightSize.width,
                y: imageYPosition + imageSize + padding,
                width: weightSize.width,
                height: weightSize.height
            )
            weightText.draw(in: weightRect, withAttributes: weightAttributes)
        }
        
        return image
    }
    
    struct ProgressPictureItem: View {
        let image: UIImage
        let date: Date
        let weight: Double
        let useMetric: Bool
        let showDelete: Bool
        let onTap: () -> Void
        let onDelete: () -> Void
        
        private var formattedDate: String { DateFormatter.mediumDate.string(from: date) }
        private var formattedWeight: String { weight > 0 ? "\(weight) \(useMetric ? "kg" : "lbs")" : "N/A" }
        
        var body: some View {
            VStack(spacing: 5) {
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipped()
                        .onTapGesture(perform: onTap)
                    
                    if showDelete {
                        Color.black.opacity(0.5)
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "xmark")
                                    .font(.system(size: 40))
                                    .foregroundColor(.red)
                            )
                            .onTapGesture(perform: onDelete)
                    }
                }
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(Styles.primaryText)
                Text(formattedWeight)
                    .font(.caption)
                    .foregroundColor(Styles.primaryText)
            }
        }
    }
    
    struct ShareSheet: UIViewControllerRepresentable {
        let activityItems: [Any]
        
        func makeUIViewController(context: Context) -> UIActivityViewController {
            let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
            return controller
        }
        
        func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
    }
    
    struct ProgressPictureView_Previews: PreviewProvider {
        static var previews: some View {
            ProgressPictureView(
                userProfile: .constant(nil),
                showDeleteOptions: .constant(false),
                onDeletePicture: { _ in }
            )
        }
    }
}
