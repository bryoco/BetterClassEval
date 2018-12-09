//
// Created by Rico Wang on 2018-12-08.
// Copyright (c) 2018 Group_5. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth

public func isValidEmail(email: String) -> Bool {
    let suffix = email.split(separator: "@")[1]
    return suffix == "uw.edu" || suffix == "u.washington.edu"
}

public func signUp(email: String) {

    let actionCodeSettings = ActionCodeSettings()
    actionCodeSettings.url = URL(string: "https://www.example.com")
    actionCodeSettings.handleCodeInApp = true
    actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)

    Auth.auth().sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings) { error in
        if let error = error {
            NSLog(error.localizedDescription)
            return
        }
        // The link was successfully sent. Inform the user.
        // Save the email locally so you don't need to ask the user for it again
        // if they open the link on the same device.
        UserDefaults.standard.set(email, forKey: "Email")

        NSLog("Check your email for link")
    }
}