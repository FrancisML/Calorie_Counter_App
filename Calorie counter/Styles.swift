//
//  Styles.swift
//  Calorie counter
//
//  Created by frank lasalvia on 2/4/25.
//

// Theme.swift

import SwiftUI

struct Styles {
    // Detect system appearance
//    @Environment(\.colorScheme) static var colorScheme
    static var isDarkMode: Bool = false
    
    // Primary Background
    static var primaryBackground: Color {
        isDarkMode
        ? Color(red: 0.129, green: 0.208, blue: 0.333)  // Dark Mode (#213555)
        : Color(red: 0.847, green: 0.769, blue: 0.714)  // Light Mode (#D8C4B6)
    }

    // Secondary Background
    static var secondaryBackground: Color {
        isDarkMode
        ? Color(red: 0.243, green: 0.345, blue: 0.475)  // Dark Mode (#3E5879)
        : Color(red: 0.961, green: 0.937, blue: 0.906)  // Light Mode (#F5EFE7)
    }

    // Primary Text
    static var primaryText: Color {
        isDarkMode
        ? Color(red: 0.847, green: 0.769, blue: 0.714)  // Dark Mode (#D8C4B6)
        : Color(red: 0.129, green: 0.208, blue: 0.333)  // Light Mode (#213555) 
    }

    // Secondary Text
    static var secondaryText: Color {
        isDarkMode
        ? Color(red: 0.961, green: 0.937, blue: 0.906)  // Dark Mode (#F5EFE7)
        : Color(red: 0.243, green: 0.345, blue: 0.475)  // Light Mode (#3E5879)
    }
//
    // Accent Colors
    static var accent: Color {
        isDarkMode ? Color.blue : Color.purple
    }

    static var warning: Color {
        isDarkMode ? Color.orange : Color.red
    }

    static var success: Color {
        isDarkMode ? Color.green : Color.green.opacity(0.8)
    }

    // Button Styles
    static var primaryButton: Color {
        isDarkMode ? Color.blue : Color.green
    }

    static var secondaryButton: Color {
        isDarkMode ? Color.gray : Color.gray.opacity(0.5)
    }
}
