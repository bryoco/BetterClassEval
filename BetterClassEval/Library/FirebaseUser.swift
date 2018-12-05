//
//  PostUserAuth.swift
//  BetterClassEval
//
//  Created by GeFrank on 11/29/18.
//  Copyright © 2018 Group_5. All rights reserved.
//

import Foundation
import Firebase

public class FirebaseUser {
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
    
    private func createUsr (_ usrName: String, _ usrPw: String) {
        Auth.auth().createUser(withEmail: usrName, password: usrPw) { (authResult, error) in
            guard let _ = authResult?.user else {return}
        }
    }
    
    private func getUserID () -> String? {
        let user = Auth.auth().currentUser!
        return user.uid
    }
    

    func postData (_ data: NSDictionary, _ quarter: String) {
        let userID = getUserID()!
        let ref = Database.database().reference()
        ref.child("users/\(userID)/").child("\(quarter)").child("\(data["Name"] as! String)").setValue(data)
    }
    
    //data format: ["Name": "Joel Ross",
    //              "Instructor\'s Contribution": "46%",
    //              "The Course as a Whole": "47%",
    //              "Instructor\'s Effectiveness": "54%",
    //              "Instructor\'s Interest": "80%",
    //              "Amount Learned": "50%",
    //              "Grading Techniques": "45%",
    //              "Course Content": "44%"]
    func getData (ofLecturer: String, completion: @escaping ([String: String]) -> Void) {
        let userID = getUserID()!
        var lecturerData: [String: String] = [:]
        let ref = Database.database().reference()
        ref.child("users").child(userID).observeSingleEvent(of: .value, with: {(snapshot) in
            lecturerData = snapshot.value as! [String : String]
            completion(lecturerData)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
//    returned data example:
//    ["Instructor\'s Contribution": ["15%", "20%"], "Grading Techniques": ["35%", "35%"], "Course Content": ["25%", "20%"], "Instructor\'s Interest": ["15%", "15%"], "Amount Learned": ["25%", "25%"], "Instructor\'s Effectiveness": ["5%", "55%"], "The Course as a Whole": ["28%", "50%"]]
    func getAllData(ofLecturer: String, ofQuarter: String, completion: @escaping ([String: [String]]) -> Void) {
    //func getAllData(ofLecturer: String, ofQuarter: String) {
        let ref = Database.database().reference()
        var result: [String: [String]] = [:]
        ref.observeSingleEvent(of: .childAdded, with: { (snapshot) in
            let userData = snapshot.value! as! NSDictionary
                for i in 0...userData.count - 1 {//traverse trough each user
                    let currentUser = userData[userData.allKeys[i]] as! NSDictionary
                    let quarters = currentUser.allKeys as! [String]//get list of quarters with survey
                    if quarters.contains(ofQuarter) {
                        let quarterData = currentUser[ofQuarter] as! NSDictionary //select current quarter
                        let lecturers = quarterData.allKeys as! [String]
                        if lecturers.contains(ofLecturer) {
                            let lecturerData = quarterData[ofLecturer] as! [String: String] //select lecturer
                            for k in lecturerData.keys {
                                if (k != "Name") {
                                        if (!result.keys.contains(k)) {
                                            result.updateValue([], forKey: k)
                                        }
                                        var currentStats = result[k]!
                                        currentStats.append(lecturerData[k]!)
                                        result.updateValue(currentStats, forKey: k)
                                }
                            }
                        }
                    
                }
            }
            completion(result)
        })
    }
}
