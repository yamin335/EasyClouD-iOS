//
//  BarChartView.swift
//  Pace Cloud
//
//  Created by rgl on 22/10/19.
//  Copyright © 2019 royalgreen. All rights reserved.
//

import SwiftUI

struct BarChartView: View {
    
    @EnvironmentObject var barChart: BarChart
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        
        GeometryReader { geometry in
            VStack(spacing: 0) { Text(self.viewModel.barChartTitle).font(.subheadline).foregroundColor(Color.gray).background(Color.white)
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(self.barChart.barIDs, id: \.self) { barID in
                        BarChartColumnView(bar: self.barChart.bars[barID]!)
                            // use a custom transition for insertions and deletions.
                            .transition(.scaleAndFade)
                    }
                }
                .padding(.leading, 8)
                .padding(.trailing, 8)
                .padding(.top, 4)
                
                if !self.viewModel.barChartTitle.isEmpty {
                    Divider()
                }
                
                HStack(alignment: .top, spacing: 2) {
                    ForEach(self.barChart.barIDs, id: \.self) { barID in
                        BarChartLegendView(bar: self.barChart.bars[barID]!).frame(minWidth: 20, maxWidth: 100)
                            // use a custom transition for insertions and deletions.
                            .transition(.scaleAndFade)
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: Alignment.top)
                .padding(.leading, 4)
                .padding(.trailing, 4)
                .padding(.bottom, 4)
                .padding(.top, 4)
            }
            .frame(width: geometry.size.width - 32, height: geometry.size.height, alignment: .top)
        }
    }
}

struct BarChartView_Previews: PreviewProvider {
    static var previews: some View {
        BarChartView(viewModel: DashboardViewModel()).environmentObject(BarChart())
    }
}
