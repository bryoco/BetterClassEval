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

        let urlList: [String] = Request().readLocalURL()

        // Log in a user
        Request().login(user, completion: {
            // Requests all URLs
//            Request().requestEvalFromList(user: user, urlList: urlList, completion: {
//                NSLog("we done")
//            })

        // Request one URL
            Request().requestEvalFromURL(user: user, url: "https://www.washington.edu/cec/a/AA101A2098.html",
                    completion: { result in NSLog(result.debugDescription) })
        })



//        Request().login(user, completion: {
//

    }





}
