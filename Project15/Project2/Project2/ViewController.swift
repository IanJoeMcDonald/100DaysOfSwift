//
//  ViewController.swift
//  Project2
//
//  Created by Ian McDonald on 03/01/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import UIKit

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
    }
    
    private func askQuestion(action: UIAlertAction! = nil) {
        countries.shuffle()
        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)
        UIView.animate(withDuration: 0.5) {
            self.button1.transform = .identity
            self.button2.transform = .identity
            self.button3.transform = .identity
        }
        correctAnswer = Int.random(in: 0...2)
        title = "\(countries[correctAnswer].uppercased()) Score: \(score)"
        questionNumber += 1
    }
    
    private func newGame(action: UIAlertAction! = nil) {
        questionNumber = 0
        score = 0
        askQuestion()
    }
    
    private func showAlert(withTitle title: String) {
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

    @IBAction func buttonTapped(_ sender: UIButton) {
        
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 5, options: [], animations: {
            sender.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            var title: String
            if sender.tag == self.correctAnswer {
                title = "Correct"
                self.score += 1
            } else {
                title = "Wrong, Thats the flag of \(self.countries[sender.tag].uppercased())"
                self.score -= 1
            }
            
            self.showAlert(withTitle: title)
        }
    }
    
}

