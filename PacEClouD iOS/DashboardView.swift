//
//  DashboardView.swift
//  Pace Cloud
//
//  Created by rgl on 1/10/19.
//  Copyright © 2019 royalgreen. All rights reserved.
//

import SwiftUI

struct DashboardView: View {
    
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var ring: Ring
    @EnvironmentObject var barChart: BarChart
    @ObservedObject var viewModel = DashboardViewModel()
    @State private var showSignoutAlert = false
    
    var signoutButton: some View {
        Button(action: {
            self.showSignoutAlert = true
        }) {
            Text("Sign Out")
                .foregroundColor(Colors.greenTheme)
        }
        .alert(isPresented:$showSignoutAlert) {
            Alert(title: Text("Sign Out"), message: Text("Are you sure to sign out?"), primaryButton: .destructive(Text("Yes")) {
                self.userData.isLoggedIn = false
                }, secondaryButton: .cancel(Text("No")))
        }
    }
    
    var refreshButton: some View {
        Button(action: {
            self.viewModel.refreshUI()
            
        }) {
            Image(systemName: "arrow.clockwise")
                .font(.system(size: 18, weight: .light))
                .imageScale(.large)
                .accessibility(label: Text("Refresh"))
                .padding()
                .foregroundColor(Colors.greenTheme)
                
        }
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 4) {
                    PieChartView(viewModel: self.viewModel)
                        .frame(width: geometry.size.width, height: geometry.size.height/2)
                        .environmentObject(self.ring)
                        .onReceive(self.viewModel.osStatusDataPublisher
                            .receive(on: RunLoop.main)) { osStatusValues in
                                if osStatusValues.count > 0 {
                                    self.viewModel.pieChartTitle = "VM Status"
                                } else {
                                    self.viewModel.pieChartTitle = ""
                                }
                            self.clearPieChart()
                            osStatusValues.forEach { value in
                                self.newWedge(chartData: value)
                            }
                            
                    }.onDisappear {
                        self.clearPieChart()
                    }
                    
                    BarChartView(viewModel: self.viewModel)
                        .frame(width: geometry.size.width, height: geometry.size.height/2)
                        .environmentObject(self.barChart)
                        .onReceive(self.viewModel.osSummaryDataPublisher
                        .receive(on: RunLoop.main)) { osSummaryValues in
                            if osSummaryValues.count > 0 {
                                self.viewModel.barChartTitle = "OS Summary"
                            } else {
                                self.viewModel.barChartTitle = ""
                            }
                            self.barChart.fullChartHeight = Double((geometry.size.height/2) - 100)
                            self.barChart.fullChartWidth = Double(geometry.size.width)
                            self.clearBarChart()
                            osSummaryValues.forEach { value in
                                self.newBar(chartData: value)
                            }
                                
                    }.onDisappear {
                        self.clearBarChart()
                    }
                }
            }
            .navigationBarTitle(Text("Dashboard"), displayMode: .inline)
            .navigationBarItems(leading: refreshButton, trailing: signoutButton)
        }.onAppear {
            self.viewModel.getOsStatus()
            self.viewModel.getOsSummary()
        }
    }
    
    func newWedge(chartData: PieChartData) {
        withAnimation(.spring()) {
            let newWedge: Wedge
            switch chartData.dataName {
                case "Running": newWedge = Wedge(label: chartData.dataName,
                                                 chartValue: Double(chartData.dataValue),
                                                 hue: 0.3781, saturation: 0.9459, brightness: 0.7255)
                case "Stopped": newWedge = Wedge(label: chartData.dataName,
                                                 chartValue: Double(chartData.dataValue),
                                                 hue: 0.1253, saturation: 1.0, brightness: 0.9961)
                case "Terminated": newWedge = Wedge(label: chartData.dataName,
                                                    chartValue: Double(chartData.dataValue),
                                                    hue: 0.0, saturation: 0.9113, brightness: 0.9725)
                case "Error": newWedge = Wedge(label: chartData.dataName,
                                               chartValue: Double(chartData.dataValue),
                                               hue: 0.0786, saturation: 0.7628, brightness: 0.9922)
                default:
                newWedge = Wedge(label: chartData.dataName,
                                 chartValue: Double(chartData.dataValue), hue: 0.2242,
                                 saturation: 0.4701, brightness: 0.9176)
            }
            self.ring.addWedge(newWedge)
        }
    }
    
    func clearPieChart() {
        withAnimation(.easeInOut(duration: 1.0)) {
            self.ring.reset()
        }
    }
    
    func newBar(chartData: BarChartData) {
        withAnimation(.spring()) {
            let newBar: BarColumn
            newBar = BarColumn(chartValue: Double(chartData.dataValue),
                               label: chartData.dataName,
                               hue: 0.2242, saturation: 0.4701, brightness: 0.9176)
            self.barChart.addBar(newBar)
        }
    }
    
    func clearBarChart() {
        withAnimation(.easeInOut(duration: 1.0)) {
            self.barChart.reset()
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(UserData())
            .environmentObject(Ring())
            .environmentObject(BarChart())
    }
}
