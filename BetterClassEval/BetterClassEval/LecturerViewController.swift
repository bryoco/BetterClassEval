//
//  LecturerViewController.swift
//  BetterClassEval
//
//  Created by Raymond Lee on 12/5/18.
//  Copyright © 2018 Group_5. All rights reserved.
//

import UIKit

class LecturerViewController: UIViewController, UITableViewDataSource  {

    
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var dummyData = [Lecturer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("did load LecturerViewController")
        setUpDummyData()

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dummyData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tblView.dequeueReusableCell(withIdentifier: "lecturerCell") as? LectuererCell else {
            return UITableViewCell()
        }
        cell.lblName.text = dummyData[indexPath.row].firstName + " " + dummyData[indexPath.row].lastName
        cell.lblDept.text = dummyData[indexPath.row].department
        return cell
    }
    
    private func setUpDummyData() {
        dummyData.append(Lecturer(firstname: "Ted", lastname: "Neward", department: "INFO"))
        dummyData.append(Lecturer(firstname: "Ryan", lastname: "Bertha", department: "INFO"))
        dummyData.append(Lecturer(firstname: "Murphy", lastname: "Heather", department: "CSE"))
        dummyData.append(Lecturer(firstname: "Smith", lastname: "Daniel", department: "BIO"))
        dummyData.append(Lecturer(firstname: "Lonnie", lastname: "Love", department: "CSE"))
    }
    
    
}

class Lecturer {
    let firstName: String
    let lastName: String
    let department: String
    
    init(firstname: String, lastname: String, department: String) {
        self.firstName = firstname
        self.lastName = lastname
        self.department = department
    }
    
}
