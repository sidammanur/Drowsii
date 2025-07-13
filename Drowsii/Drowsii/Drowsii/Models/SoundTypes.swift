import Foundation
import SwiftUI

// Enum for sound categories
// Expanded with more cases and documentation
enum SoundCategory: String, CaseIterable, Identifiable {
    case white = "White Noise"
    case pink = "Pink Noise"
    case brown = "Brown Noise"
    case nature = "Nature"
    // Add more categories as needed
    var id: String { self.rawValue }
}

// Enum for the steps in the sound setup flow
enum SoundStep {
    case category, sound, duration, alarm, summary
} 