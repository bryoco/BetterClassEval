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

    public init(fbEmail: String?, fbPw: String?, completion: @escaping (() -> Void)) {
        if fbEmail != nil && fbPw != nil {
            self.fbEmail = fbEmail
            Auth.auth().createUser(withEmail: fbEmail!, password: fbPw!) {(authResult, error) in
                guard let _ = authResult?.user else {return} ;
//            createUsr(fbEmail!, fbPw!) {
                self.userID = authResult!.user.uid
                NSLog(self.userID!)
                Auth.auth().signIn(withEmail: fbEmail!, password: fbPw!) { (user, error) in
                    completion()}}
        } else {
            self.fbEmail = fbEmail
            completion()
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
        let userID = self.userID!

        let client = Client(appID: "WLTP65SNR9", apiKey: "2130a3d1acaa370e6559052e072f1c44")
        let index = client.index(withName: "userEval")

        // Getting existing data
        var existingData: [[String : Any]] = []
        QueryFirebase().getUserSubmission(userID: userID, completion: { results in

            for r in results {
                if r["class"] as! String == data["class"] as! String { return }
                existingData.append(r)
            }

            existingData.append(data)

            // Warp and send
            let obj: [String : Any] = ["data": existingData]
            index.addObject(obj, withID: userID)
            NSLog("upload completed!")
            completion()
        })
    }
}
