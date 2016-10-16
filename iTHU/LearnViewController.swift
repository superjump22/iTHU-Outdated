//
//  FirstViewController.swift
//  iTHU
//
//  Created by 果小橙 on 16/7/29.
//  Copyright © 2016年 THU_GC. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework
import Alamofire
import EasyTipView
import Eureka
import Fuzi
import QuickLook
import WebKit

class LearnViewController: SwipeViewController {
    
    var flag: Bool = true
    
    override func viewWillAppear(animated: Bool) {
        if flag {
            flag = false
            super.viewWillAppear(animated)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let stb = UIStoryboard(name: "Design", bundle: nil)
        let realm = try! Realm()
        let courseLists = realm.objects(CourseList).sorted("compareStr", ascending: false)
        let page_one = stb.instantiateViewControllerWithIdentifier("CourseTableViewController") as! CourseTableViewController
        page_one.courseLists = courseLists.filter("page == 1")
        page_one.page = 1
        page_one.title = "秋季"
        
        
        let page_two = stb.instantiateViewControllerWithIdentifier("CourseTableViewController") as! CourseTableViewController
        page_two.courseLists = courseLists.filter("page == 2")
        page_two.page = 2
        page_two.title = "更早"
        
        
        let page_three = stb.instantiateViewControllerWithIdentifier("CourseTableViewController") as! CourseTableViewController
        page_three.courseLists = courseLists.filter("page == 1 OR page == 2")
        page_three.page = 3
        page_three.title = "全部"
        
        setViewControllerArray([page_one, page_two, page_three])
//        setFirstViewController(1)
        setFirstViewController(0)
        setSelectionBar(40, height: 2, color: UIColor(red: 0.23, green: 0.55, blue: 0.92, alpha: 1.0))
        setButtonsWithSelectedColor(UIFont(name: "HelveticaNeue-Light", size: 16)!, color: UIColor.darkGrayColor(), selectedColor: UIColor.blackColor())
        setButtonsOffset(30, gap: 8, bottomOffset: 2)
        
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: nil)
        barButtonItem.tintColor = UIColor(red: 0.23, green: 0.55, blue: 0.92, alpha: 1.0)
        setNavigationWithItem(UIColor.whiteColor(), leftItem: nil, rightItem: barButtonItem)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

class CourseCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var bbsNewLabel: UILabel!
    
    @IBOutlet weak var bbsLabel: UILabel!
    
    @IBOutlet weak var hwkNewLabel: UILabel!
    
    @IBOutlet weak var hwkLabel: UILabel!
    
    @IBOutlet weak var fileNewLabel: UILabel!
    
    @IBOutlet weak var fileLabel: UILabel!
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    @IBOutlet weak var pushIcon: UIImageView!
    
    @IBOutlet weak var mask: UIView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
        activity.hidesWhenStopped = true
    }
    
}

class CourseTableViewController: UITableViewController {
    
