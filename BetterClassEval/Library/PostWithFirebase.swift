//
//  PostUserAuth.swift
//  BetterClassEval
//
//  Created by GeFrank on 11/29/18.
//  Copyright © 2018 Group_5. All rights reserved.
//

import Foundation
import Firebase

public class PostWithFirebase {
    let fbEmail: String?
    
    public init(fbEmail: String?, fbPw: String?, completion: @escaping (() -> Void)) {
        
        if fbEmail != nil && fbPw != nil {
            self.fbEmail = fbEmail
            Auth.auth().signIn(withEmail: fbEmail!, password: fbPw!) { (user, error) in
                guard let _ = user else {print("\(error.debugDescription)"); return}; completion()}
        } else {
            let user = Auth.auth().currentUser!
            self.fbEmail = user.email
            completion()
        }
    }
    
    func createUsr (_ usrName: String, _ usrPw: String) {
        Auth.auth().createUser(withEmail: usrName, password: usrPw) { (authResult, error) in
            guard let _ = authResult?.user else {return}
        }
    }
//
//    private func usrSignIn (_ usrName: String, _ usrPw: String, completion: @escaping (() -> Void)) {
//
//        }
//    }
//
    private func getUserID () -> String? {
        let user = Auth.auth().currentUser!
        return user.uid
    }
    

    func postData (_ data: [String: Any]) {
        let userID = getUserID()!
        let lecturer = data["Name"] ?? "Unknown Professor"
        let ref = Database.database().reference()
        ref.child("users/\(userID)/").child(lecturer as! String).setValue(data)
    }
    
    //data format: ["Name": "Joel Ross",
    //              "Instructor\'s Contribution": "46%",
    //              "The Course as a Whole": "47%",
    //              "Instructor\'s Effectiveness": "54%",
    //              "Instructor\'s Interest": "80%",
    //              "Amount Learned": "50%",
    //              "Grading Techniques": "45%",
    //              "Course Content": "44%"]
    func getData (ofLecturer: String!, completion: @escaping ([String: String]) -> Void) {
        let userID = getUserID()!
        var lecturerData: [String: String] = [:]
        let ref = Database.database().reference()
        ref.child("users").child(userID).child(ofLecturer).observeSingleEvent(of: .value, with: {(snapshot) in
            lecturerData = snapshot.value as! [String : String]
            completion(lecturerData)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
}
