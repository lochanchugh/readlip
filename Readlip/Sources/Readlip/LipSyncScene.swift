//
//  LipSyncScene.swift
//  lipsync
//
//  Created by Lochan on 19/02/25.
//
//
//  LipSyncScene.swift
//  lipsync
//
//  Created by Lochan on 19/02/25.
//
import SwiftUI
import SpriteKit

class LipSyncScene: SKScene {
    private var mouthNode: SKSpriteNode!
    
    let visemeMap: [Character: (viseme: String, duration: TimeInterval)] = [
        "A": ("WideOpen", 0.15),
        "E": ("Open", 0.12),
        "I": ("Open", 0.12),
        "O": ("Rounded", 0.15),
        "U": ("Pucker", 0.15),
        "M": ("Closed", 0.08),
        "B": ("Closed", 0.06),
        "P": ("Closed", 0.06),
        "L": ("LTongue", 0.1),
        "F": ("TeethOnLip", 0.12),
        "V": ("TeethOnLip", 0.12),
        "S": ("Clenched", 0.1),
        "T": ("Clenched", 0.08),
        "R": ("Rounded", 0.12),
        "W": ("Pucker", 0.12),
        "Y": ("Open", 0.12),
        "H": ("Idle", 0.08),
        "N": ("Closed", 0.08)
    ]
    
    override func didMove(to view: SKView) {
        backgroundColor = .clear
        mouthNode = SKSpriteNode(imageNamed: "Idle")
        mouthNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(mouthNode)
    }
    
    func animateLipSync(for word: String, durationMultiplier: TimeInterval = 1.0) {
        guard let mouthNode = mouthNode else {
            print("⚠️ mouthNode is nil")
            return
        }
        
        let sequence = SKAction.sequence(createAnimationSequence(for: word.uppercased(), using: visemeMap, durationMultiplier: durationMultiplier))
        
        mouthNode.removeAllActions()
        mouthNode.run(sequence)
    }
    
    private func createAnimationSequence(for word: String, using visemeMap: [Character: (viseme: String, duration: TimeInterval)], durationMultiplier: TimeInterval) -> [SKAction] {
        var actions: [SKAction] = []
        var previousViseme = "Idle"
        
        for char in word {
            guard let visemeInfo = visemeMap[char] else { continue }
            
            if visemeInfo.viseme == previousViseme { continue }
            
            actions.append(SKAction.setTexture(SKTexture(imageNamed: visemeInfo.viseme)))
            actions.append(SKAction.wait(forDuration: visemeInfo.duration * durationMultiplier))
            
            actions.append(SKAction.setTexture(SKTexture(imageNamed: "Idle")))
            actions.append(SKAction.wait(forDuration: 0.04 * durationMultiplier))
            
            previousViseme = visemeInfo.viseme
        }
        
        return actions
    }
    
    func showViseme(named name: String, duration: TimeInterval) {
        mouthNode.texture = SKTexture(imageNamed: name)
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.mouthNode.texture = SKTexture(imageNamed: "Idle")
        }
    }
}
