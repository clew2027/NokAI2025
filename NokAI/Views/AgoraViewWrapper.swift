//
//  AgoraViewWrapper.swift
//  NokAI
//
//  Created by Charlotte Lew on 6/26/25.
//
import SwiftUI

struct AgoraViewWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = VideoViewController

    func makeUIViewController(context: Context) -> VideoViewController {
        return VideoViewController()
    }

    func updateUIViewController(_ uiViewController: VideoViewController, context: Context) {
        // No updates needed
    }

    // Optional: Only needed if you're using delegation between UIKit/SwiftUI
    class Coordinator {}
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
}


