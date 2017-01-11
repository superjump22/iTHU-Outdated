//
//  WebAPI.swift
//  iTsinghua
//
//  Created by Guo Chen on 2016/11/11.
//  Copyright © 2016年 GuoChen@THU. All rights reserved.
//

import Foundation
import Alamofire


open class iTHUWEB {
    
    private static var sessionManager: Alamofire.SessionManager!
    private static let configuration = URLSessionConfiguration.default
    
    open static func login(username: String, password: String, successClosure: (() -> Void)? = nil, failureClosure: (() -> Void)? = nil, errorClosure: (() -> Void)? = nil) {
        
    }
    
}

