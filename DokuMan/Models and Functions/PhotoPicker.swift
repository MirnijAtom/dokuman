//
//  PhotoPicker.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 02.05.25.
//

import SwiftUI
import PhotosUI

// MARK: - PhotoPicker

/// A SwiftUI view that presents a photo picker and returns selected images.
struct PhotoPicker: UIViewControllerRepresentable {
    /// Called when the user finishes picking images.
    var onComplete: ([UIImage]) -> Void

    /// Creates the PHPickerViewController.
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 3
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    /// Creates the coordinator for handling picker events.
    func makeCoordinator() -> Coordinator {
        Coordinator(onComplete: onComplete)
    }

    // MARK: - Coordinator
    /// Handles PHPickerViewControllerDelegate events.
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var onComplete: ([UIImage]) -> Void

        init(onComplete: @escaping ([UIImage]) -> Void) {
            self.onComplete = onComplete
        }

        /// Called when the user finishes picking images.
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            var images: [UIImage] = []
            let group = DispatchGroup()

            for result in results {
                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                    defer { group.leave() }

                    if let image = reading as? UIImage {
                        DispatchQueue.main.async {
                            images.append(image)
                        }
                    }
                }
            }

            group.notify(queue: .main) {
                self.onComplete(images)
            }
        }
    }
}
