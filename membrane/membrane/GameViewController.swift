//
//  GameViewController.swift
//  membrane
//
//  Created by Yongyang Nie on 10/8/17.
//  Copyright © 2017 Yongyang Nie. All rights reserved.
//

import SceneKit
import QuartzCore

class GameViewController: NSViewController {
    
    func createNADH(position: SCNVector3) -> SCNNode {
        let nadGeo = SCNSphere.init(radius: 5)
        let hGeo = SCNSphere.init(radius: 2)
        let nad = SCNNode.init(geometry: nadGeo)
        let h = SCNNode.init(geometry: hGeo)
        nad.position = position
        nad.addChildNode(h)
        h.position = SCNVector3Make(-2, 2, -2)
        return nad
    }
    
    func membraneAnimation() -> SCNAction {
        let x = CGFloat(arc4random_uniform(3))
        let y = CGFloat(arc4random_uniform(3))
        let z = CGFloat(arc4random_uniform(3))
        let up = SCNAction.move(by: SCNVector3Make(-x, -y, z), duration: 0.2)
        let down = SCNAction.move(by: SCNVector3Make(+x, y, -z), duration: 0.2)
        let sequence = SCNAction.repeatForever(SCNAction.sequence([up, down]))
        return sequence
    }
    
    func buildMembrane(layers: Int, width: Int, rootNode: SCNNode){
        
        let lipid = rootNode.childNode(withName: "membrane", recursively: true)!
        let (min, max) = lipid.boundingBox
        let w = (max.x - min.x)
        let l = (max.y - min.y)
        lipid.runAction(membraneAnimation())
        for x in 0...layers {
            for i in 0...width {
                let phlipid = lipid.clone()
                phlipid.position = SCNVector3Make(phlipid.position.x + w * CGFloat(x), phlipid.position.y, phlipid.position.z + CGFloat(i) * l)
                phlipid.runAction(membraneAnimation())
                rootNode.addChildNode(phlipid)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene(named: "tinker.scn")!
        
        buildMembrane(layers: 2, width: 3, rootNode: scene.rootNode)
        
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        scnView.autoenablesDefaultLighting = true
        
        // configure the view
        scnView.backgroundColor = NSColor.lightGray
        
        // Add a click gesture recognizer
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick(_:)))
        var gestureRecognizers = scnView.gestureRecognizers
        gestureRecognizers.insert(clickGesture, at: 0)
        scnView.gestureRecognizers = gestureRecognizers
    }
    
    @objc
    func handleClick(_ gestureRecognizer: NSGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are clicked
        let p = gestureRecognizer.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = NSColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = NSColor.red
            
            SCNTransaction.commit()
        }
    }
}
