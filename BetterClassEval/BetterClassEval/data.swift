//
//  data.swift
//  BetterClassEval
//
//  Created by GeFrank on 12/5/18.
//  Copyright © 2018 Group_5. All rights reserved.
//

import Foundation
class EvalData {
    static let shared = EvalData()
    
    open var professor = "Joel Ross"
    open var quarters =  "WI18"
    open var classTaught = "INFO 330"
    open var categories = ["Instructor\'s Contribution", "The Course as a Whole", "Instructor\'s Effectiveness", "Instructor\'s Interest", "Amount Learned", "Grading Techniques", "Course Content"]
}
