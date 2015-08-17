//
//  MainMenu.swift
//  KangarooKatch
//
//  Created by ADAM HYATT on 7/19/15.
//  Copyright (c) 2015 ADAM HYATT. All rights reserved.
//

import Foundation
import SpriteKit

class Settings: SKScene {
    let thumbButtonRect: CGRect
    let twoThumbsButtonRect: CGRect
    let backButtonRect: CGRect
    
    let thumbButton = SKSpriteNode(imageNamed: "ButtonImage")
    let twoThumbsButton = SKSpriteNode(imageNamed: "ButtonImage")
    let backButton = SKSpriteNode(imageNamed: "ButtonImage")
    
    let settingsTitleY: CGFloat = 890
    let controlLabelY: CGFloat = 770
    let controlButtonY: CGFloat = 450
    let controlMessageY: CGFloat = 380
    let controlPicY: CGFloat = 620
    
    let thumbImage = SKSpriteNode(imageNamed: "OneThumb")
    let twoThumbsImage = SKSpriteNode(imageNamed: "TwoThumbs")
    
    let oneThirdX: CGFloat
    let twoThirdX: CGFloat
    let backButtonX: CGFloat = 190
    let backButtonY: CGFloat = 970
    
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.whiteColor()
        let background = SKSpriteNode(imageNamed: "ImageBoundary")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = -1
        addChild(background)
        
        let settingsLabel: [SKLabelNode] = createShadowLabel(font: "Soup of Justice", text: "SETTINGS",
            fontSize: 70,
            horAlignMode: .Center, vertAlignMode: .Baseline,
            labelColor: SKColor.blackColor(), shadowColor: SKColor.whiteColor(),
            name: "settingsLabel",
            positon: CGPoint(x: size.width/2, y: settingsTitleY),
            shadowZPos: 2, shadowOffset: 3)
        addChild(settingsLabel[0])
        addChild(settingsLabel[1])
        
        let controlSettingLabel: [SKLabelNode] = createShadowLabel(font: "Soup of Justice", text: "Controls:",
            fontSize: 50,
            horAlignMode: .Center, vertAlignMode: .Baseline,
            labelColor: SKColor.blackColor(), shadowColor: SKColor.whiteColor(),
            name: "controlLabel",
            positon: CGPoint(x: oneThirdX-50, y: controlLabelY),
            shadowZPos: 2, shadowOffset: 3)
        addChild(controlSettingLabel[0])
        addChild(controlSettingLabel[1])
        
        let stretch = SKAction.scaleYTo(1.6, duration: 0.0)
        
        let thumbLabel: [SKLabelNode] = createShadowLabel(font: "Soup of Justice", text: "ONE HAND",
            fontSize: 30,
            horAlignMode: .Center, vertAlignMode: .Baseline,
            labelColor: SKColor.blackColor(), shadowColor: SKColor.whiteColor(),
            name: "thumbLabel",
            positon: CGPoint(x: oneThirdX-25, y: controlButtonY-15),
            shadowZPos: 2, shadowOffset: 2)
        thumbLabel[0].runAction(stretch)
        thumbLabel[1].runAction(stretch)
        addChild(thumbLabel[0])
        addChild(thumbLabel[1])
        
        let twoThumbsLabel: [SKLabelNode] = createShadowLabel(font: "Soup of Justice", text: "TWO HANDS",
            fontSize: 30,
            horAlignMode: .Center, vertAlignMode: .Baseline,
            labelColor: SKColor.blackColor(), shadowColor: SKColor.whiteColor(),
            name: "twoThumbsLabel",
            positon: CGPoint(x: twoThirdX+25, y: controlButtonY-15),
            shadowZPos: 2, shadowOffset: 2)
        twoThumbsLabel[0].runAction(stretch)
        twoThumbsLabel[1].runAction(stretch)
        addChild(twoThumbsLabel[0])
        addChild(twoThumbsLabel[1])
        
        let backLabel: [SKLabelNode] = createShadowLabel(font: "Soup of Justice", text: "BACK",
            fontSize: 20,
            horAlignMode: .Center, vertAlignMode: .Baseline,
            labelColor: SKColor.blackColor(), shadowColor: SKColor.whiteColor(),
            name: "backLabel",
            positon: CGPoint(x: backButtonX, y: backButtonY-10),
            shadowZPos: 2, shadowOffset: 2)
        let backStretch = SKAction.scaleXTo(1.6, y: 1.6, duration: 0.0)
        backLabel[0].runAction(backStretch)
        backLabel[1].runAction(backStretch)
        addChild(backLabel[0])
        addChild(backLabel[1])
        
