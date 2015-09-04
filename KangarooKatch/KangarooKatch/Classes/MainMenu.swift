//
//  MainMenu.swift
//  KangarooKatch
//
//  Created by ADAM HYATT on 7/19/15.
//  Copyright (c) 2015 ADAM HYATT. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenu: SKScene {
    let classicRect: CGRect
    let endlessRect: CGRect
    let multiRect: CGRect
    let settingsRect: CGRect
    
    let classicButton = SKSpriteNode(imageNamed: "ButtonImage")
    let endlessButton = SKSpriteNode(imageNamed: "ButtonImage")
    let multiplayerButton = SKSpriteNode(imageNamed: "ButtonImage")
    let settingsButton = SKSpriteNode(imageNamed: "ButtonImage")
    let classicY: CGFloat = 760
    let endlessY: CGFloat = 580
    let multiY: CGFloat = 400
    let settingsY: CGFloat = 220
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.whiteColor()
        let background = SKSpriteNode(imageNamed: "MainMenu")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = -1
        addChild(background)
        
        println("height: \(size.height)")
        
        classicButton.position = CGPoint(x: size.width/2, y: classicY)
        endlessButton.position = CGPoint(x: size.width/2, y: endlessY)
        multiplayerButton.position = CGPoint(x: size.width/2, y: multiY)
        settingsButton.position = CGPoint(x: size.width/2, y: settingsY)
        
        let stretch = SKAction.scaleYTo(1.6, duration: 0.0)
        
        let classicLabel: [SKLabelNode] = createShadowLabel(font: "Soup of Justice", text: "CLASSIC MODE",
            fontSize: 50,
            horAlignMode: .Center, vertAlignMode: .Baseline,
            labelColor: SKColor.blackColor(), shadowColor: SKColor.whiteColor(),
            name: "classicLabel",
            positon: CGPoint(x: size.width/2, y: classicY-15),
            shadowZPos: 2, shadowOffset: 2)
        classicLabel[0].runAction(stretch)
        classicLabel[1].runAction(stretch)
        
        let endlessLabel: [SKLabelNode] = createShadowLabel(font: "Soup of Justice", text: "ENDLESS MODE",
            fontSize: 50,
            horAlignMode: .Center, vertAlignMode: .Baseline,
            labelColor: SKColor.blackColor(), shadowColor: SKColor.whiteColor(),
            name: "endlessLabel",
            positon: CGPoint(x: size.width/2, y: endlessY-15),
            shadowZPos: 2, shadowOffset: 2)
        endlessLabel[0].runAction(stretch)
        endlessLabel[1].runAction(stretch)
        
        let multiplayerLabel: [SKLabelNode] = createShadowLabel(font: "Soup of Justice", text: "MULTIPLAYER MODE",
            fontSize: 50,
            horAlignMode: .Center, vertAlignMode: .Baseline,
            labelColor: SKColor.blackColor(), shadowColor: SKColor.whiteColor(),
            name: "multiplayerLabel",
            positon: CGPoint(x: size.width/2, y: multiY-15),
            shadowZPos: 2, shadowOffset: 2)
        multiplayerLabel[0].runAction(stretch)
        multiplayerLabel[1].runAction(stretch)
        
        let settingsLabel: [SKLabelNode] = createShadowLabel(font: "Soup of Justice", text: "SETTINGS",
            fontSize: 50,
            horAlignMode: .Center, vertAlignMode: .Baseline,
            labelColor: SKColor.blackColor(), shadowColor: SKColor.whiteColor(),
            name: "settingsLabel",
            positon: CGPoint(x: size.width/2, y: settingsY-15),
            shadowZPos: 2, shadowOffset: 2)
        settingsLabel[0].runAction(stretch)
        settingsLabel[1].runAction(stretch)
        
        addChild(classicButton)
        addChild(endlessButton)
        addChild(multiplayerButton)
        addChild(settingsButton)
        
        addChild(classicLabel[0])
        addChild(classicLabel[1])
        addChild(endlessLabel[0])
        addChild(endlessLabel[1])
        addChild(multiplayerLabel[0])
        addChild(multiplayerLabel[1])
        addChild(settingsLabel[0])
        addChild(settingsLabel[1])
        
        //debugDrawPlayableArea()
    }
    
    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0/9.0
        let playableWidth = size.height / maxAspectRatio
        let playableMargin = (size.width-playableWidth)/2.0
        
        classicRect = CGRect(x: size.width/2 - classicButton.size.width/2,
            y: classicY - classicButton.size.height/2,
            width: classicButton.size.width,
            height: classicButton.size.height)
        endlessRect = CGRect(x: size.width/2 - classicButton.size.width/2,
            y: endlessY - classicButton.size.height/2,
            width: classicButton.size.width,
            height: classicButton.size.height)
        multiRect = CGRect(x: size.width/2 - classicButton.size.width/2,
            y: multiY - classicButton.size.height/2,
            width: classicButton.size.width,
            height: classicButton.size.height)
        settingsRect = CGRect(x: size.width/2 - classicButton.size.width/2,
            y: settingsY - classicButton.size.height/2,
            width: classicButton.size.width,
            height: classicButton.size.height)
        
        super.init(size: size)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func sceneTouched(touchLocation:CGPoint) {
        var shade: SKShapeNode!
        var buttonTouched: Bool = false
        if(classicRect.contains(touchLocation)) {
            shade = drawRectangle(classicRect, SKColor.grayColor(), 1.0)
            buttonTouched = true
        }
        else if(endlessRect.contains(touchLocation)) {
            shade = drawRectangle(endlessRect, SKColor.grayColor(), 1.0)
            buttonTouched = true
        }
        else if(multiRect.contains(touchLocation)) {
            shade = drawRectangle(multiRect, SKColor.grayColor(), 1.0)
            buttonTouched = true
        }
        else if(settingsRect.contains(touchLocation)) {
            shade = drawRectangle(settingsRect, SKColor.grayColor(), 1.0)
            buttonTouched = true
        }
        
        if buttonTouched {
            shade.fillColor = SKColor.grayColor()
            shade.alpha = 0.4
            shade.name = "buttonDown"
            shade.zPosition = 4
            addChild(shade)
            buttonTouched = false
        }
        
    }
    
    func sceneUntouched(touchLocation:CGPoint) {
        let shade = childNodeWithName("buttonDown")
        if (shade != nil) {
            shade!.removeFromParent()
            
            var myScene: SKScene!
            if(classicRect.contains(touchLocation)) {
                myScene = ClassicGameScene(size: self.size, difficulty: 3, joeys: 100, controls: gameControls)
                myScene.scaleMode = self.scaleMode
                let reveal = SKTransition.flipHorizontalWithDuration(0.5)
                self.view?.presentScene(myScene, transition: reveal)
            }
            else if(endlessRect.contains(touchLocation)) {
                if gameControls == .Thumb { println("One Hand") }
                if gameControls == .TwoThumbs { println("Two Hands") }
               
                myScene = GameScene(size: self.size, controls: gameControls)
                myScene.scaleMode = self.scaleMode
                let reveal = SKTransition.flipHorizontalWithDuration(0.5)
                self.view?.presentScene(myScene, transition: reveal)
            }
            else if(multiRect.contains(touchLocation)) {
                //multiplayer scene (?) good luck...
            }
            else if(settingsRect.contains(touchLocation)) {
                myScene = Settings(size: self.size)
                myScene.scaleMode = self.scaleMode
                let reveal = SKTransition.flipHorizontalWithDuration(0.5)
                self.view?.presentScene(myScene, transition: reveal)
            }
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let touchLocation = touch.locationInNode(self)
        sceneTouched(touchLocation)
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let touchLocation = touch.locationInNode(self)
        sceneUntouched(touchLocation)
    }
    
    func debugDrawPlayableArea() {
        let cShape = drawRectangle(classicRect, SKColor.redColor(), 4.0)
        addChild(cShape)
        
        let eShape = drawRectangle(endlessRect, SKColor.redColor(), 4.0)
        addChild(eShape)
        
        let mShape = drawRectangle(multiRect, SKColor.redColor(), 4.0)
        addChild(mShape)
        
        let sShape = drawRectangle(settingsRect, SKColor.redColor(), 4.0)
        addChild(sShape)
  
    }
    
    
}