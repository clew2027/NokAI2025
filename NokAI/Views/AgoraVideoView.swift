//
//  AgoraVideoView.swift
//  NokAI
//
//  Created by Charlotte Lew on 7/7/25.
//

import SwiftUI
import UIKit

struct AgoraVideoView: UIViewRepresentable {
    var setup: (UIView) -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        setup(view)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
