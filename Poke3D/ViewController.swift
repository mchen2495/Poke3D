//
//  ViewController.swift
//  Poke3D
//
//  Created by Michael Chen on 1/18/21.
//

import UIKit
import SceneKit
import ARKit

/*
 If we had actual cards to add, take pictures of them filling up as much of frame as
 possible than edit them in preview for image to show more clearly. Then add them
 to AR resoruce group folder. In this case, since we are using proxy card we just copy
 and pasted them in to the AR resource group folder
 */

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        
        sceneView.autoenablesDefaultLighting = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        //CHANGED FROM ARWorldTrackingConfiguration
        let configuration = ARImageTrackingConfiguration()
        
        //get the images to track from the folder in xc asset folder
        if let imageToTrack = ARReferenceImage.referenceImages(inGroupNamed: "Pokemon Cards", bundle: Bundle.main) {
        
            configuration.trackingImages = imageToTrack
            
            //allows us to track location and motion of two images
            configuration.maximumNumberOfTrackedImages = 2
            print("Images Successfully Added")
        }
        

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    //when image get detected this tells it what to render
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        print("card detected!!!")
        
        let node = SCNNode()
        
        //if the anchor that was detected was of type ARImageAnchor type
        if let imageAnchor = anchor as? ARImageAnchor {
            
            //create new plane that is the same size as the card
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            
            plane.firstMaterial?.diffuse.contents = UIColor(white: 1.0, alpha: 0.6)
            
            //plane that we render just on top of our card so we know it was detected
            let planeNode = SCNNode(geometry: plane)
            
            /*currently plane is render vertical on the detected card (xz plane), perpendicular/putting
              up from the card. We want to make it flat with the card. We need to rotate
              it 90 degrees counterclockwise (in radians)
             */
            planeNode.eulerAngles.x = -Float.pi/2
            
            node.addChildNode(planeNode)
            
            //name of card in pokemon folder, determines which pokemon to render base on off card detected
            if let pokemon = imageAnchor.referenceImage.name {
                
                if let pokeScene = SCNScene(named: "art.scnassets/\(pokemon).scn"){
                    
                    print("Pokemon scene")
                    
                    if let pokeNode = pokeScene.rootNode.childNodes.first{
                        
                        print(pokeNode)
                        
                        
                        pokeNode.eulerAngles.x = Float.pi/2
                        planeNode.addChildNode(pokeNode)
                    }
                }
                
            }
            
        }
        
        
        return node
        
    }
    

}
