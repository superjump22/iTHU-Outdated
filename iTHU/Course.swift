//
//  Lesson.swift
//  LemonTHU
//
//  Created by 果小橙 on 16/7/5.
//  Copyright © 2016年 THU_GC. All rights reserved.
//

import Foundation
import RealmSwift

class Course: Object
{
    // 数据是否有效
    dynamic var useful: Bool = false
    // 课程属性: “必修”/“限选”/“任选”
    dynamic var character: String = ""
    // 学分: 2
    dynamic var credit: Int8 = 0
    // 百分成绩: 87
    dynamic var grade: Int8 = 0
    // 学年: "2014-2015夏季学期"
    dynamic var semester: String = ""
    // 绩点: "3.7"
    dynamic var gpa: Float = 0.0
    // 网络学堂id: "112559"
    dynamic var id: String = ""
    // 名字: "复变函数引论"
    dynamic var name: String = ""
    // 成绩等级: “A+”
    dynamic var level: String = ""
    // 新学堂还是老学堂
    dynamic var isNew: Bool = false
    // id为主键
    override static func primaryKey() -> String?
    {
        return "id"
    }
}

class CourseList: Object
{
    dynamic var page: Int = -1
    dynamic var semester: String = ""
    dynamic var compareStr: String = ""
    let list = List<Course>()
    override static func primaryKey() -> String?
    {
        return "semester"
    }
}

public class BBS: Object
{
    dynamic var course_id: String = ""
    dynamic var isNew: Bool = false
    dynamic var id: String = ""
    dynamic var title: String = ""
    dynamic var owner: String = ""
    dynamic var date: String = ""
    override public static func primaryKey() -> String?
    {
        return "id"
    }
}

public class HWK: Object
{
    dynamic var course_id: String = ""
    dynamic var isNew: Bool = false
    dynamic var id: String = ""
    dynamic var rec_id: String = ""
    dynamic var title: String = ""
    dynamic var startDate: String = ""
    dynamic var deadLine: String = ""
    override public static func primaryKey() -> String?
    {
        return "id"
    }
}

public class FIL: Object
{
    dynamic var course_id: String = ""
    dynamic var isNew: Bool = false
    dynamic var link: String = ""
    dynamic var id: String = ""
    dynamic var title: String = ""
    dynamic var date: String = ""
    dynamic var size: String = ""
    dynamic var info: String = ""
    override public static func primaryKey() -> String?
    {
        return "id"
    }
}