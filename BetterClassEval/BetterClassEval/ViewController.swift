//
//  ViewController.swift
//  BetterClassEval
//
//  Created by Rico Wang on 11/21/18.
//  Copyright © 2018 Group_5. All rights reserved.
//

import UIKit
import WebKit
import Alamofire

class ViewController: UIViewController {

//    override func loadView() {}

    override func viewDidLoad() {

        super.viewDidLoad()
        NSLog("I loaded.")

        let user: Authentication = Authentication(username: Creds().username, password: Creds().password)

//        let url: String = "https://www.washington.edu/cec/a/AA101A2098.html"
//        Request().requestEvalFromURL(user: user, url: url, completion: { result in
//            NSLog("result: \(result)")
//            NSLog("done")
//        })

//        writeLogToDisk(fileName: "100")
        let urlList: [String] = Request().readLocalURL()
        if !user.cookiesAreValid() {
            // Step 1
            user.webLoginFirstKiss(completion: {
                // Step 2
                user.weblogin(completion: {
                    // Step 3
                    user.getCoursePage(urlList[0], completion: {
                        // Step 4, gets pubcookie_g
                        user.webloginRedirect(urlList[0], completion: {
                            // Requests all URLs
                            Request().requestEvalFromList(user: user, urlList: urlList, completion: {
                                NSLog("we done") })})})})})
        }


//        writeLogToDisk(fileName: "log")

//        let user = Authentication(username: Creds().username, password: Creds().password)
//        let URLList: [String] = Request().readLocalURL()
//
//        requestEvalFromList(user: user, urlList: URLList, completion: { result in
//            NSLog(result.debugDescription)
//        })

        // https://stackoverflow.com/questions/1081131/viewdidload-getting-called-twice-on-rootviewcontroller-at-launch
        // So this is expected to be executed twice.
    }





}
