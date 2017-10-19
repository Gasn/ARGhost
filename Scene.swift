//
//  Scene.swift
//  ARGhost
//
//  Created by Sang Luu on 9/25/17.
//  Copyright © 2017 Sang Luu. All rights reserved.
//

import SpriteKit
import ARKit

class Scene: SKScene {
    
    let ghostsLabel = SKLabelNode(text: "Ghosts")
    let numberOfGhostsLabel = SKLabelNode(text: "0")
    var creationTime : TimeInterval = 0
    var ghostCount = 0 {
        didSet{
            self.numberOfGhostsLabel.text = "\(ghostCount)"
        }
    }
    
    var anchorDict = [String: ARAnchor]()
    
    var weapSound: SKAction {
        return SKAction.playSoundFileNamed("weap.wav", waitForCompletion: false)
    }
    
    var popSound: SKAction {
        return SKAction.playSoundFileNamed("pop.mp3", waitForCompletion: false)
    }
    
    var explosionSound: SKAction {
        return SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
    }
    
    override func didMove(to view: SKView) {
        ghostsLabel.fontSize = 20
        ghostsLabel.fontName = "DevanagariSangamMN-Bold"
        ghostsLabel.color = .white
        ghostsLabel.position = CGPoint(x: 40, y: 50)
        addChild(ghostsLabel)
        
        numberOfGhostsLabel.fontSize = 30
        numberOfGhostsLabel.fontName = "DevanagariSangamMN-Bold"
        numberOfGhostsLabel.color = .white
        numberOfGhostsLabel.position = CGPoint(x: 40, y: 10)
        addChild(numberOfGhostsLabel)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if currentTime > creationTime {
            createGhostAnchor(time: currentTime)
            creationTime = currentTime + TimeInterval(randomFloat(min: 3.0, max: 5.0))
        }
    }
    
    func createGhostAnchor(time: TimeInterval){
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        let _360degrees = 2.0 * Float.pi
        let rotateX = simd_float4x4(SCNMatrix4MakeRotation(_360degrees * randomFloat(min: 0.0, max: 1.0), 1, 0, 0))
        let rotateY = simd_float4x4(SCNMatrix4MakeRotation(_360degrees * randomFloat(min: 0.0, max: 1.0), 0, 1, 0))
        let rotation = simd_mul(rotateX, rotateY)
        var translation = matrix_identity_float4x4
        translation.columns.3.z = randomFloat(min: -1.5, max: -0.5)
        let transform = simd_mul(rotation, translation)
        let anchor = ARAnchor(transform: transform)
        anchorDict[anchor.identifier.uuidString] = anchor
        sceneView.session.add(anchor: anchor)
        ghostCount += 1
    }
    
    func randomFloat(min: Float, max: Float) -> Float {
        return (Float(arc4random()) / 0xFFFFFFFF) * (max - min) + min
    }
    
    func shoot (target: ARAnchor){
        
        //Create the bulltet sprite
        let bullet = SKSpriteNode()
        bullet.color = UIColor.green
        bullet.size = CGSize(width: 5, height: 20)
        bullet.position = CGPoint(x: frame.width/2, y: 0)
        target.parent?.addChild(bullet)
        
//        determine vector to target
        let vector = CGVector(dx: target.position.x - frame.width/2, dy: target.position.y)
        
//        create the action to move the bullet
        let bulletAction = SKAction.sequence([SKAction.repeat(SKAction.move(by: vector, duration: 0.1), count: 10) ,  SKAction.wait(forDuration: 1), SKAction.removeFromParent()])
        bullet.run(bulletAction)
        
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)
        let hit = nodes(at: location)
        if let node = hit.first {
            guard let name = node.name else {return}
            if anchorDict[name] != nil{
                guard let anchor = anchorDict[node.name!] else {return}
                
                shoot(target: anchor)
                let explosion = SKAction.wait(forDuration: 0.5)
                let fadeOut = SKAction.fadeOut(withDuration: 0.1)
                
                let groupKillingActions = SKAction.group([fadeOut, explosion, explosionSound])
                
                let remove = SKAction.removeFromParent()
                let sequenceAction = SKAction.sequence([groupKillingActions, remove])
                
                node.run(sequenceAction)
                guard let emitterNode = SKEmitterNode(fileNamed: "ExplosionParticle.sks") else {return;}
                emitterNode.particlePosition = location
                self.addChild(emitterNode)
                ghostCount -= 1
                anchorDict.removeValue(forKey: node.name!)
            }
        }
    }
}