    var courseLists: Results<CourseList>!
    var page: Int!
    let realm = try! Realm()
    let stb = UIStoryboard(name: "Design", bundle: nil)
    var useful: [[Bool]] = []
    var startLoading: [[Bool]] = []
    var errorFlag: [[Bool]] = []
    var tipView: EasyTipView!
    var preferences: EasyTipView.Preferences!
    var selectIndex : NSIndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(UINib(nibName:"CourseCell", bundle:nil), forCellReuseIdentifier:"CourseCell")
        for i in 0..<courseLists.count
        {
            useful.append([Bool]())
            startLoading.append([Bool]())
            errorFlag.append([Bool]())
            for _ in 0..<courseLists[i].list.count {
                useful[i].append(false)
                startLoading[i].append(false)
                errorFlag[i].append(false)
            }
        }
        preferences = EasyTipView.Preferences()
        preferences.drawing.font = UIFont(name: "HelveticaNeue-Light", size: 16)!
        preferences.drawing.foregroundColor = UIColor.whiteColor()
        preferences.drawing.backgroundColor = UIColor(hexString: "7241B7", withAlpha: 0.9)
        preferences.drawing.arrowHeight = 24.0
        preferences.drawing.arrowWidth = 24.0
        preferences.positioning.maxWidth = UIScreen.mainScreen().bounds.width * 0.618
        preferences.animating.showDuration = 0.618
        preferences.animating.dismissDuration = 0.618
        preferences.drawing.arrowPosition = .Top
        tipView = EasyTipView(text: "")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.parentViewController?.navigationItem.rightBarButtonItem?.target = self
        self.parentViewController?.navigationItem.rightBarButtonItem?.action = #selector(self.refresh(_:))
        if selectIndex != nil {
            let cell = tableView.cellForRowAtIndexPath(selectIndex) as! CourseCell
            cell.pushIcon.hidden = true
            cell.activity.startAnimating()
            test(courseLists[selectIndex.section].list[selectIndex.row].id, indexPath: selectIndex)
            selectIndex = nil
        }
    }
    
    func refresh(sender: UIBarButtonItem) {
        self.tipView.dismiss()
        for i in 0..<courseLists.count
        {
            for j in 0..<courseLists[i].list.count {
                useful[i][j] = false
                startLoading[i][j] = false
                errorFlag[i][j] = false
            }
        }
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("CourseCell", forIndexPath: indexPath) as! CourseCell

        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        
        guard case let cell as CourseCell = cell else
        {
            return
        }
        
        let course = courseLists[indexPath.section].list[indexPath.row]
        let course_id: String = course.id
        let course_name: String = course.name
        cell.nameLabel.text = course_name
        cell.nameLabel.textColor = UIColor.blackColor()
        cell.bbsNewLabel.textColor = UIColor.blackColor()
        cell.hwkNewLabel.textColor = UIColor.blackColor()
        cell.fileNewLabel.textColor = UIColor.blackColor()
        cell.mask.backgroundColor = UIColor.whiteColor()
        cell.backgroundColor = UIColor.clearColor()
        
        if errorFlag[indexPath.section][indexPath.row] {
            useful[indexPath.section][indexPath.row] = false
            //            errorFlag[indexPath.section][indexPath.row] = false
            startLoading[indexPath.section][indexPath.row] = false
            cell.activity.stopAnimating()
            cell.pushIcon.hidden = true
            cell.mask.backgroundColor = UIColor.clearColor()
            cell.backgroundColor = UIColor(hexString: "ff0000", withAlpha: 0.2)
        } else if useful[indexPath.section][indexPath.row] {
            let bbsLists = realm.objects(BBS).filter("course_id == %@", course_id)
            let bbsCount = bbsLists.count
            let bbsNewCount = bbsLists.filter("isNew == true").count
            
            let hwkLists = realm.objects(HWK).filter("course_id == %@", course_id)
            let hwkCount = hwkLists.count
            let hwkNewCount = hwkLists.filter("isNew == true").count
            
            let fileLists = realm.objects(FIL).filter("course_id == %@", course_id)
            let fileCount = fileLists.count
            let fileNewCount = fileLists.filter("isNew == true").count
            
            cell.bbsNewLabel.text = String(bbsNewCount)
            if cell.bbsNewLabel.text != "0"
            {
                cell.nameLabel.textColor = FlatRed()
                cell.bbsNewLabel.textColor = FlatRed()
            }
            
            cell.bbsLabel.text = "/" + String(bbsCount)
            cell.bbsLabel.textColor = UIColor.blackColor()
            
            cell.hwkNewLabel.text = String(hwkNewCount)
            if cell.hwkNewLabel.text != "0"
            {
                cell.nameLabel.textColor = FlatRed()
                cell.hwkNewLabel.textColor = FlatRed()
            }
            
            cell.hwkLabel.text = "/" + String(hwkCount)
            cell.hwkLabel.textColor = UIColor.blackColor()
            
            cell.fileNewLabel.text = String(fileNewCount)
            if cell.fileNewLabel.text != "0"
            {
                cell.nameLabel.textColor = FlatRed()
                cell.fileNewLabel.textColor = FlatRed()
            }
            
            cell.fileLabel.text = "/" + String(fileCount)
            cell.fileLabel.textColor = UIColor.blackColor()
            cell.activity.stopAnimating()
            cell.pushIcon.hidden = false
        } else if startLoading[indexPath.section][indexPath.row] {
            cell.pushIcon.hidden = true
            cell.activity.startAnimating()
        }
        else {
            errorFlag[indexPath.section][indexPath.row] = false
            useful[indexPath.section][indexPath.row] = false
            startLoading[indexPath.section][indexPath.row] = true
            cell.pushIcon.hidden = true
            cell.activity.startAnimating()
            test(course_id, indexPath: indexPath)
        }
        
        
    }
    
}

