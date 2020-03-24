//
//  GameController.swift
//  MilestoneChallenge10
//
//  Created by Ian McDonald on 24/03/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import Foundation

struct GameOptions {
    static let flags = ["A"]
    static let sports = ["B"]
    static let fruit = [""]
    static let clothes = [""]
    static let animals = [""]
    static let transport = [""]
    static let technology = [""]
    
    static let options = [flags, sports, fruit, clothes, animals, transport, technology]
}

class GameController {
    
    var cards = [Card]()
    var moves = 0
    var viewController: ViewController?
    
    func startGame(numberOfCards: Int) {
        guard var options = GameOptions.options.randomElement() else { fatalError() }
        for _ in 0 ..< numberOfCards / 2 {
            options.shuffle()
            let value = options.remove(at: 0)
            cards.append(contentsOf: [Card(value: value), Card(value: value)])
        }
        //cards.shuffle()
    }
    
    func checkCards() {
        var faceUpCard: Card? = nil
        for card in cards {
            if card.isFaceUp {
                if faceUpCard == nil {
                    faceUpCard = card
                } else {
                    viewController?.setCardEnableStatus(to: false)
                    if faceUpCard?.value == card.value {
                        guard let faceUpCard = faceUpCard else { return }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                            self?.viewController?.hideCard(faceUpCard)
                            self?.viewController?.hideCard(card)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                            self?.viewController?.setCardEnableStatus(to: true)
                        }
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) { [weak self] in
                            self?.viewController?.turnDownAllCards()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) { [weak self] in
                            self?.viewController?.setCardEnableStatus(to: true)
                        }
                    }
                }
            }
        }
    }
}
