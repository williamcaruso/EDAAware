//
//  SettingsViewController.swift
//  EDA Aware
//
//  Created by William Caruso on 4/20/18.
//  Copyright © 2018 wcaruso. All rights reserved.
//

import UIKit

class Surveys: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet var doneButton: UIButton!
    @IBAction func done(_ sender: Any) {
        self.navigationController?.isNavigationBarHidden = false
        navigationController!.popViewController(animated: true)
    }
    
    var currentQuestion = 0
    var questions:[String] = []
    var answers = [String:String]()
    
    var start_time: String!

    
    let options = ["Yes", "Sometimes/Maybe", "No"]
    
    let pre_questions = [
    "I am aware of my emotions",
    "I label my emotions accurately",
    "I use a wide variety of feeling words to describe my emotions",
    "I want to learn about my emotional states",
    "I can identify things that help me feel better",
    "I can identify things that cause me to feel not so good",
    "I often control or regulate my emotional response",
    "I monitor my emotions throughout the school day",
    "When I feel a negative emotion I try to express it in expected ways",
    "When I feel a negative emotion I try to suppress it",
    "Little things get me upset",
    "People have told me my emotional response is too big",
    "I want to be more aware of my emotional state",
    "I’m interested in regulating my emotional responses",
    "Getting feedback or another perspective helps me understand my emotions"
    ]
    
    
    let post_questions = [
    "I enjoyed using the EDA Aware",
    "The wearable sensor was comfortable",
    "EDA Aware helped me regulate my emotions",
    "The real-time mobile notification were useful in increasing my awareness",
    "I am aware of my emotions",
    "I label my emotions accurately",
    "I use a wide variety of feeling words to describe my emotions",
    "I want to learn about my emotional states",
    "I can identify things that help me feel better",
    "I can identify things that cause me to feel not so good",
    "I often control or regulate my emotional response",
    "I monitor my emotions throughout the school day",
    "When I feel a negative emotion I try to express it in expected ways",
    "When I feel a negative emotion I try to suppress it",
    "Little things get me upset",
    "People have told me my emotional response is too big",
    "I want to be more aware of my emotional state",
    "I’m interested in regulating my emotional responses",
    "Getting feedback or another perspective helps me understand my emotions",
    "I would like to continue using the EDA Aware"
    ]
    
    
    @IBOutlet var surveryTableView: UITableView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var backButton: UIButton!
    
    @IBAction func back(_ sender: Any) {
        currentQuestion -= 1
        currentQuestion = max(currentQuestion, 0)
        titleLabel.text = questions[currentQuestion]
        self.surveryTableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.right)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = true

        // Do any additional setup after loading the view.
        if getDate() == "05-11-2018" {
            questions = post_questions
        } else {
            questions = pre_questions
        }
        
        
        start_time = getTime()
        titleLabel.text = questions[currentQuestion]
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "survey", for: indexPath) as! SurveyTableViewCell
        cell.label.text = options[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        answers[questions[currentQuestion]] = options[indexPath.row]
        currentQuestion += 1
        
        if currentQuestion == questions.count {
    
            let tabbar = tabBarController as! AwareTabBarController
            let date = getDate()
            print(tabbar.username)
            print(date)
            print(answers)
            print("Saving...")
            titleLabel.text = "All done"
            surveryTableView.isHidden = true
            backButton.isHidden = true
            doneButton.isHidden = false
        } else {
            titleLabel.text = questions[currentQuestion]
            self.surveryTableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.left)
        }
    }
    
    
    func nextQuestion() {
        
    }


}
