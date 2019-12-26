//
//  BarChartColumnView.swift
//  Pace Cloud
//
//  Created by rgl on 21/10/19.
//  Copyright © 2019 royalgreen. All rights reserved.
//

import SwiftUI

struct BarChartColumnView: View {
    
    @State var bar: BarColumn
    @State private var dim = false
    
    var body: some View {
        VStack(spacing: 2) {
            Text(String(bar.chartValue)
                .split(separator: ".")[0])
                .font(.footnote)
                .foregroundColor(Color.gray)
            Rectangle().fill(Color(hue: bar.hue, saturation: bar.saturation,
                                   brightness: bar.brightness))
                .frame(height: CGFloat(bar.height)).frame(minWidth: 20, maxWidth: 100)
                .opacity(dim ? 0.5 : 1.0)
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        self.dim.toggle()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation(.easeInOut) {
                            self.dim = false
                        }
                    }
                }
        }.animation(.spring())
    }
    
    var animatableData: BarColumn.AnimatableData {
        get { bar.animatableData }
        set { bar.animatableData = newValue }
    }
}

struct BarChartColumnView_Previews: PreviewProvider {
    static var previews: some View {
        BarChartColumnView(bar: BarColumn(chartValue: 5, label: "Test",
                                          hue: 0.2242, saturation: 0.4701,
                                          brightness: 0.9176))
    }
}
