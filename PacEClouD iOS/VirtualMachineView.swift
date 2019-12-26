//
//  VirtualMachineView.swift
//  Pace Cloud
//
//  Created by rgl on 16/10/19.
//  Copyright © 2019 royalgreen. All rights reserved.
//

import SwiftUI

struct VirtualMachineView: View {
    
//  @EnvironmentObject var userData: UserData
    @ObservedObject var viewModel = VirtualMachineViewModel()
    @State private var showLoader = false
    
    // Toasts
    @State var showSuccessToast = false
    @State var successMessage: String = ""
    @State var showErrorToast = false
    @State var errorMessage: String = ""
    @State var deployment: ListCloudvm?
    @State var showRenameDialog = false
    @State var showConfirmDialog = false
    @State var showNoteDialog = false
    @State var renameSaveDisabled = true
    
    @State var operationType = ""
    @State var vm: VMList?
    @State var firstNumber = 0
    @State var secondNumber = 0
    
    @State var confYesDisabled = true
    
    @State var note = ""
    
    struct MultilineTextField: UIViewRepresentable {
        @Binding var text: String
        
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
        
        func makeUIView(context: Context) -> UITextView {
            let view = UITextView()
            view.delegate = context.coordinator
            view.layer.borderWidth = 0.5
            view.layer.borderColor = UIColor.lightGray.cgColor
            view.font = UIFont.systemFont(ofSize: 16.0, weight: .light)
            view.layer.cornerRadius = 6
            view.isScrollEnabled = true
            view.isEditable = true
            view.isUserInteractionEnabled = true
            return view
        }
        
        func updateUIView(_ uiView: UITextView, context: Context) {
            uiView.text = text
        }
        
        class Coordinator : NSObject, UITextViewDelegate {
            
            var parent: MultilineTextField
            
            init(_ uiTextView: MultilineTextField) {
                self.parent = uiTextView
            }
            
            func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
                return true
            }
            
