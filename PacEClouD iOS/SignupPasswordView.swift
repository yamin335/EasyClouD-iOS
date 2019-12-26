//
//  SignupPasswordView.swift
//  Pace Cloud
//
//  Created by rgl on 3/10/19.
//  Copyright © 2019 royalgreen. All rights reserved.
//

import SwiftUI

struct SignupPasswordView: View {
    
    @ObservedObject var loginViewModel: LoginViewModel

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
            
            SecureField(placeHolder, text: $loginViewModel.signUpPassword)
                .padding(.leading, 16)
                .padding(.trailing, 16)
                .padding(.top, 8)
                .padding(.bottom, 8)
                .background(Colors.offWhite)
                .cornerRadius(5)
        }
        .padding(.leading, 20)
        .padding(.trailing, 20)
    }
}

struct SignupPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        SignupPasswordView(loginViewModel: LoginViewModel())
    }
}
