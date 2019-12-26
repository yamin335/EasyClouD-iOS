//
//  VirtualMachineViewModel.swift
//  Pace Cloud
//
//  Created by rgl on 27/10/19.
//  Copyright © 2019 royalgreen. All rights reserved.
//

import Foundation
import Combine

class VirtualMachineViewModel: NSObject, ObservableObject, URLSessionTaskDelegate {
    
    private var VMListSubscriber: AnyCancellable? = nil
    private var renameSubscriber: AnyCancellable? = nil
    private var startStopSubscriber: AnyCancellable? = nil
    private var rebootSubscriber: AnyCancellable? = nil
    private var noteSubscriber: AnyCancellable? = nil
    private var syncDatabaseAndRefreshSubscriber: AnyCancellable? = nil
    
    var showLoader = PassthroughSubject<Bool, Never>()
    var errorToastPublisher = PassthroughSubject<(Bool, String), Never>()
    var successToastPublisher = PassthroughSubject<(Bool, String), Never>()
    var deploymentRenamePublisher = PassthroughSubject<(Bool, ListCloudvm), Never>()
    var noteUpdateDialogPublisher = PassthroughSubject<(Bool, VMList), Never>()
    var vmConfirmDialogPublisher = PassthroughSubject<(Bool, VMList, String), Never>()
    private var deploymentRenameChecker: AnyCancellable!
    private var confirmationAnswerChecker: AnyCancellable!
    var saveButtonDisablePublisher = PassthroughSubject<Bool, Never>()
    var confSaveButtonDisablePublisher = PassthroughSubject<Bool, Never>()
    var objectWillChange = PassthroughSubject<Bool, Never>()
    var vmStartStopPublisher = PassthroughSubject<(String, String), Never>()
    private var validDigits = CharacterSet(charactersIn: "1234567890")
    
    // VM Lists
    @Published var deploymentList = [ListCloudvm]() {
        willSet {
            objectWillChange.send(true)
        }
    }
    @Published var deploymentName: String = ""
    @Published var confirmtionAnswer: String = ""
    public var confirmationOriginalAnswer = ""
    
    
    var pageNumber = -1
    
    let config = URLSessionConfiguration.default
    
    let loggedUser = UserLocalStorage.getUser()
    
