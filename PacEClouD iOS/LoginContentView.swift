//
//  LoginContentView.swift
//  Pace Cloud
//
//  Created by rgl on 7/10/19.
//  Copyright © 2019 royalgreen. All rights reserved.
//

import SwiftUI
import Combine
struct LoginContentView: View {
    @EnvironmentObject var userData: UserData
    @ObservedObject var loginViewModel: LoginViewModel
    @State private var loginButtonDisabled = true
    @State private var username: String = ""
    @State private var password: String = ""
    
    var body: some View {
        VStack(alignment: .center) {
            Image("pace_cloud_logo")
                .resizable()
                .frame(width: 90, height: 90)
            
            TextField("Username", text: $loginViewModel.username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.leading, 20).padding(.trailing, 20).padding(.top, 20)
            
            SecureField("Password", text: $loginViewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.leading, 20).padding(.trailing, 20).padding(.top, 8)
            HStack{
                Button(action: {
                    self.loginViewModel.doLogIn()
                }) {
                    HStack{
                        Spacer()
                        Text("Sign In").foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                    .background(Colors.greenTheme)
                    .cornerRadius(2)
                }
                .disabled(loginButtonDisabled)
                .onReceive(self.loginViewModel.validatedCredentials) { validCredential in
                    self.loginButtonDisabled = !validCredential
                }
                .onReceive(self.loginViewModel.loginStatusPublisher.receive(on: RunLoop.main)) { isLoggedIn in
                    self.userData.isLoggedIn = isLoggedIn
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .padding(.top, 8)
        }
    }
}

struct LoginContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginContentView(loginViewModel: LoginViewModel())
            .environmentObject(UserData())
    }
}
