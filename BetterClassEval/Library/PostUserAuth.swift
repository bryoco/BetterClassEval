//
//  PostUserAuth.swift
//  BetterClassEval
//
//  Created by GeFrank on 11/29/18.
//  Copyright © 2018 Group_5. All rights reserved.
//

import Foundation
import Firebase

public class PostUserAuth {
    let mockUsrName = "info449betterclasseval@gmail.com"
    let mockUsrPw = "uwinfo449"
    
    func createUsr (_ usrName: String, _ mockusrPw: String) {
        Auth.auth().createUser
    }
}