    var urlSession: URLSession {
        get {
            config.timeoutIntervalForResource = 5
            config.waitsForConnectivity = true
            return URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue());
        }
    }
    
    override init() {
        super.init()
        deploymentRenameChecker = $deploymentName.sink { val in
            //check if the new string contains any invalid characters
            let regexPattern = "^(?=[A-Za-z]).*"
            let range = val.range(of: regexPattern, options: .regularExpression)
            if range == nil {
                self.saveButtonDisablePublisher.send(true)
                self.errorToastPublisher.send((true, "Invalid deployment name!"))
            } else {
                if val.count > 30 {
                    //clean the string (do this on the main thread to avoid overlapping with the current ContentView update cycle)
                    DispatchQueue.main.async {
                        self.saveButtonDisablePublisher.send(true)
                        self.deploymentName = String(val.prefix(30))
                        self.errorToastPublisher.send((true, "Deployment name too long!"))
                    }
                } else {
                    self.saveButtonDisablePublisher.send(false)
                }
            }
        }
        
        confirmationAnswerChecker = $confirmtionAnswer.sink { val in
            if val == self.confirmationOriginalAnswer {
                self.confSaveButtonDisablePublisher.send(false)
            } else {
                self.confSaveButtonDisablePublisher.send(true)
            }
            //check if the new string contains any invalid characters
            if val.rangeOfCharacter(from: self.validDigits.inverted) != nil {
                //clean the string (do this on the main thread to avoid overlapping with the current ContentView update cycle)
                DispatchQueue.main.async {
                    self.confirmtionAnswer = String(self.confirmtionAnswer.unicodeScalars.filter {
                        self.validDigits.contains($0)
                    })
                }
            }
        }
    }
    
    deinit {
        self.VMListSubscriber?.cancel()
        self.renameSubscriber?.cancel()
        self.confirmationAnswerChecker?.cancel()
        self.deploymentRenameChecker?.cancel()
        self.startStopSubscriber?.cancel()
        self.rebootSubscriber?.cancel()
        self.noteSubscriber?.cancel()
        self.syncDatabaseAndRefreshSubscriber?.cancel()
//        self.urlSession.invalidateAndCancel()
    }
    
    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        // waiting for connectivity, update UI, etc.
        self.errorToastPublisher.send((true, "Please turn on your internet connection!"))
    }
    
    func getVMList() {
        self.VMListSubscriber = self.executeVMListApiCall()?
            .sink(receiveCompletion: { completion in
                switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self.errorToastPublisher.send((true, error.localizedDescription))
                        print(error.localizedDescription)
                    //                        fatalError(error.localizedDescription)
                }
            }, receiveValue: { deploymentList in
                self.deploymentList.append(contentsOf: deploymentList)
                self.objectWillChange.send(true)
//                self.deploymentListPublisher.send(self.deploymentList)
//                if let resstate = loginResponse.resdata.resstate {
//                    self.loginStatusPublisher.send(resstate)
//                    if resstate == true {
//                        guard let loggedUser = loginResponse.resdata.loggeduser else {return}
//                        let user = User(userID: loggedUser.userID, userType: loggedUser.userType,
//                                        userName: loggedUser.userName, fullName: loggedUser.fullName,
//                                        displayName: loggedUser.displayName, email: loggedUser.email,
//                                        companyID: loggedUser.companyID, balance: loggedUser.balance,
//                                        activationProfileId: loggedUser.activationProfileId,
//                                        companyName: loggedUser.companyName, status: loggedUser.status,
//                                        type: loggedUser.type)
//                        UserLocalStorage.saveUser(user: user)
//                    } else {
//                        if let errMessage = loginResponse.resdata.message {
//                            switch errMessage {
//                                case "Username does not exist.":
//                                    self.errorToastPublisher.send((true, "Invalid username or password!"))
//                                case "Password is wrong.":
//                                    self.errorToastPublisher.send((true, "Invalid username or password!"))
//                                case "User not active.":
//                                    self.errorToastPublisher.send((true, "User not active."))
//                                default:
//                                    self.errorToastPublisher.send((true, "Something wrong, please try again!"))
//                            }
//                        }
//                    }
//                }
            })
    }
    
    func executeVMListApiCall() -> AnyPublisher<[ListCloudvm], Error>? {
        pageNumber += 1
        let jsonObject = ["UserID": loggedUser.userID ?? 0, "pageNumber": pageNumber, "pageSize": 30]
        
        let jsonArray = [jsonObject]
        if !JSONSerialization.isValidJSONObject(jsonArray) {
            print("Problem in parameter creation...")
            return nil
        }
        let tempJson = try? JSONSerialization.data(withJSONObject: jsonArray, options: [])
        guard let jsonData = tempJson else {
            print("Problem in parameter creation...")
            return nil
        }
        let tempParams = String(data: jsonData, encoding: String.Encoding.ascii)
        guard let params = tempParams else {
            print("Problem in parameter creation...")
            return nil
        }
        var queryItems = [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "param", value: params))
        guard var urlComponents = URLComponents(string: NetworkApiService.webBaseUrl+"/api/portal/cloudvmbyuserid") else {
            print("Problem in UrlComponent creation...")
            return nil
        }
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            return nil
        }
        
        var request = getCommonUrlRequest(url: url)
        request.httpMethod = "GET"
        
        return urlSession.dataTaskPublisher(for: request)
            .handleEvents(receiveSubscription: { _ in
                self.showLoader.send(true)
            }, receiveOutput: { _ in
                self.showLoader.send(false)
            }, receiveCompletion: { _ in
                self.showLoader.send(false)
            }, receiveCancel: {
                self.showLoader.send(false)
            })
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw NetworkApiService.APIFailureCondition.InvalidServerResponse
                }
                
