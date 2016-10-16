//
//  ViewController.swift
//  LemonTHU
//
//  Created by 果小橙 on 16/7/7.
//  Copyright © 2016年 THU_GC. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift
import ChameleonFramework
import TextFieldEffects
import EasyTipView

class LoginViewController: UIViewController, UIViewControllerTransitioningDelegate, UITextFieldDelegate
{
    
    @IBOutlet weak var userNameField: HoshiTextField!
    @IBOutlet weak var passWordField: HoshiTextField!
    @IBOutlet weak var maskView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var idImage: UIImageView!
    @IBOutlet weak var passImage: UIImageView!
 
    var sb = UIStoryboard(name: "Main", bundle:nil)
    var btn: TKTransitionSubmitButton!
    var tipView: [EasyTipView] = []
    var loginFailTip: EasyTipView!
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() 
    {
        super.viewDidLoad()
        
        maskView.backgroundColor = UIColor(gradientStyle:UIGradientStyle.topToBottom, withFrame: self.view.layer.frame, andColors:[HexColor("7728A4"),HexColor("000000")])
        
        userNameField.delegate = self
        passWordField.delegate = self
        
        btn = TKTransitionSubmitButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width - 64, height: 44))
        btn.center = self.view.center
        btn.frame.bottom = self.view.frame.height - 100
        btn.setTitle("登录", for: UIControlState())
        btn.setTitleColor(HexColor("E8ECEE"), for: UIControlState())
        btn.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 18)
        btn.normalCornerRadius = btn.frame.height / 2
        btn.addTarget(self, action: #selector(LoginViewController.onTapButton(_:)), for: UIControlEvents.touchUpInside)
        btn.backgroundColor = UIColor(hexString: "7241B7", withAlpha: 0.8)
        self.view.addSubview(btn)
        
        var preferences = EasyTipView.Preferences()
        preferences.drawing.font = UIFont(name: "HelveticaNeue-Light", size: 16)!
        preferences.drawing.foregroundColor = HexColor("E8ECEE")
        preferences.drawing.backgroundColor = UIColor(hue:0.46, saturation:0.99, brightness:0.6, alpha:0.8)
        preferences.drawing.arrowHeight = 24.0
        preferences.drawing.arrowWidth = 24.0
        preferences.positioning.maxWidth = UIScreen.main.bounds.width * 0.618
        preferences.animating.showDuration = 0.618
        preferences.animating.dismissDuration = 0.618
        
        preferences.drawing.arrowPosition = .top
        tipView.append(EasyTipView(text: "学号或密码错误，请重试。（若多次无法登录，可能是学校服务器的问题）", preferences: preferences))
        preferences.drawing.arrowPosition = .bottom
        tipView.append(EasyTipView(text: "学号或密码错误，请重试。（若多次无法登录，可能是学校服务器的问题）", preferences: preferences))
        tipView.append(EasyTipView(text: "学号格式不正确，请重新输入。", preferences: preferences))
        preferences.drawing.backgroundColor = UIColor.red.flatten()
        tipView.append(EasyTipView(text: "网络错误，请重试。\n（轻触关闭提示）", preferences: preferences))
        
    }

}

