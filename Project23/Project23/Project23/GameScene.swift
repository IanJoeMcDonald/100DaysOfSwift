//
//  GameScene.swift
//  Project23
//
//  Created by Masipack Eletronica on 12/03/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

enum SequenceType: CaseIterable {
    case oneNoBomb, one, twoWithOneBomb, two, three, four, chain, fastChain
}

enum ForceBomb {
    case never, always, random
}

struct EnemyValues {
    static let minXPosition = 64
    static let maxXPosition = 960
    static let yPosition = -128
    
    static let minAngularVelocity: CGFloat = -3
    static let maxAngularVelocity: CGFloat = 3
    
    static let minLowXVelocity = 3
    static let maxLowXVelocity = 5
    static let minHighXVelocity = 8
    static let maxHighXVelocity = 15
    
    static let minYVelocity = 24
    static let maxYVelocity = 32
    
    static let velocityScaler = 40
    static let fastVelocityScaler = 60
    
    static let firstQuarterDivider: CGFloat = 256
    static let middleDivider: CGFloat = 512
    static let threeQuarterDivider: CGFloat = 768
    
    static let physicsBodySize: CGFloat = 64
}

class GameScene: SKScene {
    
    var gameScore: SKLabelNode!
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    
    var livesImages = [SKSpriteNode]()
    var lives = 3
    
    var activeSliceBG: SKShapeNode!
    var activeSliceFG: SKShapeNode!
    var activeSlicePoints = [CGPoint]()
    
    var isSwooshSoundActive = false
    var bombSoundEffect: AVAudioPlayer?
    
    var activeEnemies = [SKSpriteNode]()
    
    var popupTime = 0.9
    var sequence = [SequenceType]()
    var sequencePosition = 0
    var chainDelay = 3.0
    var nextSequenceQueued = true
    
    var isGameEnded = false
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "sliceBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -6)
        physicsWorld.speed = 0.85
        
        createScore()
        createLives()
        createSlices()
        
        sequence = [.oneNoBomb, .oneNoBomb, .twoWithOneBomb, .twoWithOneBomb, .three, .one, .chain]
        for _ in 0 ... 1000 {
            if let nextSequence = SequenceType.allCases.randomElement() {
                sequence.append(nextSequence)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() +  2) { [weak self] in
            self?.tossEnemies()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        // 1
        activeSlicePoints.removeAll(keepingCapacity: true)
        
        // 2
        let location = touch.location(in: self)
        activeSlicePoints.append(location)
        
        // 3
        redrawActiveSlice()
        
        // 4
        activeSliceBG.removeAllActions()
        activeSliceFG.removeAllActions()
        
        // 5
        activeSliceBG.alpha = 1
        activeSliceFG.alpha = 1
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameEnded {
            return
        }
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        activeSlicePoints.append(location)
        redrawActiveSlice()
        if !isSwooshSoundActive {
            playSwooshSound()
        }
        
        let nodesAtPoint = nodes(at: location)
        
        for case let node as SKSpriteNode in nodesAtPoint {
            if node.name == "enemy" || node.name == "fastEnemy" {
                // 1
                if let emitter = SKEmitterNode(fileNamed: "sliceHitEnemy") {
                    emitter.position = node.position
                    addChild(emitter)
                }
                
                // 2
                if node.name == "fastEnemy" {
                    score += 2
                }
                node.name = ""
                
                // 3
                node.physicsBody?.isDynamic = false
                
                // 4
                let scaleOut = SKAction.scale(by: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut])
                
                // 5
                let seq = SKAction.sequence([group, .removeFromParent()])
                node.run(seq)
                
                // 6
                score += 1
                
                // 7
                if let index = activeEnemies.firstIndex(of: node) {
                    activeEnemies.remove(at: index)
                }
                
                // 8
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
            } else if node.name == "bomb" {
                guard let bombContainer = node.parent as? SKSpriteNode else { continue }
                
                if let emitter = SKEmitterNode(fileNamed: "sliceHitBomb") {
                    emitter.position = bombContainer.position
                    addChild(emitter)
                }
                
                node.name = ""
                bombContainer.physicsBody?.isDynamic = false
                
                let scaleOut = SKAction.scale(by: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut])
                
                let seq = SKAction.sequence([group, .removeFromParent()])
                bombContainer.run(seq)
                
                if let index = activeEnemies.firstIndex(of: bombContainer) {
                    activeEnemies.remove(at: index)
                }
                
                run(SKAction.playSoundFileNamed("explosion.caf", waitForCompletion: false))
                endGame(triggeredByBomb: true)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeSliceBG.run(SKAction.fadeOut(withDuration: 0.25))
        activeSliceFG.run(SKAction.fadeOut(withDuration: 0.25))
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        var bombCount = 0
        
        for node in activeEnemies {
            if node.name == "bombContainer" {
                bombCount += 1
                break
            }
        }
        
        if bombCount == 0 {
            // no bombs - stop the fuse sound!
            bombSoundEffect?.stop()
            bombSoundEffect = nil
        }
        
        if activeEnemies.count > 0 {
            for(index, node) in activeEnemies.enumerated().reversed() {
                if node.position.y < -140 {
                    node.removeAllActions()
                    
                    if node.name == "enemy" {
                        node.name = ""
                        subtractLife()
                        
                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                    } else if node.name == "bombContainer" {
                        node.name = ""
                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                    } else if node.name == "fastEnemy" {
                        node.name = ""
                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                    }
                }
            }
        } else {
            if !nextSequenceQueued {
                DispatchQueue.main.asyncAfter(deadline: .now() + popupTime) { [weak self] in
                    self?.tossEnemies()
                }
                
                nextSequenceQueued = true
            }
        }
    }
    
    func createScore() {
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)
        
        gameScore.position = CGPoint(x: 8, y: 8)
        score = 0
    }
    
