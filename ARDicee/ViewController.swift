//
//  ViewController.swift
//  ARDicee
//
//  Created by TRUNG NGUYEN on 1/14/19.
//  Copyright © 2019 TRUNG NGUYEN. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    
    var diceArray = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Set the view's delegate
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        sceneView.showsStatistics = true
        
        // Create a new scene

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        // Create a session configuration
        
        print("World Tracking is supproted = \(ARWorldTrackingConfiguration.isSupported)")

        if !ARWorldTrackingConfiguration.isSupported{
            print("The World Tracking is not supported on the device.")
            }
        else {

            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
            
            // Run the view's session
            sceneView.session.run(configuration)
        }

 
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    //MARK: - Dice Rendering Methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if !results.isEmpty {
                print("touch the plane")
            }else {
                print("touch somewhere else")
            }
            
            if let hitResult = results.first{
                print(hitResult)
                
                addDice(atLocation: hitResult)

            }
            
        }
    }
    
    func addDice(atLocation location: ARHitTestResult){
        //TODO: Spawn a dice on the plane
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
            
            diceNode.position = SCNVector3(
                x: location.worldTransform.columns.3.x,
                y: location.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                z: location.worldTransform.columns.3.z)
            
            diceArray.append(diceNode)
            
            sceneView.scene.rootNode.addChildNode(diceNode)
            
            roll(diceNode)
            
        }
    }
    
    func roll(_ diceNode : SCNNode){
        let randomX = Float(arc4random_uniform(4) + 1) * Float.pi/2
        let randomZ = Float(arc4random_uniform(4) + 1) * Float.pi/2
    
        diceNode.runAction(
            SCNAction.rotateBy(
            x: CGFloat(randomX * 5),
            y: 0,
            z: CGFloat(randomZ * 5),
            duration: 0.5)
        )
    }
    
    func rollAll(){
        if !diceArray.isEmpty{
            for dice in diceArray{
                roll(dice)
            }
        }
    }
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        if !diceArray.isEmpty{
            for dice in diceArray{
                dice.removeFromParentNode()
            }
        }
    }
    
    // motionEnded: the events happen after the motion ends e.g. shaking
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    
    //MARK: - ARSCNViewDelegateMethods
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {

        
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        
        let planeNode = createPlane(with: planeAnchor)

        node.addChildNode(planeNode)
    }

    
    //MARK: - Plane Rendering Methods
    
    func createPlane(with planeAnchor: ARPlaneAnchor) -> SCNNode {
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let planeNode = SCNNode()
        planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
        
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        
        plane.materials = [gridMaterial]
        
        planeNode.geometry = plane
        
        return planeNode

    }
    
}

