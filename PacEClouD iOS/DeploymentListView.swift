//
//  DeploymentListView.swift
//  Pace Cloud
//
//  Created by rgl on 30/10/19.
//  Copyright © 2019 royalgreen. All rights reserved.
//
import UIKit
import SwiftUI

struct DeploymentListView: View {
    
    @ObservedObject var viewModel: VirtualMachineViewModel
    @EnvironmentObject var userData: UserData
    @State private var isLoading: Bool = false
    @State var totalVMs = ""
    @State var runningVMs = ""
    @State var firstTime = true
    private let offset: Int = 10
    
    var refreshButton: some View {
        Button(action: {
            self.viewModel.doSyncDatabaseAndRefresh()
        }) {
            Image(systemName: "arrow.clockwise")
                .font(.system(size: 18, weight: .light))
                .imageScale(.large)
                .accessibility(label: Text("Refresh"))
                .padding()
                .foregroundColor(Colors.greenTheme)
            
        }
    }
    
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
    
    var vmStatus: some View {
        HStack(spacing: 6) {
            Text("Running VM:").font(.system(size: 24.0)).foregroundColor(Colors.color2)
            Text(runningVMs).font(.system(size: 24.0)).foregroundColor(Colors.color2)
            Text("of").font(.system(size: 24.0)).foregroundColor(Colors.color2)
            Text(totalVMs).font(.system(size: 24.0)).foregroundColor(Colors.color2)
            Spacer()
        }
        .frame(minHeight: 0, maxHeight: 50)
        .padding(.leading, 20)
        .background(Colors.color1)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if totalVMs != "" {
                vmStatus
            }
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(self.viewModel.deploymentList, id: \.deploymentId) { item in
                        VStack(spacing: 0) {
                            DeploymentRowView(viewModel: self.viewModel, deployment: item)
                            if !self.viewModel.deploymentList.isLastItem(item: item) {
                                Divider()
                            }
                            
                            if self.isLoading && self.viewModel.deploymentList.isLastItem(item: item) {
                                Divider()
                                Text("Loading ...")
                                    .padding(.vertical)
                            }
                        }.onAppear {
                            self.listItemAppears(item)
                            if self.firstTime {
                                self.totalVMs = String(item.totalNumberOfVMs ?? 0)
                                self.runningVMs = String(item.totalNumberOfRunningVMs ?? 0)
                                self.firstTime = false
                            }
                        }
                    }
                }
            }
            .navigationBarItems(leading: refreshButton, trailing: signoutButton)
            .onAppear {
                self.viewModel.getVMList()
            }
            .onDisappear {
                self.viewModel.pageNumber = -1
                self.viewModel.deploymentList = []
            }
        }
    }
}

struct DeploymentListView_Previews: PreviewProvider {
    static var previews: some View {
        DeploymentListView(viewModel: VirtualMachineViewModel()).environmentObject(UserData())
    }
}


extension RandomAccessCollection where Self.Element == ListCloudvm {
    
    func isLastItem(item: ListCloudvm) -> Bool {
        guard !isEmpty else {
            return false
        }
        
        guard let itemIndex = firstIndex(where: { $0.deploymentId == item.deploymentId }) else {
            return false
        }
        
        let distance = self.distance(from: itemIndex, to: endIndex)
        return distance == 1
    }
    
    func isThresholdItem(offset: Int, item: ListCloudvm) -> Bool {
        guard !isEmpty else {
            return false
        }
        
        guard let itemIndex = firstIndex(where: { $0.deploymentId == item.deploymentId }) else {
            return false
        }
        
        let distance = self.distance(from: itemIndex, to: endIndex)
        let offset = offset < count ? offset : count - 1
        return offset == (distance - 1)
    }
}

extension DeploymentListView {
    private func listItemAppears(_ item: ListCloudvm) {
        if self.viewModel.deploymentList.isThresholdItem(offset: offset,
                                          item: item) {
            print("Paging Working...")
            if self.viewModel.deploymentList.count > 30 {
                isLoading = true
                viewModel.getVMList()
                print("Working...")
            }
            
            /*
             Simulated async behaviour:
             Creates items for the next page and
             appends them to the list after a short delay
             */
            //            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            //                self.page += 1
            //                let moreItems = self.getMoreItems(forPage: self.page, pageSize: self.pageSize)
            //                self.items.append(contentsOf: moreItems)
            //
            //                self.isLoading = false
            //            }
        }
    }
    
    /*
     In a real app you would probably fetch data
     from an external API.
     */
//    private func getMoreItems(forPage page: Int,
//                              pageSize: Int) -> [String] {
//        let maximum = ((page * pageSize) + pageSize) - 1
//        let moreItems: [String] = Array(items.count...maximum).map { "Item \($0)" }
//        return moreItems
//    }
}
