//
//  DeploymentRowView.swift
//  Pace Cloud
//
//  Created by rgl on 30/10/19.
//  Copyright © 2019 royalgreen. All rights reserved.
//

import SwiftUI

struct DeploymentRowView: View {
    
    @ObservedObject var viewModel: VirtualMachineViewModel
    @State var deployment: ListCloudvm
    
    var editButton: some View {
        Button(action: {
            self.viewModel.deploymentRenamePublisher.send((true, self.deployment))
        }) {
            HStack(spacing: 2) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 18, weight: .light))
                    .imageScale(.large)
                    .accessibility(label: Text("Edit Deployment Name"))
                    .padding(.trailing, 0)
                    .foregroundColor(Color.gray)
                
                Text("Edit")
                    .font(.headline)
                    .foregroundColor(Color.gray)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(deployment.deploymentName)
                    .font(.system(size: 24))
                    .foregroundColor(Colors.greenTheme)
                Spacer()
                self.editButton
            }
            .padding(.top, 12)
            .padding(.bottom, 12)
            VStack(spacing: 0) {
                ForEach(deployment.vmLists, id: \.id) { item in
                    VStack(spacing: 0) {
                        Divider()
                        VMRowView(viewModel: self.viewModel, vm: item)
                    }
                }
            }
        }.padding(.leading, 16).padding(.trailing, 16)
    }
}
