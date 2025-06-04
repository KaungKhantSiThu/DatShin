// DateFormatter.swift

import Foundation

class AppDateFormatter {
    static let shared = AppDateFormatter()
    private init() {}

    // lazy var iso8601Full: ISO8601DateFormatter = {
    //     let formatter = ISO8601DateFormatter()
    //     formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    //     return formatter
    // }()

    // lazy var shortDate: DateFormatter = {
    //     let formatter = DateFormatter()
    //     formatter.dateStyle = .short
    //     formatter.timeStyle = .none
    //     return formatter
    // }()
}
