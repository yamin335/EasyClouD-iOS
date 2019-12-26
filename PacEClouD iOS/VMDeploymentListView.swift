//
//  VMDeploymentListView.swift
//  Pace Cloud
//
//  Created by rgl on 4/11/19.
//  Copyright © 2019 royalgreen. All rights reserved.
//

import SwiftUI

struct VMDeploymentListView: View {
    
    @ObservedObject var viewModel: VirtualMachineViewModel
    // VM Lists
    @State var deploymentList = ["item - 0", "item - 1", "item - 2", "item - 3",
                                 "item - 4", "item - 5", "item - 6",
                                 "item - 7", "item - 8", "item - 9"]
    @State private var isLoading: Bool = false
    private let offset: Int = 10
    var page = 0
    var refreshButton: some View {
        Button(action: {
            self.viewModel.refreshUI()
        }) {
            Image("baseline_refresh_black_24pt")
                .imageScale(.large)
                .accessibility(label: Text("Refresh"))
                .padding()
                .foregroundColor(Color(red: 10.0 / 255, green: 185.0 / 255, blue: 57.0 / 255))
            
        }
    }
    
    var body: some View {
        ScrollView {
            Text ("Hi")
//            VStack {
//                ForEach(deploymentList, id: \.self) { item in
//                    VStack {
//                        Text(item).frame(height: 100)
//
//                        if self.isLoading && self.deploymentList.isItLastItem(item: item) {
//                            Divider()
//                            Text("Loading ...")
//                                .padding(.vertical)
//                        }
//                    }.onAppear {
//                        if self.shouldLoadNextPage(currentItem: item) {
//                            /*
//                             Simulated async behaviour:
//                             Creates items for the next page and
//                             appends them to the list after a short delay
//                             */
//                            self.isLoading = true
//                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
//                                self.page += 1
//                                let moreItems = self.getMoreItems(forPage: self.page, pageSize: self.pageSize)
//                                self.deploymentList.append(contentsOf: moreItems)
//
//                                self.isLoading = false
//                            }
//                        }
//                    }
//                }
//            }
//        }
//        .navigationBarItems(leading: refreshButton)
//        .onDisappear {
//            self.viewModel.pageNumber = -1
//            self.viewModel.deploymentList = []
//        }
//        .onReceive(self.viewModel.vmListPublisher.receive(on: RunLoop.main)) { deploymentList in
//            self.deploymentList = deploymentList
//        }
    }
}

struct VMDeploymentListView_Previews: PreviewProvider {
    static var previews: some View {
        VMDeploymentListView(viewModel: VirtualMachineViewModel())
    }
}

//extension String: Identifiable {
//    public var id: String {
//        return self
//    }
//}
//
//extension Array where Array.Element == String {
//    public func isItLastItem(item: String) -> Bool {
//        guard let itemIndex = lastIndex(where: { $0.id == item.id }) else {
//            return false
//        }
//        return itemIndex == self.endIndex
//    }
//}

//extension VMDeploymentListView {
//    private func shouldLoadNextPage(currentItem item: String) -> Bool {
//        guard let currentItemIndex = self.deploymentList.firstIndex(where: { $0.id == item.id } ) else {
//            return false
//        }
//        let lastIndex = self.deploymentList.count - 1
//        let offset = 10 //Load next page when 5 from bottom, adjust to meet needs
//        return currentItemIndex == lastIndex - offset
//
////            if deploymentList.count > 30 {
////                isLoading = true
////                viewModel.getVMList()
////            }
//    }
//}

/*
 In a real app you would probably fetch data
 from an external API.
 */
//    private func getMoreItems(forPage page: Int,
//                              pageSize: Int) -> [String] {
//        let maximum = ((page * pageSize) + pageSize) - 1
//        let moreItems: [String] = Array(deploymentList.count...maximum).map { "Item \($0)" }
//        return moreItems
//    }
}
