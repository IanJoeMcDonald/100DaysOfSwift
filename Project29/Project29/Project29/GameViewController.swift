//
//  GameViewController.swift
//  Project29
//
//  Created by Masipack Eletronica on 17/03/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var angleSlider: UISlider!
    @IBOutlet weak var angleLabel: UILabel!
    @IBOutlet weak var velocitySlider: UISlider!
    @IBOutlet weak var velocityLabel: UILabel!
    @IBOutlet weak var launchButton: UIButton!
    @IBOutlet weak var playerNumber: UILabel!
    @IBOutlet weak var player1ScoreLabel: UILabel!
    @IBOutlet weak var player2ScoreLabel: UILabel!
    
    var currentGame: GameScene!
    var isGameOver = false
    var player1Score = 0 {
        didSet {
            player1ScoreLabel.text = "Player 1 Score: \(player1Score)"
            if player1Score >= 3 {
                isGameOver = true
                gameOver(winner: 1)
            }
        }
    }
    var player2Score = 0 {
        didSet {
            player2ScoreLabel.text = "Player 2 Score: \(player2Score)"
            if player2Score >= 3 {
                isGameOver = true
                gameOver(winner: 2)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        angleChanged(angleSlider)
        velocityChanged(velocitySlider)
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
                currentGame = scene as? GameScene
                currentGame.viewController = self
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func activatePlayer(number: Int) {
        if !isGameOver {
            if number == 1 {
                playerNumber.text = "<<< PLAYER ONE"
            } else {
                playerNumber.text = "PLAYER TWO >>>"
            }
            
            angleSlider.isHidden = false
            angleLabel.isHidden = false
            
            velocitySlider.isHidden = false
            velocityLabel.isHidden = false
            
            launchButton.isHidden = false
        }
    }
    
    func gameOver(winner: Int) {
        if winner == 1 {
            playerNumber.text = "<<< PLAYER 1 WINS"
        } else {
            playerNumber.text = "PLAYER 2 WINS >>>"
        }
        
        angleSlider.isHidden = true
        angleLabel.isHidden = true
        
        velocitySlider.isHidden = true
        velocityLabel.isHidden = true
        
        launchButton.isHidden = true
    }
    
    @IBAction func angleChanged(_ sender: UISlider) {
        angleLabel.text = "Angle: \(Int(angleSlider.value))º"
    }
    
    @IBAction func velocityChanged(_ sender: UISlider) {
        velocityLabel.text = "Velocity: \(Int(velocitySlider.value))"
    }
    
    @IBAction func launch(_ sender: UIButton) {
        angleSlider.isHidden = true
        angleLabel.isHidden = true
        
        velocitySlider.isHidden = true
        velocityLabel.isHidden = true
        
        launchButton.isHidden = true
        
        currentGame.launch(angle: Int(angleSlider.value), velocity: Int(velocitySlider.value))
    }
}
