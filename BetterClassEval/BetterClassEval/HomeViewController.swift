//
//  HomeViewController.swift
//  BetterClassEval
//
//  Created by Rico Wang on 12/9/18.
//  Copyright © 2018 Group_5. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate {

    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchResultTableView: UITableView!
    
    var data: [ClassData] = []
    
    
    /// TableView protocol stubs
    /// Created by Raymond
    ///
    /// - Parameters:
    ///   - tableView: TableView
    ///   - section: Section
    /// - Returns: Number of sections
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    
    /// TableView protocol stubs
    /// Created by Raymond
    ///
    /// - Parameters:
    ///   - tableView: TableView
    ///   - indexPath: Index
    /// - Returns: Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = searchResultTableView.dequeueReusableCell(withIdentifier: "searchCell") as? ClassesCell else {
            return UITableViewCell()
        }
        
        cell.lblClassname.text = data[indexPath.row].className
        cell.lblLecturername.text = data[indexPath.row].quarter + " " + data[indexPath.row].lecturer
        cell.lblQuarter.text = ""

        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Registering SearchBar delegate
        self.searchBar.showsScopeBar = true
        self.searchBar.delegate = self
        self.searchBar.placeholder = "Search Anything!"
        
        // Registering TableView data source
        searchResultTableView.dataSource = self
    }
    
    
    /// Perform search
    /// Created by Rico
    ///
    /// - Parameter searchBar: UISearchBar
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = self.searchBar.text else { return }

        // Query data
        QueryFirebase().query(anything: query, completion: { results in
            self.data = []
            for result in results {
                self.data.append(result)
            }
            self.searchResultTableView.reloadData()
        })
        
    }

}
