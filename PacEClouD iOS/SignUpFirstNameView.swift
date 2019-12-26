//
//  SignUpFirstNameView.swift
//  Pace Cloud
//
//  Created by rgl on 10/10/19.
//  Copyright © 2019 royalgreen. All rights reserved.
//

import SwiftUI

struct SignUpFirstNameView: View {
    
    @ObservedObject var loginViewModel: LoginViewModel
    @State private var showErrorMessage = false
    var label = ""
    var placeHolder = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(label)
                    .font(.headline).padding(.trailing, -5)
                Text("*")
                    .font(.headline)
                    .foregroundColor(.red)
            }.padding(.bottom, 4)
            
            TextField(placeHolder, text: $loginViewModel.firstName)
                .padding(.leading, 16)
                .padding(.trailing, 16)
                .padding(.top, 8)
                .padding(.bottom, 8)
                .background(Colors.offWhite)
                .cornerRadius(5)
            if showErrorMessage {
                Text("Invalid First Name")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.leading, 20)
            }
        }
        .padding(.leading, 20)
        .padding(.trailing, 20)
        .onReceive(self.loginViewModel.validatedFirstName) { newValidatedCredentials in
            self.showErrorMessage = (newValidatedCredentials == nil)
        }
    }
}

struct SignUpFirstNameView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpFirstNameView(loginViewModel: LoginViewModel())
    }
}
