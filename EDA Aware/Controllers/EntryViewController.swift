//
//  EntryViewController.swift
//  EDA Aware
//
//  Created by William Caruso on 5/1/18.
//  Copyright © 2018 wcaruso. All rights reserved.
//

import UIKit
import TagListView

class EntryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tags:[String] = []
    var oneLineHeight: CGFloat {
        return 54.0
    }
    
    // Mark: - Properties
    // TODO start time end time
    // TODO save to Firebase
    var finished = false
    var currentQuestion = 0
    var currentSelectedOptions:[String] = []
    var answers = [Int:[String]]()
    let questions = [
        ["title": "I am in...",
         "multiple": false,
         "options": ["Math", "ELA", "Social Studies", "Science", "Health", "Art", "Counseling", "Academic Support", "Lunch", "Transition/Post-Secondary", "Science of Me", "Advisory", "Elective", "PE", "Sensory Room", "Walking", "Other"],
         "next": []
        ],
        ["title": "I am...",
         "multiple": true,
         "options": ["Watching a video", "Reviewing, correcting, editing work", "Listening to a teacher", "Taking test/quiz", "Working independently", "Reading", "Talking with staff/peers", "Writing", "Playing a board/card/dice game", "Doing something with others", "Exercising", "Participating in a game in the Gym", "Participating in a class discussion", "Other"],
         "next": []
        ],
        ["title": "My physiological state is...",
         "multiple": false,
         "options": ["Very Activated", "Activated", "Neutral/Middle", "Calm", "Very Calm"],
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
        ["title": "I will use a strategy to help\nregulate myself",
         "multiple": false,
         "options": ["True", "False", "I don't know"],
         "next": []
        ],
        ["title": "I will...",
         "multiple": true,
         "options": ["Take a break in sensory room", "Think a different thought", "Pay attention to the teacher", "Go for a walk", "Do nothing", "Use a fidget", "Take deep breaths", "Go to nurse", "Take a break in class", "Visualize", "Draw", "Read", "Other"],
         "next": []
        ],
        ["title": "Right now I feel...",
         "multiple": false,
         "options": ["More activated", "Less activated", "No change", "I don't know"],
         "next": []
        ],
    ]

    // Mark: - Outlets
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var optionsTableView: UITableView!
    @IBOutlet var tagView: TagListView!
    @IBOutlet var nextButton: UIButton!
    
    // Mark: - Actions
    @IBAction func next(_ sender: Any) {
        if finished {
            navigationController!.popViewController(animated: true)
        } else {
            nextQuestion()
        }
    }
    
    // Mark: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        tagView.textFont = UIFont(name: "Hiragino Sans", size: 14)!
        tagView.alignment = .left
    }
    
    // Mark: TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let options = questions[currentQuestion]["options"] as! [String]
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "option", for: indexPath) as! OptionTableViewCell
        let options = questions[currentQuestion]["options"] as! [String]
        let multiple = questions[currentQuestion]["multiple"] as! Bool
        cell.optionLabel.text = options[indexPath.row]
        if currentSelectedOptions.count == 0 || !multiple {
            nextButton.isHidden = true
        }
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
            nextButton.isHidden = false
            if let idx = currentSelectedOptions.index(of: cell.optionLabel.text!) {
                currentSelectedOptions.remove(at: idx)
            } else {
                currentSelectedOptions.append(cell.optionLabel.text!)
            }
            optionsTableView.reloadData()
        } else {
            currentSelectedOptions.append(cell.optionLabel.text!)
            nextQuestion()
        }
    }
    
    // Mark: - Helper Methods
    func nextQuestion() {
        answers[currentQuestion] = currentSelectedOptions
//        tags += currentSelectedOptions
        tagView.addTags(currentSelectedOptions)
        currentQuestion += 1
        currentSelectedOptions = []

        
        if currentQuestion == questions.count {
            optionsTableView.isHidden = true
            currentQuestion -= 1
            subtitleLabel.isHidden = true
            titleLabel.text = "All Done"
            nextButton.isHidden = false
            finished = true
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let title = self.questions[self.currentQuestion]["title"] as! String
            let multiple = self.questions[self.currentQuestion]["multiple"] as! Bool
            self.titleLabel.text = title
            self.subtitleLabel.text = multiple ? "Select as many as apply" : "Select one"
            self.optionsTableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.left)
        }
        print(answers)
    }

}
