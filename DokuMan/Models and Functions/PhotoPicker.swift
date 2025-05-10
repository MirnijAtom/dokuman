//
//  PhotoPicker.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 02.05.25.
//

import SwiftUI
import PhotosUI


struct PhotoPicker: UIViewControllerRepresentable {
    var onComplete: ([UIImage]) -> Void
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 3
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onComplete: onComplete)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var onComplete: ([UIImage]) -> Void
        
        init(onComplete: @escaping ([UIImage]) -> Void) {
            self.onComplete = onComplete // Capturing the closure explicitly
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            let group = DispatchGroup()
            var images: [UIImage] = []
            
            for result in results {
                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { reading, _ in
                    if let image = reading as? UIImage {
                        images.append(image)
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                self.onComplete(images) // Ensure it's self.onComplete to capture correctly
            }
        }
    }
}
