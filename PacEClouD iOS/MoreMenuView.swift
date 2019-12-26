//
//  MoreMenuView.swift
//  Pace Cloud
//
//  Created by rgl on 16/10/19.
//  Copyright © 2019 royalgreen. All rights reserved.
//

import SwiftUI

struct MoreMenuView: View {
    
    @EnvironmentObject var userData: UserData
    @State private var showSignoutAlert = false
    
    var signoutButton: some View {
        Button(action: {
            self.showSignoutAlert = true
        }) {
            Text("Sign Out")
                .foregroundColor(Colors.greenTheme)
        }
        .alert(isPresented:$showSignoutAlert) {
            Alert(title: Text("Sign Out"), message: Text("Are you sure to sign out?"), primaryButton: .destructive(Text("Yes")) {
                self.userData.isLoggedIn = false
                }, secondaryButton: .cancel(Text("No")))
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("More Menu View")
            }
            .navigationBarTitle(Text("Menu"))
            .navigationBarItems(trailing: signoutButton)
        }
    }
}

struct MoreMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MoreMenuView()
    }
}
