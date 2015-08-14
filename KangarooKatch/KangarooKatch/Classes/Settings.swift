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
    
    let thumbButton = SKSpriteNode(imageNamed: "ButtonImage")
    let twoThumbsButton = SKSpriteNode(imageNamed: "ButtonImage")
    let settingsTitleY: CGFloat = 900
    let controlLabelY: CGFloat = 770
    let controlButtonY: CGFloat = 450
    let controlPicY: CGFloat = 620
    
    let thumbImage = SKSpriteNode(imageNamed: "OneThumb")
    let twoThumbsImage = SKSpriteNode(imageNamed: "TwoThumbs")
    
    let oneThirdX: CGFloat
    let twoThirdX: CGFloat
    
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
        
        thumbImage.position = CGPoint(x: oneThirdX-20, y: controlPicY)
        twoThumbsImage.position = CGPoint(x: twoThirdX+20, y: controlPicY)
        thumbImage.setScale(0.7)
        twoThumbsImage.setScale(0.7)
        addChild(thumbImage)
        addChild(twoThumbsImage)
        
        addChild(thumbButton)
        addChild(twoThumbsButton)
        
        debugDrawPlayableArea()
    }
    
    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0/9.0
        let playableWidth = size.height / maxAspectRatio
        let playableMargin = (size.width-playableWidth)/2.0
        
        oneThirdX = playableMargin + (playableWidth/3)
        twoThirdX = playableMargin + (playableWidth*(2/3))
        
        thumbButton.setScale(0.5)
        twoThumbsButton.setScale(0.5)
        
        thumbButtonRect = CGRect(x: oneThirdX-25 - thumbButton.size.width/2,
            y: controlButtonY - thumbButton.size.height/2,
            width: thumbButton.size.width,
            height: thumbButton.size.height)
        twoThumbsButtonRect = CGRect(x: twoThirdX+25 - thumbButton.size.width/2,
            y: controlButtonY - thumbButton.size.height/2,
            width: thumbButton.size.width,
            height: thumbButton.size.height)
        
        thumbButton.position = CGPoint(x: oneThirdX-25, y: controlButtonY)
        twoThumbsButton.position = CGPoint(x: twoThirdX+25, y: controlButtonY)
        
        super.init(size: size)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
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
                myScene = ClassicGameScene(size: self.size, difficulty: 0, joeys: 0, controls: Control.Thumb)
                myScene.scaleMode = self.scaleMode
                let reveal = SKTransition.flipHorizontalWithDuration(0.5)
                self.view?.presentScene(myScene, transition: reveal)
            }
            else if(endlessRect.contains(touchLocation)) {
                myScene = GameScene(size: self.size, difficulty: 0, joeys: 0, controls: Control.Thumb)
                myScene.scaleMode = self.scaleMode
                let reveal = SKTransition.flipHorizontalWithDuration(0.5)
                self.view?.presentScene(myScene, transition: reveal)
            }
            else if(multiRect.contains(touchLocation)) {
                //multiplayer scene (?) good luck...
            }
            else if(settingsRect.contains(touchLocation)) {
                //scene to choose sound options / controls (two hands or swiping)
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
    */
    
    func debugDrawPlayableArea() {
        let tShape = drawRectangle(thumbButtonRect, SKColor.redColor(), 4.0)
        addChild(tShape)
        
        let ttShape = drawRectangle(twoThumbsButtonRect, SKColor.redColor(), 4.0)
        addChild(ttShape)
        
    }
    
    
}