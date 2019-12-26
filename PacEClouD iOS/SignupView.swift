//
//  SignupView.swift
//  Pace Cloud
//
//  Created by rgl on 2/10/19.
//  Copyright © 2019 royalgreen. All rights reserved.
//

import SwiftUI
import Combine

struct SignupView: View {
    @EnvironmentObject var userData: UserData
    @ObservedObject var loginViewModel: LoginViewModel
    @State private var signUpDisabled = true
    
    var body: some View {
        ZStack {
            Color.black
                .blur(radius: 0.5, opaque: false)
                .opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                
                Text("Sign UP").font(.title).padding(.top, 20)
                
                Divider()
                
                SignUpFirstNameView(loginViewModel: self.loginViewModel, label: "First Name", placeHolder: "First Name")
                SignUpLastNameView(loginViewModel: self.loginViewModel, label: "Last Name", placeHolder: "Last Name")
                SignupMobileView(loginViewModel: self.loginViewModel, label: "Mobile", placeHolder: "Mobile")
                SignupEmailView(loginViewModel: self.loginViewModel, label: "Email", placeHolder: "Email")
                SignupPasswordView(loginViewModel: self.loginViewModel, label: "Password", placeHolder: "Password")
                SignupConfPasswordView(loginViewModel: self.loginViewModel, label: "Confirm Password", placeHolder: "Confirm Password")
                SignupCompanyNameView(loginViewModel: self.loginViewModel, label: "Company Name", placeHolder: "Company Name")
                
                HStack(alignment: .center, spacing: 20) {
                    Button(action: {
                        self.loginViewModel.showSignupModal = false
                    }) {
                        HStack{
                            Spacer()
                            Text("Cancel").foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                        .background(Color.red)
                        .cornerRadius(2)
                    }
                    
                    Button(action: {
                        self.loginViewModel.doSignUp()
                    }) {
                        HStack{
                            Spacer()
                            Text("Create Account").foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                        .background(Colors.greenTheme)
                        .cornerRadius(2)
                    }
                    .disabled(self.signUpDisabled)
                    .onReceive(self.loginViewModel.isSignupFormValid) { shouldEnabled in
                        self.signUpDisabled = (shouldEnabled == nil)
                    }
                }
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)
                
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 6, style: .circular).fill(Color.white))
            .padding(.leading, 25)
            .padding(.trailing, 25)
        }
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView(loginViewModel: LoginViewModel()).environmentObject(UserData())
    }
}
