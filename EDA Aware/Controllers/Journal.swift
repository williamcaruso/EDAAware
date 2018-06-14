//
//  Journal.swift
//  EDA Aware
//
//  Created by William Caruso on 4/11/18.
//  Copyright © 2018 wcaruso. All rights reserved.
//

import UIKit

class Journal: UIViewController, DrawerControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // Mark: - Properties
    var drawer = DrawerView()
    var journalEntries:[Any] = []
    
    // Mark: - Outlets
    @IBOutlet var journalTableView: UITableView!
    
    // Mark: - Actions
    @IBAction func showSideMenu(_ sender: Any) {
        drawer = self.showDrawer(drawer: drawer)
    }
    
    // Mark: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    override func viewDidAppear(_ animated: Bool) {
        let tabbar = tabBarController as! AwareTabBarController
        journalEntries = tabbar.journalEntries
        self.journalTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.journalEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "journal", for: indexPath) as! JournalTableViewCell

        let j = self.journalEntries[indexPath.row] as! [String: Any]
        let date = j["date"] as! String
        let time = j["time"] as! String
        let entry = j["entry"] as! [String: Any]
        let tags = entry["tags"] as! [String]
        cell.tagListView.removeAllTags()
        cell.tagListView.addTags(tags)
        cell.titleLabel.text = "\(dateToTitle(date:date)) at \(time)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    // MARK: - Helper Methods
    func dateToTitle(date:String) -> String {
        if date == getDate() {
            return "Today"
        } else {
            return date
        }
    }

}
