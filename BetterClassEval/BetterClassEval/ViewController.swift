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

        /*
        To any poor souls whom try to maintain this spaghetti, you have my warning - don't.

        Just use it.

        This service literally retires on Dec. 30, 2018 and I am not intended to maintain it unless they switch to
        oauth or something similar.

        The complete flow of requesting a review page is as followed:
        1. Issue a GET request to UW Weblogin, get the hidden fields
        2. POST user creds and the hidden fields from Step 1 to UW Weblogin to *actually* log in,
           record pubcookie_l from response
        3. GET the review page, record pubcookie_g_req and relay_url from response
        4. POST to UW Weblogin with [Cookie: pubcookie_l] as header, and pubcookie_g_req=?&relay_url=? as body,
           record pubcookie_g from the hidden fields from response
        5. GET the review page with [Cookie: pubcookie_g] as header, and parse the resulting HTML

        TODO: Will simplify multiple requests and release later so no need to do all five steps for every request.
              So long as cookies are valid, the pubcookie_g is the universal key to any review page
        */

        // Creating a new Authentication object
        let user = Authentication(username: Creds().username, password: Creds().password)
        // Specify a target review URL
        let url: String = "https://www.washington.edu/cec/m/MATH307F2696.html"

//        // Step 1
//        user.firstKiss(completion: { result in
//            // Step 2
//            user.weblogin(cookies: result, completion: {
//                // Step 3
//                user.getCoursePage(url, completion: {
//                    // Step 4
//                    user.webloginRedirect(url, completion: {
//                        // Step 5
//                        user.getCoursePageWithCookie(url, completion: { result in
//                            HTMLParser().getStatsFromPage(result, completion: { result in
//                                NSLog(result.debugDescription) })})})})})})
        
        user.firstKiss(completion: {
            user.weblogin(cookies: user.firstKiss, completion: {
                user.getCoursePage(url, completion: {
                    user.webloginRedirect(url, completion: {
                        user.getCoursePageWithCookie(url, completion: { _ in
                            user.printFields()
//                            let list: [[String : String]] = HTMLParser().parseAllClassHrefs(result)
//                            for l: [String : String] in list {
//                                print(l.debugDescription)
//                            }
                        })
                    })
                })
            })
        })
        
    }
}
