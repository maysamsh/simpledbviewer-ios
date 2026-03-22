//
//  Spacing.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-05.
//
import Foundation

/// A spacing system based on Fibonacci numbers for harmonious, naturally-scaling UI layouts
enum Spacing {
    /// 1pt - Minimal spacing
    static let xs: CGFloat = 1

    /// 1pt - Extra small spacing (same as xs for continuity)
    static let xs2: CGFloat = 1

    /// 2pt - Tiny spacing
    static let sm: CGFloat = 2

    /// 3pt - Small spacing
    static let sm2: CGFloat = 3

    /// 5pt - Small-medium spacing
    static let md: CGFloat = 5

    /// 8pt - Medium spacing (most common)
    static let md2: CGFloat = 8

    /// 13pt - Medium-large spacing
    static let lg: CGFloat = 13

    /// 21pt - Large spacing
    static let lg2: CGFloat = 21

    /// 34pt - Extra large spacing
    static let xl: CGFloat = 34

    /// 55pt - Extra extra large spacing
    static let xl2: CGFloat = 55

    /// 89pt - Maximum spacing (exceeds 70, but completes the sequence)
    static let xxl: CGFloat = 89

    // Alternative: Access by index
    static func fibonacci(_ n: Int) -> CGFloat {
        let sequence: [CGFloat] = [1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89]
        guard n >= 0 && n < sequence.count else { return 8 }
        return sequence[n]
    }
}
