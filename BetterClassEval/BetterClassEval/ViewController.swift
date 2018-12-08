//
//  ViewController.swift
//  BetterClassEval
//
//  Created by Rico Wang on 11/21/18.
//  Copyright © 2018 Group_5. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseDatabase

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        QueryFirebase().queryByLecturer("Andy Ko", completion: { results in
            for result in results {
                NSLog(result.debugDescription)
            }
        })

        QueryFirebase().queryByClass("INFO 200", completion: <#T##@escaping (([classData]) -> ())##@escaping (([BetterClassEval.classData]) -> ())#>)

        NSLog("exited from completion")
    }

}
