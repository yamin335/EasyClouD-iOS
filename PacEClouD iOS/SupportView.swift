//
//  SupportView.swift
//  Pace Cloud
//
//  Created by rgl on 16/10/19.
//  Copyright © 2019 royalgreen. All rights reserved.
//

import SwiftUI
import MessageUI
import UIKit

struct SupportView: View {
    
    @EnvironmentObject var userData: UserData
    @State private var showSignoutAlert = false
    @Environment(\.presentationMode) var presentation
    @State var tel = "+88-09603-111999"
    @State var phone1 = "+88-01777706745"
    @State var phone2 = "+88-01777706746"
    /// The delegate required by `MFMailComposeViewController`
    private let mailComposeDelegate = MailDelegate()
    /// The delegate required by `MFMessageComposeViewController`
    private let messageComposeDelegate = MessageDelegate()
    
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
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    Image("pace_cloud_logo")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .padding(.top, 20)
                    Text("114, Motijheel (Level 9 & 17), Dhaka, 1000")
                        .font(.subheadline)
                        .foregroundColor(Colors.color2)
                        .padding(.top, 10)
                }.padding(.bottom, 20)
                
                Button(action: {
                    guard let url = URL(string: "tel://\(self.tel)"),
                        UIApplication.shared.canOpenURL(url) else { return }
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(url)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }) {
                    HStack {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 24, weight: .ultraLight))
                            .imageScale(.large)
                            .foregroundColor(Colors.greenTheme)
                        VStack(alignment: .leading) {
                            Text(tel)
                                .font(.callout)
                                .foregroundColor(Colors.color2)
                            Text("Telephone")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                }
                
                Button(action: {
                    //
                }) {
                    HStack {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 24, weight: .ultraLight))
                            .imageScale(.large)
                            .foregroundColor(Colors.greenTheme)
                        VStack(alignment: .leading) {
                            Text(phone1)
                                .font(.callout)
                                .foregroundColor(Colors.color2)
                            Text("Mobile")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                }
                
                Button(action: {
                    self.presentMessageCompose()
                }) {
                    HStack {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 24, weight: .ultraLight))
                            .imageScale(.large)
                            .foregroundColor(Colors.greenTheme)
                        VStack(alignment: .leading) {
                            Text(phone2)
                                .font(.callout)
                                .foregroundColor(Colors.color2)
                            Text("Mobile")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                }
                
                Button(action: {
                    // Present the view controller modally.
                    self.presentMailCompose()
                }) {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 24, weight: .ultraLight))
                            .imageScale(.large)
                            .foregroundColor(Colors.color3)
                        VStack(alignment: .leading) {
                            Text("support@royalgreen.net")
                                .font(.callout)
                                .foregroundColor(Colors.color2)
                            Text("Email")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                }
                
                Button(action: {
                    let webURL = NSURL(string: "https://www.royalgreen.net")!
                    //redirect to safari
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(webURL as URL, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(webURL as URL)
                    }
                }) {
                    HStack {
                        Image(systemName: "globe")
                            .font(.system(size: 24, weight: .ultraLight))
                            .imageScale(.large)
                            .foregroundColor(Colors.color4)
                        VStack(alignment: .leading) {
                            Text("www.royalgreen.net")
                                .font(.callout)
                                .foregroundColor(Colors.color2)
                            Text("Web")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                }
                
                HStack {
                    Image("icons8_facebook_circled_36")
                        .resizable()
                        .frame(width: 36, height: 36)
                    VStack(alignment: .leading) {
                        Text("www.facebook.com/Royalgreenbd")
                            .font(.callout)
                            .foregroundColor(Colors.color2)
                        Text("Facebook")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }.padding(.top, 5).onTapGesture {
                    let screenName = "Royalgreenbd"
                    let appURL = NSURL(string: "facebook://user?screen_name=\(screenName)")!
                    let webURL = NSURL(string: "https://facebook.com/\(screenName)")!
                    
                    if UIApplication.shared.canOpenURL(appURL as URL) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(appURL as URL, options: [:], completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(appURL as URL)
                        }
                    } else {
                        //redirect to safari because the user doesn't have facebook app
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(webURL as URL, options: [:], completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(webURL as URL)
                        }
                    }
                }
                Spacer()
            }
            .padding(.all, 20)
            .navigationBarTitle(Text("Support"), displayMode: .inline)
            .navigationBarItems(trailing: signoutButton)
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController,
                               didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        // Check the result or perform other tasks.
        
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: The mail part
extension SupportView {
    
    /// Delegate for view controller as `MFMailComposeViewControllerDelegate`
    private class MailDelegate: NSObject, MFMailComposeViewControllerDelegate {
        
        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            //Customize here
            controller.dismiss(animated: true, completion: nil)
        }
        
    }
    
    /// Present an mail compose view controller modally in UIKit environment
    private func presentMailCompose() {
        guard MFMailComposeViewController.canSendMail() else {
            // show failure alert
            return
        }
        
        let vc = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController
        
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = mailComposeDelegate
        // Configure the fields of the interface.
        composeVC.setToRecipients(["address@example.com"])
        composeVC.setSubject("Hello!")
        composeVC.setMessageBody("Hello from California!", isHTML: false)
        
        vc?.present(composeVC, animated: true)
    }
}

// MARK: The message part
extension SupportView {
    
    /// Delegate for view controller as `MFMessageComposeViewControllerDelegate`
    private class MessageDelegate: NSObject, MFMessageComposeViewControllerDelegate {
        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            // Customize here
            controller.dismiss(animated: true, completion: nil)
        }
        
    }
    
    /// Present an message compose view controller modally in UIKit environment
    private func presentMessageCompose() {
        guard MFMessageComposeViewController.canSendText() else {
            return
        }
        let vc = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController
        
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = messageComposeDelegate
        
        //Customize here
        
        vc?.present(composeVC, animated: true)
    }
}

struct SupportView_Previews: PreviewProvider {
    static var previews: some View {
        SupportView().environmentObject(UserData())
    }
}