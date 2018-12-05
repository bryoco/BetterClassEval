//
//  ViewController.swift
//  BetterClassEval
//
//  Created by Rico Wang on 11/21/18.
//  Copyright © 2018 Group_5. All rights reserved.
//

import UIKit
import WebKit
import Firebase

class ViewController: UIViewController, WKUIDelegate {
    let mockUsrEmail = "info449betterclasseval@gmail.com"
    let mockUsrPw = "uwinfo449"
    
    var webView = WKWebView()
    override func loadView() {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let testData = ["Name": "Joel Ross", "Instructor\'s Contribution": "46%", "The Course as a Whole": "47%", "Instructor\'s Effectiveness": "54%", "Instructor\'s Interest": "80%", "Amount Learned": "50%", "Grading Techniques": "45%", "Course Content": "44%"]
        var fbUser = PostWithFirebase(fbEmail: nil, fbPw: nil) {return}
        fbUser = PostWithFirebase(fbEmail: mockUsrEmail, fbPw: mockUsrPw, completion: {
            fbUser.postData(testData); fbUser.getData(ofLecturer: "Joel Ross", completion: {
                (lecturerData) in NSLog(lecturerData.description)
            })})
        
//        let user = Authentication(username: "", password: "")
//        
//        user.getFirstKiss(completion: { result in
//            user.getWeblogin(cookies: result, completion: {
//                user.getCoursePage("https://www.washington.edu/cec/f/FHL333A4651.html", completion: {
//                    user.printFields()
//        })})})
    }
    
}
