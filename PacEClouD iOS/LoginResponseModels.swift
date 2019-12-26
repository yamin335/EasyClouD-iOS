//
//  LoginResponseModels.swift
//  Pace Cloud
//
//  Created by rgl on 6/10/19.
//  Copyright © 2019 royalgreen. All rights reserved.
//

import Foundation

// MARK: - LoginResponse
struct LoginResponse: Codable {
    var resdata: LoginResdata
}

// MARK: - LoginResdata
struct LoginResdata: Codable {
    var loggeduser: Loggeduser?
    var message: String?
    var resstate: Bool?
}

// MARK: - Loggeduser
struct Loggeduser: Codable {
    var userID: Int?
    var userCode: String?
    var userType: Int?
    var roleID: String?
    var userName, fullName, displayName, email: String?
    var companyID: Int?
    var phone: String?
    var balance: Double?
    var activationProfileId, created, lastUpdated, companyName: String?
    var status, type: String?
}
