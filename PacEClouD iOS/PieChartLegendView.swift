//
//  PieChartLegendView.swift
//  Pace Cloud
//
//  Created by rgl on 23/10/19.
//  Copyright © 2019 royalgreen. All rights reserved.
//

import SwiftUI

struct PieChartLegendView: View {
    
    @State var wedge: Wedge
    
    var body: some View {
        VStack(spacing: 4) {
            Circle().fill(Color(hue: wedge.hue, saturation: wedge.saturation,
                                brightness: wedge.brightness)).frame(width: 18, height: 18)
            Text(String(wedge.chartValue).split(separator: ".")[0] + "-" + wedge.label)
                .font(.footnote).foregroundColor(Color.gray)
        }
    }
}

struct PieChartLegendView_Previews: PreviewProvider {
    static var previews: some View {
        PieChartLegendView(wedge: Wedge(label: "Test",
                                        chartValue: 5.0, hue: 0.2242,
                                        saturation: 0.4701, brightness: 0.9176))
    }
}