    func createLives() {
        for i in 0 ..< 3 {
            let spriteNode = SKSpriteNode(imageNamed: "sliceLife")
            spriteNode.position = CGPoint(x: CGFloat(834 + (i * 70)), y: 720)
            addChild(spriteNode)
            
            livesImages.append(spriteNode)
        }
    }
    
    func createSlices() {
        activeSliceBG = SKShapeNode()
        activeSliceBG.zPosition = 2
        
        activeSliceFG = SKShapeNode()
        activeSliceFG.zPosition = 3
        
        activeSliceBG.strokeColor = UIColor(red: 1, green: 0.9, blue: 0, alpha: 1)
        activeSliceBG.lineWidth = 9
        
        activeSliceFG.strokeColor = UIColor.white
        activeSliceFG.lineWidth = 5
        
        addChild(activeSliceBG)
        addChild(activeSliceFG)
    }
    
    func redrawActiveSlice() {
        // 1
        if activeSlicePoints.count < 2 {
            activeSliceBG.path = nil
            activeSliceFG.path = nil
            return
        }
        
        // 2
        if activeSlicePoints.count > 12 {
            activeSlicePoints.removeFirst(activeSlicePoints.count - 12)
        }
        
        // 3
        let path = UIBezierPath()
        path.move(to: activeSlicePoints[0])
        
        for i in 1 ..< activeSlicePoints.count {
            path.addLine(to: activeSlicePoints[i])
        }
        
        // 4
        activeSliceBG.path = path.cgPath
        activeSliceFG.path = path.cgPath
    }
    
    func playSwooshSound() {
        isSwooshSoundActive = true
        
        let randomNumber = Int.random(in: 1...3)
        let soundName = "swoosh\(randomNumber).caf"
        
        let swooshSound = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        
        run(swooshSound) { [weak self] in
            self?.isSwooshSoundActive = false
        }
    }
    
