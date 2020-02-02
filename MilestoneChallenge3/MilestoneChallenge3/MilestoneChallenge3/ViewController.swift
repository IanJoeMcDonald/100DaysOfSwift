//
//  ViewController.swift
//  MilestoneChallenge3
//
//  Created by Ian McDonald on 02/02/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    //IBOutlets
    @IBOutlet weak var ResultLabel: UILabel!
    @IBOutlet weak var GuessTextField: UITextField!
    @IBOutlet weak var IncorrectGuessesLabel: UILabel!
    @IBOutlet weak var HangmanLabel: UILabel!
    
    //Constants
    let hangmanStates = ["",
                         "_______\n|\n|\n|\n|_",
                         "_______\n|     0\n|\n|\n|_",
                         "_______\n|     0\n|     |\n|\n|_",
                         "_______\n|     0\n|     |\n|    /\n|_",
                         "_______\n|     0\n|     |\n|    / \\\n|_",
                         "_______\n|     0\n|    /|\n|    / \\\n|_",
                         "_______\n|     0\n|    /|\\\n|    / \\\n|_"]
    
    //Variables
    var allWords = [String]()
    
    var level = 0 {
        didSet {
            HangmanLabel.text = hangmanStates[level]
        }
    }
    var word = "" {
        didSet {
            var first = true
            var newTitle = ""
            for _ in 0 ..< word.count {
                if(!first) {
                    newTitle += " "
                }
                first = false
                newTitle += "_"
            }
            currentTitle = newTitle
        }
    }
    var currentTitle = "" {
        didSet {
            title = currentTitle
        }
    }
    var incorrectGuesses = [String]() {
        didSet {
            var first = true
            var newLabel = ""
            for index in 0..<incorrectGuesses.count {
                if(!first) {
                    newLabel += " "
                }
                first = false
                newLabel += incorrectGuesses[index]
            }
            IncorrectGuessesLabel.text = newLabel
        }
        
    }
    var correctGuesses = [String]()
    
    //Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh,
                                                            target: self,
                                                            action: #selector(startGame))
        loadWords()
        startGame()
    }

    //Functions
    func loadWords() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
    }
    
    func correctGuess(character: String) {
        correctGuesses.append(character)
        var newTitle = ""
        var underscoreCount = 0
        var first = true
        for letter in word {
            if(!first) {
                newTitle += " "
            }
            first = false
            if correctGuesses.contains(String(letter)) {
                newTitle += String(letter)
            } else {
                newTitle += "_"
                underscoreCount += 1
            }
        }
        currentTitle = newTitle
        if underscoreCount == 0 {
            ResultLabel.text = "You Win :)"
            ResultLabel.isHidden = false
        }
    }
    
    func incorrectGuess(character: String) {
        incorrectGuesses.append(character)
        if level + 1 < hangmanStates.count {
            level += 1
        }
        if level == hangmanStates.count - 1 {
            ResultLabel.text = "You Lose :("
            ResultLabel.isHidden = false
            title = word
        }
    }
    
    //Objc Functions
    @objc func startGame() {
        level = 0
        ResultLabel.isHidden = true
        incorrectGuesses.removeAll(keepingCapacity: true)
        word = allWords.shuffled()[0].lowercased()
    }
    
    //IBAction Functions
    @IBAction func SubmitButtonPressed(_ sender: Any) {
        GuessTextField.resignFirstResponder()
        guard let string = GuessTextField.text else { return }
        guard let character = string.first?.lowercased() else { return }
        
        if correctGuesses.contains(String(character)) ||
            incorrectGuesses.contains(String(character)) {
            GuessTextField.text = ""
            return
        }
        
        if word.contains(character) {
            correctGuess(character: character)
        } else {
            incorrectGuess(character: character)
        }
        
        GuessTextField.text = ""
    }
}
