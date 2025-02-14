//
//  AddFood.swift
//  Calorie counter
//
//  Created by frank lasalvia on 2/13/25.
//
import SwiftUI

struct AddFoodView: View {
    var closeAction: () -> Void
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
                // ✅ Search Bar (Below Title, Above Tabs)
                // ✅ Search Bar (Below Title, Above Tabs)
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
                        QuickAddView()
                    } else {
                        AdvancedAddView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // ✅ Bottom Navigation Bar (Closes View)
                bottomNavBar()
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

    // ✅ Bottom Navigation Bar
    private func bottomNavBar() -> some View {
        // ✅ Bottom Navigation Bar with Three Evenly Spaced Buttons
        ZStack {
            // ✅ Background Bar (Same as Dashboard)
            Rectangle()
                .fill(Styles.secondaryBackground)
                .frame(height: 96)
                .shadow(radius: 5)

            HStack(spacing: 0) { // ✅ Ensures even spacing
                // 🔴 X Button (Closes View)
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

                Spacer() // ✅ Ensures even spacing

                // 📸 Barcode Scanner Button (NEW CENTER BUTTON)
                ZStack {
                    Circle()
                        .fill(Styles.primaryText)
                        .frame(width: 80, height: 80)
                        .shadow(radius: 5)

                    Image("BarCode") // ✅ Your Barcode Image (Smaller Now)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40) // 🔥 Reduced size
                }
                .onTapGesture {
                    print("Barcode Scanner Tapped!") // Replace with functionality
                }

                Spacer() // ✅ Ensures even spacing

                // ➕ "+" Button (Same as Dashboard)
                ZStack {
                    Circle()
                        .fill(Styles.primaryText)
                        .frame(width: 80, height: 80)
                        .shadow(radius: 5)

                    Image(systemName: "plus")
                        .font(.largeTitle)
                        .foregroundColor(Styles.secondaryBackground)
                }
            }
            .padding(.horizontal, 30) // ✅ Adjust horizontal padding if needed
            .frame(maxWidth: .infinity)
            .offset(y: -36) // ✅ Keeps buttons at same height as Dashboard "+"
        }
        .frame(height: 96)

    }
}