        thumbImage.position = CGPoint(x: oneThirdX-20, y: controlPicY)
        twoThumbsImage.position = CGPoint(x: twoThirdX+20, y: controlPicY)
        thumbImage.setScale(0.7)
        twoThumbsImage.setScale(0.7)
        addChild(thumbImage)
        addChild(twoThumbsImage)
        
        addChild(thumbButton)
        addChild(twoThumbsButton)
        addChild(backButton)
        
        //debugDrawPlayableArea()
    }
    
    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0/9.0
        let playableWidth = size.height / maxAspectRatio
        let playableMargin = (size.width-playableWidth)/2.0
        
        oneThirdX = playableMargin + (playableWidth/3)
        twoThirdX = playableMargin + (playableWidth*(2/3))
        
        thumbButton.setScale(0.5)
        twoThumbsButton.setScale(0.5)
        backButton.setScale(0.3)
        
        thumbButtonRect = CGRect(x: oneThirdX-25 - thumbButton.size.width/2,
            y: controlButtonY - thumbButton.size.height/2,
            width: thumbButton.size.width,
            height: thumbButton.size.height)
        twoThumbsButtonRect = CGRect(x: twoThirdX+25 - thumbButton.size.width/2,
            y: controlButtonY - thumbButton.size.height/2,
            width: thumbButton.size.width,
            height: thumbButton.size.height)
        backButtonRect = CGRect(x: backButtonX - backButton.size.width/2,
            y: backButtonY - backButton.size.height/2,
            width: backButton.size.width,
            height: backButton.size.height)
        
        thumbButton.position = CGPoint(x: oneThirdX-25, y: controlButtonY)
        twoThumbsButton.position = CGPoint(x: twoThirdX+25, y: controlButtonY)
        backButton.position = CGPoint(x: backButtonX, y: backButtonY)
        
        super.init(size: size)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func sceneTouched(touchLocation:CGPoint) {
        var shade: SKShapeNode!
        var buttonTouched: Bool = false
        if(thumbButtonRect.contains(touchLocation)) {
            shade = drawRectangle(thumbButtonRect, SKColor.grayColor(), 1.0)
            buttonTouched = true
        }
        else if(twoThumbsButtonRect.contains(touchLocation)) {
            shade = drawRectangle(twoThumbsButtonRect, SKColor.grayColor(), 1.0)
            buttonTouched = true
        }
        else if(backButtonRect.contains(touchLocation)) {
            shade = drawRectangle(backButtonRect, SKColor.grayColor(), 1.0)
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
            var controlChangeMessage: String!
            var controlChange: Bool = false
            if(thumbButtonRect.contains(touchLocation)) {
                gameControls = .Thumb
                controlChangeMessage = "Controls Changed: One Hand"
                controlChange = true
            }
            else if(twoThumbsButtonRect.contains(touchLocation)) {
                gameControls = .TwoThumbs
                controlChangeMessage = "Controls Changed: Two Hands"
                controlChange = true
            }
            else if(backButtonRect.contains(touchLocation)) {
                myScene = MainMenu(size: self.size)
                myScene.scaleMode = self.scaleMode
                let reveal = SKTransition.flipHorizontalWithDuration(0.5)
                self.view?.presentScene(myScene, transition: reveal)
            }
            
            if(controlChange) {
                let controlChangeLabel: [SKLabelNode] = createShadowLabel(font: "Soup of Justice", text: controlChangeMessage,
                    fontSize: 30,
                    horAlignMode: .Center, vertAlignMode: .Baseline,
                    labelColor: SKColor.blackColor(), shadowColor: SKColor.whiteColor(),
                    name: "controlChangeLabel",
                    positon: CGPoint(x: size.width/2, y: controlMessageY),
                    shadowZPos: 2, shadowOffset: 2)
                addChild(controlChangeLabel[0])
                addChild(controlChangeLabel[1])
            
                let wait = SKAction.waitForDuration(0.8)
                let fade = SKAction.fadeAlphaTo(0.0, duration: 0.5)
                let remove = SKAction.runBlock({
                    controlChangeLabel[0].removeFromParent()
                    controlChangeLabel[1].removeFromParent()})
                let sequence = SKAction.sequence([wait, fade, remove])
                controlChangeLabel[0].runAction(sequence)
                controlChangeLabel[1].runAction(sequence)
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
        let tShape = drawRectangle(thumbButtonRect, SKColor.redColor(), 4.0)
        addChild(tShape)
        
        let ttShape = drawRectangle(twoThumbsButtonRect, SKColor.redColor(), 4.0)
        addChild(ttShape)
        
        let bShape = drawRectangle(backButtonRect, SKColor.redColor(), 4.0)
        addChild(bShape)
        
    }
    
    
}