//
//  GameViewController.swift
//  Proton_Pump
//
//  Created by Yongyang Nie on 10/5/17.
//  Copyright © 2017 Yongyang Nie. All rights reserved.
//

import SceneKit
import QuartzCore

class GameViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        // var scene = SCNScene(named: "art.scnassets/ship.scn")!
        let scene = SCNScene.init(named: "simulation.scn")!
        // create and add a camera to the scene
        
        // retrieve the ship node
        let lipid = scene.rootNode.childNode(withName: "phlipid", recursively: true)!
        lipid.scale = SCNVector3Make(0.3, 0.3, 0.3)
        let (min, max) = lipid.boundingBox
        let width = (max.x - min.x) / 3.0
        let layers = 3
        
        let protein = scene.rootNode.childNode(withName: "protein", recursively: true)!
        protein.position = SCNVector3Make(-30, -30, width * 15.0 / 2.0)
        
        let hp = scene.rootNode.childNode(withName: "hp", recursively: true)!
        hp.position = SCNVector3Make(0, 0, width * 15.0 / 2.0)
        
        let gfp = scene.rootNode.childNode(withName: "gfp", recursively: true)!
        gfp.position = SCNVector3Make(-100, 0, 0)

        for x in -2...layers {
            for i in 0...10 {
                let phlipid = lipid.clone()
                phlipid.position = SCNVector3Make(phlipid.position.x + CGFloat(20 * x), phlipid.position.y, phlipid.position.z + CGFloat(i) * width)
                phlipid.scale = SCNVector3Make(0.3, 0.3, 0.3)
                let x = CGFloat(arc4random_uniform(8))
                let y = CGFloat(arc4random_uniform(8))
                let z = CGFloat(arc4random_uniform(8))
                let up = SCNAction.move(by: SCNVector3Make(-x, -y, z), duration: 0.5)
                let down = SCNAction.move(by: SCNVector3Make(+x, y, -z), duration: 0.5)
                let sequence = SCNAction.repeatForever(SCNAction.sequence([up, down]))
                phlipid.runAction(sequence)
                scene.rootNode.addChildNode(phlipid)
            }
            for i in 0...10 {
                let phlipid = lipid.clone()
                phlipid.position = SCNVector3Make(phlipid.position.x + CGFloat(20 * x), phlipid.position.y - 100, phlipid.position.z + CGFloat(i) * width)
                phlipid.scale = SCNVector3Make(0.3, 0.3, 0.3)
                phlipid.eulerAngles = SCNVector3Make(0, 0, CGFloat(Double.pi))
                let x = CGFloat(arc4random_uniform(8))
                let y = CGFloat(arc4random_uniform(8))
                let z = CGFloat(arc4random_uniform(8))
                let up = SCNAction.move(by: SCNVector3Make(-x, -y, z), duration: 0.5)
                let down = SCNAction.move(by: SCNVector3Make(+x, y, -z), duration: 0.5)
                let sequence = SCNAction.repeatForever(SCNAction.sequence([up, down]))
                phlipid.runAction(sequence)
                scene.rootNode.addChildNode(phlipid)
            }
        }
        
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        scnView.autoenablesDefaultLighting = true
        // configure the view
        scnView.backgroundColor = NSColor.black
        
    }

}