extension CourseTableViewController
{
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return courseLists.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return courseLists[section].list.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if section == 0 && courseLists[section].page == 1 {
            return courseLists[section].semester + "（当前学期）"
        }
        return courseLists[section].semester
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 80.0
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0
        {
            return 50.0
        }
        return 30.0
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == courseLists.count - 1
        {
            return 53.0
        }
        return 0.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! CourseCell
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if useful[indexPath.section][indexPath.row] {
            let vc = stb.instantiateViewControllerWithIdentifier("CourseDetailViewController") as! CourseDetailViewController
            vc.title = "\(cell.nameLabel.text!)"
            vc.course = courseLists[indexPath.section].list[indexPath.row]
            
            self.navigationController?.pushViewController(vc, animated: true)
            self.selectIndex = indexPath
            errorFlag[indexPath.section][indexPath.row] = false
            useful[indexPath.section][indexPath.row] = false
            startLoading[indexPath.section][indexPath.row] = true
            
        } else if (errorFlag[indexPath.section][indexPath.row]) {
            
            tipView = EasyTipView(text: "网络错误\n课程「\(cell.nameLabel.text!)」数据加载失败，点此刷新。\n（轻触关闭提示）", preferences: preferences)
            tipView.show(forItem: self.parentViewController!.navigationItem.rightBarButtonItem!)
            
        }
    }
    
}


