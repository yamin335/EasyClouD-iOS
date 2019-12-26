//
//  SpinLoaderSmall.swift
//  Pace Cloud
//
//  Created by rgl on 11/11/19.
//  Copyright © 2019 royalgreen. All rights reserved.
//

import SwiftUI

struct SpinLoaderSmall: View {
    
    @State var spinLine = false
    
    var body: some View {
        Rectangle()
            .frame(height: 2)
            .foregroundColor(Colors.greenTheme)
            .cornerRadius(1)
            .shadow(color: .black, radius: 15)
            .padding(.all, 1)
            .rotationEffect(.degrees(spinLine ? 0 : -360), anchor: .center)
            .animation(Animation.linear(duration: 0.8).repeatForever(autoreverses: false))
            .onAppear {
                self.spinLine = true
            }
    }
}

struct SpinLoaderSmall_Previews: PreviewProvider {
    static var previews: some View {
        SpinLoaderSmall()
    }
}
