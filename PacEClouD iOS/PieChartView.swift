//
//  PieChartView.swift
//  Pace Cloud
//
//  Created by rgl on 20/10/19.
//  Copyright © 2019 royalgreen. All rights reserved.
//

import SwiftUI

struct PieChartView: View {
    /// The description of the ring of wedges.
    @EnvironmentObject var ring: Ring
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        
        let pieChartTitle = HStack(alignment: .center) {
            Spacer()
            Text(viewModel.pieChartTitle).font(.subheadline).foregroundColor(Color.gray)
            Spacer()
        }
        .padding(.top, 10)
        
        let pieChartView = VStack(spacing: 0) {
            ZStack {
                ForEach(ring.wedgeIDs, id: \.self) { wedgeID in
                    WedgeView(wedge: self.ring.wedges[wedgeID]!)
                        
                        // use a custom transition for insertions and deletions.
                        .transition(.scaleAndFade)
                        
                        // remove wedges when they're tapped.
                        .onTapGesture {
                            withAnimation(.spring()) {
                                self.ring.wedgeOnTapped(id: wedgeID)
                            }
                    }
                }
                Spacer()
            }
            .flipsForRightToLeftLayoutDirection(true)
            .padding(.top, 40)
            .padding(.bottom, 10)
            .drawingGroup()
            
            HStack {
                ForEach(ring.wedgeIDs, id: \.self) { wedgeID in
                    PieChartLegendView(wedge: self.ring.wedges[wedgeID]!)
                        .onTapGesture {
                            withAnimation(.spring()) {
                                self.ring.wedgeOnTapped(id: wedgeID)
                            }
                    }
                }
            }
            .padding(.trailing, 16)
            .padding(.leading, 16)
            .frame(height: 50)
            
        }
        
        return pieChartView.overlay(pieChartTitle, alignment: .topLeading)
        
    }
    
}

/// The custom view modifier defining the transition applied to each
/// wedge view as it's inserted and removed from the display.
struct ScaleAndFade: ViewModifier {
    /// True when the transition is active.
    var isEnabled: Bool
    
    // Scale and fade the content view while transitioning in and
    // out of the container.
    
    func body(content: Content) -> some View {
        return content
            .scaleEffect(isEnabled ? 0.1 : 1)
            .opacity(isEnabled ? 0 : 1)
    }
}

extension AnyTransition {
    static let scaleAndFade = AnyTransition.modifier(
        active: ScaleAndFade(isEnabled: true),
        identity: ScaleAndFade(isEnabled: false))
}

struct PieChartView_Previews: PreviewProvider {
    static var previews: some View {
        PieChartView(viewModel: DashboardViewModel()).environmentObject(Ring())
    }
}
