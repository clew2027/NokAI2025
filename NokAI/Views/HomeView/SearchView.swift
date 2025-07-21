//
//  Search.swift
//  NokAI
//
//  Created by Charlotte Lew on 6/30/25.
import SwiftUI

struct UserSearchResult: Identifiable, Decodable {
    var id: String { username }
    let username: String
    let name: String?
    let profilePhoto: String?
}

struct SearchView: View {
    @Binding var showSearchView: Bool
    @StateObject private var viewModel = SearchViewModel()

    var body: some View {
        ZStack {
            Color("LightGreen").ignoresSafeArea()

            VStack {
                HStack {
                    Button(action: {
                        showSearchView = false
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.custom("VT323-Regular", size: 24))
                        .foregroundColor(Color("AccentGreen"))
                        .padding()
                    }
                    Spacer()
                }

                TextField("Search usernames...", text: $viewModel.searchText)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)

                List(viewModel.searchResults ?? [], id: \.username) { user in
                    Button {
                        viewModel.handleSelection(user: user)
                    } label: {
                        Text(user.username)
                            .font(.custom("VT323-Regular", size: 18))
                    }
                }
                .listStyle(.plain)
            }
            .padding(.top)
        }
        .onChange(of: viewModel.searchText) { _ in
            viewModel.performSearch()
        }
        .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.alertMessage)
        }
    }
}
