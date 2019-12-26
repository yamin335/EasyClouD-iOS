//
//  SignupCompanyNameView.swift
//  Pace Cloud
//
//  Created by rgl on 13/10/19.
//  Copyright © 2019 royalgreen. All rights reserved.
//

import SwiftUI

struct SignupCompanyNameView: View {
    
    @ObservedObject var loginViewModel: LoginViewModel

    var label = ""
    var placeHolder = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(label)
                    .font(.headline)
            }.padding(.bottom, 4)
            
            TextField(placeHolder, text: $loginViewModel.companyName)
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

struct SignupCompanyNameView_Previews: PreviewProvider {
    static var previews: some View {
        SignupCompanyNameView(loginViewModel: LoginViewModel())
    }
}
