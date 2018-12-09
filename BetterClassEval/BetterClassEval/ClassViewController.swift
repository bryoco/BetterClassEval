//
//  ClassViewController.swift
//  BetterClassEval
//
//  Created by Raymond Lee on 12/7/18.
//  Copyright © 2018 Group_5. All rights reserved.
//

import UIKit

class ClassViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var dummyClasses = [Lecture]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("did load ClassViewController")

        setUpDummyClass()

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dummyClasses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tblView.dequeueReusableCell(withIdentifier: "classCell") as? ClassesCell else {
            return UITableViewCell()
        }
        cell.lblClassAbbrev.text = dummyClasses[indexPath.row].classAbbrev
        cell.lblClassFull.text = dummyClasses[indexPath.row].classFullName
        return cell
    }
    
    private func setUpDummyClass() {
        dummyClasses.append(Lecture(classAbbrev: "CSE 142", classFullName: "Introductory Programming I"))
        dummyClasses.append(Lecture(classAbbrev: "CSE 143", classFullName: "Introductory Programming II"))
        dummyClasses.append(Lecture(classAbbrev: "CSE 154", classFullName: "Web Programming"))
        dummyClasses.append(Lecture(classAbbrev: "INFO 200", classFullName: "Intellectual Foundation of Informatics"))
        dummyClasses.append(Lecture(classAbbrev: "CLAS 430", classFullName: "Greek & Roman Mythology"))
        dummyClasses.append(Lecture(classAbbrev: "MATH 324", classFullName: "Multivariable Calculus"))
    }

}

class Lecture {
    let classAbbrev: String
    let classFullName: String
    
    init(classAbbrev: String, classFullName: String) {
        self.classAbbrev = classAbbrev
        self.classFullName = classFullName
    }
    
}
