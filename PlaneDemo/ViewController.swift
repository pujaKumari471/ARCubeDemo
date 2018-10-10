//
//  ViewController.swift
//  PlaneDemo
//
//  Created by Puja Kumari on 07/09/18.
//  Copyright © 2018 Puja Kumari. All rights reserved.
//

import UIKit
import ARKit


class ViewController: UIViewController,UIGestureRecognizerDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var increaseButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
   
    var object: SCNNode = SCNNode()
    var currentAngleY: Float = 0.0
    var currentAngleX: Float = 0.0
    var flag:Bool = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.removeButton.isHidden = true
        self.removeButton.isEnabled = false
        self.startButton.isHidden = true
        self.startButton.isEnabled = false
        self.infoLabel.isHidden = false
        addTapGestureToSceneView()
        addPinchGestureToSceneView()
        addPanGestureToSceneView()
        configureLighting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpSceneView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func setUpSceneView() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        sceneView.session.run(configuration)
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        
    }
   
    
    
    
    
    @objc func addCubeToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
        switch recognizer.state {
        case .began:
        print("Object began to move")
        let hitResults = self.sceneView.hitTest(tapLocation, options: nil)
        if hitResults.isEmpty { return }
        let hitResult = hitResults.first
        if let node = hitResult?.node.parent?.parent?.parent {
            self.object = node
            }
        case .changed:
            print("Moving object position changed")
            
        case .ended:
            print("Done moving object")
            let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
            guard let hitTestResult = hitTestResults.first else { return }
            let translation = hitTestResult.worldTransform.translation
            let x = translation.x
            let y = translation.y
            let z = translation.z
            let cube:SCNNode = addCube()
            cube.position = SCNVector3(x,y,z)
            sceneView.scene.rootNode.addChildNode(cube)
        default:
            break
        }
     
    }
    
    
    func addCube() -> SCNNode {
        let colors = [UIColor.green, // front
            UIColor.red, // right
            UIColor.blue, // back
            UIColor.yellow, // left
            UIColor.purple, // top
            UIColor.black] // bottom
        
        let sideMaterials = colors.map { color -> SCNMaterial in
            let material = SCNMaterial()
            material.diffuse.contents = color
            material.locksAmbientWithDiffuse = true
            return material
        }
        
        
        let sceneObject = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.015)
        sceneObject.materials = sideMaterials
        
        
        // add object to the geometry of node ,node has properties like geometry,position etc.
        object.geometry =  sceneObject
        return object
    }
    
    
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.addCubeToSceneView(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    func addPinchGestureToSceneView() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(didPinch(_:)))
        sceneView.addGestureRecognizer(pinchGesture)
    }
    
    
    @objc func didPinch(_ gesture: UIPinchGestureRecognizer) {
        var originalScale = object.scale
        
        switch gesture.state {
        case .began:
            originalScale = object.scale
            gesture.scale = CGFloat((object.scale.x))
        case .changed:
            var newScale = originalScale
            if gesture.scale < 0.5{ newScale = SCNVector3(x: 0.5, y: 0.5, z: 0.5) }else if gesture.scale > 2{
                newScale = SCNVector3(2, 2, 2)
            }else{
                newScale = SCNVector3(gesture.scale, gesture.scale, gesture.scale)
            }
            object.scale = newScale
        case .ended:
            var newScale = originalScale
            if gesture.scale < 0.5{ newScale = SCNVector3(x: 0.5, y: 0.5, z: 0.5) }else if gesture.scale > 2{
                newScale = SCNVector3(2, 2, 2)
            }else{
                newScale = SCNVector3(gesture.scale, gesture.scale, gesture.scale)
            }
            object.scale = newScale
            gesture.scale = CGFloat((object.scale.x))
        default:
            gesture.scale = 1.0
            
        }
    }
    func addPanGestureToSceneView() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        panGesture.delegate = self
        sceneView.addGestureRecognizer(panGesture)
    }
    
    //Remove Cube
    @IBAction func removeButtonClicked(_ sender: Any) {
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
        self.resetTracking()
        self.flag = false
    }
    @IBAction func startButtonClicked(_ sender: Any) {
        
    }
    
    @IBAction func increaseButtonClicked(_ sender: Any) {let action = SCNAction.rotateBy(x: 0, y: CGFloat(2 * Double.pi), z: 0, duration: 10)
        let repAction = SCNAction.repeatForever(action)
        object.runAction(repAction, forKey: "rotate")
        
    }
    
    @IBAction func closeButtonClicked(_ sender: Any) {
       object.removeAction(forKey: "rotate")
    }
    
    
}



extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

extension UIColor {
    open class var transparentLightBlue: UIColor {
        return UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 0.50)
    }
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        DispatchQueue.main.async {
            self.infoLabel.text = "Surface Detected."
        }
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        
        if self.flag == false  {
            let cube:SCNNode = addCube()
            cube.position = SCNVector3(x,y,z)
            cube.eulerAngles.x = -.pi / 2
            node.addChildNode(cube)
            DispatchQueue.main.async {
                self.infoLabel.text = "Cube Added Successfully"
            }
            self.flag = true
        }
        
        DispatchQueue.main.async {
            self.removeButton.isHidden = false
            self.removeButton.isEnabled = true
            self.infoLabel.text = "Tap to resposition the cube"
        }
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
      
        
    }
    
    
    func sessionWasInterrupted(_ session: ARSession) {
        infoLabel.text = "Session was interrupted"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        infoLabel.text = "Session interruption ended"
        resetTracking()
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        infoLabel.text = "Session failed: \(error.localizedDescription)"
        resetTracking()
    }
    
    func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        // help us inform the user when the app is ready
        switch camera.trackingState {
        case .normal :
            infoLabel.text = "Move the device to detect surfaces."
            
        case .notAvailable:
            infoLabel.text = "Tracking not available."
            
        case .limited(.excessiveMotion):
            infoLabel.text = "Tracking limited - Move the device more slowly."
            
        case .limited(.insufficientFeatures):
            infoLabel.text = "Point the device with visible surface detail."
            
        case .limited(.initializing):
            infoLabel.text = "Initializing AR session."
            
        default:
            infoLabel.text = ""
        }
    }
    
}

extension ViewController : ARSessionDelegate {
    
    @objc func didPan(_ gesture: UIPanGestureRecognizer) {
        
        let translation = gesture.translation(in: gesture.view)
        var newAngleY = (Float)(translation.x)*(Float)(Double.pi)/180.0
        var newAngleX = (Float)(translation.y)*(Float)(Double.pi)/180.0
        
        newAngleY += currentAngleY
        newAngleX += currentAngleX
        object.eulerAngles.y = newAngleY
        object.eulerAngles.x = newAngleX
        
        if gesture.state == .ended{
            currentAngleY = newAngleY
            currentAngleX = newAngleX
        }
    }
}
