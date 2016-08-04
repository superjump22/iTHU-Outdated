//
//  User.swift
//  iTHU
//
//  Created by 果小橙 on 16/7/30.
//  Copyright © 2016年 THU_GC. All rights reserved.
//

import Foundation
import RealmSwift

class User: Object {
    // 学号
    dynamic var id: String = ""
    // 密码
    dynamic var pass: String = ""
    // 
    dynamic var login: Bool = false
    let list = List<CourseList>()
    override static func primaryKey() -> String?
    {
        return "id"
    }

}