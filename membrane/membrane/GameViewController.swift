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
    
    @IBOutlet weak var sceneView: SCNView!
    
    // MARK: Actions
    
    
    @IBAction func nadhTohad(_ sender: Any) {
        
        let protein = sceneView.scene?.rootNode.childNode(withName: "protein", recursively: true)!
        for i in 0..<1 {
            let nadh = sceneView.scene?.rootNode.childNode(withName: "nadh-\(i)", recursively: true)!
            nadh?.removeAllActions()
            nadh?.runAction(SCNAction.move(by: subtract(vector1: (protein?.position)!, vector2: (nadh?.position)!), duration: 3), completionHandler: {
                nadh?.removeFromParentNode()
                
                let hGeo = SCNSphere.init(radius: 2)
                let h = SCNNode.init(geometry: hGeo)
                h.position = (protein?.position)!
                h.geometry?.firstMaterial?.diffuse.contents = NSColor.blue
                h.runAction(SCNAction.move(by: self.subtract(vector1: (h.position),
                                                             vector2: SCNVector3Make(h.position.x, h.position.y - 60, h.position.z)),
                                           duration: 1))
                self.sceneView.scene?.rootNode.addChildNode(h)
            })
        }
    }
    
    // MARK: SceneKit
    
    func createNADH(position: SCNVector3, name: String) -> SCNNode {
        let nadGeo = SCNSphere.init(radius: 5)
        let hGeo = SCNSphere.init(radius: 2)
        let nad = SCNNode.init(geometry: nadGeo)
        nad.geometry?.firstMaterial?.diffuse.contents = NSColor.darkGray
        let h = SCNNode.init(geometry: hGeo)
        h.geometry?.firstMaterial?.diffuse.contents = NSColor.blue
        nad.position = position
        nad.addChildNode(h)
        h.position = SCNVector3Make(-3, 3, -3)
        nad.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 1, z: 0, duration: 1)))
        nad.runAction(molecularAnimation())
        nad.name = name
        return nad
    }
    
    func molecularAnimation() -> SCNAction {
        let x = CGFloat(arc4random_uniform(10))
        let y = CGFloat(arc4random_uniform(10))
        let z = CGFloat(arc4random_uniform(10))
        let up = SCNAction.move(by: SCNVector3Make(-x, -y, z), duration: 0.6)
        let down = SCNAction.move(by: SCNVector3Make(+x, y, -z), duration: 0.6)
        let sequence = SCNAction.repeatForever(SCNAction.sequence([up, down]))
        return sequence
    }
    
    func membraneAnimation() -> SCNAction {
        let x = CGFloat(arc4random_uniform(2))
        let y = CGFloat(arc4random_uniform(2))
        let z = CGFloat(arc4random_uniform(2))
        let up = SCNAction.move(by: SCNVector3Make(-x, -y, z), duration: 0.2)
        let down = SCNAction.move(by: SCNVector3Make(+x, y, -z), duration: 0.2)
        let sequence = SCNAction.repeatForever(SCNAction.sequence([up, down]))
        return sequence
    }
    
    func buildMembrane(layers: Int, width: Int, rootNode: SCNNode){
        
        let lipid = rootNode.childNode(withName: "membrane", recursively: true)!
        let (min, max) = lipid.boundingBox
        let w = (max.x - min.x)
        let l = (max.y - min.y) - 4
        lipid.runAction(membraneAnimation())
        for x in 0...layers {
            for i in 0...width {
                let phlipid = lipid.clone()
                if i % 2 == 0 {
                    phlipid.eulerAngles = SCNVector3Make(CGFloat(Double.pi / 2), 0, CGFloat(Double.pi))
                    phlipid.position = SCNVector3Make(phlipid.position.x + w * CGFloat(x), phlipid.position.y - (l / 2.0 + 9.0), phlipid.position.z + CGFloat(i) * l)
                }else{
                    phlipid.position = SCNVector3Make(phlipid.position.x + w * CGFloat(x), phlipid.position.y, phlipid.position.z + CGFloat(i) * l)
                }
                phlipid.name = "memebrane_copy"
                phlipid.runAction(membraneAnimation())
                rootNode.addChildNode(phlipid)
            }
        }
        lipid.isHidden = true
    }
    
    func buildProteins(rootNode: SCNNode){
        
        let protein = rootNode.childNode(withName: "protein", recursively: true)!
        protein.scale = SCNVector3Make(1.2, 1.2, 1.2)
        protein.position = SCNVector3Make(25, -55, 20)
    }
    
    // MARK: Helpers
    
    func randomIntFrom(start: Int, to end: Int) -> Int {
        var a = start
        var b = end
        // swap to prevent negative integer crashes
        if a > b {
            swap(&a, &b)
        }
        return Int(arc4random_uniform(UInt32(b - a + 1))) + a
    }
    
    func subtract(vector1: SCNVector3, vector2: SCNVector3) -> SCNVector3{
        return SCNVector3Make(vector1.x - vector2.x, vector1.y - vector2.y, vector1.z - vector2.z)
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene(named: "tinker.scn")!
        
        buildMembrane(layers: 1, width: 1, rootNode: scene.rootNode)
        buildProteins(rootNode: scene.rootNode)
        for i in 0...10 {
            scene.rootNode.addChildNode(createNADH(position: SCNVector3Make(CGFloat(randomIntFrom(start: -50, to: 60)),
                                                                            CGFloat(randomIntFrom(start: -80, to: -130)),
                                                                            CGFloat(randomIntFrom(start: -50, to: 100))), name: "nadh-\(i)"))
        }
        
        // set the scene to the view
        self.sceneView.scene = scene
        
        // allows the user to manipulate the camera
        self.sceneView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        self.sceneView.showsStatistics = true
        
        self.sceneView.autoenablesDefaultLighting = true
        
        // configure the view
        self.sceneView.backgroundColor = NSColor.lightGray
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
