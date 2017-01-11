//
//  RealmAPI.swift
//  iTsinghua
//
//  Created by Guo Chen on 2016/11/11.
//  Copyright © 2016年 GuoChen@THU. All rights reserved.
//

import Foundation
import RealmSwift


open class iTHUREALM {
    
    open static let realm = try! Realm()
    open static var username: String = "app"
    
    open static func setDefaultRealm(realmName: String = "app") {
        username = realmName
        var config = Realm.Configuration(
            schemaVersion: 2,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 2) {
                    
                }
        })
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("\(realmName).realm")
        Realm.Configuration.defaultConfiguration = config
    }
    
    open static func addOrUpdate(object: Object) {
        try! realm.write {
            realm.add(object, update: true)
        }
    }
    
    open static func add(object: Object) {
        try! realm.write {
            realm.add(object)
        }
    }
    
}