extension CourseTableViewController
{
    func test(id: String, indexPath: NSIndexPath)
    {


        Alamofire.request(.GET, bbsListUrl.stringByReplacingOccurrencesOfString("||COURSEID||", withString: id)).responseString
            {
                response in
                switch response.result {
                case .Success:
                    let bbsResponseStr = String(response).stringByReplacingOccurrencesOfString(" ", withString: "").stringByReplacingOccurrencesOfString("\r", withString: "").stringByReplacingOccurrencesOfString("\n", withString: "").stringByReplacingOccurrencesOfString("\t", withString: "")
                    let bbsResponseNSStr = NSString(string: bbsResponseStr)
                    Alamofire.request(.GET, hwkListUrl.stringByReplacingOccurrencesOfString("||COURSEID||", withString: id)).responseString
                        {
                            response in
                            switch response.result {
                            case .Success:
                                let hwkResponseStr = String(response).stringByReplacingOccurrencesOfString(" ", withString: "").stringByReplacingOccurrencesOfString("\r", withString: "").stringByReplacingOccurrencesOfString("\n", withString: "").stringByReplacingOccurrencesOfString("\t", withString: "")
                                let hwkResponseNSStr = NSString(string: hwkResponseStr)
                                Alamofire.request(.GET, fileListUrl.stringByReplacingOccurrencesOfString("||COURSEID||", withString: id)).responseString
                                    {
                                        response in
                                        switch response.result {
                                        case .Success:
                                            let fileResponseStr = String(response).stringByReplacingOccurrencesOfString(" ", withString: "").stringByReplacingOccurrencesOfString("\r", withString: "").stringByReplacingOccurrencesOfString("\n", withString: "").stringByReplacingOccurrencesOfString("\t", withString: "")
                                            let fileResponseNSStr = NSString(string: fileResponseStr)
                                            let defaultPriority = DISPATCH_QUEUE_PRIORITY_DEFAULT
                                            let backgroundQueue = dispatch_get_global_queue(defaultPriority, 0)
                                            let group: dispatch_group_t = dispatch_group_create()
                                            
                                            dispatch_group_async(group, backgroundQueue, {
                                                let pattern = "\\d*&course_id=(.*?)</tr>"
                                                let regular = try! NSRegularExpression(pattern: pattern, options:.CaseInsensitive)
                                                let results = regular.matchesInString(bbsResponseStr, options: .ReportProgress , range: NSMakeRange(0, bbsResponseNSStr.length))
                                                let realm = try! Realm()
                                                for result in results
                                                {
                                                    let eee = bbsResponseNSStr.substringWithRange(result.range).stringByReplacingOccurrencesOfString("<fontcolor=red>", withString: "").stringByReplacingOccurrencesOfString("</font>", withString: "").componentsSeparatedByString("=25>")
                                                    if eee.count > 3 {
                                                        let fff = eee[0].stringByReplacingOccurrencesOfString("</a", withString: "'").componentsSeparatedByString("&course_id=")
                                                        if fff.count > 1 {
                                                            let bbs = BBS()
                                                            bbs.id = fff[0]
                                                            bbs.title = fff[1].componentsSeparatedByString("'>")[1].stringByReplacingOccurrencesOfString("&nbsp;", withString: " ")
                                                            bbs.owner = eee[1].componentsSeparatedByString("</td")[0]
                                                            bbs.date = eee[2].componentsSeparatedByString("</td")[0]
                                                            bbs.isNew = eee[3].componentsSeparatedByString("</td")[0] == "未读"
                                                            bbs.course_id = id
                                                            try! realm.write
                                                                {
                                                                    realm.add(bbs, update: true)
                                                            }
                                                        }
                                                        else {
                                                            self.errorFlag[indexPath.section][indexPath.row] = true
                                                            break
                                                        }
                                                        
                                                    }else {
                                                        self.errorFlag[indexPath.section][indexPath.row] = true
                                                        break
                                                    }
                                                    
                                                }
                                                
                                            })
                                            
                                            dispatch_group_async(group, backgroundQueue, {
                                                let pattern = "\\?id=(.*?)</tr>"
                                                let regular = try! NSRegularExpression(pattern: pattern, options:.CaseInsensitive)
                                                let results = regular.matchesInString(hwkResponseStr, options: .ReportProgress , range: NSMakeRange(0, hwkResponseNSStr.length))
                                                let realm = try! Realm()
                                                for result in results
                                                {
                                                    let eee = hwkResponseNSStr.substringWithRange(result.range).stringByReplacingOccurrencesOfString("<fontcolor=red>", withString: "").stringByReplacingOccurrencesOfString("</font>", withString: "").componentsSeparatedByString("</td><tdwidth=\"10%\">")
                                                    if eee.count > 2 {
                                                        let fff = eee[2].componentsSeparatedByString("</td><tdwidth=\"15%\">")
                                                        let ggg = eee[0].stringByReplacingOccurrencesOfString("&course_", withString: "").stringByReplacingOccurrencesOfString("&rec_", withString: "").componentsSeparatedByString("id=")
                                                        if fff.count > 1 && ggg.count > 3 {
                                                            let hhh = ggg[3].componentsSeparatedByString("\">")
                                                            if hhh.count > 1 {
                                                                let hwk = HWK()
                                                                hwk.id = ggg[1]
                                                                hwk.rec_id = hhh[0]
                                                                hwk.title = hhh[1].stringByReplacingOccurrencesOfString("</a>", withString: "").stringByReplacingOccurrencesOfString("&nbsp;", withString: " ")
                                                                hwk.startDate = eee[1]
                                                                hwk.deadLine = fff[0]
                                                                hwk.isNew = fff[1] != "已经提交"
                                                                hwk.course_id = id
//                                                                print(hwk.id,hwk.title,hwk.rec_id,hwk.startDate,hwk.deadLine,hwk.isNew)

                                                                try! realm.write
                                                                    {
                                                                        realm.add(hwk, update: true)
                                                                }
                                                            }else {
                                                                self.errorFlag[indexPath.section][indexPath.row] = true
                                                                break
                                                            }
                                                        }else {
                                                            self.errorFlag[indexPath.section][indexPath.row] = true
                                                            break
                                                        }
                                                    }else {
                                                        self.errorFlag[indexPath.section][indexPath.row] = true
                                                        break
                                                    }
                                                }
                                                
                                            })
                                            
                                            dispatch_group_async(group, backgroundQueue, {
                                                let pattern = "<trclass(.*?)</tr>"
                                                let regular = try! NSRegularExpression(pattern: pattern, options:.CaseInsensitive)
                                                let results = regular.matchesInString(fileResponseStr, options: .ReportProgress , range: NSMakeRange(0, fileResponseNSStr.length))
                                                let realm = try! Realm()
                                                for result in results
                                                {
                                                    let eee = fileResponseNSStr.substringWithRange(result.range).stringByReplacingOccurrencesOfString("<fontcolor=red>", withString: "").stringByReplacingOccurrencesOfString("</font>", withString: "").stringByReplacingOccurrencesOfString("</a>", withString: "").stringByReplacingOccurrencesOfString("&nbsp;", withString: " ")
                                                    let eeeNSStr = NSString(string: eee)
                                                    let pattern_link = "/uploadFile/downloadFile_student.jsp(.*?)</tr>"
                                                    let regular_link = try! NSRegularExpression(pattern: pattern_link, options:.CaseInsensitive)
                                                    let results_link = regular_link.matchesInString(eee, options: .ReportProgress , range: NSMakeRange(0, eeeNSStr.length))
                                                    
                                                    if results_link.count > 0 {
                                                        let fff = eeeNSStr.substringWithRange(results_link[0].range).componentsSeparatedByString("\"center\">")
                                                        if fff.count > 3 {
                                                            let ggg = fff[3].componentsSeparatedByString("</td>")
                                                            if ggg.count > 1 {
                                                                let file = FIL()
                                                                file.link = "http://learn.tsinghua.edu.cn" + fff[0].componentsSeparatedByString("\">")[0]
                                                                
                                                                file.id = file.link.componentsSeparatedByString("&file_id=")[1]
                                                                file.title = fff[0].componentsSeparatedByString("\">")[1].componentsSeparatedByString("</td>")[0]
                                                                file.info = fff[1].componentsSeparatedByString("</td>")[0]
                                                                file.size = fff[2].componentsSeparatedByString("</td>")[0]
                                                                file.date = ggg[0]
                                                                file.isNew = ggg[1].componentsSeparatedByString("'>")[1] != ""
                                                                file.course_id = id
                                                                try! realm.write
                                                                    {
                                                                        realm.add(file, update: true)
                                                                }
                                                            }else {
                                                                self.errorFlag[indexPath.section][indexPath.row] = true
                                                                break
                                                            }
                                                        }else {
                                                            self.errorFlag[indexPath.section][indexPath.row] = true
                                                            break
                                                        }
                                                    }else {
                                                        self.errorFlag[indexPath.section][indexPath.row] = true
                                                        break
                                                    }
                                                }
                                                
                                            })
                                            
                                            dispatch_group_notify(group, backgroundQueue, {
                                                
                                                dispatch_async(dispatch_get_main_queue(), {
                                                    if !self.errorFlag[indexPath.section][indexPath.row] {
                                                        self.useful[indexPath.section][indexPath.row] = true
                                                        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                                                    } else {
                                                        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                                                    }
                                                })
                                            })
                                            
                                        case .Failure:
                                            self.errorFlag[indexPath.section][indexPath.row] = true
                                            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                                        }
                                }
                                
                            case .Failure:
                                self.errorFlag[indexPath.section][indexPath.row] = true
                                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                            }
                    }
                    
                case .Failure:
                    self.errorFlag[indexPath.section][indexPath.row] = true
                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                }
        }
    }
    
}

