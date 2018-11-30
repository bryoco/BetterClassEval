//
//  ViewController.swift
//  BetterClassEval
//
//  Created by Rico Wang on 11/21/18.
//  Copyright © 2018 Group_5. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate {
    
    var webView = WKWebView()
    
    override func loadView() {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = Authentication(username: "ricowang", password: "Jiayu@9264")
        
        user.getFirstKiss(completion: { result in
            user.getWeblogin(cookies: result, completion: {
                user.getCoursePage("https://www.washington.edu/cec/f/FHL333A4651.html", completion: {
                    user.printFields()
        })})})
    }
    
}
