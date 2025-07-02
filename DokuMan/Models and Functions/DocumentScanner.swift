//
//  DocumentScanner.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 14.04.25.
//

import SwiftUI
import VisionKit

// MARK: - DocumentScanner

/// A SwiftUI view that presents a document scanner and returns scanned images.
struct DocumentScanner: UIViewControllerRepresentable {
    /// Called when the user finishes scanning documents.
    var onScanComplete: ([UIImage]) -> Void

    /// Creates the VNDocumentCameraViewController.
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}

    /// Creates the coordinator for handling scanner events.
    func makeCoordinator() -> Coordinator {
        Coordinator(onScanComplete: onScanComplete)
    }

    // MARK: - Coordinator
    /// Handles VNDocumentCameraViewControllerDelegate events.
    @MainActor
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var onScanComplete: ([UIImage]) -> Void

        init(onScanComplete: @escaping ([UIImage]) -> Void) {
            self.onScanComplete = onScanComplete
        }

        /// Called when the user finishes scanning documents.
        nonisolated func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            var images: [UIImage] = []
            for i in 0..<scan.pageCount {
                images.append(scan.imageOfPage(at: i))
            }
            Task { @MainActor in
                controller.dismiss(animated: true)
                onScanComplete(images)
            }
        }

        /// Called when the user cancels scanning.
        nonisolated func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            Task { @MainActor in
                controller.dismiss(animated: true)
            }
        }

        /// Called when scanning fails with an error.
        nonisolated func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            print("Document scanning failed with error: \(error.localizedDescription)")
            Task { @MainActor in
                controller.dismiss(animated: true)
            }
        }
    }
}