extension LoginViewController {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (regularString(self.userNameField.text!, pattern: "\\b20\\d{8}\\b").count == 0) {
            if textField === self.userNameField {
                self.tipView[2].show(forView: self.idImage, withinSuperview: self.idImage.superview!)
            }
            self.btn.isEnabled = false
        } else {
            self.btn.isEnabled = true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField === userNameField {
            self.tipView[0].dismiss()
            self.tipView[1].dismiss()
            self.tipView[2].dismiss()
        } else {
            self.tipView[0].dismiss()
            self.tipView[1].dismiss()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === userNameField {
            textField.resignFirstResponder()
            passWordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func onTapButton(_ button: TKTransitionSubmitButton) {

        self.btn.startLoadingAnimation()
        let formData =
        [
            "userid":userNameField.text!, "userpass":passWordField.text!, "submit1":"登录"
        ]
        Alamofire.request(loginLearnUrl, method: .post, parameters: formData).validate().responseString
        {
            response in
            switch response.result {
            case .success:
                if (!String(describing: response).contains("用户名或密码错误，登录失败！") && !String(describing: response).contains("您没有登陆网络学堂的权限！")) {
                    let user = User()
                    user.id = self.userNameField.text!
                    user.pass = self.passWordField.text!
                    config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("\(user.id).realm")
//                    print(config.fileURL)
                    let realm = try! Realm()
                    try! realm.write
                    {
                        realm.add(user, update: true)
                    }
                    request(self.userNameField.text!,
                        pass: self.passWordField.text!,
                        block: {
                            if (flag) {
                                try! realm.write
                                    {
                                        user.login = true
                                }
                                Realm.Configuration.defaultConfiguration = config
                                self.btn.startFinishAnimation(1, completion: { () -> () in
//                                    print("9")
                                    let rootVC = self.sb.instantiateViewController(withIdentifier: "root")
                                    rootVC.transitioningDelegate = self
                                    self.present(rootVC, animated: true, completion: nil)
                                })
                            } else {
                                self.tipView[3].show(forView: self.btn, withinSuperview: self.btn.superview!)
                                self.btn.setOriginalState()
                            }
                        },
                        loginFail: {
                            self.tipView[3].show(forView: self.btn, withinSuperview: self.btn.superview!)
                            self.btn.setOriginalState()
                        }
                    )
                } else {
                    self.tipView[2].dismiss()
                    self.tipView[0].show(forView: self.passImage, withinSuperview: self.passImage.superview!)
                    self.tipView[1].show(forView: self.idImage, withinSuperview: self.idImage.superview!)
                    self.btn.isEnabled = false
                    self.btn.setOriginalState()
                }
            case .failure:
                self.tipView[3].show(forView: self.btn, withinSuperview: self.btn.superview!)
                self.btn.setOriginalState()
            }
        }

    }

}

class LaunchViewController: UIViewController, CAAnimationDelegate
{

    @IBOutlet weak var imageView: UIImageView!

    var courseListHtml: String = ""
    var set: Set<String> = []
    var timer: Timer!
    let sb = UIStoryboard(name: "Main", bundle:nil)

    override func viewDidLoad()
    {
        super.viewDidLoad()
        if !firstFlag {
            let backgroundQueue = DispatchQueue.global(qos: .default)
            let id = userNow
            let pass = userNowPass
            backgroundQueue.async(execute: {
                request(id, pass: pass,
                    block: {
                        if (flag) {
                            self.timer = Timer.scheduledTimer(timeInterval: 2.4, target:self, selector: #selector(LaunchViewController.timer(_:)), userInfo:["type":"root"], repeats:false)
                        } else {
                            let vc = self.sb.instantiateViewController(withIdentifier: "login") as! LoginViewController
                            self.present(vc, animated: true, completion: { ()->() in
                                let vc = (self.presentedViewController as! LoginViewController)
                                var preferences = EasyTipView.Preferences()
                                preferences.drawing.font = UIFont(name: "HelveticaNeue-Light", size: 16)!
                                preferences.drawing.foregroundColor = HexColor("E8ECEE")
                                preferences.drawing.backgroundColor = UIColor.red.flatten()
                                preferences.drawing.arrowHeight = 24.0
                                preferences.drawing.arrowWidth = 24.0
                                preferences.positioning.maxWidth = UIScreen.main.bounds.width / 2.0
                                preferences.animating.showDuration = 0.618
                                preferences.animating.dismissDuration = 0.618
                                vc.loginFailTip = EasyTipView(text: "网络错误，数据获取失败，请重新登录。\n（轻触关闭提示）", preferences: preferences)
                                vc.loginFailTip.show(forView: vc.btn)
                                vc.userNameField.text = id
                                vc.passWordField.text = pass
                            })
                        }
                    },
                    loginFail: {
                        let vc = self.sb.instantiateViewController(withIdentifier: "login") as! LoginViewController
                        self.present(vc, animated: true, completion: { ()->() in
                            let vc = (self.presentedViewController as! LoginViewController)
                            var preferences = EasyTipView.Preferences()
                            preferences.drawing.font = UIFont(name: "HelveticaNeue-Light", size: 16)!
                            preferences.drawing.foregroundColor = HexColor("E8ECEE")
                            preferences.drawing.backgroundColor = UIColor.red.flatten()
                            preferences.drawing.arrowHeight = 24.0
                            preferences.drawing.arrowWidth = 24.0
                            preferences.positioning.maxWidth = UIScreen.main.bounds.width / 2.0
                            preferences.animating.showDuration = 0.618
                            preferences.animating.dismissDuration = 0.618
                            vc.loginFailTip = EasyTipView(text: "网络错误，自动登录失败，请重新登录。\n（轻触关闭提示）", preferences: preferences)
                            vc.loginFailTip.show(forView: vc.btn)
                            vc.userNameField.text = id
                            vc.passWordField.text = pass
                        })
                    }
                )
            })
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        let animation = CABasicAnimation(keyPath: "bounds.size")
        animation.delegate = self
        animation.isRemovedOnCompletion = false;
        animation.fillMode = kCAFillModeForwards;
        animation.fromValue = NSValue(cgSize: self.imageView.frame.size)
        animation.toValue = NSValue(cgSize: CGSize(width: 2.0*self.imageView.frame.size.width, height: 2.0*self.imageView.frame.size.height))
        animation.duration = 16.0
        self.imageView.layer.add(animation, forKey: "Image-expend")
        
        if firstFlag {

            self.timer = Timer.scheduledTimer(timeInterval: 2.4, target:self, selector: #selector(LaunchViewController.timer(_:)), userInfo:["type":"login"], repeats:false)
        
        }
    
    }
    
    func timer(_ sender:AnyObject!) {
        let vc = sb.instantiateViewController(withIdentifier: sender.userInfo["type"] as! String)
        self.present(vc, animated: true, completion: nil)
    }
    
}


// 登录失败执行loginFail，登录成功则在主线程中执行block，全局flag为true表示网络学堂三个页面访问正常，false表示至少一个不正常，可在block中利用
// 这里的失败都是指网络原因
func request(_ id: String, pass: String, block: @escaping ()->(), loginFail: @escaping ()->()) {
    let formData =
        [
            "userid": id, "userpass": pass, "submit1": "登录"
    ]
    Alamofire.request(loginLearnUrl, method: .post, parameters: formData).validate().responseString
        {
            response in
            switch response.result {
            case .success:
                let backgroundQueue = DispatchQueue.global(qos: .default)
                let group: DispatchGroup = DispatchGroup()
                
                flag = true
                backgroundQueue.async(group: group, execute: {
                    Alamofire.request(courseLidtUrl.replacingOccurrences(of: "||typepage||", with: "1")).responseString
                    {
                    response in
                    switch response.result {
                    case .success: getCourse(String(describing: response), page: 1, id: id, pass: pass)
                    //                                print("6")
                    case .failure: flag = false
                    }
                    }
                    })

                
                backgroundQueue.async(group: group, execute: {
                    Alamofire.request(courseLidtUrl.replacingOccurrences(of: "||typepage||", with: "2")).responseString
                        {
                            response in
                            switch response.result {
                            case .success: getCourse(String(describing: response), page: 2, id: id, pass: pass)
//                                print("7")
                            case .failure: flag = false
                            }
                    }
                })
                
//                print("2")
                
//                dispatch_group_async(group, backgroundQueue, {
//                    Alamofire.request(.GET, courseLidtUrl.stringByReplacingOccurrencesOfString("||typepage||", withString: "3")).responseString
//                        {
//                            response in
//                            switch response.result {
//                            case .Success: getCourse(String(response), page: 3, id: id, pass: pass)
//                                print("8")
//                            case .Failure: flag = false
//                            }
//                    }
//                })
                
//                print("3")
                
                group.notify(queue: backgroundQueue, execute: {
//                    print("4")
                    DispatchQueue.main.async(execute: block)
//                    print("5")
                })
                
            case .failure:
                loginFail()
            }
    }
    
}

func regularString(_ str: String, pattern: String, opt: (String)->(String) = {(para: String)->(String) in return para})->[String] {
    
    let strNS = NSString(string: str)
    let regular = try! NSRegularExpression(pattern: pattern, options:.caseInsensitive)
    let results = regular.matches(in: str, options: .reportProgress , range: NSMakeRange(0, strNS.length))
    var value: [String] = []
    
    for result in results {
        value.append(opt(strNS.substring(with: result.range)))
    }
    return value
}

func getCourse(_ response: String, page: Int, id: String, pass: String) {
    
    let html = response.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\r", with: "").replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\t", with: "")
    let html_NS = NSString(string: html)
    let pattern = "course_id=(.*?)</a>"
    let regular = try! NSRegularExpression(pattern: pattern, options:.caseInsensitive)
    let results = regular.matches(in: html, options: .reportProgress , range: NSMakeRange(0, html_NS.length))
    
//    let html1 = response
//    let html1_NS = NSString(string: html1)
//    let pattern1 = "course_id=(.*?)</a>"
//    let regular1 = try! NSRegularExpression(pattern: pattern1, options:.DotMatchesLineSeparators)
//    let results1 = regular1.matchesInString(html1, options: .ReportProgress , range: NSMakeRange(0, html1_NS.length))
//    for i in results1 {
//        print(html1_NS.substringWithRange(i.range).stringByReplacingOccurrencesOfString(" ", withString: "").stringByReplacingOccurrencesOfString("\r", withString: "").stringByReplacingOccurrencesOfString("\n", withString: "").stringByReplacingOccurrencesOfString("\t", withString: ""))
//    }
    
    
    let realm = try! Realm(configuration: config)
    
    var set: Set<String> = []
    for result in results
    {
        let courseStr = html_NS.substring(with: result.range).components(separatedBy: "course_id=")[1].components(separatedBy: "</a>")[0].components(separatedBy: "\"target=\"_blank\">")
        let id = courseStr[0]
        
        if (realm.object(ofType: Course.self, forPrimaryKey: id as AnyObject) == nil) {
            var nameSplit = courseStr[1].components(separatedBy: "(")
            var name = ""
            var semester = ""
            if nameSplit.count == 4
            {
                name = nameSplit[0]+"("+nameSplit[1]
                semester = nameSplit[3].replacingOccurrences(of: ")", with: "")
            }
            else
            {
                name = nameSplit[0]
                semester = nameSplit[2].replacingOccurrences(of: ")", with: "")
            }
            let course = Course()
            course.id = id
            course.name = name
            course.semester = semester
            set.insert(semester)
            try! realm.write
            {
                realm.add(course)
            }
        }
        else {
            set.insert(realm.object(ofType: Course.self, forPrimaryKey: id as AnyObject)!.semester)
            try! realm.write
            {
                realm.create(Course.self, value: ["id": id, "useful": false], update: true)
            }
        }
        
    }
    
    for semester in set {
        
        let courseList = CourseList()
        courseList.semester = semester
        courseList.page = page
        courseList.compareStr = semester.replacingOccurrences(of: "秋季", with: "0").replacingOccurrences(of: "春季", with: "1").replacingOccurrences(of: "夏季", with: "2")
        try! realm.write
        {
            realm.add(courseList, update: true)
            courseList.list.append(objectsIn: realm.objects(Course.self).filter("semester == %@", semester))
        }
        
    }
    
    
}



