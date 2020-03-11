//
//  ViewController.swift
//  Project2
//
//  Created by Ian McDonald on 03/01/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {

    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    
    var countries = [String]()
    var score = 0
    var correctAnswer = 0
    var questionNumber = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        button1.layer.borderWidth = 1
        button2.layer.borderWidth = 1
        button3.layer.borderWidth = 1
        
        button1.layer.borderColor = UIColor.lightGray.cgColor
        button2.layer.borderColor = UIColor.lightGray.cgColor
        button3.layer.borderColor = UIColor.lightGray.cgColor
        
        countries += ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
        
        askQuestion()
        requestPermission()
        
        // Detect app moved to background set Reminders
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(setNotifications),
                                       name: UIApplication.willResignActiveNotification,
                                       object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(cancelNotifications),
                                       name: UIApplication.willEnterForegroundNotification,
                                       object: nil)
    }
    
    private func askQuestion(action: UIAlertAction! = nil) {
        countries.shuffle()
        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)
        correctAnswer = Int.random(in: 0...2)
        title = "\(countries[correctAnswer].uppercased()) Score: \(score)"
        questionNumber += 1
    }
    
    private func newGame(action: UIAlertAction! = nil) {
        questionNumber = 0
        score = 0
        askQuestion()
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        var title: String
        
        if sender.tag == correctAnswer {
            title = "Correct"
            score += 1
        } else {
            title = "Wrong, Thats the flag of \(countries[sender.tag].uppercased())"
            score -= 1
        }
        
        if questionNumber < 10 {
            let ac = UIAlertController(title: title, message: "Your score is \(score)", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: title, message: "Your final score is \(score)", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "New Game", style: .default, handler: newGame))
            present(ac, animated: true)
        }
        
    }
    
    func requestPermission() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay!")
            } else {
                print("D'oh")
            }
        }
    }
    
    @objc func setNotifications() {
        cancelNotifications()
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Don't forget to play "
        content.categoryIdentifier = "alarm"
        content.sound = UNNotificationSound.default
        
        for index in 1...7 {
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(index * 86400),
                                                            repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content,
                                                trigger: trigger)
            center.add(request)
        }
    }
    
    @objc func cancelNotifications() {
         UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

