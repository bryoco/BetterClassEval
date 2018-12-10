//
//  HomeViewController.swift
//  BetterClassEval
//
//  Created by Rico Wang on 12/9/18.
//  Copyright © 2018 Group_5. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate, UITableViewDelegate {

    var profSelected = ""
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchResultTableView: UITableView!
    
    var data: [ClassData] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print(data.count)
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = searchResultTableView.dequeueReusableCell(withIdentifier: "searchCell") as? ClassesCell else {
            return UITableViewCell()
        }
        
        cell.lblClassname.text = data[indexPath.row].className
        cell.lblLecturername.text = data[indexPath.row].quarter + " " + data[indexPath.row].lecturer
        cell.lblQuarter.text = ""
//        cell.lblQuarter.text = data[indexPath.row].quarter

        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchBar.showsScopeBar = true
        self.searchBar.delegate = self
        
        self.searchBar.placeholder = "Search Anything!"
        
        searchResultTableView.dataSource = self
        searchResultTableView.delegate = self
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = self.searchBar.text else { return }
        
        
        QueryFirebase().query(anything: query, completion: { results in
            self.data = []
            for result in results {
//                NSLog(result.debugDescription)
                self.data.append(result)
            }
            self.searchResultTableView.reloadData()
        })
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //appData.quizController.reset(indexPath.row)
        self.profSelected = data[indexPath.row].lecturer
        EvalData.shared.professor = data[indexPath.row].lecturer
        EvalData.shared.quarters =  data[indexPath.row].quarter
        EvalData.shared.classTaught = data[indexPath.row].className
        //EvalData.shared.categories = []
        self.performSegue(withIdentifier: "toDetail", sender: self)
    }

}
