//
//  GameScene.swift
//  FlappyRedone
//
//  Created by Ethan Hess on 1/4/16.
//  Copyright (c) 2016 Ethan Hess. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //properties
    
    var score = 0
    var scoreLabel = SKLabelNode()
    var gameOverLabel = SKLabelNode()
    var bird = SKSpriteNode()
    var backgroundNode = SKSpriteNode()
//    var pipeOne = SKSpriteNode()
//    var pipeTwo = SKSpriteNode()
    var movingObjects = SKSpriteNode()
    var labelContainer = SKSpriteNode()
    
    enum ColliderType: UInt32 {
        
        case Bird = 1
        case Object = 2
        case Gap = 4
    }
    
    var gameOver = false
    
    //equivalent of view did load method
    
    override func didMoveToView(view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        self.addChild(labelContainer)
        self.addChild(movingObjects)
        
        makeBackground()
        
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 70)
        self.addChild(scoreLabel)
        
        //adds nodes
        
        let birdTextureOne = SKTexture(imageNamed: "flappy1.png")
        let birdTextureTwo = SKTexture(imageNamed: "flappy2.png")
        
        let animation = SKAction.animateWithTextures([birdTextureOne, birdTextureTwo], timePerFrame: 0.1)
        let makeBirdFlap = SKAction.repeatActionForever(animation)
        
        bird = SKSpriteNode(texture: birdTextureTwo)
        bird.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        bird.runAction(makeBirdFlap)
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTextureOne.size().height / 2)
        bird.physicsBody?.dynamic = true
        bird.physicsBody?.allowsRotation = false
        
        bird.physicsBody?.categoryBitMask = ColliderType.Bird.rawValue
        bird.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
        bird.physicsBody?.collisionBitMask = ColliderType.Object.rawValue
        
        self.addChild(bird)
        
        //ground
        
        let ground = SKNode()
        ground.position = CGPointMake(0, 0)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, 1))
        ground.physicsBody!.dynamic = false

        ground.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        
        self.addChild(ground)
        
        _ = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("makePipes"), userInfo: nil, repeats: true)
        
    }
    
    func makeBackground() {
        
        let backgroundTexture = SKTexture(imageNamed: "bg.png")
        
        let moveBackground = SKAction.moveByX(-backgroundTexture.size().width, y: 0, duration: 9)
        let replaceBackground = SKAction.moveByX(backgroundTexture.size().width, y: 0, duration: 0)
        let moveBackgroundForever = SKAction.repeatActionForever(SKAction.sequence([moveBackground, replaceBackground]))
        
        for var i : CGFloat = 0; i < 3; i++ {
            
            backgroundNode = SKSpriteNode(texture: backgroundTexture)
            backgroundNode.position = CGPoint(x: backgroundTexture.size().width/2 + backgroundTexture.size().width * i, y: CGRectGetMidY(self.frame))
            backgroundNode.size.height = self.frame.height
            backgroundNode.zPosition = -5
            backgroundNode.runAction(moveBackgroundForever)
            movingObjects.addChild(backgroundNode)
        }
        
    }
    
    func makePipes() {
        
        let gapHeight = bird.size.height * 4
        
        let movementAmout = arc4random() % UInt32(self.frame.size.height / 2)
        let pipeOffset = CGFloat(movementAmout) - self.frame.size.height / 4
        
        let movePipes = SKAction.moveByX(-self.frame.size.width * 2, y: 0, duration: NSTimeInterval(self.frame.size.width / 100))
        let removePipes = SKAction.removeFromParent()
        let moveAndRemovePipes = SKAction.sequence([movePipes, removePipes])
        
        //make pipes
        
        let pipeTexture = SKTexture(imageNamed: "pipe1.png")
        let pipeOne = SKSpriteNode(texture: pipeTexture)
        pipeOne.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) + pipeTexture.size().height / 2 + gapHeight / 2 + pipeOffset)
        pipeOne.runAction(moveAndRemovePipes)
        pipeOne.physicsBody = SKPhysicsBody(rectangleOfSize: pipeTexture.size())
        pipeOne.physicsBody?.dynamic = false
        
        //bit masks
        
        pipeOne.physicsBody?.categoryBitMask = ColliderType.Object.rawValue
        pipeOne.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
        pipeOne.physicsBody?.collisionBitMask = ColliderType.Object.rawValue
        
        movingObjects.addChild(pipeOne)
        
        let pipeTwoTexture = SKTexture(imageNamed: "pipe2.png")
        let pipeTwo = SKSpriteNode(texture: pipeTwoTexture)
        pipeTwo.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) - pipeTwoTexture.size().height/2 - gapHeight / 2 + pipeOffset)
        pipeTwo.runAction(moveAndRemovePipes)
        
        pipeTwo.physicsBody = SKPhysicsBody(rectangleOfSize: pipeTexture.size())
        pipeTwo.physicsBody!.dynamic = false
        
        pipeTwo.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        pipeTwo.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        pipeTwo.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        
        movingObjects.addChild(pipeTwo)
        
        //adds gap
        
        let gap = SKNode()
        gap.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) + pipeOffset)
        gap.runAction(moveAndRemovePipes)
        gap.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(pipeOne.size.width, gapHeight))
        gap.physicsBody!.dynamic = false
        
        gap.physicsBody!.categoryBitMask = ColliderType.Gap.rawValue
        gap.physicsBody!.contactTestBitMask = ColliderType.Bird.rawValue
        gap.physicsBody!.collisionBitMask = ColliderType.Gap.rawValue
        
        movingObjects.addChild(gap)
    }
    
    //delegate method
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        if contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue {
            
            score++
            scoreLabel.text = String(score)
        }
        
        else {
            
            if gameOver == false {
                
                gameOver = true
                self.speed = 0
                
                gameOverLabel.fontName = "Helvetica"
                gameOverLabel.fontSize = 30
                gameOverLabel.text = "Game Over! Tap to play again."
                gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
                labelContainer.addChild(gameOverLabel)
            }
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        if gameOver == false {
            
            bird.physicsBody?.velocity = CGVectorMake(0, 0)
            bird.physicsBody?.applyImpulse(CGVectorMake(0, 50))
        }
        
        else {
            
            score = 0
            scoreLabel.text = "0"
            
            bird.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
            bird.physicsBody!.velocity = CGVectorMake(0, 0)
            
            movingObjects.removeAllChildren()
            makeBackground()
            
            self.speed = 1
            
            gameOver = false
            labelContainer.removeAllChildren()
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
