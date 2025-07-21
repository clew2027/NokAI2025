//
//  HomeView.swift
//  NokAI
//
//  Created by Charlotte Lew on 6/30/25.
//

import SwiftUI


struct HomeView: View {
    var body: some View {
        TabView {

            NavigationView {
                ContactsView()
            }
            .tabItem {
                Label("Contacts", systemImage: "person.2").font(.custom("VT323-Regular", size: 18))
            }

            NavigationView {
                ProfileView() 
            }
            .tabItem {
                Label("Profile", systemImage: "person.circle").font(.custom("VT323-Regular", size: 18))
            }
        }
        .tint(Color("AccentPurple"))
    }
    
}

