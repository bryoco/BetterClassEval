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

class ViewController: UIViewController, WKUIDelegate {

    override func loadView() {}

    override func viewDidLoad() {

        super.viewDidLoad()

        writeLogToDisk(fileName: "log")

        let user = Authentication(username: Creds().username, password: Creds().password)
        let URLList: [String] = Request().readLocalURL()

        requestEvalFromList(user: user, urlList: URLList, completion: { result in
            NSLog(result.debugDescription)
        })

        // https://stackoverflow.com/questions/1081131/viewdidload-getting-called-twice-on-rootviewcontroller-at-launch
        // So this is expected to be executed twice.
    }





}
