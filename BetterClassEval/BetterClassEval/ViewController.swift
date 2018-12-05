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
        let testData = ["Name": "Joel Ross", "Instructor\'s Contribution": "15%", "The Course as a Whole": "28%", "Instructor\'s Effectiveness": "5%", "Instructor\'s Interest": "15%", "Amount Learned": "25%", "Grading Techniques": "35%", "Course Content": "25%"] //mock data for post to firebase
        var fbUser = FirebaseUser(fbEmail: nil, fbPw: nil) {return}
        fbUser = FirebaseUser(fbEmail: mockUsrEmail, fbPw: mockUsrPw, completion: {
            fbUser.postData(testData as NSDictionary, "WI18"); fbUser.getAllData(ofLecturer: "Joel Ross", ofQuarter: "WI18") { result in
                print(result)
            }

            })
        
//        let user = Authentication(username: "", password: "")
//        
//        user.getFirstKiss(completion: { result in
//            user.getWeblogin(cookies: result, completion: {
//                user.getCoursePage("https://www.washington.edu/cec/f/FHL333A4651.html", completion: {
//                    user.printFields()
//        })})})
    }
    
}
