//
//  ViewController.swift
//  MilestoneChallenge10
//
//  Created by Ian McDonald on 22/03/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import UIKit

struct GameOptions {
    static let emoji = ["😀","🤪","😎","🤩","🤬","🥶","😱","🤯","😷","😴","🤗","🤥","🤔"]
    static let people = ["👩‍🦽","💇‍♀️","🙎‍♂️","🤷‍♂️","🙆","🧏‍♀️","🙅","🤱","🙇‍♂️","💆","🧖‍♀️","👨‍🦼","👨‍🦯"]
    static let clothes = ["🧥","🥼","🦺","👚","👕","👖","🩳","👔","👗","👠","👞","🥾","🧤"]
    static let animals = ["🐶","🐱","🐭","🐰","🦊","🐻","🐨","🐯","🦁","🐮","🐵","🦆","🦄"]
    static let moons = ["🌝","🌛","🌜","🌚","🌘","🌗","🌖","🌕","🌑","🌒","🌓","🌔","🌙"]
    static let fruit = ["🍏","🍐","🍊","🍋","🍌","🍉","🍇","🍓","🥥","🍒","🍑","🍍","🥝"]
    static let drinks = ["🍾","🧉","🍹","🥂","🍷","🥃","🍸","🍻","🍶","🥤","☕️","🧃","🥛"]
    static let sports = ["⚽️","🏀","🏈","⚾️","🎾","🏐","🥏","🎱","🪀","🏓","🏒","🏏","⛳️"]
    static let hobbies = ["🩰","🎨","🎬","🎼","🎲","🎳","🎮","🎰","🧩","🎯","🎪","🛹","🤹"]
    static let transport = ["🚗","🚕","🚙","🚌","🚎","🏎","🚓","🚑","🚒","🚐","🚚","🚛","🚜"]
    static let technology = ["⌚️","📱","💻","🖥","🖨","🖱","💿","📷","📺","🎙","⏱","🔦","🛢"]
    static let flags = ["🏳️‍🌈","🇧🇪","🇧🇷","🇨🇦","🇨🇮","🇪🇨","🇪🇺","🇮🇪","🇰🇪","🇲🇽","🇰🇷","🇿🇦","🇺🇸"]
    
    static let choices = [emoji, people, clothes, animals, moons, fruit, drinks, sports, hobbies,
                          transport, technology, flags]
    
}

class ViewController: UIViewController {

    @IBOutlet var cardButtons: [UIButton]!
    var cards = [Card]()
    var moves = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startGame()
    }
    
    private func startGame() {
        moves = 0
        guard var options = GameOptions.choices.randomElement() else { fatalError() }
        for _ in 0 ..< (cardButtons.count / 2 ) {
            options.shuffle()
            let value = options.remove(at: 0)
            cards.append(Card(value: value))
            cards.append(Card(value: value))
        }
        cards.shuffle()
    }
    
    private func checkCards() {
        var faceUpCard: Card? = nil
        for card in cards {
            if card.isFaceUp {
                if faceUpCard == nil {
                    faceUpCard = card
                } else {
                    setCardEnableStatus(to: false)
                    if faceUpCard?.value == card.value {
                        guard let faceUpCard = faceUpCard else { return }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                            self?.hideCard(faceUpCard)
                            self?.hideCard(card)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                            self?.setCardEnableStatus(to: true)
                        }
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) { [weak self] in
                            self?.turnDownAllCards()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) { [weak self] in
                            self?.setCardEnableStatus(to: true)
                        }
                    }
                }
            }
        }
    }
    
    private func setCardEnableStatus(to value: Bool) {
        for card in cardButtons {
            card.isEnabled = value
        }
    }
    
    private func turnDownAllCards() {
        for index in 0 ..< cardButtons.count {
            let cardSelected = cards[index]
            if cardSelected.isFaceUp {
                cardSelected.isFaceUp = false
                turnDownCard(cardButtons[index])
            }
        }
    }
    
    private func turnDownCard(_ card: UIButton) {
        UIView.transition(with: card, duration: 1,
                          options: [.transitionFlipFromLeft, .allowAnimatedContent],
                          animations: {
                            card.setTitle(nil, for: .normal)
                            card.backgroundColor = UIColor.systemGray
        })
    }
    
    private func hideCard(_ card: Card) {
        guard let cardIndex = cards.firstIndex(where: { $0.id == card.id}) else { return }
        card.isHidden = true
        card.isFaceUp = false
        let button = cardButtons[cardIndex]
        
        UIView.animate(withDuration: 1, animations: {
            button.transform = CGAffineTransform(rotationAngle: .pi)
            button.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
            button.setTitle(nil, for: .normal)
        }) { [weak self] _ in
            guard let self = self else { return }
            var count = 0
            for card in self.cards {
                if !card.isHidden {
                    count += 1
                }
            }
            if count == 0 {
                let ac = UIAlertController(title: "Congratulations, You Won",
                                           message: "You completed the challenge in \(self.moves) moves",
                                           preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Play Again", style: .default, handler: { _ in
                    self.restartGame()
                }))
                self.present(ac, animated: true)
            }
        }
    }
    
    private func showAllCards() {
        for card in cardButtons {
            UIView.animate(withDuration: 1, animations: {
                card.transform = .identity
                card.backgroundColor = UIColor.systemGray
                card.setTitle(nil, for: .normal)
            })
        }
    }
    
    private func restartGame() {
        showAllCards()
        cards.removeAll(keepingCapacity: true)
        startGame()
    }

    @IBAction func cardTapped(_ sender: UIButton) {
        guard let index = cardButtons.firstIndex(of: sender) else { return }
        
        let cardSelected = cards[index]
        if cardSelected.isFaceUp {
            UIView.transition(with: sender, duration: 1,
                              options: [.transitionFlipFromLeft, .allowAnimatedContent],
                              animations: {
                                sender.setTitle(nil, for: .normal)
                                sender.backgroundColor = UIColor.systemGray
                                cardSelected.isFaceUp = false
            })
        } else {
            if !cardSelected.isHidden {
                cardSelected.isFaceUp = true
                UIView.transition(with: sender, duration: 1,
                                  options: [.transitionFlipFromRight, .allowAnimatedContent],
                                  animations: { [weak self] in
                                    sender.setTitle(cardSelected.value, for: .normal)
                                    sender.setTitleColor(UIColor.systemPurple, for: .normal)
                                    sender.backgroundColor = UIColor.systemTeal
                                    self?.checkCards()
                                    
                })
                moves += 1
            }
            
        }
    }
    
}

