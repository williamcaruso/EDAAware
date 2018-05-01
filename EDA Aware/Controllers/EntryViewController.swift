//
//  EntryViewController.swift
//  EDA Aware
//
//  Created by William Caruso on 5/1/18.
//  Copyright © 2018 wcaruso. All rights reserved.
//

import UIKit

class EntryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // Mark: - Properties
    var currentQuestion = 0
    var currentSelectedOptions:[String] = []
    let questions = [
        ["title": "I am in...",
         "multiple": false,
         "options": ["Math", "ELA", "Social Studies", "Science", "Health", "Art", "Counseling", "Academic Support", "Lunch", "Transition/Post-Secondary", "Science of Me", "Advisory", "Elective", "PE", "Sensory Room", "Walking", "Other"],
         "next": []
        ],
        ["title": "I am...",
         "multiple": false,
         "options": ["Watching a video", "Reviewing, correcting, editing work", "Listening to a teacher", "Taking test/quiz", "Working independently", "Reading", "Talking with staff/peers", "Writing", "Playing a board/card/dice game", "Doing something with others", "Exercising", "Participating in a game in the Gym", "Participating in a class discussion", "Other"],
         "next": []
        ],
        ["title": "My physiological state is...",
         "multiple": false,
         "options": ["Very High", "High", "Neutral/Middle", "Low", "Very Low"],
         "next": []
        ],
        ["title": "I'm feeling...",
         "multiple": false,
         "options": ["Very Positive", "Positive", "Neutral", "Negative", "Very Negative", "I don't know"],
         "next": []
        ],
        // TODO
        ["title": "Is my [state] physiological\nstate expected in [context]?",
         "multiple": false,
         "options": ["True", "False", "I don't know"],
         "next": []
        ],
        ["title": "I will use a trategy to help\nregulate myself",
         "multiple": false,
         "options": ["True", "False", "I don't know"],
         "next": []
        ],
        ["title": "I will...",
         "multiple": true,
         "options": ["Take a break in sensory room", "Think a different thought", "Pay attention to the teacher", "Go for a walk", "Do nothing", "Use a fidget", "Take deep breaths", "Go to nurse", "Take a break in class", "Visualize", "Draw", "Read", "Other"],
         "next": []
        ],
        ["title": "After reporting, now I feel...",
         "multiple": false,
         "options": ["More activated", "Less activated", "No change", "I don't know"],
         "next": []
        ],
    ]

    // Mark: - Outlets
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var optionsTableView: UITableView!
    @IBOutlet var tagCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    // Mark: TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let options = questions[currentQuestion]["options"] as! [String]
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "option", for: indexPath) as! OptionTableViewCell
        let options = questions[currentQuestion]["options"] as! [String]
        cell.optionLabel.text = options[indexPath.row]
        
        if let _ = currentSelectedOptions.index(of: options[indexPath.row]) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = optionsTableView.cellForRow(at: indexPath) as! OptionTableViewCell
        let multiple = questions[currentQuestion]["multiple"] as! Bool

        if multiple{
            if let idx = currentSelectedOptions.index(of: cell.optionLabel.text!) {
                currentSelectedOptions.remove(at: idx)
            } else {
                currentSelectedOptions.append(cell.optionLabel.text!)
            }
        } else {
            // TODO save data
            currentQuestion += 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.optionsTableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.left)
        }
    }
    

}
