//
//  CallHistoryCard.swift
//  NokAI
//
//  Created by Charlotte Lew on 7/13/25.
//

import SwiftUI

struct CallHistoryCard: View {
    let entry: CallRecord

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .stroke(Color.black, lineWidth: 1)
            .background(Color.clear)
            .overlay(
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.with)
                            .font(.custom("VT323-Regular", size: 16))
                            .foregroundColor(.black)

                        Text("@\(entry.with)")
                            .font(.custom("VT323-Regular", size: 14))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color("AccentPurple"))
                            .foregroundColor(Color("AccentGreen"))
                            .cornerRadius(4)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(formatDate(entry.timestamp))
                            .font(.custom("VT323-Regular", size: 14))
                            .foregroundColor(.black)

                        Text(formatDuration(entry.duration))
                            .font(.custom("VT323-Regular", size: 14))
                            .foregroundColor(.black)
                    }
                }
                .padding()
            )
            .frame(height: 80)
            .padding(.horizontal, 16)
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func formatDuration(_ interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: interval) ?? "00:00:00"
    }

}
