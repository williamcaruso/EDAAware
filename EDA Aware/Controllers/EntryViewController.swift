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

    // MARK: - Outlets
    @IBOutlet var backButton: UIButton!
    @IBAction func back(_ sender: Any) {
        currentQuestion -= 1
        currentQuestion = max(currentQuestion, 0)
        
        currentSelectedOptions.removeAll()
        currentSelectedTimes.removeAll()
        
        let prevAns = answers[String(currentQuestion)]
        for ans in prevAns! {
            currentSelectedOptions.append(ans)
            tagView.removeTag(ans)
            if let idx = tags.index(of: ans) {
                tags.remove(at: idx)
            }
        }
        
        let title = self.questions[self.currentQuestion]["title"] as! String
        let multiple = self.questions[self.currentQuestion]["multiple"] as! Bool
        self.titleLabel.text = title
        self.subtitleLabel.text = multiple ? "Select as many as apply" : "Select one"
        if !multiple {
            currentSelectedOptions.removeAll()
        }
        
        self.optionsTableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.right)
    }
    
    var start_time: Int64!
    var tags:[String] = []
    
    // Mark: - Properties
    var finished = false
    var currentQuestion = 0
    var currentSelectedOptions:[String] = []
    var currentSelectedTimes:[Int64] = []
    var answers: [String:[String]] = [:]
    var times: [Int64] = []
    var questions = [
        ["title": "I am in...",
         "multiple": false,
         "options": ["Math", "ELA", "Social Studies", "Science", "Health", "Art", "Counseling", "Academic Support", "Lunch", "Transition/Post-Secondary", "Science of Me", "Advisory", "Elective", "PE", "Sensory Room", "Walking", "Other"],
         "next": [],
         "saveTags": true
        ],
        ["title": "I am...",
         "multiple": true,
         "options": ["Watching a video", "Reviewing, correcting, editing work", "Listening to a teacher", "Taking test/quiz", "Working independently", "Reading", "Talking with staff/peers", "Writing", "Playing a board/card/dice game", "Doing something with others", "Exercising", "Participating in a game in the Gym", "Participating in a class discussion", "Other"],
         "next": [],
         "saveTags": true
        ],
        ["title": "My physiological state is...",
         "multiple": false,
         "options": ["Very Activated", "Activated", "Neutral/Middle", "Calm", "Very Calm"],
         "next": [],
         "saveTags": true
        ],
        ["title": "I'm feeling...",
         "multiple": false,
         "options": ["Very Positive", "Positive", "Neutral", "Negative", "Very Negative", "I don't know"],
         "next": [],
         "saveTags": true
        ],
        // TODO
        ["title": "Is my @ physiological\nstate expected in this context?",
         "multiple": false,
         "options": ["True", "False", "I don't know"],
         "next": [],
         "saveTags": false
        ],
        ["title": "I will use a strategy to help\nregulate myself",
         "multiple": false,
         "options": ["Yes", "No", "I don't know"],
         "next": [],
         "saveTags": false
        ],
        ["title": "I will...",
         "multiple": true,
         "options": ["Take a break in sensory room", "Think a different thought", "Pay attention to the teacher", "Go for a walk", "Do nothing", "Use a fidget", "Take deep breaths", "Go to nurse", "Take a break in class", "Visualize", "Draw", "Read", "Other"],
         "next": [],
         "saveTags": false
        ],
        ["title": "Right now I feel...",
         "multiple": false,
         "options": ["More activated", "Less activated", "No change", "I don't know"],
         "next": [],
         "saveTags": false
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
            self.navigationController?.isNavigationBarHidden = false
            navigationController!.popViewController(animated: true)
        } else {
            nextQuestion()
        }
    }
    
    // Mark: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        tagView.textFont = UIFont(name: "Hiragino Sans", size: 13)!
        tagView.alignment = .left
        
        
        start_time = Date().toMillis()
        
        backButton.isHidden = true
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
                currentSelectedTimes.remove(at: idx)
            } else {
                currentSelectedOptions.append(cell.optionLabel.text!)
                currentSelectedTimes.append(Date().toMillis())
            }
            optionsTableView.reloadData()
        } else {
            currentSelectedOptions.append(cell.optionLabel.text!)
            nextQuestion()
        }
    }
    
    // Mark: - Helper Methods
    func nextQuestion() {
        if questions[currentQuestion]["saveTags"] as! Bool {
            tagView.addTags(currentSelectedOptions)
            tags += currentSelectedOptions
        }
        
        if currentQuestion == 0 {
            backButton.isHidden = false
        }
        
        if currentQuestion == 2 {
            print("Question 4")
            let old5 = questions[4]["title"] as! String
            let split5 = old5.components(separatedBy: "@")
            let newQ5 = split5[0] + currentSelectedOptions[0].lowercased() + split5[1]
            print(newQ5)
            questions[4]["title"] = newQ5
        }
        if currentQuestion == 5 {
            if currentSelectedOptions[0] != "Yes" {
                currentQuestion += 1
            }
        }
        
        answers[String(currentQuestion)] = currentSelectedOptions
        times += currentSelectedTimes
        currentSelectedOptions.removeAll()
        currentSelectedTimes.removeAll()
        currentQuestion += 1

        
        
        if currentQuestion == questions.count {
            optionsTableView.isHidden = true
            currentQuestion -= 1
            subtitleLabel.isHidden = true
            titleLabel.text = "All Done"
            nextButton.isHidden = false
            backButton.isHidden = false
            finished = true
            
            let tabbar = tabBarController as! AwareTabBarController
            let date = getDate()
            let time = getTime()
            print("path ==> users/\(tabbar.username)/journal/\(date)/\(time)")

            tabbar.journalEntries.insert(["date": date,
                                          "time": time,
                                          "entry": ["tags": tags]], at: 0)
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let title = self.questions[self.currentQuestion]["title"] as! String
            let multiple = self.questions[self.currentQuestion]["multiple"] as! Bool
            self.titleLabel.text = title
            self.subtitleLabel.text = multiple ? "Select as many as apply" : "Select one"
            self.optionsTableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.left)
        }
    }

}