            func textViewDidChange(_ textView: UITextView) {
                self.parent.text = textView.text
            }
        }
    }
    
    var confirmationDialog: some View {
        ZStack {
            Color.black
                .blur(radius: 0.5, opaque: false)
                .opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    HStack {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 24, weight: .light))
                            .imageScale(.large)
                            .padding(.leading, 16)
                            .foregroundColor(Colors.color2)
                        Text("Are you sure to \(vm?.status == "Running" ? "stop" : "start") \"\(vm?.vmName ?? "this")\" VM?")
                            .font(.system(size: 20, weight: .light))
                            .foregroundColor(Colors.color2)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                    }
                    Spacer()
                }
                .padding(.top, 16)
                .padding(.trailing, 20)
                
                HStack {
                    Text("What is \(firstNumber) + \(secondNumber) ?")
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(Colors.color2).padding(.leading, 20)
                    Button(action: {
                        self.firstNumber = Int.random(in: 1 ..< 10)
                        self.secondNumber = Int.random(in: 1 ..< 10)
                        self.viewModel.confirmationOriginalAnswer
                            = String(self.firstNumber + self.secondNumber)
                        self.confYesDisabled = true
                    }) {
                        Image(systemName: "arrow.2.circlepath.circle.fill")
                            .font(.system(size: 24, weight: .light))
                            .imageScale(.large)
                            .foregroundColor(Colors.greenTheme)
                            .padding(.all, 1)
                    }
                    Spacer()
                }
                
                TextField("Answer", text: $viewModel.confirmtionAnswer)
                    .lineLimit(1)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                
                HStack(alignment: .center, spacing: 20) {
                    Spacer()
                    Button(action: {
                        self.showConfirmDialog = false
                    }) {
                        HStack{
                            Spacer()
                            Text("No")
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                        .background(Color.red)
                        .cornerRadius(2)
                    }
                    
                    Button(action: {
                        self.showConfirmDialog = false
                        self.viewModel.confirmtionAnswer = ""
                        if self.operationType == "Running" || self.operationType == "Stopped" {
                            self.viewModel.doStartStop(vm: self.vm)
                            self.viewModel.vmStartStopPublisher.send((self.vm?.id ?? "0", "block"))
                        } else if self.operationType == "Reboot" {
                            self.viewModel.doReboot(vm: self.vm)
                        }
                    }) {
                        HStack{
                            Spacer()
                            Text("Yes")
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                        .background(Colors.greenTheme)
                        .cornerRadius(2)
                    }
                    .disabled(self.confYesDisabled)
                    .onReceive(self.viewModel.confSaveButtonDisablePublisher.receive(on: RunLoop.main)) { isDisabled in
                        self.confYesDisabled = isDisabled
                    }
                }
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 6, style: .circular).fill(Color.white)
            .shadow(color: .black, radius: 15))
            .padding(.leading, 25)
            .padding(.trailing, 25)
        }
    }
    
    var noteUpdateDialog: some View {
        ZStack {
            Color.black
                .blur(radius: 0.5, opaque: false)
                .opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Image(systemName: "pencil.and.ellipsis.rectangle")
                        .font(.system(size: 24, weight: .light))
                        .imageScale(.large)
                        .padding(.leading, 20).foregroundColor(Colors.color2)
                    Text("Note")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(Colors.color2).padding(.top, 4)
                    Spacer()
                }
                .padding(.top, 16)
                MultilineTextField(text: $note).frame(height: 150)
                    .padding(.leading, 20).padding(.trailing, 20).padding(.top, 8)
                
                HStack(alignment: .center, spacing: 20) {
                    Spacer()
                    Button(action: {
                        self.showNoteDialog = false
                    }) {
                        HStack{
                            Spacer()
                            Text("Cancel").foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                        .background(Color.red)
                        .cornerRadius(2)
                    }
                    
                    Button(action: {
                        self.viewModel.doNoteUpdate(vm: self.vm, note: self.note)
                        self.showNoteDialog = false
                    }) {
                        HStack{
                            Spacer()
                            Text("Save").foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                        .background(Colors.greenTheme)
                        .cornerRadius(2)
                    }
                }
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 6, style: .circular)
            .fill(Color.white).shadow(color: .black, radius: 15))
            .padding(.leading, 25)
            .padding(.trailing, 25)
        }
    }
    
    var deploymentRenameDialog: some View {
        ZStack {
            Color.black
                .blur(radius: 0.5, opaque: false)
                .opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 24, weight: .light))
                        .imageScale(.large)
                        .padding(.leading, 16).foregroundColor(Colors.color2)
                    Text(UserLocalStorage.getUser().fullName ?? "Rename")
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(Colors.color2)
                    Spacer()
                }
                .padding(.top, 16)
                TextField("Deployment Name", text: $viewModel.deploymentName).lineLimit(1)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.leading, 20).padding(.trailing, 20).padding(.top, 8)
                
                HStack(alignment: .center, spacing: 20) {
                    Spacer()
                    Button(action: {
                        self.showRenameDialog = false
                    }) {
                        HStack{
                            Spacer()
                            Text("Cancel").foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                        .background(Color.red)
                        .cornerRadius(2)
                    }
                    
                    Button(action: {
                        self.viewModel.doRename(deployment: self.deployment)
                        self.showRenameDialog = false
                    }) {
                        HStack{
                            Spacer()
                            Text("Save").foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                        .background(Colors.greenTheme)
                        .cornerRadius(2)
                    }
                    .disabled(self.renameSaveDisabled)
                    .onReceive(self.viewModel.saveButtonDisablePublisher.receive(on: RunLoop.main)) { isDisabled in
                        self.renameSaveDisabled = isDisabled
                    }
                }
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 6, style: .circular)
                .fill(Color.white).shadow(color: .black, radius: 15))
            .padding(.leading, 25)
            .padding(.trailing, 25)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                DeploymentListView(viewModel: viewModel)
                    .onReceive(self.viewModel.deploymentRenamePublisher.receive(on: RunLoop.main)) {
                    (shouldShowDialog, deployment) in
                    self.showRenameDialog = shouldShowDialog
                    self.deployment = deployment
                    self.viewModel.deploymentName = deployment.deploymentName
                }
                .onReceive(self.viewModel.vmConfirmDialogPublisher.receive(on: RunLoop.main)) {
                    (shouldShowDialog, vm, opType) in
                    self.showConfirmDialog = shouldShowDialog
                    self.vm = vm
                    self.operationType = opType
                }
                .onReceive(self.viewModel.noteUpdateDialogPublisher.receive(on: RunLoop.main)) {
                    (shouldShowDialog, vm) in
                    self.showNoteDialog = shouldShowDialog
                    self.vm = vm
                    self.note = vm.vmNote ?? ""
                }
                
                if showNoteDialog {
                    noteUpdateDialog
                }
                
                if showRenameDialog {
                    deploymentRenameDialog
                }
                
                if showConfirmDialog {
                    confirmationDialog
                        .onAppear {
                            self.firstNumber = Int.random(in: 1 ..< 10)
                            self.secondNumber = Int.random(in: 1 ..< 10)
                            self.viewModel.confirmationOriginalAnswer
                                = String(self.firstNumber + self.secondNumber)
                    }
                }
                
                if self.showSuccessToast {
                    VStack {
                        Spacer()
                        SuccessToast(message: self.successMessage).onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation() {
                                    self.showSuccessToast = false
                                    self.successMessage = ""
                                }
                            }
                        }.padding(.all, 20)
                    }
                }

                if showErrorToast {
                    VStack {
                        Spacer()
                        ErrorToast(message: self.errorMessage).onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation() {
                                    self.showErrorToast = false
                                    self.errorMessage = ""
                                }
                            }
                        }.padding(.all, 20)
                    }
                }

                if showLoader {
                    SpinLoaderView()
                }
            }
            .navigationBarTitle(Text("Virtual Machines"), displayMode: .inline)
            .onReceive(self.viewModel.showLoader.receive(on: RunLoop.main)) { doingSomethingNow in
                self.showLoader = doingSomethingNow
            }
            .onReceive(self.viewModel.successToastPublisher.receive(on: RunLoop.main)) {
                showToast, message in
                self.successMessage = message
                withAnimation() {
                    self.showSuccessToast = showToast
                }
            }
            .onReceive(self.viewModel.errorToastPublisher.receive(on: RunLoop.main)) {
                showToast, message in
                self.errorMessage = message
                withAnimation() {
                    self.showErrorToast = showToast
                }
            }
        }
    }
}

struct VirtualMachineView_Previews: PreviewProvider {
    static var previews: some View {
        VirtualMachineView()
    }
}
