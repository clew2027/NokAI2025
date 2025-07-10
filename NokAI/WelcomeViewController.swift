//
//  WelcomeView.swift
//  NokAI
//
//  Created by Charlotte Lew on 6/27/25.
//

import SwiftUI

struct WelcomeView: View {
  @State private var username = ""
  @State private var isSignedUp = false

  var body: some View {
    if isSignedUp {
      // Wrap your UIKit ViewController in a UIHostingController bridge
      CallContainerView()
        .edgesIgnoringSafeArea(.all)
    } else {
        WelcomeViewInitial()
          .edgesIgnoringSafeArea(.all)
    }
  }
}

struct CallContainerView: UIViewControllerRepresentable {
  func makeUIViewController(context: Context) -> UIViewController {
    return VideoViewModel()
  }
  func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct WelcomeViewInitial: UIViewControllerRepresentable {
  func makeUIViewController(context: Context) -> UIViewController {
    return WelcomeViewController()
  }
  func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
