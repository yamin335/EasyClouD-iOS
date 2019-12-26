//
//  MainScreen.swift
//  Pace Cloud
//
//  Created by rgl on 1/10/19.
//  Copyright © 2019 royalgreen. All rights reserved.
//

import SwiftUI

struct MainScreen: View {
    @State private var selection = 0
    
    var body: some View {
        TabView(selection: $selection){
            DashboardView()
                .tabItem {
                VStack {
                    Image("baseline_cloud_circle_black_24")
                    Text("Dashboard")
                }
            }
            .tag(0)
            
            VirtualMachineView()
                .tabItem {
                VStack {
                    Image("storage_black_24")
                    Text("Virtual Machine")
                }
            }
            .tag(1)
            
            PaymentView()
                .tabItem {
                    VStack {
                        Image("equalizer_black_24")
                        Text("Payment")
                    }
            }
            .tag(2)
            
            SupportView()
                .tabItem {
                    VStack {
                        Image(systemName: "questionmark.circle.fill")
                            .imageScale(.large)
                        Text("Support")
                    }
            }
            .tag(3)
            
            MoreMenuView()
                .tabItem {
                    VStack {
                        Image(systemName: "ellipsis.circle.fill")
                            .imageScale(.large)
                        Text("More")
                    }
            }
            .tag(4)
        }.accentColor(Colors.greenTheme)
    }
}

struct MainScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen()
            .environmentObject(UserData())
    }
}