public final class BBSCell: Cell<BBS>, CellType {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var owner: UILabel!
    
    override public func setup() {
        super.setup()
        title.text = row.value?.title
        date.text = row.value?.date
        owner.text = row.value?.owner
        if row.value!.isNew {
            title.textColor = FlatRed()
        } else {
            title.textColor = UIColor.blackColor()
        }
    }
    
    override public func update() {
        super.update()
        if row.value!.isNew {
            title.textColor = FlatRed()
        } else {
            title.textColor = UIColor.blackColor()
        }
    }
}

public final class HWKCell: Cell<HWK>, CellType {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var deadLine: UILabel!
    
    override public func setup() {
        super.setup()
        title.text = row.value?.title
        startDate.text = row.value?.startDate
        deadLine.text = row.value?.deadLine
        if row.value!.isNew {
            title.textColor = FlatRed()
        } else {
            title.textColor = UIColor.blackColor()
        }
    }
    
    override public func update() {
        super.update()
        if row.value!.isNew {
            title.textColor = FlatRed()
        } else {
            title.textColor = UIColor.blackColor()
        }
    }
}

public final class FILECell: Cell<FIL>, CellType {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var size: UILabel!
    @IBOutlet weak var info: UILabel!
    
    override public func setup() {
        super.setup()
        title.text = row.value?.title
        date.text = row.value?.date
        size.text = row.value?.size
        info.text = row.value?.info
        if row.value!.isNew {
            title.textColor = FlatRed()
        } else {
            title.textColor = UIColor.blackColor()
        }
    }
    
    override public func update() {
        super.update()
        if row.value!.isNew {
            title.textColor = FlatRed()
        } else {
            title.textColor = UIColor.blackColor()
        }
    }
}

public final class BBSRow:  Row<BBS, BBSCell>, RowType {
    
    public required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<BBSCell>(nibName: "BBSCell")
    }
}

public final class HWKRow:  Row<HWK, HWKCell>, RowType {
    
    public required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<HWKCell>(nibName: "HWKCell")
    }
}

public final class FILERow:  Row<FIL, FILECell>, RowType {
    
    public required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<FILECell>(nibName: "FILECell")
    }
}

class CourseDetailViewController: FormViewController {
    
    var course: Course!
    var bbsList: Results<BBS>!
    var hwkList: Results<HWK>!
    var fileList: Results<FIL>!
    
    @IBAction func chageSegment(sender: UISegmentedControl) {
        (form.rowByTag("segments") as! SegmentedRow<Int>).value = sender.selectedSegmentIndex
    }
    
//    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 100.0
//    }
    
