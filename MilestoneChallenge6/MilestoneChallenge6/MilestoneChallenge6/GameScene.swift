//
//  GameScene.swift
//  MilestoneChallenge6
//
//  Created by Masipack Eletronica on 09/03/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var bulletsSprite1: SKSpriteNode!
    var bulletsSprite2: SKSpriteNode!
    var bulletTextures = [
        SKTexture(imageNamed: "shots0"),
        SKTexture(imageNamed: "shots1"),
        SKTexture(imageNamed: "shots2"),
        SKTexture(imageNamed: "shots3")
    ]
    
    var bulletsInClip = 6 {
        didSet {
            if bulletsInClip > 3 {
                bulletsSprite1.texture = bulletTextures[3]
                bulletsSprite2.texture = bulletTextures[bulletsInClip-3]
            } else {
                bulletsSprite1.texture = bulletTextures[bulletsInClip]
                bulletsSprite2.texture = bulletTextures[0]
            }
        }
    }
    var gameScore: SKLabelNode!
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    
    var targetSpeed = 4.0
    var targetDelay = 0.8
    var targetsCreated = 0
    
    override func didMove(to view: SKView) {
        // Set Up
        addBackground()
        addWater()
        addStage()
        
        // Start
        nextLevel()
        
    }
    
    func addBackground() {
        let background = SKSpriteNode(imageNamed: "wood-background")
        background.position = CGPoint(x: 400, y: 300)
        background.blendMode = .replace
        addChild(background)
        
        let grass = SKSpriteNode(imageNamed: "grass-trees")
        grass.position = CGPoint(x: 400, y: 300)
        addChild(grass)
        grass.zPosition = 100
    }
    
    func addWater() {
        func animate(_ node: SKNode, distance: CGFloat, duration: TimeInterval) {
            let movimentUp = SKAction.moveBy(x: 0, y: distance, duration: duration)
            let movimentDown = movimentUp.reversed()
            let sequence = SKAction.sequence([movimentUp, movimentDown])
            let repeatForever = SKAction.repeatForever(sequence)
            node.run(repeatForever)
        }
        
        let waterBackground = SKSpriteNode(imageNamed: "water-bg")
        waterBackground.position = CGPoint(x: 400, y: 180)
        waterBackground.zPosition = 200
        addChild(waterBackground)
        
        let waterForeground = SKSpriteNode(imageNamed: "water-fg")
        waterForeground.position = CGPoint(x: 400, y: 120)
        waterForeground.zPosition = 300
        addChild(waterForeground)
        
        animate(waterBackground, distance: 8, duration: 1.3)
        animate(waterForeground, distance: 12, duration: 1)
    }
    
    func addStage() {
        let curtains = SKSpriteNode(imageNamed: "curtains")
        curtains.position = CGPoint(x: 400, y: 300)
        curtains.zPosition = 400
        addChild(curtains)
        
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.horizontalAlignmentMode = .right
        gameScore.position = CGPoint(x: 680, y: 50)
        gameScore.zPosition = 500
        addChild(gameScore)
        score = 0
        
        bulletsSprite1 = SKSpriteNode(imageNamed: "shots3")
        bulletsSprite1.position = CGPoint(x: 110, y: 60)
        bulletsSprite1.zPosition = 500
        bulletsSprite1.name = "reload"
        addChild(bulletsSprite1)
        
        bulletsSprite2 = SKSpriteNode(imageNamed: "shots3")
        bulletsSprite2.position = CGPoint(x: 190, y: 60)
        bulletsSprite2.zPosition = 500
        bulletsSprite2.name = "reload"
        addChild(bulletsSprite2)
    }
    
    func nextLevel() {
        targetSpeed *= 0.99
        targetDelay *= 0.99
        targetsCreated += 1
        
        if targetsCreated < 100 {
            DispatchQueue.main.asyncAfter(deadline: .now() + targetDelay) { [weak self] in
                self?.addTarget()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.endGame()
            }
        }
    }
    
    func addTarget() {
        let target = Target()
        target.setup()

        let level = Int.random(in: 0...2)
        var movingRight = true

        switch level {
        case 0:
            // in front of the grass
            target.zPosition = 150
            target.position.y = 280
            target.setScale(0.7)
        case 1:
            // in front of the water background
            target.zPosition = 250
            target.position.y = 190
            target.setScale(0.85)
            movingRight = false
        default:
            // in front of the water foreground
            target.zPosition = 350
            target.position.y = 100
        }

        let move: SKAction

        if movingRight {
            target.position.x = 0
            move = SKAction.moveTo(x: 800, duration: targetSpeed)
        } else {
            target.position.x = 800
            target.xScale = -target.xScale
            move = SKAction.moveTo(x: 0, duration: targetSpeed)
        }

        let sequence = SKAction.sequence([move, SKAction.removeFromParent()])
        target.run(sequence)
        addChild(target)

        nextLevel()
    }
    
    func endGame() {
        let gameOverTitle = SKSpriteNode(imageNamed: "game-over")
        gameOverTitle.alpha = 0
        gameOverTitle.position = CGPoint(x: 400, y: 300)
        gameOverTitle.zPosition = 900
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        gameOverTitle.run(fadeIn)
        
        addChild(gameOverTitle)
    }
    
    func shot(at location: CGPoint) {
        let hitNodes = nodes(at: location).filter { $0.name == "target" }
        
        guard let hitNode = hitNodes.first else { return }
        guard let parentNode = hitNode.parent as? Target else { return }
        
        parentNode.hit()
        
        score += 3
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        for node in tappedNodes {
            if node.name == "reload" {
                run(SKAction.playSoundFileNamed("reload.wav", waitForCompletion: false))
                bulletsInClip = 6
                score -= 1
            } else {
                if node == tappedNodes.first {
                    if bulletsInClip > 0 {
                        run(SKAction.playSoundFileNamed("shot.wav", waitForCompletion: false))
                        bulletsInClip -= 1

                        shot(at: location)
                    } else {
                        run(SKAction.playSoundFileNamed("empty.wav", waitForCompletion: false))
                    }
                }
            }
            
        }
    }
    
}
