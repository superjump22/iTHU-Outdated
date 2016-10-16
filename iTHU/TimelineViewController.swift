//
//  TimelineViewController.swift
//  iTHU
//
//  Created by 果小橙 on 2016/10/17.
//  Copyright © 2016年 THU_GC. All rights reserved.
//

import UIKit
import RealmSwift

class TimelineViewController: UIViewController {


    @IBOutlet weak var scrollView: UIScrollView!
    
    var timeline: TimelineView!
    var courseList: Results<Course>!
    var hwkList: Results<HWK>!
    var timeFrames :[TimeFrame] = []
    var fromDateStr: String!
    var toDateStr: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fromDate = NSDate()
//        let toDate = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: 45, toDate: fromDate, options: NSCalendarOptions.init(rawValue: 0))!
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let formatter1 = NSDateFormatter()
        formatter1.dateStyle = NSDateFormatterStyle.MediumStyle
        let formatter2 = NSDateFormatter()
        formatter2.dateFormat = "yyyy-MM"
        fromDateStr = formatter.stringFromDate(fromDate)
//        toDateStr = formatter.stringFromDate(toDate)
//        print(formatter2.stringFromDate(fromDate), formatter2.stringFromDate(toDate))
        let realm = try! Realm()
        courseList = realm.objects(Course)
        hwkList = realm.objects(HWK).filter("isNew == true").sorted("deadLine", ascending: true)
        
        var count = 0
        for hwk in hwkList {
            if hwk.deadLine < fromDateStr {
                continue
            }
//            if hwk.deadLine > toDateStr {
//                break
//            }
            timeFrames.append(TimeFrame(text: "\n" + courseList.filter("id == %@", hwk.course_id).first!.name + "\n\n" + hwk.title + "\n", date: formatter1.stringFromDate(formatter.dateFromString(hwk.deadLine)!),  image: nil))
            count += 1
            if count > 20 {
                break
            }
        }

        // Do any additional setup after loading the view.
        timeline = TimelineView(bulletType: .Circle, timeFrames: timeFrames)
        
        scrollView.addSubview(timeline)
        scrollView.addConstraints([
            NSLayoutConstraint(item: timeline, attribute: .Left, relatedBy: .Equal, toItem: scrollView, attribute: .Left, multiplier: 1.0, constant: 10),
            NSLayoutConstraint(item: timeline, attribute: .Bottom, relatedBy: .LessThanOrEqual, toItem: scrollView, attribute: .Bottom, multiplier: 1.0, constant: -50),
            NSLayoutConstraint(item: timeline, attribute: .Top, relatedBy: .Equal, toItem: scrollView, attribute: .Top, multiplier: 1.0, constant: -20),
            NSLayoutConstraint(item: timeline, attribute: .Right, relatedBy: .Equal, toItem: scrollView, attribute: .Right, multiplier: 1.0, constant: -30),
            
            NSLayoutConstraint(item: timeline, attribute: .Width, relatedBy: .Equal, toItem: scrollView, attribute: .Width, multiplier: 1.0, constant: -40)
            ])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