    func loadINFO() {
        
        let section = form.sectionByTag("COURSEINFO")!
        let section1 = form.sectionByTag("TEACHERINFO")!
        
        Alamofire.request(.GET, ("http://learn.tsinghua.edu.cn/MultiLanguage/lesson/student/course_info.jsp?course_id=" + self.course.id).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!).validate().responseString
            {
                response in
                do {
                    // if encoding is omitted, it defaults to NSUTF8StringEncoding
                    let doc = try HTMLDocument(string: String(response), encoding: NSUTF8StringEncoding).xpath("//*[@id=\"table_box\"]/tr")
                    
                    section
                        <<< LabelRow() {
                            $0.title = "课程编号"
                            $0.value = doc[0]?.children[1].stringValue
                        }
                        <<< LabelRow() {
                            $0.title = "课程序号"
                            $0.value = doc[0]?.children[3].stringValue
                        }
                        <<< LabelRow() {
                            $0.title = "课程名称"
                            $0.value = doc[1]?.children[1].stringValue
                        }
                        <<< LabelRow() {
                            $0.title = "学分"
                            $0.value = doc[2]?.children[1].stringValue
                        }
                        <<< LabelRow() {
                            $0.title = "学时"
                            $0.value = doc[2]?.children[3].stringValue
                        }
                        
                    section1
                        
                        <<< LabelRow() {
                            $0.title = "姓名"
                            $0.value = doc[4]?.children[2].stringValue.stringByReplacingOccurrencesOfString("&nbsp;", withString: " ")
                        }
                        <<< LabelRow() {
                            $0.title = "电子邮件"
                            $0.value = doc[4]?.children[4].stringValue.stringByReplacingOccurrencesOfString("&nbsp;", withString: " ")
                        }
                        <<< LabelRow() {
                            $0.title = "电话"
                            $0.value = doc[5]?.children[1].stringValue.stringByReplacingOccurrencesOfString("&nbsp;", withString: " ")
                        }
                        <<< LabelRow() {
                            $0.title = "简介"
                    }
                    
                    var result = ""
                    var str: NSAttributedString!
                    var str1: NSMutableAttributedString!
                    
                    result = doc[6]!.children[1].rawXML
                    
                    str = try NSAttributedString(data: result.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!, options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
                    str1 = NSMutableAttributedString(attributedString: str)
                    str1.addAttributes([NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 16)!], range: NSMakeRange(0, str.length))
                    
                    section1
                        <<< TextAreaRow(){
                            $0.textAreaHeight = .Dynamic(initialTextViewHeight: 0)
                            }.cellUpdate({ (cell, row) -> () in
                                cell.textView.attributedText = str1
                                cell.textView.editable = false
                                cell.textView.selectable = false
                            })
                    
                } catch _ {
                    
                }
                
        }
    
    }

    func loadBBS() {

        let section = form.sectionByTag("BBS")!
        
        let bbsNewList = bbsList.filter("isNew == true")
        let bbsOldList = bbsList.filter("isNew == false")
        
        for bbs in bbsNewList {
            section
                <<< BBSRow(){
                    $0.value = bbs
                    }
                    .onCellSelection { cell, row in
                        let vc = BBSDetailViewController()
                        vc.course_id = row.value?.course_id
                        vc.bbs_id = row.value?.id
                        vc.bbs_owner = row.value?.owner
                        vc.bbs_date = row.value?.date
                        vc.bbs_title = row.value?.title
                        self.navigationController?.pushViewController(vc, animated: true)
                        let realm = try! Realm()
                        try! realm.write {
                            row.value?.isNew = false
                        }
                        row.reload()
            }
        }
        
        
        
        for bbs in bbsOldList {
            section <<< BBSRow(){
                $0.value = bbs
                }
                .onCellSelection { cell, row in
                    let vc = BBSDetailViewController()
                    vc.course_id = row.value?.course_id
                    vc.bbs_id = row.value?.id
                    vc.bbs_owner = row.value?.owner
                    vc.bbs_date = row.value?.date
                    vc.bbs_title = row.value?.title
                    self.navigationController?.pushViewController(vc, animated: true)
                    row.reload()
            }
        }

    }
    
    func loadHWK() {
        
        let section = form.sectionByTag("HWK")!
        
        let hwkNewList = hwkList.filter("isNew == true")
        let hwkOldList = hwkList.filter("isNew == false")
            
        for hwk in hwkNewList {
            section
                <<< HWKRow(){
                    $0.value = hwk
                    }
                    .onCellSelection { cell, row in
                        let vc = HWKDetailViewController()
                        vc.course_id = row.value?.course_id
                        vc.hwk_id = row.value?.id
                        vc.rec_id = row.value?.rec_id
                        vc.hwk_deadLine = row.value?.deadLine
                        vc.hwk_startDate = row.value?.startDate
                        vc.hwk_title = row.value?.title
                        self.navigationController?.pushViewController(vc, animated: true)
                        row.reload()
            }
        }
        
        for hwk in hwkOldList {
            section <<< HWKRow(){
                $0.value = hwk
                }
                .onCellSelection { cell, row in
                    let vc = HWKDetailViewController()
                    vc.course_id = row.value?.course_id
                    vc.hwk_id = row.value?.id
                    vc.rec_id = row.value?.rec_id
                    vc.hwk_deadLine = row.value?.deadLine
                    vc.hwk_startDate = row.value?.startDate
                    vc.hwk_title = row.value?.title
                    self.navigationController?.pushViewController(vc, animated: true)
                    row.reload()
            }
        }
        
        
    }

