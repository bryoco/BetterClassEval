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

        let user = Authentication(username: Creds().username, password: Creds().password)
        let url: String = "https://www.washington.edu/cec/d/DANCE100A1116.html"

        user.firstKiss(completion: { result in
            user.weblogin(cookies: result, completion: {
                user.getCoursePage(url, completion: {
                    user.webloginRedirect(url, completion: {
                        user.getCoursePageWithCookie(url, completion: { result in
                            HTMLParser().getStatsFromPage(result, completion: { result in
                                NSLog(result.debugDescription)
                            })
                        })
                    })
                })
            })
        })
    }

}
