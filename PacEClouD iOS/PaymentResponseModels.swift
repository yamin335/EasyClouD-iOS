//
//  PaymentResponseModels.swift
//  Pace Cloud
//
//  Created by rgl on 14/11/19.
//  Copyright © 2019 royalgreen. All rights reserved.
//

import Foundation

// MARK: - UserBalanceModel
struct UserBalanceModel: Codable {
    let resdata: BalanceResData
}

// MARK: - BalanceResData
struct BalanceResData: Codable {
    let billCloudUserBalance: BillCloudUserBalance
}

// MARK: - BillCloudUserBalance
struct BillCloudUserBalance: Codable {
    let cloudUserId: Int?
    let balanceAmount: Double?
    let isActive: Bool?
    let companyId: Int?
    let createDate: String?
    let createdBy: Int?
}

// MARK: - LastRechargeBalance
struct LastRechargeBalance: Codable {
    let resdata: LastRechargeResdata
}

// MARK: - LastRechargeResdata
struct LastRechargeResdata: Codable {
    let objBilCloudUserLedger: LastRechargeUserLedger
}

// MARK: - LastRechargeUserLedger
struct LastRechargeUserLedger: Codable {
    let cloudUserLedgerId: Int?
    let cloudUserId: Int?
    let vmid: Int?
    let transactionDate: String?
    let debitAmount: Double?
    let creditAmount: Double?
    let balanceAmount: Double?
    let particulars: String?
    let isActive: Bool?
    let companyId: Int?
    let createDate: String?
    let createdBy: Int?
}

// MARK: - PostAmountResponse
struct PostAmountResponse: Codable {
    let resdata: PostAmountResdata
}

// MARK: - PostAmountResdata
struct PostAmountResdata: Codable {
    let message: String?
    let resstate: Bool?
    let paymentProcessUrl: String?
    let paymentStatusUrl: String?
    let amount: String?
}

// MARK: - FosterStatusCheckModel
struct FosterStatusCheckModel: Codable {
    let resdata: FosterStatusResdata
}

// MARK: - FosterStatusResdata
struct FosterStatusResdata: Codable {
    let resstate: Bool?
    let fosterRes: String?
}

// MARK: - FosterModel
struct FosterModel: Codable {
    let MerchantTxnNo: String?
    let TxnResponse: String?
    let TxnAmount: String?
    let Currency: String?
    let ConvertionRate: String?
    let OrderNo: String?
    let fosterid: String?
    let hashkey: String?
    let message: String?
}

// MARK: - BKashTokenResponse
struct BKashTokenResponse: Codable {
    let resdata: BKashTokenResdata?
}

// MARK: - BKashTokenResdata
struct BKashTokenResdata: Codable {
    let resstate: Bool?
    let tModel: TModel?
}

// MARK: - TModel
struct TModel: Codable {
    let token: String?
    let appKey: String?
    let currency: String?
    let marchantInvNo: String?
}
