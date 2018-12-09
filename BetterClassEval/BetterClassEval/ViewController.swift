//
//  ViewController.swift
//  BetterClassEval
//
//  Created by Rico Wang on 11/21/18.
//  Copyright © 2018 Group_5. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseDatabase

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let target = "UW" // or "userEval"

//        // **** Lecturer lookup ****
//        let lecturer = "Robert Nicklas"
//        QueryFirebase().queryByLecturer(target: target, lecturer: lecturer, completion: { results in
//            for result in results {
//                NSLog(result.debugDescription)
//            }
//        })

//        // **** Class lookup ****
//        let className = "Computer Science & Engineering CSE 373"
//        QueryFirebase().queryByClass(target: target, className: className, completion: { results in
//            for result in results {
//                NSLog(result.debugDescription)
//            }
//        })

//        QueryFirebase().queryAllClasses()

//        // **** Upload new evaluation ****
//        let test: [String : Any] = ["class" : "Information School INFO 481 B",
//                                    "lecturer" : "Robert Nicklas",
//                                    "quarter" : "AU17",
//                                    "enrolled" : "21",
//                                    "surveyed" : 5,
//                                    "statistics" : ["Instructor\'s effectiveness": ["40", "20", "20", "20", "0", "0", "4.00"],
//                                                    "The course as a whole": ["20", "40", "20", "20", "0", "0", "3.75"],
//                                                    "Instructor\'s contribution": ["40", "20", "40", "0", "0", "0", "4.00"],
//                                                    "The course content": ["40", "40", "0", "20", "0", "0", "4.25"]]]
//        // Option 1: Upload using a raw map
//        QueryFirebase().uploadEvaluation(map: test)
//        // Option 2: Upload using a ClassData struct
//        let testClassData = ClassData(test)
//        QueryFirebase().uploadEvaluation(classData: testClassData)


        QueryFirebase().query(anything: "INFO 200", completion: { results in
            NSLog("returning results of size \(results.count)")
            for result in results {
                NSLog(result.debugDescription)
            }
        })
    }

}