    func loadFILE() {
        
        let section = form.sectionByTag("FILE")!
        
        let fileNewList = fileList.filter("isNew == true")
        let fileOldList = fileList.filter("isNew == false")
        
        var count = 0
        
        for file in fileNewList {
            
            section
                <<< FILERow(){
                    $0.value = file
                    }
                    .onCellSelection { cell, row in
                        
                        let docUrl = NSURL(string: file.link)
                        let req = NSURLRequest(URL: docUrl!)

                        let vc = UIViewController()
                        let webView = UIWebView(frame: vc.view.frame)
                        webView.scalesPageToFit = true
                        webView.contentMode = .ScaleAspectFit
                        webView.loadRequest(req)
                        vc.view.addSubview(webView)
                        self.navigationController?.pushViewController(vc, animated: true)
                        let realm = try! Realm()
                        try! realm.write {
                            row.value?.isNew = false
                        }
                        row.reload()
                    }
            
            count += 1
        }
        
        for file in fileOldList {
            section <<< FILERow(){
                $0.value = file
                }
                .onCellSelection { cell, row in
                    //Document file url
                    let docUrl = NSURL(string: file.link)
                    let req = NSURLRequest(URL: docUrl!)

                    let vc = UIViewController()
                    let webView = UIWebView(frame: vc.view.frame)
                    webView.scalesPageToFit = true
                    webView.contentMode = .ScaleAspectFit
                    webView.loadRequest(req)
                    vc.view.addSubview(webView)
                    self.navigationController?.pushViewController(vc, animated: true)
                    row.reload()
            }
            
            count += 1
        }
        
        
    }

    func load() {
        loadINFO()
        loadBBS()
        loadHWK()
        loadFILE()
    }
    
    func reload() {
        form.removeLast()
        form.removeLast()
        form.removeLast()
        form
            +++ Section(){
                $0.tag = "BBS"
                $0.header = nil
                $0.footer = nil
                $0.hidden = "$segments != 1"
            }
            +++ Section(){
                $0.tag = "HWK"
                $0.header = nil
                $0.footer = nil
                $0.hidden = "$segments != 2"
            }
            +++ Section(){
                $0.tag = "FILE"
                $0.header = nil
                $0.footer = nil
                $0.hidden = "$segments != 3"
        }
        load()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let realm = try! Realm()
        bbsList = realm.objects(BBS).filter("course_id == %@", course.id).sorted("date", ascending: false)
        hwkList = realm.objects(HWK).filter("course_id == %@", course.id).sorted("startDate", ascending: false)
        fileList = realm.objects(FIL).filter("course_id == %@", course.id).sorted("date", ascending: false)
        
        form +++ Section()
            <<< SegmentedRow<Int>("segments"){
                $0.options = [0, 1, 2, 3]
                $0.value = 1
                $0.hidden = true
                }
            +++ Section("课程信息") {
                $0.tag = "COURSEINFO"
                $0.footer = nil
                $0.hidden = "$segments != 0"
                }
            +++ Section("教师信息") {
                $0.tag = "TEACHERINFO"
                $0.footer = nil
                $0.hidden = "$segments != 0"
            }
            +++ Section(){
                $0.tag = "BBS"
                $0.header = nil
                $0.footer = nil
                $0.hidden = "$segments != 1"
            }
            +++ Section(){
                $0.tag = "HWK"
                $0.header = nil
                $0.footer = nil
                $0.hidden = "$segments != 2"
            }
            +++ Section(){
                $0.tag = "FILE"
                $0.header = nil
                $0.footer = nil
                $0.hidden = "$segments != 3"
        }
        
        load()
        
        self.tableView!.estimatedRowHeight = 64.0
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        let rect = CGRectMake(0, 0, 0
            , 0.1)
        self.tableView?.tableHeaderView = UIView(frame: rect)
        self.tableView?.tableFooterView = UIView(frame: rect)
    }
    
}

class BBSDetailViewController: FormViewController {
    
