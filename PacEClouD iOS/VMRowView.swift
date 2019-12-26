//
//  VMRowView.swift
//  Pace Cloud
//
//  Created by rgl on 31/10/19.
//  Copyright © 2019 royalgreen. All rights reserved.
//

import SwiftUI

struct VMRowView: View {
    
    @ObservedObject var viewModel: VirtualMachineViewModel
    @State var vm: VMList
    @State var showActionPopup = false
    @State var blockPopupMenu = false
    
    var vmImage: some View {
        Image("\(vm.appIcon?.split(separator: ".")[0] ?? "default")")
            .resizable()
            .frame(width: 60, height: 60)
    }
    
    var vmDetails: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                Text(vm.vmName ?? "No Name")
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                    .foregroundColor(Colors.color2)
                Circle()
                    .frame(width: 18, height: 18)
                    .foregroundColor(vm.status == "Stopped" ? Color.red : Colors.greenTheme)
                    .padding(.all, 1)
                if blockPopupMenu {
                    SpinLoaderSmall()
                        .frame(width: 17, height: 17)
                        .overlay(Circle().stroke(Color.blue, lineWidth:2).frame(width: 17, height: 17))
                        .padding(.all, 1)
                }

                Spacer()
            }.padding(.bottom, 4)
            Text("Runtime: \(vm.nodeHours ?? "0.00")")
                .font(.footnote)
                .foregroundColor(Color.gray)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
            Divider().padding(.top, 2).padding(.bottom, 2)
            Text("Cost/Hour: \(getRoundedValue(value: vm.costPerHour ?? 0.00, roundBy: 2))")
                .font(.footnote)
                .foregroundColor(Color.gray)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
        }
    }
    
    var actionButton: some View {
        Button(action: {
            withAnimation {
                self.showActionPopup.toggle()
            }
        }) {
            HStack(spacing: 2) {
                Text("Action").foregroundColor(Colors.color2).padding(.trailing, 3)
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .light))
                    .imageScale(.large).foregroundColor(Colors.color2).padding(.trailing, 4)
            }
            .padding(.trailing, 5)
            .padding(.leading, 10)
            .padding(.top, 4)
            .padding(.bottom, 4)
            .overlay (
                RoundedRectangle(cornerRadius: 4, style: .circular)
                    .stroke(Color.gray, lineWidth: 0.5)
            )
        }
    }
    
    var actionMenu: some View {
        HStack {
            Spacer()
            VStack(spacing: 0) {
                ZStack {
                    VStack(spacing: 0) {
                        Button(action: {
                            self.viewModel.vmConfirmDialogPublisher.send((true, self.vm, self.vm.status ?? "Start"))
                            self.showActionPopup.toggle()
                        }) {
                            HStack {
                                Image(vm.status == "Running" ? "baseline_toggle_off_black_24" : "baseline_toggle_on_black_24")
                                    .padding(.leading, 16)
                                    .foregroundColor(vm.status == "Running" ? Color.red : Colors.greenTheme)
                                Text(vm.status == "Running" ? "Stop" : "Start")
                                    .foregroundColor(Colors.color2)
                                Spacer()
                            }
                            .frame(width: 150, height: 30)
                        }
                        
                        Divider()
                        
                        Button(action: {
                            self.viewModel.vmConfirmDialogPublisher.send((true, self.vm, "Reboot"))
                            self.showActionPopup.toggle()
                        }) {
                            HStack {
                                Image(systemName: "arrow.2.squarepath")
                                    .font(.system(size: 14, weight: .light))
                                    .imageScale(.large)
                                    .padding(.leading, 16)
                                    .foregroundColor(Colors.color2)
                                Text("Reboot").foregroundColor(Colors.color2)
                                Spacer()
                            }
                            .frame(width: 150, height: 30)
                        }
                        
                        Divider()
                        
                        Button(action: {
                            self.viewModel.noteUpdateDialogPublisher.send((true, self.vm))
                            self.showActionPopup.toggle()
                        }) {
                            HStack {
                                Image(systemName: "square.and.pencil")
                                    .font(.system(size: 14, weight: .light))
                                    .imageScale(.large)
                                    .padding(.leading, 20).foregroundColor(Colors.color2)
                                Text("Note").foregroundColor(Colors.color2)
                                Spacer()
                            }
                            .frame(width: 150, height: 30)
                        }
                    }
                    if blockPopupMenu {
                        Button(action: {
                            self.showActionPopup.toggle()
                        }) {
                            ZStack {
                                Color.black
                                    .blur(radius: 0.5, opaque: false)
                                    .opacity(0.75)
                                Text("Close Menu").foregroundColor(.white)
                            }
                            .frame(minWidth:0 , maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        }
                    }
                }
            }
            .frame(width: 150, height: 90).background(Color.white)
            .cornerRadius(4).shadow(color: .black, radius: 20)
        }
    }
    
    var body: some View {
        ZStack {
            HStack(alignment: .center, spacing: 8) {
                vmImage
                vmDetails
                actionButton
            }
            .padding(.bottom, 16)
            .padding(.top, 16)
            .onReceive(self.viewModel.vmStartStopPublisher.receive(on: RunLoop.main)) { id, action in
                if id == self.vm.id {
                    if action == "block" {
                        self.blockPopupMenu = true
                    } else {
                        self.blockPopupMenu = false
                    }
                }
            }
            
            if showActionPopup {
                HStack {
                    Spacer()
                    actionMenu
                }.padding(.trailing, 70)
            }
        }
    }
    
    func getRoundedValue(value: Double, roundBy: Int) -> Double {
        let result = (value * pow(10.0, Double(roundBy))).rounded() / pow(10.0, Double(roundBy))
        return result
    }
    
}

//
//struct VMRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        VMRowView(deployment: VMList())
//    }
//}
