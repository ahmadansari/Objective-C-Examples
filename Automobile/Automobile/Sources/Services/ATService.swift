//
//  ATService.swift
//  Automobile
//
//  Created by Ahmad Ansari on 16/02/2018.
//  Copyright © 2018 Ahmad Ansari. All rights reserved.
//

import Foundation
import Alamofire
import AXReachability


typealias ServiceResponseHandler = (_ data: Any, _ error: Bool) -> Void

//MARK:- Service Helper
class ATService  {
    final var baseURL:String
    final var servicePath:String
    
    init(baseURL url:String,servicePath path:String) {
        self.baseURL = url
        self.servicePath = path
    }
    
    func peformGetRequest(parameters:[String:Any]?, responseHandler:@escaping (DataResponse<Any>?) -> Void) -> Void {
        if (AXReachability.shared().isConnectedToInternet()) {
            let queue = DispatchQueue.global()
            queue.async {
                var serviceURL = URL.init(string: self.baseURL)
                serviceURL?.appendPathComponent(self.servicePath)
                if serviceURL != nil {
                    Alamofire.request(serviceURL!,
                                      method: HTTPMethod.get,
                                      parameters: parameters,
                                      encoding: URLEncoding.queryString,
                                      headers: nil).responseJSON(completionHandler: { (response) in
                                        responseHandler(response)
                                      })
                }
            }
        } else {
            //No Connectivity
            responseHandler(nil)
        }
    }
}

//MARK:- Manufacturer Service
final class ATManufacturerService : ATService {
    init() {
        super.init(baseURL: ATConstants.baseURL,
                   servicePath: ATConstants.manufacturerList)
    }
    
    func getManufacturers(page:Int, completionHandler:ServiceResponseHandler?) -> Void {
        let parameters : [String:Any] = [ATKeys.page:page,
                                         ATKeys.pageSize:ATConstants.defaultPageSize,
                                         ATKeys.wa_key:ATConstants.serviceKey
        ]
        
        self.peformGetRequest(parameters: parameters) { (response) in
            if (response == nil || response?.error != nil) {
                let error = response?.error
                SLog.error(error as Any)
                if(completionHandler != nil) {
                    completionHandler!(error as Any, true)
                }
            } else {
                let json = response?.value as Any
                SLog.debug(json)
                if(completionHandler != nil) {
                    completionHandler!(json, false)
                }
            }
        }
    }
}

//MARK:- Model Service
final class ATModelService : ATService {
    init() {
        super.init(baseURL: ATConstants.baseURL,
                   servicePath: ATConstants.mainTypes)
    }
    
    func getModels(manufacturerId:Int32, page:Int, completionHandler:ServiceResponseHandler?) -> Void {
        let parameters : [String:Any] = [ATKeys.manufacturer:manufacturerId,
                                         ATKeys.page:page,
                                         ATKeys.pageSize:ATConstants.defaultPageSize,
                                         ATKeys.wa_key:ATConstants.serviceKey
        ]
        
        self.peformGetRequest(parameters: parameters) { (response) in
            if (response == nil || response?.error != nil) {
                let error = response?.error
                SLog.error(error as Any)
                if(completionHandler != nil) {
                    completionHandler!(error as Any, true)
                }
            } else {
                let json = response?.value as Any
                SLog.debug(json)
                if(completionHandler != nil) {
                    completionHandler!(json, false)
                }
            }
        }
    }
}
