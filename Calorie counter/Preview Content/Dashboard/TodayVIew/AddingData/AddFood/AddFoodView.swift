//
//  AddFood.swift
//  Calorie counter
//
//  Created by frank lasalvia on 2/13/25.
//
import SwiftUI

struct AddFoodView: View {
    var closeAction: () -> Void
    @Binding var diaryEntries: [DiaryEntry]
    @State private var selectedTab: FoodTab = .quickAdd // Default to Quick Add
    @State private var searchText: String = "" // ✅ Search text state
    
    enum FoodTab {
        case quickAdd, advancedAdd
    }
    
    var body: some View {
        GeometryReader { geometry in
            let safeAreaTopInset = geometry.safeAreaInsets.top
            
            VStack(spacing: 0) {
                // ✅ Title Bar with Shadow
                ZStack {
                    Rectangle()
                        .fill(Styles.secondaryBackground)
                        .frame(height: 80)
                        .shadow(color: Color.black.opacity(0.2), radius: 4, y: 4)
                    
                    Text("Add Food")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Styles.primaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, safeAreaTopInset) // ✅ Pushes below notch
                
                // ✅ Search Bar (Below Title, Above Tabs)
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Styles.secondaryText)
                    
                    TextField("Search food...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(Styles.primaryText)
                }
                .padding(14)  // ✅ Adds internal padding inside the search bar (top/bottom/left/right)
                .frame(maxWidth: .infinity)
                .background(Styles.primaryBackground.opacity(0.3))
                .clipShape(Capsule()) // ✅ Fully curved shape
                .padding(.horizontal, 20)  // ✅ Extra space on the sides
                .padding(.top, 16)  // ✅ More space above the search bar
                .padding(.bottom, 16) // ✅ More space below the search bar
                
                
                
                
                // ✅ Full-Width Tabs Section
                ZStack {
                    Rectangle()
                        .fill(Styles.secondaryBackground)
                        .frame(width: geometry.size.width, height: 50) // ✅ Now spans full width
                        .shadow(radius: 2)
                    
                    HStack(spacing: 0) {
                        tabButton(title: "Quick Add", selected: selectedTab == .quickAdd) {
                            selectedTab = .quickAdd
                        }
                        tabButton(title: "Advanced Add", selected: selectedTab == .advancedAdd) {
                            selectedTab = .advancedAdd
                        }
                    }
                    .frame(width: geometry.size.width, height: 50) // ✅ Ensures buttons fill the bar
                }
                
                // ✅ Content Area (Switches Between Views)
                VStack {
                    if selectedTab == .quickAdd {
                        QuickFoodAddView(diaryEntries: $diaryEntries, closeAction: closeAction) // ✅ FIXED
                    } else {
                        AdvancedFoodAddView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                // ✅ Bottom Navigation Bar (Closes View)
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Styles.secondaryBackground) // ✅ Sets entire background color
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    // ✅ Tab Button Component
    private func tabButton(title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Text(title)
            .font(.headline)
            .foregroundColor(selected ? .orange : Styles.primaryText)
            .frame(maxWidth: .infinity, maxHeight: .infinity) // ✅ Ensures full height coverage
            .background(selected ? Color.clear : Styles.primaryBackground.opacity(0.3))
            .onTapGesture {
                withAnimation {
                    action()
                }
            }
    }
    
}
   
