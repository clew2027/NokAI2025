//
//  CustomTextField.swift
//  NokAI
//
//  Created by Charlotte Lew on 7/3/25.
//

import SwiftUICore
import SwiftUI


struct CustomTextField: View {
    @Binding var text: String
    var placeholder: String
    var placeholderColor: Color = Color("AccentPurple")
        .opacity(0.5)
    var textColor: Color = Color("AccentPurple")

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(placeholderColor)
                    .font(.custom("VT323", size: 20))
                    .padding(.leading, 8)
            }

            TextField("", text: $text)
                .foregroundColor(textColor)
                .font(.custom("VT323", size: 20))
                .padding(.horizontal, 8)
        }
        .frame(width: 240, height: 30)
        .overlay(
            Rectangle()
                .frame(height: 1) // Border thickness
                .foregroundColor(Color("AccentBlack")), // Border color
            alignment: .bottom
        )
    }
}


struct CustomSecureField: View {
    @Binding var text: String
    var placeholder: String
    var placeholderColor: Color = Color("AccentPurple")
        .opacity(0.5)
    var textColor: Color = Color("AccentPurple")

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(placeholderColor)
                    .font(.custom("VT323", size: 20))
                    .padding(.leading, 8)
            }

            SecureField("", text: $text)
                .foregroundColor(textColor)
                .font(.custom("VT323", size: 20))
                .padding(.horizontal, 8)
        }
        .frame(width: 240, height: 30)
        .overlay(
                Rectangle()
                    .frame(height: 1) // Border thickness
                    .foregroundColor(Color("AccentBlack")), // Border color
                alignment: .bottom
            )
    }
}

