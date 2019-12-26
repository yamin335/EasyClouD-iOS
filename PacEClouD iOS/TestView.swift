//
//  TestView.swift
//  Pace Cloud
//
//  Created by rgl on 31/10/19.
//  Copyright © 2019 royalgreen. All rights reserved.
//

import Foundation
import SwiftUI

struct TestView: View {
    
    @State var test = true
    @State var name = ""
    var body: some View {
        ZStack {
            Color.black
                .blur(radius: 0.5, opaque: false)
                .opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    HStack {
                        Image("baseline_help_black_24pt")
                            .padding(.leading, 16)
                            .foregroundColor(Colors.color2)
                        Text("Are you sure to stop VM?")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Colors.color2)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                    }
                    Spacer()
                }
                .padding(.top, 16)
                .padding(.trailing, 20)
                
                HStack {
                    Text("What is 8 + 4?")
                        .font(.headline)
                        .foregroundColor(Colors.color2).padding(.leading, 20)
                    Button(action: {
                        self.test = false
                    }) {
                        Image("baseline_loop_black_24pt")
                            .foregroundColor(.white)
                            .padding(.all, 1)
                            .background(Circle().fill(Colors.greenTheme)).shadow(radius: 10)
                    }
                    Spacer()
                }
                
                TextField("Answer", text: $name)
                    .lineLimit(1)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                
                HStack(alignment: .center, spacing: 20) {
                    Spacer()
                    Button(action: {
                        self.test = false
                    }) {
                        HStack{
                            Spacer()
                            Text("No")
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                        .background(Color.red)
                        .cornerRadius(2)
                    }
                    
                    Button(action: {
                        self.test = false
                    }) {
                        HStack{
                            Spacer()
                            Text("Yes")
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                        .background(Colors.greenTheme)
                        .cornerRadius(2)
                    }
                }
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 6, style: .circular).fill(Color.white)
            .shadow(color: .black, radius: 15))
            .padding(.leading, 25)
            .padding(.trailing, 25)
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
