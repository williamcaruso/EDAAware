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

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "journal", for: indexPath) as! JournalTableViewCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}
