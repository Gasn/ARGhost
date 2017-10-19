//
//  ViewController.swift
//  ARGhost
//
//  Created by Sang Luu on 9/25/17.
//  Copyright © 2017 Sang Luu. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit

class ViewController: UIViewController, ARSKViewDelegate {
    
    @IBOutlet var sceneView: ARSKView!
    
    var scene: Scene?
    
    var nodeDict = [
        0: "🎃",
        1: "👻",
        2: "👹",
        3: "👽",
        4: "🤖",
        5: "👁",
        6: "👾",
        7: "☠️",
        8: "💀"
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and node count
        sceneView.showsFPS = true
        sceneView.showsNodeCount = true
        
        scene = Scene(size: sceneView.bounds.size)
        scene?.scaleMode = .resizeFill
        sceneView.presentScene(scene)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // MARK: - ARSKViewDelegate
    
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        // Create and configure a node for the anchor added to the view's session.
        if ((scene?.anchorDict[anchor.identifier.uuidString]) != nil) {
            let key = Int(arc4random_uniform(9))
            let labelNode = SKLabelNode(text: nodeDict[key])
            labelNode.name = anchor.identifier.uuidString
            labelNode.horizontalAlignmentMode = .center
            labelNode.verticalAlignmentMode = .center
            return labelNode;
        } else{
            let labelNode = SKLabelNode(text: "🌟")
            labelNode.name = "bullet"
            labelNode.horizontalAlignmentMode = .center
            labelNode.verticalAlignmentMode = .center
            return labelNode;
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
