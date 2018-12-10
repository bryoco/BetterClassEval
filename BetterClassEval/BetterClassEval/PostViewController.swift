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

    let fbUsrEmail = "info449betterclasseval1@gmail.com"
    let fbUsrPw = "uwinfo449"
    var currentData = EvalData.shared
    var submitForm: [String: Any] = [:]
    var fbUser: FirebaseUser = FirebaseUser(fbEmail: nil, fbPw: nil) {return}

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lecturerName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("did load PostViewController")
        print(currentData.professor)
        
        let classArray = currentData.classTaught.split(separator: " ")

        lecturerName.text = "\(currentData.professor) \(classArray[classArray.count - 3]) \(classArray[classArray.count - 2])"
        submitForm.updateValue(currentData.professor, forKey: "Name")
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentData.categories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! PostTableViewCell
        cell.categoryLabel.text = currentData.categories[indexPath.row]
        cell.scoreLabel.text = String(Int(round(cell.scoreSlider.value)))
        return cell
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func submitBtnTouched(_ sender: Any) {
        let cells = self.tableView.visibleCells as! [PostTableViewCell]
        for cell in cells {
            let categoryName = cell.categoryLabel.text
            let categoryValue = Int(cell.scoreSlider.value)
            submitForm.updateValue(categoryValue, forKey: categoryName!)
        }
        let UIalert = UIAlertController(title: "Sign in/ Sign up", message: "Please type in Firebase email and password (If you don't have an account, sign up by typing in an email address and password.)", preferredStyle: .alert)
        UIalert.addTextField { (username) in
            username.text = ""
            username.placeholder = "Login:"
        }
        UIalert.addTextField(configurationHandler: { (passwordField) in
            passwordField.text = ""
            passwordField.placeholder = "Password:"
            passwordField.isSecureTextEntry = true
        })
        UIalert.addAction(UIAlertAction(title:"OK", style: .default, handler: {alert -> Void in
            let userEmail = UIalert.textFields![0] as UITextField
            let userPw = UIalert.textFields![1] as UITextField
            self.fbUser = FirebaseUser(fbEmail: userEmail.text!, fbPw: userPw.text!, completion: {
                self.fbUser.postData(self.submitForm as NSDictionary, self.currentData.quarters, self.currentData.classTaught) {
                    let uiAlert = UIAlertController(title: "Thank you for evaluating \(self.currentData.professor) for \(self.currentData.classTaught)!", message: nil, preferredStyle: .alert)
                    uiAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(uiAlert, animated: true, completion: nil)
                }
            })
        }))
        UIalert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(UIalert, animated: true, completion: nil)

    }
    
}
