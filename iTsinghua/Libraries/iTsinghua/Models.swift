//
//  Models.swift
//  iTsinghua
//
//  Created by Guo Chen on 2016/11/11.
//  Copyright © 2016年 GuoChen@THU. All rights reserved.
//

import Foundation
import RealmSwift


open class State: Object {
    
    dynamic var id: Int8 = 0
    dynamic var username: String = ""
    dynamic var hasLoggedUser: Bool = false
    
    override open static func primaryKey() -> String? {
        return "id"
    }
    
}


open class User: Object {
    
    dynamic var username: String = ""
    dynamic var password: String = ""
    dynamic var isLogged: Bool = false
    let semesters = List<Semester>()
    
    override open static func primaryKey() -> String? {
        return "username"
    }
    
}


open class Semester: Object {
    
    dynamic var id: String = ""
    dynamic var schoolYear: Int16 = 2016
    // 0-Autumn, 1-Spring, 2-Summer
    dynamic var schoolTerm: Int8 = 0
    dynamic var user: User?
    let courses = List<Course>()
    
    override open static func primaryKey() -> String? {
        return "id"
    }
    
}


open class Course: Object {

    dynamic var id: String = ""
    dynamic var name: String = ""
    dynamic var semester: Semester?
    let notices = List<Notice>()
    let homeworks = List<Homework>()
    let files = List<File>()
    
    override open static func primaryKey() -> String? {
        return "id"
    }
    
}


open class Notice: Object {
    
    dynamic var id: String = ""
    dynamic var courseID: String = ""
    dynamic var title: String = ""
    dynamic var owner: String = ""
    dynamic var date: NSDate = NSDate()
    dynamic var isNew: Bool = false
    dynamic var course: Course?
    
    override open static func primaryKey() -> String? {
        return "id"
    }
    
}


open class Homework: Object {
    
    dynamic var id: String = ""
    dynamic var courseID: String = ""
    dynamic var recID: String = ""
    dynamic var title: String = ""
    dynamic var startDate: NSDate = NSDate()
    dynamic var deadLine: NSDate = NSDate()
    dynamic var isNew: Bool = false
    dynamic var course: Course?
    
    override open static func primaryKey() -> String? {
        return "id"
    }
}


open class File: Object {
    
    dynamic var id: String = ""
    dynamic var courseID: String = ""
    dynamic var title: String = ""
    dynamic var info: String = ""
    dynamic var size: String = ""
    dynamic var link: String = ""
    dynamic var date: NSDate = NSDate()
    dynamic var isNew: Bool = false
    dynamic var course: Course?
    
    override open static func primaryKey() -> String? {
        return "id"
    }
    
}
