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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = searchResultTableView.dequeueReusableCell(withIdentifier: "searchCell") as? ClassesCell else {
            return UITableViewCell()
        }
        
        cell.lblClassFull.text! = "1"
        cell.lblClassAbbrev.text! = "2"
        
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchBar.showsScopeBar = true
        self.searchBar.delegate = self
        
        self.searchBar.placeholder = "Search Anthing!"
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = self.searchBar.text else { return }
        
        QueryFirebase().query(anything: query, completion: { results in
            for result in results {
                NSLog(result.debugDescription)
            }
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
