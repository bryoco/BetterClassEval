//
//  PostUserAuth.swift
//  BetterClassEval
//
//  Created by GeFrank on 11/29/18.
//  Copyright © 2018 Group_5. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth

public class FirebaseUser {
    let fbEmail: String?
    var userID: String?
    
    public init(fbEmail: String?, fbPw: String?, completion: @escaping (() -> Void)) {
        if fbEmail != nil && fbPw != nil {
            self.fbEmail = fbEmail
            createUsr(fbEmail!, fbPw!) {
                Auth.auth().signIn(withEmail: fbEmail!, password: fbPw!) { (user, error) in
                    guard let _ = user else {print("\(error.debugDescription)"); return}; self.userID = Auth.auth().currentUser!.uid;completion()}}
        } else {
            self.fbEmail = fbEmail
            completion()
        }
    }
    
    private func createUsr (_ usrName: String, _ usrPw: String, completion: @escaping(() -> Void)) {
        Auth.auth().createUser(withEmail: usrName, password: usrPw) { (authResult, error) in
            guard let _ = authResult?.user else {return}; completion()
        }
    }
    

    func postData (_ data: NSDictionary, _ quarter: String, _ forClass: String, completion: @escaping (() -> Void)) {
        let userID = self.userID
        let ref = Database.database().reference()
        ref.child("users/\(String(describing: userID!))/").child("\(quarter)").child("\(data["Name"] as! String)").child("\(forClass)").setValue(data)
        completion()
    }
    
//    returned data example:j
//    ["Instructor\'s Contribution": ["15%", "20%"], "Grading Techniques": ["35%", "35%"], "Course Content": ["25%", "20%"], "Instructor\'s Interest": ["15%", "15%"], "Amount Learned": ["25%", "25%"], "Instructor\'s Effectiveness": ["5%", "55%"], "The Course as a Whole": ["28%", "50%"]]
    func getAllData(ofLecturer: String, ofQuarter: String, ofClass: String, completion: @escaping ([String: [Int]]) -> Void) {
    //func getAllData(ofLecturer: String, ofQuarter: String) {
        let ref = Database.database().reference()
        var result: [String: [Int]] = [:]
        ref.observeSingleEvent(of: .childAdded, with: { (snapshot) in
            let userData = snapshot.value! as! NSDictionary
                for i in 0...userData.count - 1 {//traverse trough each user
                    let currentUser = userData[userData.allKeys[i]] as! NSDictionary
                    let quarters = currentUser.allKeys as! [String]//get list of quarters with survey
                    if quarters.contains(ofQuarter) {
                        let quarterData = currentUser[ofQuarter] as! NSDictionary //select current quarter
                        let lecturers = quarterData.allKeys as! [String]
                        if lecturers.contains(ofLecturer) {
                            let lecturerData = quarterData[ofLecturer] as! NSDictionary //select lecturer
                            let classesTaught = lecturerData.allKeys as! [String]
                            if classesTaught.contains(ofClass) {
                                let classData = lecturerData [ofClass] as! [String: Any] //select class
                                for k in classData.keys {
                                    if (k != "Name") {
                                        if (!result.keys.contains(k)) {
                                            result.updateValue([], forKey: k)
                                        }
                                        var currentStats = result[k]!
                                        currentStats.append(classData[k] as? Int ?? 0)
                                        result.updateValue(currentStats, forKey: k)
                                    }
                                }
                            }
                            
                        }
                    
                }
            }
            completion(result)
        })
    }
}