    var course_id:String!
    var bbs_id:String!
    var bbs_owner:String!
    var bbs_date:String!
    var bbs_title:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        TextRow.defaultCellUpdate = { cell, row in
        //            cell.textLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 16)!
        //        }

        
        self.form +++
            
            Section(){
                $0.header = nil
                $0.footer = nil
            }
            
            <<< TextAreaRow() {
                $0.value = self.bbs_title
                $0.textAreaHeight = .Dynamic(initialTextViewHeight: 24)
                }.cellUpdate({ (cell, row) -> () in
                    cell.textView.font = UIFont(name: "HelveticaNeue", size: 16)
                    cell.textView.editable = false
                })
            
            <<< LabelRow() {
                $0.title = self.bbs_owner
                $0.value = self.bbs_date
        }
        
        if course_id != nil && bbs_id != nil {
            Alamofire.request(.GET, bbsUrl.stringByReplacingOccurrencesOfString("||BBSID||", withString: self.bbs_id).stringByReplacingOccurrencesOfString("||COURSEID||", withString: self.course_id).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!).validate().responseString
                {
                    response in
                    do {
                        // if encoding is omitted, it defaults to NSUTF8StringEncoding
                        let doc = try HTMLDocument(string: String(response), encoding: NSUTF8StringEncoding)
                        var result = ""
                        for i in doc.xpath("//*[@id=\"table_box\"]/tr[2]/td[2]") {
                            result += i.rawXML
                        }
                        
                        let str = try NSAttributedString(data: result.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!, options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
                        let str1 = NSMutableAttributedString(attributedString: str)
                        str1.addAttributes([NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 16)!], range: NSMakeRange(0, str.length))
                        
                        self.form.last!
                            
                            <<< TextAreaRow(){
                                $0.textAreaHeight = .Dynamic(initialTextViewHeight: 40)
                                }.cellUpdate({ (cell, row) -> () in
                                    cell.textView.attributedText = str1
                                    cell.textView.editable = false
                                })
                        
                    } catch _ {
                        
                    }
                    
            }
            
            
        }
        let rect = CGRectMake(0, 0, 0, 0.1)
        self.tableView?.tableHeaderView = UIView(frame: rect)
        self.tableView?.tableFooterView = UIView(frame: rect)
        
    }
    
}


class HWKDetailViewController: FormViewController {
    
    var course_id: String!
    var hwk_id: String!
    var hwk_deadLine: String!
    var hwk_startDate: String!
    var hwk_title: String!
    var rec_id: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        TextRow.defaultCellUpdate = { cell, row in
        //            cell.textLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 16)!
        //        }
        
        
        self.form +++
            
            Section(){
                $0.header = nil
                $0.footer = nil
            }
            
            <<< TextAreaRow() {
                $0.value = self.hwk_title
                $0.textAreaHeight = .Dynamic(initialTextViewHeight: 24)
                }.cellUpdate({ (cell, row) -> () in
                    cell.textView.font = UIFont(name: "HelveticaNeue", size: 16)
                    cell.textView.editable = false
                })
            
            <<< LabelRow() {
                $0.title = "发布日期"
                $0.value = self.hwk_startDate
            }
            
            <<< LabelRow() {
                $0.title = "截止日期"
                $0.value = self.hwk_deadLine
                
        }
        
        if course_id != nil && hwk_id != nil {
            Alamofire.request(.GET, hwkUrl.stringByReplacingOccurrencesOfString("||HWKID||", withString: self.hwk_id).stringByReplacingOccurrencesOfString("||COURSEID||", withString: self.course_id).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!).validate().responseString
                {
                    response in
                    do {
                        // if encoding is omitted, it defaults to NSUTF8StringEncoding
                        let doc = try HTMLDocument(string: String(response), encoding: NSUTF8StringEncoding)
                        var result = ""
                        for i in doc.xpath("//*[@id=\"table_box\"]/tr[2]/td[2]/textarea") {
                            result += i.rawXML
                        }
                        
                        let str = try NSAttributedString(data: result.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!, options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
                        let str1 = NSMutableAttributedString(attributedString: str)
                        str1.addAttributes([NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 16)!], range: NSMakeRange(0, str.length))
                        
                        self.form.last!
                            
                            <<< TextAreaRow(){
                                $0.textAreaHeight = .Dynamic(initialTextViewHeight: 40)
                                }.cellUpdate({ (cell, row) -> () in
                                    cell.textView.attributedText = str1
                                    cell.textView.editable = false
                                })
                        
                        for i in doc.xpath("//*[@id=\"table_box\"]/tr[3]/td[2]/a") {
                            
                            let str = try NSAttributedString(data: i.rawXML.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!, options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
                            let str1 = NSMutableAttributedString(attributedString: str)
                            str1.addAttributes([NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 16)!], range: NSMakeRange(0, str.length))
//                            
                            self.form
                            
                                +++ Section("附件") {_ in 
                                    
                                    }
                                
                                <<< TextAreaRow(){
                                    $0.textAreaHeight = .Dynamic(initialTextViewHeight: 40)
                                    }.cellUpdate({ (cell, row) -> () in
                                        cell.textView.attributedText = str1
                                        cell.textView.editable = false
                                    })

                        }
                        
                    } catch _ {
                        
                    }
                    
            }
            
            
        }
        let rect = CGRectMake(0, 0, 0, 0.1)
        self.tableView?.tableHeaderView = UIView(frame: rect)
        self.tableView?.tableFooterView = UIView(frame: rect)
        
    }
    
}


