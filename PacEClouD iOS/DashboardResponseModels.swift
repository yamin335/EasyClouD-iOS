//
//  DashboardResponseModels.swift
//  Pace Cloud
//
//  Created by rgl on 21/10/19.
//  Copyright © 2019 royalgreen. All rights reserved.
//

import Foundation

// MARK: - OSStatusModel
struct OSStatusModel: Codable {
    let resdata: PieResdata
}

// MARK: - PieResdata
struct PieResdata: Codable {
    let dashboardchartdata: [PieChartData]
}

// MARK: - PieChartData
struct PieChartData: Codable {
    let dataName: String
    let dataValue: Int
}

// MARK: - OSSummaryModel
struct OSSummaryModel: Codable {
    let resdata: BarResdata
}

// MARK: - BarResdata
struct BarResdata: Codable {
    let dashboardchartdata: [BarChartData]
}

// MARK: - PieChartData
struct BarChartData: Codable {
    let dataName: String
    let dataValue: Int
}
