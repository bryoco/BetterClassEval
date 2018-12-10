//
//  PostUserAuth.swift
//  BetterClassEval
//
//  Created by GeFrank on 11/29/18.
//  Copyright © 2018 Group_5. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import InstantSearchClient

public class FirebaseUser {
    let fbEmail: String?
    var userID: String?

    public init(fbEmail: String?, fbPw: String?, completion: @escaping ((String?) -> ())) {
        if fbEmail != nil && fbPw != nil {
            self.fbEmail = fbEmail
            Auth.auth().createUser(withEmail: fbEmail!, password: fbPw!) { (authResult, error) in

                // if user exists
                if error != nil {
                    NSLog("error at create \(error)")
                    // Login
                    Auth.auth().signIn(withEmail: fbEmail!, password: fbPw!) { (user, error) in
                        if error != nil { NSLog("error at login new user \(error)") }
                        completion(error!.localizedDescription)
                    }
                    // if doesn't exist
                } else {
                    guard let _ = authResult?.user else { return }
                    self.userID = authResult!.user.uid
                    Auth.auth().signIn(withEmail: fbEmail!, password: fbPw!) { (user, error) in
                        // Wrong password
                        if error != nil {
                            NSLog("error at logging in existing user \(error)")
                            completion(error!.localizedDescription)
                        }

//                        self.fbEmail = fbEmail
                        completion(nil)
                    }
                }

            }
        } else {
            self.fbEmail = fbEmail
            completion(nil)
        }
    }


    /// Create an user on Firebase.
    /// Created by Frank
    ///
    /// - Parameters:
    ///   - usrName
    ///   - usrPw
    ///   - completion: Does nothing?
    private func createUsr (_ usrName: String, _ usrPw: String, completion: @escaping(() -> Void)) {
        Auth.auth().createUser(withEmail: usrName, password: usrPw) { (authResult, error) in
            guard let _ = authResult?.user else {return} ; completion()
        }
    }



    /// Post user data to Algolio
    /// Created by Rico
    ///
    /// - Parameters:
    ///   - data
    ///   - completion: Does nothing
    func postData (_ data: [String : Any], completion: @escaping (() -> Void)) {

        print("data: \(data)")

        let userID = self.userID!
        let client = Client(appID: "WLTP65SNR9", apiKey: "2130a3d1acaa370e6559052e072f1c44")
        let index = client.index(withName: "userEval")

        // Getting existing data
        var existingData: [[String : Any]] = []
        QueryFirebase().getUserSubmission(userID: userID, completion: { results in

            // Update existing data with current one
            for r in results {
                print(r)
//                if r["class"] as! String == data["class"] as! String {
//                    return
//                }
                existingData.append(r)
            }

            existingData.append(data)

            // Warp and send
            let obj: [String: Any] = ["data": existingData]
            print("obj: \(obj)")
            index.addObject(obj, withID: userID)
            completion()
        })
    }
}
