//
//  Int+DateComponentsFormatter.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 05/06/2024.
//

import Foundation

extension Int {
    func convertMinutesToDurationString() -> String? {
        // Create an instance of DateComponentsFormatter
        let formatter = DateComponentsFormatter()
        
        // Set the units style to full
        formatter.unitsStyle = .abbreviated
        
        // Specify that the formatter should include hours and minutes
        formatter.allowedUnits = [.hour, .minute]
        
        // Create a DateComponents instance with the given minutes
        let components = DateComponents(minute: self)
        
        // Format the components into a string
        return formatter.string(from: components)
    }
}
