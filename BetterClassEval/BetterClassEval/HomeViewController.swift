//
//  HomeViewController.swift
//  BetterClassEval
//
//  Created by Rico Wang on 12/9/18.
//  Copyright © 2018 Group_5. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate, UITableViewDelegate {

    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchResultTableView: UITableView!
    @IBOutlet weak var tableView: UITableView!
    
    var selectedData = EvalData.shared

    var data: [ClassData] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(data.count)
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = searchResultTableView.dequeueReusableCell(withIdentifier: "searchCell") as? ClassesCell else {
            return UITableViewCell()
        }
        
        cell.lblClassname.text = data[indexPath.row].className
        cell.lblLecturername.text = data[indexPath.row].lecturer
        cell.lblQuarter.text = data[indexPath.row].quarter
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let cell = self.tableView.visibleCells[indexPath.row] as! ClassesCell
        selectedData.professor = cell.lblLecturername.text!
        selectedData.classTaught = cell.lblClassname.text!
        selectedData.quarters = cell.lblQuarter.text!
    }
    
    override func viewDidLoad() {
        
        self.searchBar.showsScopeBar = true
        self.searchBar.delegate = self
        super.viewDidLoad()

        self.searchBar.placeholder = "Search Anthing!"
        
        self.searchResultTableView.dataSource = self
        self.searchResultTableView.delegate = self
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

}
