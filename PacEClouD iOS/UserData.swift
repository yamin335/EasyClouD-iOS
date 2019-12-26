//
//  UserData.swift
//  Pace Cloud
//
//  Created by rgl on 1/10/19.
//  Copyright © 2019 royalgreen. All rights reserved.
//

import SwiftUI
import Combine

final class UserData: ObservableObject  {
    @Published var isLoggedIn = false
    @Published var userId = ""
    @Published var shouldShowSplash = true
}

struct UserLocalStorage {
    private static let userDefault = UserDefaults.standard
    static func saveUser(user: User) {
        userDefault.set(user.userID, forKey: "userID")
        userDefault.set(user.userType, forKey: "userType")
        userDefault.set(user.userName, forKey: "userName")
        userDefault.set(user.fullName, forKey: "fullName")
        userDefault.set(user.displayName, forKey: "displayName")
        userDefault.set(user.email, forKey: "email")
        userDefault.set(user.companyID, forKey: "companyID")
        userDefault.set(user.balance, forKey: "balance")
        userDefault.set(user.activationProfileId, forKey: "activationProfileId")
        userDefault.set(user.companyName, forKey: "companyName")
        userDefault.set(user.status, forKey: "status")
        userDefault.set(user.type, forKey: "type")
    }
    
    static func getUser() -> User {
        var user = User()
        
        user.userID = userDefault.value(forKey: "userID") as? Int ?? 0
        user.userType = userDefault.value(forKey: "userType") as? Int ?? 0
        user.userName = userDefault.value(forKey: "userName") as? String ?? ""
        user.fullName = userDefault.value(forKey: "fullName") as? String ?? ""
        user.displayName = userDefault.value(forKey: "displayName") as? String ?? ""
        user.email = userDefault.value(forKey: "email") as? String ?? ""
        user.companyID = userDefault.value(forKey: "companyID") as? Int ?? 0
        user.balance = userDefault.value(forKey: "balance") as? Double ?? 0.0
        user.activationProfileId = userDefault.value(forKey: "activationProfileId") as? String ?? ""
        user.companyName = userDefault.value(forKey: "companyName") as? String ?? ""
        user.status = userDefault.value(forKey: "status") as? String ?? ""
        user.type = userDefault.value(forKey: "type") as? String ?? ""
        
        return user
    }
    
    static func clearUser(){
        userDefault.removeObject(forKey: "userID")
        userDefault.removeObject(forKey: "userType")
        userDefault.removeObject(forKey: "userName")
        userDefault.removeObject(forKey: "fullName")
        userDefault.removeObject(forKey: "displayName")
        userDefault.removeObject(forKey: "email")
        userDefault.removeObject(forKey: "companyID")
        userDefault.removeObject(forKey: "balance")
        userDefault.removeObject(forKey: "activationProfileId")
        userDefault.removeObject(forKey: "companyName")
        userDefault.removeObject(forKey: "status")
        userDefault.removeObject(forKey: "type")
        
    }
}

struct User {
    var userID: Int?
    var userType: Int?
    var userName, fullName, displayName, email: String?
    var companyID: Int?
    var balance: Double?
    var activationProfileId, companyName: String?
    var status, type: String?
    
    init() {
        self.userID = 0
        self.userType = 0
        self.userName = ""
        self.fullName = ""
        self.displayName = ""
        self.email = ""
        self.companyID = 0
        self.balance = 0.0
        self.activationProfileId = ""
        self.companyName = ""
        self.status = ""
        self.type = ""
    }
    
    init(userID: Int?, userType: Int?,
         userName: String?, fullName: String?,
         displayName: String?, email: String?,
         companyID: Int?, balance: Double?,
         activationProfileId: String?, companyName: String?,
         status: String?, type: String?) {
        
        self.userID = userID
        self.userType = userType
        self.userName = userName
        self.fullName = fullName
        self.displayName = displayName
        self.email = email
        self.companyID = companyID
        self.balance = balance
        self.activationProfileId = activationProfileId
        self.companyName = companyName
        self.status = status
        self.type = type
    }
}
