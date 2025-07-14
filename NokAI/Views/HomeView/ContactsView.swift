//
//  ContactsView.swift
//  NokAI
//
//  Created by Charlotte Lew on 6/30/25.
//

import SwiftUI
import CoreData

struct LocalFriendRequest: Identifiable {
    var id: String { "\(fromUsername ?? "from")-\(toUsername ?? "to")" }
    let fromUsername: String?
    let toUsername: String?
    let status: String?
}
 
struct FriendDisplay: Identifiable {
    var id: String { username }
    let name: String
    let username: String
    let photo: UIImage
}

struct ContactsView: View {
    @State private var callHistories: [CallRecord] = []
    @StateObject var callManager = CallHistoryManager(currentUsername: UserDefaults.standard.string(forKey: "currentUsername") ?? "")
    @State private var sampleFriends: [FriendDisplay] = []
    @State private var showSearchView = false
    @State private var incomingRequests: [LocalFriendRequest] = []
    @State private var outgoingRequests: [LocalFriendRequest] = []
    @State private var showProfileView = false
    @State private var selectedUsername: String?



    var body: some View {
        Group {
            if showSearchView {
                SearchView(showSearchView: $showSearchView)
            } else if showProfileView, let username = selectedUsername {
                FriendProfileView(
                        friendUsername: username,
                        showProfileView: $showProfileView,
                        selectedUsername: $selectedUsername
                    )
            } else {
                contactsMainView
            }
        }
    }

    var contactsMainView: some View {
        ZStack {
            Color("LightGreen").ignoresSafeArea()
            
            VStack(spacing: 0) {
                ZStack(alignment: .top) {
                    Image("background")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipped()
                        .ignoresSafeArea(edges: .top)
                    
                    HStack {
                        Text("Contacts")
                            .font(.custom("VT323-Regular", size: 32))
                            .foregroundColor(.white)
                            .padding(.leading, 24)
                        Spacer()
                        Button(action: {
                            print("")
                            showSearchView = true
                        }) {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color("AccentPurple"))
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 24)
                    }
                    .padding(.top, 50)
                }
                .onAppear {
                    loadUser()
                    loadRequests()
                    loadCallHistories()
                }
                .frame(height: 180)
                
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 24) {
                            ForEach(sampleFriends) { friend in
                                Button(action: {
                                    selectedUsername = friend.username.replacingOccurrences(of: "@", with: "")
                                    showProfileView = true
                                }) {
                                    VStack(spacing: 4) {
                                        Image(uiImage: friend.photo)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 72, height: 72)
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle()
                                                    .stroke(Color("LightGreen"), lineWidth: 4)
                                            )

                                        Text(friend.name)
                                            .font(.custom("VT323-Regular", size: 14))
                                            .foregroundColor(.black)

                                        Text(friend.username)
                                            .font(.custom("VT323-Regular", size: 14))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 2)
                                            .background(Color("AccentPurple"))
                                            .foregroundColor(Color("AccentGreen"))
                                            .cornerRadius(4)
                                    }
                                }
                            }

                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 170)
                        .padding(.bottom, 16)
                    }

                if !incomingRequests.isEmpty || !outgoingRequests.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Friend Requests")
                            .font(.custom("VT323-Regular", size: 24))
                            .foregroundColor(.black)
                            .padding(.horizontal)

                        ForEach(incomingRequests, id: \.id) { request in
                            HStack {
                                Text("@\(request.fromUsername ?? "")")
                                    .font(.custom("VT323-Regular", size: 16))
                                    .foregroundColor(.black)
                                Spacer()
                                Button("Accept") {
                                    handleRequest(request, accepted: true)
                                }
                                .font(.custom("VT323-Regular", size: 16))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green)
                                .cornerRadius(4)

                                Button("Decline") {
                                    handleRequest(request, accepted: false)
                                }
                                .font(.custom("VT323-Regular", size: 16))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.red)
                                .cornerRadius(4)
                            }
                            .padding(.horizontal)
                        }

                        ForEach(outgoingRequests, id: \.id) { request in
                            HStack {
                                Text("To @\(request.toUsername ?? "")")
                                    .font(.custom("VT323-Regular", size: 16))
                                Spacer()
                                Text("Pending")
                                    .font(.custom("VT323-Regular", size: 14))
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Call History")
                        .font(.custom("VT323-Regular", size: 28))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    
                    
                    ScrollView {
                        ForEach(callHistories) { call in
                                CallHistoryCard(entry: call)
                            }
                        }
                        .frame(height: 80)
                        .padding(.horizontal, 16)
                }
                Spacer()
            }
        }
    }
    
    private func handleRequest(_ request: LocalFriendRequest, accepted: Bool) {
        if accepted {
            // Add to Friend list both ways
            UserDataManager.shared.addFriend(userA: request.fromUsername ?? "", userB: request.toUsername ?? "") { success in
            }
            FriendRequestManager.shared.acceptRequest(from: request.fromUsername ?? "", to: request.toUsername ?? "") { success in
            }
        }
        
        if !accepted {
            FriendRequestManager.shared.declineRequest(from: request.fromUsername ?? "", to: request.toUsername ?? "") { success in
            }
        }
        loadRequests()
        loadUser()
    }


    private func loadRequests() {
        guard let currentUsername = UserDefaults.standard.string(forKey: "currentUsername") else { return }

        incomingRequests = []
        outgoingRequests = []

        // Fetch incoming requests
        FriendRequestManager.shared.fetchIncomingRequests(for: currentUsername) { incoming in
            self.incomingRequests = incoming.map {
                LocalFriendRequest(fromUsername: $0["fromUsername"] as? String,
                                   toUsername: $0["toUsername"] as? String,
                                   status: $0["status"] as? String)
            }
        }

        // Fetch outgoing requests
        FriendRequestManager.shared.fetchOutgoingRequests(from: currentUsername) { outgoing in
            self.outgoingRequests = outgoing.map {
                LocalFriendRequest(fromUsername: $0["fromUsername"] as? String,
                                   toUsername: $0["toUsername"] as? String,
                                   status: $0["status"] as? String)
            }
        }
    }
    
    private func loadCallHistories() {
        print("loading histories in view")
        callManager.fetchCallHistory { records in
            self.callHistories = records
        }
    }


    private func loadUser() {
        guard let currentUsername = UserDefaults.standard.string(forKey: "currentUsername") else { return }
        UserDataManager.shared.listFriends(ofUsername: currentUsername) { friendUsernames in
            var tempFriends: [FriendDisplay] = []
            let group = DispatchGroup()

            for username in friendUsernames {
                group.enter()
                UserDataManager.shared.fetchUser(byUsername: username) { userData in
                    defer { group.leave() }

                    guard let userData = userData else { return }

                    let name = userData["name"] as? String ?? "Unknown"
                    let username = userData["username"] as? String ?? "Unknown"
                    var photo = UIImage(systemName: "person.crop.circle.fill")!

                    if let photoString = userData["profilePhoto"] as? String,
                       let base64 = UserDataManager.shared.extractBase64Data(from: photoString),
                       let imageData = Data(base64Encoded: base64),
                       let image = UIImage(data: imageData) {
                        photo = image
                    }

                    let display = FriendDisplay(name: name, username: "@\(username)", photo: photo)
                    tempFriends.append(display)
                }
            }

            group.notify(queue: .main) {
                self.sampleFriends = tempFriends.sorted { $0.username < $1.username }
            }
        }
    }
}
