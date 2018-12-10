//
//  PostViewController.swift
//  BetterClassEval
//
//  Created by GeFrank on 12/5/18.
//  Copyright © 2018 Group_5. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseCore

class PostViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var currentData = EvalData.shared
    var submitForm: [String : Any] = [:]
    var fbUser: FirebaseUser = FirebaseUser(fbEmail: nil, fbPw: nil) {return}

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lecturerName: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        lecturerName.text = "\(currentData.professor) \(currentData.classTaught)"
    }

    
    /// TableView Protocol stubs
    /// Created by Frank
    ///
    /// - Parameters:
    ///   - tableView: TableView
    ///   - section: Section
    /// - Returns: Number of sections
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentData.categories.count
    }
    
    
    /// TableView protocol stubs
    /// Created by Frank
    ///
    /// - Parameters:
    ///   - tableView: TableView
    ///   - indexPath: Index
    /// - Returns: Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! PostTableViewCell
        cell.categoryLabel.text = currentData.categories[indexPath.row]
        cell.scoreLabel.text = String(Int(round(cell.scoreSlider.value)))
        return cell
    }
    
    
    /// Submit
    /// Created by Frank
    ///
    /// - Parameter sender: submit button is pressed
    @IBAction func submitBtnTouched(_ sender: Any) {
        let cells = self.tableView.visibleCells as! [PostTableViewCell]

        for cell in cells {
            let categoryName = cell.categoryLabel.text
            let categoryValue = Int(cell.scoreSlider.value)
            submitForm.updateValue(categoryValue, forKey: categoryName!)
        }

        let UIalert = UIAlertController(title: "Sign in/ Sign up",
                message: "Please type in Firebase email and password (If you don't have an account, " +
                        "sign up by typing in an email address and password.)", preferredStyle: .alert)

        UIalert.addTextField { (username) in
            username.text = ""
            username.placeholder = "Login"
        }

        UIalert.addTextField(configurationHandler: { (passwordField) in
            passwordField.text = ""
            passwordField.placeholder = "Password"
            passwordField.isSecureTextEntry = true
        })

        UIalert.addAction(UIAlertAction(title:"OK", style: .default, handler: { alert -> Void in

            let userEmail: String = UIalert.textFields![0].text!
            let userPw: String = UIalert.textFields![1].text!

            if !self.isValidEmail(userEmail) {

                let uiAlert = UIAlertController(title: "Invalid email", message: "You cannot submit an evaluation " +
                        "without a valid UW NetID", preferredStyle: .alert)
                uiAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(uiAlert, animated: true)

            } else {

                // Dispatch queue: Sign up/in
                self.fbUser = FirebaseUser(fbEmail: userEmail, fbPw: userPw, completion: {

                    // Dispatch queue: Post data
                    let postData: [String: Any] = ["statistics": self.submitForm,
                                                   "lecturer": self.currentData.professor,
                                                   "quarter": self.currentData.quarters,
                                                   "class": self.currentData.classTaught]

                    self.fbUser.postData(postData) {

                        let uiAlert = UIAlertController(title: "Thank you for evaluating \(self.currentData.professor) for " +
                                "\(self.currentData.classTaught)!", message: nil, preferredStyle: .alert)
                        uiAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(uiAlert, animated: true, completion: nil)

                    }
                })
            }
        }))

        UIalert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(UIalert, animated: true, completion: nil)

    }

    
    /// Check if a given email is valid by looking at its regex pattern and the "uw.edu" suffix.
    /// Created by Rico
    ///
    /// - Parameter email: An email address
    /// - Returns: true if is valid, false otherwise
    func isValidEmail(_ email: String) -> Bool {

        // Check regex pattern
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = email as NSString
            let results = regex.matches(in: email, range: NSRange(location: 0, length: nsString.length))

            if results.count == 0 { return false }

        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return false
        }

        // Check UW domain
        let split = email.split(separator: "@")
        if String(split[(split.count - 1)]) != "uw.edu" {
            return false
        }

        return true
    }
}