    func createEnemy(forceBomb: ForceBomb = .random) {
        let enemy: SKSpriteNode
        
        var enemyType = Int.random(in: 0...6)
        
        if forceBomb == .never {
            enemyType = 1
        } else if forceBomb == .always {
            enemyType = 0
        }
        
        if enemyType == 0 {
            // 1
            enemy = SKSpriteNode()
            enemy.zPosition = 1
            enemy.name = "bombContainer"
            
            // 2
            let bombImage = SKSpriteNode(imageNamed: "sliceBomb")
            bombImage.name = "bomb"
            enemy.addChild(bombImage)
            
            // 3
            if bombSoundEffect != nil {
                bombSoundEffect?.stop()
                bombSoundEffect = nil
            }
            
            // 4
            if let path = Bundle.main.url(forResource: "sliceBombFuse", withExtension: "caf") {
                if let sound = try? AVAudioPlayer(contentsOf: path) {
                    bombSoundEffect = sound
                    sound.play()
                }
            }
            
            // 5
            if let emitter = SKEmitterNode(fileNamed: "sliceFuse") {
                emitter.position = CGPoint(x: 76, y: 64)
                enemy.addChild(emitter)
            }
        } else if enemyType == 6 {
            enemy = SKSpriteNode(imageNamed: "ball")
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
            enemy.name = "fastEnemy"
        }else {
            enemy = SKSpriteNode(imageNamed: "penguin")
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
            enemy.name = "enemy"
        }
        
        // 1
        let randomPosition = CGPoint(x:
            Int.random(in: EnemyValues.minXPosition...EnemyValues.maxXPosition),
                                     y: EnemyValues.yPosition)
        enemy.position = randomPosition
        
        // 2
        let randomAngularVelocity = CGFloat.random(in: EnemyValues.minAngularVelocity ...
            EnemyValues.maxAngularVelocity)
        let randomXVelocity: Int
        
        // 3
        if randomPosition.x < EnemyValues.firstQuarterDivider {
            randomXVelocity = Int.random(in: EnemyValues.minHighXVelocity ...
                EnemyValues.maxHighXVelocity)
        } else  if randomPosition.x < EnemyValues.middleDivider {
            randomXVelocity = Int.random(in: EnemyValues.minLowXVelocity ...
            EnemyValues.maxLowXVelocity)
        } else if randomPosition.x < EnemyValues.threeQuarterDivider {
            randomXVelocity = -Int.random(in: EnemyValues.minLowXVelocity ...
            EnemyValues.maxLowXVelocity)
        } else   {
            randomXVelocity = -Int.random(in: EnemyValues.minHighXVelocity ...
            EnemyValues.maxHighXVelocity)
        }
        
        // 4
        let randomYVelocity = Int.random(in: EnemyValues.minYVelocity...EnemyValues.maxYVelocity)
        
        // 5
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: EnemyValues.physicsBodySize)
        if enemy.name == "fastEnemy" {
            enemy.physicsBody?.velocity = CGVector(dx: randomXVelocity *
                EnemyValues.fastVelocityScaler, dy: randomYVelocity *
                    EnemyValues.fastVelocityScaler)
        } else {
            enemy.physicsBody?.velocity = CGVector(dx: randomXVelocity * EnemyValues.velocityScaler,
            dy: randomYVelocity * EnemyValues.velocityScaler)
        }
        
        enemy.physicsBody?.angularVelocity = randomAngularVelocity
        enemy.physicsBody?.collisionBitMask = 0
        
        
        addChild(enemy)
        activeEnemies.append(enemy)
    }
    
    func tossEnemies() {
        if isGameEnded {
            return
        }
        
        popupTime *= 0.991
        chainDelay += 0.99
        physicsWorld.speed *= 1.02
        
        let sequenceType = sequence[sequencePosition]
        
        switch sequenceType {
        case .oneNoBomb:
            createEnemy(forceBomb: .never)
            
        case .one:
            createEnemy()
            
        case .twoWithOneBomb:
            createEnemy(forceBomb: .never)
            createEnemy(forceBomb: .always)
            
        case .two:
            createEnemy()
            createEnemy()
            
        case .three:
            createEnemy()
            createEnemy()
            createEnemy()
            
        case .four:
            createEnemy()
            createEnemy()
            createEnemy()
            createEnemy()
            
        case .chain:
            createEnemy()
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0)) { [weak self] in
                self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 2)) {
                [weak self] in self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0) * 3) {
                [weak self] in self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0) * 4) {
                [weak self] in self?.createEnemy()
            }
            
        case .fastChain:
            createEnemy()
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0)) { [weak self] in
                self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 2)) {
                [weak self] in self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0) * 3) {
                [weak self] in self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0) * 4) {
                [weak self] in self?.createEnemy()
            }
        }
        
        sequencePosition += 1
        nextSequenceQueued = false
    }
    
    func subtractLife() {
        lives -= 1
        
        run(SKAction.playSoundFileNamed("wrong.caf", waitForCompletion: false))
        
        var life: SKSpriteNode
        
        if lives == 2 {
            life = livesImages[0]
        } else if lives == 1 {
            life = livesImages[1]
        } else {
            life = livesImages[2]
            endGame(triggeredByBomb: false)
        }
        
        life.texture = SKTexture(imageNamed: "sliceLifeGone")
        
        life.xScale = 1.3
        life.yScale = 1.3
        life.run(SKAction.scale(by: 1, duration: 0.1))
    }
    
    func endGame(triggeredByBomb: Bool) {
        if isGameEnded {
            return
        }
        
        isGameEnded = true
        physicsWorld.speed = 0
        isUserInteractionEnabled = false
        
        bombSoundEffect?.stop()
        bombSoundEffect = nil
        
        if triggeredByBomb {
            livesImages[0].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImages[1].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImages[2].texture = SKTexture(imageNamed: "sliceLifeGone")
        }
    }
}
