 //
//  BarChartLegendView.swift
//  Pace Cloud
//
//  Created by rgl on 23/10/19.
//  Copyright © 2019 royalgreen. All rights reserved.
//

import SwiftUI

struct BarChartLegendView: View {
    
    @State var bar: BarColumn
    
    var body: some View {
        HStack {
            Spacer()
            Text(getLegendLabel(label: bar.label)).lineLimit(nil).multilineTextAlignment(.center).font(.footnote)
                .foregroundColor(Color.gray)
            Spacer()
        }
    }
    
    func getLegendLabel(label: String) -> String {
        var legend = ""
        if label.contains(" ") {
            let legends = label.split(separator: " ")
            if legends.count > 1 {
                legend = legends[0] + " " + legends[1]
            } else if legends.count == 1 {
                legend = legends[0] + ""
            }
        } else {
            legend = label
        }
        return legend
    }
}

struct BarChartLegendView_Previews: PreviewProvider {
    static var previews: some View {
        BarChartLegendView( bar: BarColumn(chartValue: 5, label: "Test",
                                           hue: 0.2242, saturation: 0.4701, brightness: 0.9176))
    }
}
