//
//  VirtualMachineResponseModels.swift
//  Pace Cloud
//
//  Created by rgl on 28/10/19.
//  Copyright © 2019 royalgreen. All rights reserved.
//

import Foundation

// MARK: - VirtualMachineList
struct VirtualMachineList: Codable {
    let listCloudvm: [ListCloudvm]
}

// MARK: - ListCloudvm
struct ListCloudvm: Codable {
    let depCloudUserId: Int?
    let deploymentName: String
    let serviceId, cloudId: Int?
    let deploymentId: Int
    let vmLists: [VMList]
    let recordsTotal, totalNumberOfVMs, totalNumberOfRunningVMs, totalCloudCost: Int?
    let totalNodeHours: Int?
    let IsSyncVM: Bool?
}

// MARK: - VMList
struct VMList: Codable {
    let userId: Int?
    let id: String?
    let numberOfCpus, memorySize, storageSize: Int?
    let osName: String?
    let costPerHour: Double?
    let hostName: String?
    let approxCostPerMonth: Double?
    let status, cloudId, cloudAccountId, regionId: String?
    let parentJobId, parentJobStatus, appId, vmName: String?
    let appIcon, appVersion, publicIpAddresses, privateIpAddresses: String?
    let cloudCost: Double?
    let nodeHours: String?
    let running: Bool?
    let runTime: Int?
    let vmNote, serviceTierId: String?
    let noOfNic, serviceId, depCloudId: Int?
    let isProcessing, isTrial: Bool?
}