//                let string = String(data: data, encoding: .utf8) ?? "[]"
//                print(string)
//                let stringData = Data(string.utf8)
//                let tempJsonData = try? JSONSerialization.data(withJSONObject: temp as Any, options: [])
//                do {
//                    let f = try JSONDecoder().decode([ListCloudvm].self, from: tempAgain?.data(using: .utf8) ?? data)
//                    print(f)
//                } catch {
//                    print(error)
//                }
                
                let jsonString = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                print(jsonString ?? "not right")
                let tempString = jsonString?["resdata"] as? [String: String]
                let tempAgain = tempString?["listCloudvm"]
                guard let finalData = tempAgain?.data(using: .utf8) else {
                    print("Problem in response data parsing...")
                    return data
                }
                
                return finalData
        }
        .retry(1)
        .decode(type: [ListCloudvm].self, decoder: JSONDecoder())
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    func doRename(deployment: ListCloudvm?) {
        self.renameSubscriber = self.executeRenameApiCall(deployment: deployment)?
            .sink(receiveCompletion: { completion in
                switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self.errorToastPublisher.send((true, error.localizedDescription))
                        print(error.localizedDescription)
                    //                        fatalError(error.localizedDescription)
                }
            }, receiveValue: { renameResponse in
                print(renameResponse)
                if let resstate = renameResponse.resdata.resstate {
                    if resstate == true {
                        self.refreshUI()
                        self.successToastPublisher.send((true, renameResponse.resdata.message ?? ""))
                    } else {
                        self.errorToastPublisher.send((true, renameResponse.resdata.message ?? ""))
                    }
                }
            })
    }
    
    func executeRenameApiCall(deployment: ListCloudvm?) -> AnyPublisher<DefaultResponse, Error>? {
        
        let jsonObject = ["UserID": loggedUser.userID ?? 0,
                          "id": deployment?.deploymentId,
                          "Name": deploymentName] as [String : Any?]
        let jsonArray = [jsonObject]
        
        if !JSONSerialization.isValidJSONObject(jsonArray) {
            print("Problem in parameter creation...")
            return nil
        }
        
        let tempJson = try? JSONSerialization.data(withJSONObject: jsonArray, options: [])
        guard let jsonData = tempJson else {
            print("Problem in parameter creation...")
            return nil
        }
        
        guard let urlComponents = URLComponents(string: NetworkApiService.webBaseUrl+"/api/portal/updatedeploymentname") else {
            print("Problem in UrlComponent creation...")
            return nil
        }
        
        guard let url = urlComponents.url else {
            return nil
        }
        
        //Request type
        var request = getCommonUrlRequest(url: url)
        request.httpMethod = "POST"
        
        //Setting headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //Setting body for POST request
        request.httpBody = jsonData
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .handleEvents(receiveSubscription: { _ in
                self.showLoader.send(true)
            }, receiveOutput: { _ in
                self.showLoader.send(false)
            }, receiveCompletion: { _ in
                self.showLoader.send(false)
            }, receiveCancel: {
                self.showLoader.send(false)
            })
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw NetworkApiService.APIFailureCondition.InvalidServerResponse
                }
                return data
        }
        .retry(1)
        .decode(type: DefaultResponse.self, decoder: JSONDecoder())
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    func doStartStop(vm: VMList?) {
        self.startStopSubscriber = self.executeStartStopApiCall(vm: vm)?
            .sink(receiveCompletion: { completion in
                switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self.errorToastPublisher.send((true, error.localizedDescription))
                        print(error.localizedDescription)
                }
            }, receiveValue: { startStopResponse in
                print(startStopResponse)
                if let resstate = startStopResponse.resdata.resstate {
                    if resstate == true {
                        DispatchQueue.main.asyncAfter(deadline: .now() + (vm?.status == "Running" ? 45.0 : 70.0)) {
                            self.refreshUI()
                            self.successToastPublisher.send((true, startStopResponse.resdata.message ?? ""))
                            self.vmStartStopPublisher.send((vm?.id ?? "0", "unblock"))
                        }
                    } else {
                        self.errorToastPublisher.send((true, startStopResponse.resdata.message ?? ""))
                    }
                }
            })
    }
    
    func executeStartStopApiCall(vm: VMList?) -> AnyPublisher<DefaultResponse, Error>? {
        
        let firstObject = ["UserID": loggedUser.userID ?? 0,
                          "id": vm?.id,
                          "IsTrue": vm?.status == "Running" ? true : false,
                          "CostPerHour": vm?.costPerHour] as [String : Any?]
        let secondObject = ["resourceType": "VIRTUAL_MACHINE",
                            "executionSpecs": [],
                            "executionResources": [["id": vm?.id]]] as [String : Any?]
        let thirdObject = ["acknowledgedByUser": true]
        let jsonArray = [firstObject, secondObject, thirdObject]
        
        if !JSONSerialization.isValidJSONObject(jsonArray) {
            print("Problem in parameter creation...")
            return nil
        }
        
        let tempJson = try? JSONSerialization.data(withJSONObject: jsonArray, options: [])
        guard let jsonData = tempJson else {
            print("Problem in parameter creation...")
            return nil
        }
        
        guard let urlComponents = URLComponents(string: NetworkApiService.webBaseUrl+"/api/portal/cloudvmstartstop") else {
            print("Problem in UrlComponent creation...")
            return nil
        }
        
        guard let url = urlComponents.url else {
            return nil
        }
        
        //Request type
        var request = getCommonUrlRequest(url: url)
        request.httpMethod = "POST"
        
        //Setting headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //Setting body for POST request
        request.httpBody = jsonData
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .handleEvents(receiveSubscription: { _ in
                self.showLoader.send(true)
            }, receiveOutput: { _ in
                self.showLoader.send(false)
            }, receiveCompletion: { _ in
                self.showLoader.send(false)
            }, receiveCancel: {
                self.showLoader.send(false)
            })
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw NetworkApiService.APIFailureCondition.InvalidServerResponse
                }
                return data
        }
        .retry(1)
        .decode(type: DefaultResponse.self, decoder: JSONDecoder())
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    func doReboot(vm: VMList?) {
        self.rebootSubscriber = self.executeRebootApiCall(vm: vm)?
            .sink(receiveCompletion: { completion in
                switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self.errorToastPublisher.send((true, error.localizedDescription))
                        print(error.localizedDescription)
                }
            }, receiveValue: { rebootResponse in
                print(rebootResponse)
                if let resstate = rebootResponse.resdata.resstate {
                    if resstate == true {
                        self.refreshUI()
                        self.successToastPublisher.send((true, rebootResponse.resdata.message ?? ""))
                    } else {
                        self.errorToastPublisher.send((true, rebootResponse.resdata.message ?? ""))
                    }
                }
            })
    }
    
    func executeRebootApiCall(vm: VMList?) -> AnyPublisher<DefaultResponse, Error>? {
        
        let firstObject = ["UserID": loggedUser.userID ?? 0,
                           "id": vm?.id,
                           "IsTrue": true,
                           "CostPerHour": vm?.costPerHour] as [String : Any?]
        let secondObject = ["resourceType": "VIRTUAL_MACHINE",
                            "executionSpecs": [],
                            "executionResources": [["id": vm?.id]]] as [String : Any?]
        let thirdObject = ["acknowledgedByUser": true]
        let jsonArray = [firstObject, secondObject, thirdObject]
        
        if !JSONSerialization.isValidJSONObject(jsonArray) {
            print("Problem in parameter creation...")
            return nil
        }
        
        let tempJson = try? JSONSerialization.data(withJSONObject: jsonArray, options: [])
        guard let jsonData = tempJson else {
            print("Problem in parameter creation...")
            return nil
        }
        
        guard let urlComponents = URLComponents(string: NetworkApiService.webBaseUrl+"/api/portal/cloudvmreboot") else {
            print("Problem in UrlComponent creation...")
            return nil
        }
        
        guard let url = urlComponents.url else {
            return nil
        }
        
        //Request type
        var request = getCommonUrlRequest(url: url)
        request.httpMethod = "POST"
        
        //Setting headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //Setting body for POST request
        request.httpBody = jsonData
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .handleEvents(receiveSubscription: { _ in
                self.showLoader.send(true)
            }, receiveOutput: { _ in
                self.showLoader.send(false)
            }, receiveCompletion: { _ in
                self.showLoader.send(false)
            }, receiveCancel: {
                self.showLoader.send(false)
            })
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw NetworkApiService.APIFailureCondition.InvalidServerResponse
                }
                return data
        }
        .retry(1)
        .decode(type: DefaultResponse.self, decoder: JSONDecoder())
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    func doNoteUpdate(vm: VMList?, note: String) {
        self.noteSubscriber = self.executeNoteApiCall(vm: vm, note: note)?
            .sink(receiveCompletion: { completion in
                switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self.errorToastPublisher.send((true, error.localizedDescription))
                        print(error.localizedDescription)
                }
            }, receiveValue: { noteResponse in
                print(noteResponse)
                if let resstate = noteResponse.resdata.resstate {
                    if resstate == true {
                        self.refreshUI()
                        self.successToastPublisher.send((true, noteResponse.resdata.message ?? ""))
                    } else {
                        self.errorToastPublisher.send((true, noteResponse.resdata.message ?? ""))
                    }
                }
            })
    }
    
    func executeNoteApiCall(vm: VMList?, note: String) -> AnyPublisher<DefaultResponse, Error>? {
        
        let firstObject = ["vmNote": note,
                           "id": vm?.id] as [String : Any?]
        
        let jsonArray = [firstObject]
        
        if !JSONSerialization.isValidJSONObject(jsonArray) {
            print("Problem in parameter creation...")
            return nil
        }
        
        let tempJson = try? JSONSerialization.data(withJSONObject: jsonArray, options: [])
        guard let jsonData = tempJson else {
            print("Problem in parameter creation...")
            return nil
        }
        
        guard let urlComponents = URLComponents(string: NetworkApiService.webBaseUrl+"/api/portal/updatevmnote") else {
            print("Problem in UrlComponent creation...")
            return nil
        }
        
        guard let url = urlComponents.url else {
            return nil
        }
        
        //Request type
        var request = getCommonUrlRequest(url: url)
        request.httpMethod = "POST"
        
        //Setting headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //Setting body for POST request
        request.httpBody = jsonData
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .handleEvents(receiveSubscription: { _ in
                self.showLoader.send(true)
            }, receiveOutput: { _ in
                self.showLoader.send(false)
            }, receiveCompletion: { _ in
                self.showLoader.send(false)
            }, receiveCancel: {
                self.showLoader.send(false)
            })
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw NetworkApiService.APIFailureCondition.InvalidServerResponse
                }
                return data
        }
        .retry(1)
        .decode(type: DefaultResponse.self, decoder: JSONDecoder())
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    func doSyncDatabaseAndRefresh() {
        self.syncDatabaseAndRefreshSubscriber = self.executeSyncDatabaseApiCall()?
            .sink(receiveCompletion: { completion in
                switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self.errorToastPublisher.send((true, error.localizedDescription))
                        print(error.localizedDescription)
                }
            }, receiveValue: { response in
                if let resstate = response.resdata.resstate {
                    if resstate == true {
                        self.refreshUI()
                        self.successToastPublisher.send((true, response.resdata.message ?? ""))
                    } else {
                        self.errorToastPublisher.send((true, response.resdata.message ?? ""))
                    }
                }
            })
    }
    
    func executeSyncDatabaseApiCall() -> AnyPublisher<DefaultResponse, Error>? {
        
        let jsonObject = ["pageNumber": "1",
                          "pageSize": "20",
                          "id": loggedUser.userID ?? 0] as [String : Any?]
        let jsonArray = [jsonObject]
        
        if !JSONSerialization.isValidJSONObject(jsonArray) {
            print("Problem in parameter creation...")
            return nil
        }
        
        let tempJson = try? JSONSerialization.data(withJSONObject: jsonArray, options: [])
        guard let jsonData = tempJson else {
            print("Problem in parameter creation...")
            return nil
        }
        
        guard let urlComponents = URLComponents(string: NetworkApiService.webBaseUrl+"/api/portal/clouduservmsyncwithlocaldb") else {
            print("Problem in UrlComponent creation...")
            return nil
        }
        
        guard let url = urlComponents.url else {
            return nil
        }
        
        //Request type
        var request = getCommonUrlRequest(url: url)
        request.httpMethod = "POST"
        
        //Setting headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //Setting body for POST request
        request.httpBody = jsonData
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .handleEvents(receiveSubscription: { _ in
                self.showLoader.send(true)
            }, receiveOutput: { _ in
                self.showLoader.send(false)
            }, receiveCompletion: { _ in
                self.showLoader.send(false)
            }, receiveCancel: {
                self.showLoader.send(false)
            })
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw NetworkApiService.APIFailureCondition.InvalidServerResponse
                }
                return data
        }
        .retry(1)
        .decode(type: DefaultResponse.self, decoder: JSONDecoder())
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    func refreshUI() {
        pageNumber = -1
        self.deploymentList = []
        getVMList()
    }
}
