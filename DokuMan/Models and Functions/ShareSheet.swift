//
//  ShareSheet.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 02.05.25.
//

import SwiftUI

// MARK: - ShareSheet

/// A SwiftUI view that presents a share sheet (UIActivityViewController) for sharing items.
struct ShareSheet: UIViewControllerRepresentable {
    /// The items to share.
    var activityItems: [Any]

    /// Creates the UIActivityViewController.
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    /// Updates the UIActivityViewController (no-op).
    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
