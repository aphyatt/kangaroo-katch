//
//  GameScene.swift
//  KangarooKatch
//
//  Created by ADAM HYATT on 7/8/15.
//  Copyright (c) 2015 ADAM HYATT. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {

    var gameState = GameState.GameRunning
    var controlSettings: Control
    
    let fullRect: CGRect
    let sceneRect: CGRect
    let dropletRect: CGRect
    let leftRect: CGRect
    let rightRect: CGRect
    let catchZoneRect: CGRect
    let fadeZoneRect: CGRect
    let oneThirdX: CGFloat
    let twoThirdX: CGFloat
    let playableMargin: CGFloat
    
    let kangaroo = SKSpriteNode(imageNamed: "Kangaroo")
    let horAlignModeDefault: SKLabelHorizontalAlignmentMode = .Center
    let vertAlignModeDefault: SKLabelVerticalAlignmentMode = .Baseline
    
    let dropletCatchBoundaryY: CGFloat = 175
    let dropletFadeBoundaryY: CGFloat = 65
    var leftColX: CGFloat
    var midColX: CGFloat
    var rightColX: CGFloat
    
    //Variables affecting speed / frequency of droplet lines
    var timeBetweenLines: NSTimeInterval = 0.5
    var totalLinesDropped: Int = 0
    var currLinesToDrop: Int = 0
    var lineCountBeforeDrops: Int = 0
    var eggPercentage: Int = 100
    var groupWaitTimeMin: CGFloat = 2.0
    var groupWaitTimeMax: CGFloat = 3.0
    var groupAmtMin: Int = 2
    var groupAmtMax: Int = 3
    var kangSpeed: NSTimeInterval
    
    //Variables dealing with touches (UI)
    var leftTouch: Bool = false
    var rightTouch: Bool = false
    var moveToCenterCol: Bool = false
    var kangPos: Int = 2
    var kangPosX: CGFloat = 0
    var numFingers: Int = 0
    
    //Score and Lives
    var score: Int = 0
    var dropsLeft: Int = 10
    var livesLeft: Int = 3
    let scoreLabelX: CGFloat
    let scoreLabelY: CGFloat = 962
    let livesLabelY: CGFloat = 982
    let dropsLabelY: CGFloat = 942
    var joeyLifeStartX: CGFloat
    var boomerangLifeStartX: CGFloat
    var scoreLabel : SKLabelNode!
    var scoreLabelS : SKLabelNode!
    
    //Gameover vars
    var restartTap: Bool = false
    var restartTapWait: Bool = false
    let gameOverLabel = SKLabelNode(fontNamed: "Soup of Justice")
    let gameOverLabelS = SKLabelNode(fontNamed: "Soup of Justice")
    
    //Difficulty variables
    var diffLevel: Int
    var changeDiff: Bool = false
    let V_EASY = 0
    let EASY = 1
    let MED = 2
    let HARD = 3
    let V_HARD = 4
    let EXTREME = 5
    
    //Droplet types and arrays
    let SPACE = 0
    let JOEY = 1
    let BOOMERANG = 2
    
    /************************************ Init/Update Functions ***************************************/
    
    override func didMoveToView(view: SKView) {
        debugDrawPlayableArea()
    }
    
    init(size: CGSize, controls: Control) {
        let maxAspectRatio:CGFloat = 16.0/9.0
        let playableWidth = size.height / maxAspectRatio
        playableMargin = (size.width-playableWidth)/2.0
        fullRect = CGRect(x: 0, y: 0,
            width: size.width,
            height: size.height)
        sceneRect = CGRect(x: playableMargin, y: 0,
            width: playableWidth,
            height: size.height)
        dropletRect = CGRect(x: playableMargin, y: dropletCatchBoundaryY,
            width: playableWidth,
            height: size.height - dropletCatchBoundaryY)
        leftRect = CGRect(x: 0, y: 0,
            width: size.width/2,
            height: size.height)
        rightRect = CGRect(x: size.width/2, y: 0,
            width: size.width/2,
            height: size.height)
        catchZoneRect = CGRect(x: playableMargin, y: dropletCatchBoundaryY - 5,
            width: playableWidth,
            height: 10)
        fadeZoneRect = CGRect(x: playableMargin, y: dropletFadeBoundaryY - 5,
            width: playableWidth,
            height: 10)
        oneThirdX = playableMargin + (playableWidth/3)
        twoThirdX = playableMargin + (playableWidth*(2/3))
        
        scoreLabelX = oneThirdX - 160
        
        leftColX = (size.width/2) - (dropletRect.width/3.5)
        midColX = size.width/2
        rightColX = (size.width/2) + (dropletRect.width/3.5)
        
        joeyLifeStartX = size.width/2 + 93
        boomerangLifeStartX = size.width/2 + 115
  
        controlSettings = controls
        kangSpeed = 0.1
        if(controlSettings == .Thumb) {
            kangSpeed = 0.05
        }
        if(controlSettings == .TwoThumbs) {
            kangSpeed = 0.1
        }
        diffLevel = V_EASY
        
        super.init(size: size)
        
        setupScene()
        setupHUD()
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupScene() {
        backgroundColor = SKColor.whiteColor()
        let background = SKSpriteNode(imageNamed: "Background")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = -1
        addChild(background)
        
        kangaroo.position = CGPoint(x: size.width/2, y: dropletCatchBoundaryY)
        kangaroo.zPosition = 1
        kangaroo.setScale(0.7)
        addChild(kangaroo)
        
    }
    
    func setupHUD() {
        var HUDheight: CGFloat = 120
        let HUDrect = CGRect(x: 0, y: size.height - HUDheight, width: size.width, height: HUDheight)
        var HUDshape = drawRectangle(HUDrect, SKColor.blackColor(), 1.0)
        HUDshape.fillColor = SKColor.blackColor()
        HUDshape.zPosition = 2
        addChild(HUDshape)
        
        var scoreY: CGFloat = 0
        var scoreSize: CGFloat = 0
        
        scoreSize = 50
        scoreY = scoreLabelY
        
        let scoreLabelA: [SKLabelNode] = createShadowLabel(font: "Soup of Justice", text: "Score: \(score)",
            fontSize: scoreSize,
            horAlignMode: .Left, vertAlignMode: .Center,
            labelColor: SKColor.whiteColor(), shadowColor: SKColor.grayColor(),
            name: "scoreLabel",
            positon: CGPoint(x: scoreLabelX, y: scoreY),
            shadowZPos: 4, shadowOffset: 4)
        scoreLabel = scoreLabelA[0]
        scoreLabelS = scoreLabelA[1]
        scoreLabel.runAction(SKAction.scaleYTo(1.3, duration: 0.0))
        scoreLabelS.runAction(SKAction.scaleYTo(1.3, duration: 0.0))
        addChild(scoreLabel)
        addChild(scoreLabelS)
        
        var livesDropsX: CGFloat = twoThirdX - 25
        
        let livesLabel: [SKLabelNode] = createShadowLabel(font: "Soup of Justice", text: "Lives: ",
            fontSize: 35,
            horAlignMode: .Right, vertAlignMode: .Center,
            labelColor: SKColor.whiteColor(), shadowColor: SKColor.grayColor(),
            name: "livesLabel",
            positon: CGPoint(x: livesDropsX, y: livesLabelY),
            shadowZPos: 4, shadowOffset: 2)
        livesLabel[0].runAction(SKAction.scaleYTo(1.2, duration: 0.0))
        livesLabel[1].runAction(SKAction.scaleYTo(1.2, duration: 0.0))
        addChild(livesLabel[0])
        addChild(livesLabel[1])
        
        let dropsLabel: [SKLabelNode] = createShadowLabel(font: "Soup of Justice", text: "Drops: ",
            fontSize: 35,
            horAlignMode: .Right, vertAlignMode: .Center,
            labelColor: SKColor.whiteColor(), shadowColor: SKColor.grayColor(),
            name: "dropsLabel",
            positon: CGPoint(x: livesDropsX, y: dropsLabelY),
            shadowZPos: 4, shadowOffset: 2)
        dropsLabel[0].runAction(SKAction.scaleYTo(1.2, duration: 0.0))
        dropsLabel[1].runAction(SKAction.scaleYTo(1.2, duration: 0.0))
        addChild(dropsLabel[0])
        addChild(dropsLabel[1])
        
        for i in 0...9 {
            let node = SKSpriteNode(imageNamed: "Egg")
            let nodeS = SKSpriteNode(imageNamed: "Egg")
            
            node.position.x = joeyLifeStartX + CGFloat(i)*20
            node.position.y = dropsLabelY
            node.setScale(0.04)
            node.zPosition = 5
            node.name = "drop\(i+1)"
            
            nodeS.position = node.position
            nodeS.setScale(0.04)
            nodeS.zPosition = 4
            nodeS.alpha = 0.5
            
            addChild(node)
            addChild(nodeS)
        }
        
        for i in 0...2 {
            let node = SKSpriteNode(imageNamed: "Boomerang")
            let nodeS = SKSpriteNode(imageNamed: "Boomerang")
            
            node.position.x = boomerangLifeStartX + CGFloat(i)*60
            node.position.y = livesLabelY
            node.setScale(0.10)
            node.zPosition = 5
            node.name = "life\(i+1)"
            
            nodeS.position = node.position
            nodeS.setScale(0.10)
            nodeS.zPosition = 4
            nodeS.alpha = 0.5
            
            addChild(node)
            addChild(nodeS)
        }
    }
    
    /*********************************************************************************************************
    * UPDATE
    * Function is called incredibly frequently, main game loop is here
    *********************************************************************************************************/
    override func update(currentTime: CFTimeInterval) {
        
        switch gameState {
        case .GameRunning:
            if (changeDiff) {
                updateDifficulty()
            }
            
            if (totalLinesDropped - lineCountBeforeDrops) == currLinesToDrop {
                dropNewGroup()
            }
            
            updateKangaroo()
            
            break
        case .Paused:
            break
        case .GameOver:
            endGame()
            break
        }
        
    }
    
    var endGameCalls: Int = 0
    func endGame() {
        endGameCalls++
        if(endGameCalls == 1) {
            freezeDroplets()
            let shade = drawRectangle(fullRect, SKColor.grayColor(), 1.0)
            shade.fillColor = SKColor.grayColor()
            shade.alpha = 0.4
            shade.zPosition = 6
            addChild(shade)
            runGameOverAction()
            let wait = SKAction.waitForDuration(6.5)
            let setBool = SKAction.runBlock({self.restartTapWait = true})
            runAction(SKAction.sequence([wait,setBool]))
        }
        else {
            if restartTap {
                restartTap = false
                restartTapWait = false
                endGameCalls = 0
                restartGame()
            }
        }
    }
    
    func restartGame() {
        //remove all nodes
        removeAllActions()
        removeAllChildren()
        //add background and kangaroo
        score = 0
        diffLevel = 0
        setupScene()
        //add score, drops and lives labels
        setupHUD()
        //set difficulty, speeds, ect.
        timeBetweenLines = 0.5
        totalLinesDropped = 0
        currLinesToDrop = 0
        lineCountBeforeDrops = 0
        eggPercentage = 100
        groupWaitTimeMin = 2.0
        groupWaitTimeMax = 3.0
        groupAmtMin = 2
        groupAmtMax = 3
        dropsLeft = 10
        livesLeft = 3
        kangPos = 2
        timesthisFuncCalled = 0
        scene?.physicsWorld.gravity = CGVector(dx: 0, dy: -7.8)
        //change gameState
        gameState = .GameRunning
    }
    
    func freezeDroplets() {
        removeAllActions()
        enumerateChildNodesWithName("joey") { node, _ in
            let joey = node as! SKSpriteNode
            joey.removeAllActions()
            joey.physicsBody = nil
        }
        
        enumerateChildNodesWithName("boomerang") { node, _ in
            let boom = node as! SKSpriteNode
            boom.removeAllActions()
            boom.physicsBody = nil
        }
        
        enumerateChildNodesWithName("missedJoey") { node, _ in
            let joey = node as! SKSpriteNode
            joey.removeAllActions()
            joey.physicsBody = nil
        }
        
        enumerateChildNodesWithName("missedBoomer") { node, _ in
            let boom = node as! SKSpriteNode
            boom.removeAllActions()
            boom.physicsBody = nil
        }
    }
    
    func runGameOverAction() {
        let gameOver = createShadowLabel(font: "Soup of Justice", text: "GAME OVER",
            fontSize: 70,
            horAlignMode: horAlignModeDefault, vertAlignMode: .Baseline,
            labelColor: SKColor.blackColor(), shadowColor: SKColor.whiteColor(),
            name: "gameOver",
            positon: CGPoint(x: size.width/2, y: 780),
            shadowZPos: 7, shadowOffset: 2)
        gameOver[0].alpha = 0.0
        gameOver[1].alpha = 0.0
        addChild(gameOver[0])
        addChild(gameOver[1])
        
        //fade in GAME OVER
        let wait = SKAction.waitForDuration(0.5)
        let fadeIn = SKAction.fadeAlphaTo(1.0, duration: 2.0)
        let gameOverAction = SKAction.sequence([wait, fadeIn])
        let GOgroup = SKAction.group([SKAction.runBlock({gameOver[0].runAction(gameOverAction)}),
            SKAction.runBlock({gameOver[1].runAction(gameOverAction)})])
        runAction(GOgroup)
        
        var scoreMoveLocX: CGFloat = 130
        if score < 10 {
            scoreMoveLocX += 20
        }
        else if score < 100 {
            scoreMoveLocX += 10
        }
        //have score move and grow under GAME OVER
        let wait2 = SKAction.waitForDuration(3.0)
        let bringToFront = SKAction.runBlock({self.scoreLabel.zPosition = 8; self.scoreLabelS.zPosition = 7})
        let moveIntoPos = SKAction.moveByX(scoreMoveLocX, y: -240, duration: 1.0)
        let grow = SKAction.scaleBy(1.3, duration: 1.0)
        let scoreAction = SKAction.sequence([wait2, bringToFront, SKAction.group([moveIntoPos, grow])])
        let scoreGroup = SKAction.group([SKAction.runBlock({self.scoreLabel.runAction(scoreAction)}),
            SKAction.runBlock({self.scoreLabelS.runAction(scoreAction)})])
        runAction(scoreGroup)
        
        //tap anywhere to restart
        let tapRestart = createShadowLabel(font: "Soup of Justice", text: "TAP ANYWHERE TO RESTART",
            fontSize: 20,
            horAlignMode: horAlignModeDefault, vertAlignMode: .Baseline,
            labelColor: SKColor.blackColor(), shadowColor: SKColor.whiteColor(),
            name: "tapRestartLabel",
            positon: CGPoint(x: size.width/2, y: 650),
            shadowZPos: 7, shadowOffset: 2)
        tapRestart[0].alpha = 0.0
        tapRestart[1].alpha = 0.0
        addChild(tapRestart[0])
        addChild(tapRestart[1])
        
        let wait3 = SKAction.waitForDuration(5.0)
        let fadeIn2 = SKAction.fadeAlphaTo(1.0, duration: 0.8)
        let fadeOut = SKAction.fadeAlphaTo(0.0, duration: 0.8)
        let blink = SKAction.sequence([fadeIn2, fadeOut])
        let tapAction = SKAction.sequence([wait3, SKAction.repeatActionForever(blink)])
        tapRestart[0].runAction(tapAction)
        tapRestart[1].runAction(tapAction)
       
    }
    
    /*********************************************************************************************************
    * UPDATE DIFFICULTY
    * Based on algorithm in getNewGroupAmount, calls this function
    * to adjust speeds and difficult level
    *********************************************************************************************************/
    func updateDifficulty() {
        if diffLevel < EXTREME {
            timeBetweenLines -= 0.04
            scene?.physicsWorld.gravity.dy -= 1.2
            groupWaitTimeMax -= 0.2
            groupWaitTimeMin -= 0.2
            groupAmtMin = (groupAmtMin*2 - 1)
            groupAmtMax = (groupAmtMin*2 - 1)
            diffLevel++
        }
        else {
            groupAmtMin = (groupAmtMin*2 - 1)
            groupAmtMax = (groupAmtMin*2 - 1)
        }
        
        switch diffLevel {
        case V_EASY: eggPercentage = 100
            break
        case EASY: eggPercentage = 70
            break
        case MED: eggPercentage = 70
            break
        case HARD: eggPercentage = 75
            break
        case V_HARD: eggPercentage = 90
            break
        default: eggPercentage = 90
            break
        }
        
        println("Diff Changed To: \(diffLevel)")
        changeDiff = false
    }
    
    /*********************** Difficulty Helper Functions ****************************/
    
    /*
    * Provides algorithm for deciding when to change difficulty
    */
    var timesthisFuncCalled: Int = 0
    var repeat: Int = 10
    func checkUpdateDifficulty() {
        if timesthisFuncCalled == repeat {
            timesthisFuncCalled = 0
            switch diffLevel {
            case V_EASY: repeat = 10
                break
            case EASY: repeat = 10
                break
            case MED: repeat = 10
                break
            case HARD: repeat = 7
                break
            case V_HARD: repeat = 5
                break
            default: repeat = 1
            }
            changeDiff = true
        }
        timesthisFuncCalled++
        
    }
    
    /**********************************************************************************************************
    * DROP NEW GROUP
    * Function drops new group, calls:
    * dropRandomLine: gets random line and drops
    * then groups a determined amount of these into one action
    ***********************************************************************************************************/
    func dropNewGroup() {
        //if true, drop a new group of lines
        checkUpdateDifficulty()
        let linesToDrop = totalLinesDropped == 0 ? 1 : randomInt(groupAmtMin, groupAmtMax)
        let waitBeforeGroup = totalLinesDropped == 0 ?
            0.0 : NSTimeInterval(CGFloat.random(min: groupWaitTimeMin, max: groupWaitTimeMax))
        
        let groupSequence = SKAction.sequence([SKAction.runBlock({self.dropRandomLine()}), SKAction.waitForDuration(timeBetweenLines)])
        let groupAction = SKAction.repeatAction(groupSequence, count: linesToDrop)
        let finalAction = SKAction.sequence([SKAction.waitForDuration(waitBeforeGroup), groupAction])
        
        //save variables to check when you can drop another group
        currLinesToDrop = linesToDrop
        lineCountBeforeDrops = totalLinesDropped
        
        //println("Droping group size: \(linesToDrop), waitBeforeGroup: \(waitBeforeGroup)")
        runAction(finalAction)
    }
    
    /*********************** Drop Group Helper Functions ******************************/
    
    /*
    * Drops random line chosen from pickRandomLine() by making
    * three simultaneous calls to spawnDroplet
    */
    func dropRandomLine() {
        let chosenLine = pickRandomLine()
        
        let dropLeft = SKAction.runBlock({self.spawnDroplet(1, type: chosenLine[0])})
        let dropMiddle = SKAction.runBlock({self.spawnDroplet(2, type: chosenLine[1])})
        let dropRight = SKAction.runBlock({self.spawnDroplet(3, type: chosenLine[2])})
        
        let dropLine = SKAction.group([dropLeft, dropMiddle, dropRight])
        runAction(dropLine)
        //runAction(dropLineSound) whistle down
        
        totalLinesDropped++;
    }
    
    /*
    * Fetches all possible lines based on diffLevel and
    * uses eggPercentage algorithm to return one of them
    */
    var lastIndexPicked: Int = 0
    func pickRandomLine() -> [Int] {
        let percentage: Int = randomInt(1, 100)
        let linesForDifficulty: [[Int]]
        if percentage <= eggPercentage { linesForDifficulty = difficultyArraysG[diffLevel] }
        else { linesForDifficulty = difficultyArraysB[diffLevel] }
        
        var randomIndex: Int = Int(arc4random_uniform(UInt32(linesForDifficulty.endIndex)))
        
        if diffLevel > EASY {
            if randomIndex == lastIndexPicked {
                if randomIndex == 0 { randomIndex++ }
                else { randomIndex-- }
            }
        }
        lastIndexPicked = randomIndex
        return linesForDifficulty[randomIndex]
    }
    
    /*
    * Adds child with physics body of individual droplet
    * to the top of the screen
    */
    func spawnDroplet(col: Int, type: Int) {
        var droplet: SKSpriteNode!
        var somethingDropped = true
        switch type {
        case JOEY:
            droplet = SKSpriteNode(imageNamed: "Egg")
            droplet.name = "joey"
            droplet.setScale(0.1)
            break
        case BOOMERANG:
            droplet = SKSpriteNode(imageNamed: "Boomerang")
            droplet.name = "boomerang"
            droplet.setScale(0.2)
            break
        default:
            somethingDropped = false
        }
        
        if somethingDropped {
            droplet.zPosition = 3
            var dropletPosX: CGFloat = rightColX
            if(col == 1) {
                dropletPosX = leftColX
            }
            else if(col == 2) {
                dropletPosX = midColX
            }
            droplet.position = CGPoint(
                x: dropletPosX,
                y: size.height + droplet.size.height/2)
            
            if(type == JOEY) {
                //Joey animation here
                droplet.zRotation = -π / 8.0
                let leftWiggle = SKAction.rotateByAngle(π/4.0, duration: 0.25)
                let rightWiggle = leftWiggle.reversedAction()
                let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle, leftWiggle, rightWiggle])
                let scaleUp = SKAction.scaleBy(1.1, duration: 0.25)
                let scaleDown = scaleUp.reversedAction()
                let fullScale = SKAction.sequence(
                    [scaleUp, scaleDown, scaleUp, scaleDown])
                let group = SKAction.group([fullScale, fullWiggle])
                droplet.runAction(SKAction.repeatActionForever(group))
            }
            if(type == BOOMERANG) {
                let halfSpin = SKAction.rotateByAngle(π, duration: 0.5)
                let fullSpin = SKAction.sequence([halfSpin, halfSpin])
                droplet.runAction(SKAction.repeatActionForever(fullSpin))
            }
            
            droplet.physicsBody = SKPhysicsBody(circleOfRadius: droplet.size.width/2)
            addChild(droplet)
            
        }
    }
    
    /**********************************************************************************************************
    * UPDATE KANGAROO
    * Function updates position based on booleans set from:
    * sceneTouched / touchesBegan
    * sceneUntouched / touchesEnded
    * TODO instead of catching error later, catch error after kangPos is added or subracted to, move accordingly
    * within the case statement
    **********************************************************************************************************/
    func updateKangaroo() {
        if leftTouch && (kangPos != 1) {
            kangaroo.runAction(SKAction.moveToX(leftColX, duration: kangSpeed))
            kangPos = 1
        }
        if rightTouch && (kangPos != 3) {
            kangaroo.runAction(SKAction.moveToX(rightColX, duration: kangSpeed))
            kangPos = 3
        }
        if ((!leftTouch && !rightTouch) || numFingers == 0) && (kangPos != 2) {
            kangaroo.runAction(SKAction.moveToX(midColX, duration: kangSpeed))
            kangPos = 2
        }
        
        switch kangPos {
        case 1: kangPosX = leftColX
            break
        case 2: kangPosX = midColX
            break
        default: kangPosX = rightColX
        }
        
    }
    
    /********************** Update Kangaroo Helper Functions ****************************/
    
    func sceneTouchedTwoThumbs(touchLocation:CGPoint) {
        if (gameState == .GameOver) && restartTapWait {
            restartTap = true
        }
        if leftRect.contains(touchLocation) {
            leftTouch = true
            rightTouch = false
        }
        if rightRect.contains(touchLocation) {
            rightTouch = true
            leftTouch = false
        }
    }
    
    func sceneUntouchedTwoThumbs(touchLocation:CGPoint) {
        let leftEndTouch = leftRect.contains(touchLocation)
        let rightEndTouch = rightRect.contains(touchLocation)
        
        if leftEndTouch || (numFingers == 0) {
            leftTouch = false
        }
        if rightEndTouch || (numFingers == 0) {
            rightTouch = false
        }
    }
    
    func sceneTouchedThumb(touchLocation:CGPoint) {
        if (gameState == .GameOver) && restartTapWait {
            restartTap = true
        }
        if touchLocation.x < oneThirdX {
            leftTouch = true
            rightTouch = false
        }
        if touchLocation.x > twoThirdX {
            rightTouch = true
            leftTouch = false
        }
    }
    
    func sceneUntouchedThumb(touchLocation:CGPoint) {
        if numFingers == 0 {
            leftTouch = false
            rightTouch = false
        }
    }
    
    func trackThumb(touchLocation:CGPoint) {
        if touchLocation.x < oneThirdX {
            leftTouch = true
            rightTouch = false
        }
        else if touchLocation.x > twoThirdX {
            rightTouch = true
            leftTouch = false
        }
        else {
            leftTouch = false
            rightTouch = false
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let touchLocation = touch.locationInNode(self)
        numFingers += touches.count
        if(controlSettings == .TwoThumbs) {
            sceneTouchedTwoThumbs(touchLocation)
        }
        if(controlSettings == .Thumb) {
            sceneTouchedThumb(touchLocation)
        }
       
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let touchLocation = touch.locationInNode(self)
        if(controlSettings == .Thumb) {
            trackThumb(touchLocation)
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let touchLocation = touch.locationInNode(self)
        numFingers -= touches.count
        if(controlSettings == .TwoThumbs) {
            sceneUntouchedTwoThumbs(touchLocation)
        }
        if(controlSettings == .Thumb) {
            sceneUntouchedThumb(touchLocation)
        }
    }
    
    /*********************************************************************************************************
    * CHECK COLLISIONS
    * Function for determining collisions between Kangaroo and droplets
    *********************************************************************************************************/
    func checkCollisions() {
        
        var caughtJoeys: [SKSpriteNode] = []
        var missedJoeys: [SKSpriteNode] = []
        enumerateChildNodesWithName("joey") { node, _ in
            let joey = node as! SKSpriteNode
            if (Int(joey.position.x) == Int(self.kangPosX)) {
                if CGRectIntersectsRect(CGRectInset(joey.frame, 5, 5), self.catchZoneRect) {
                    caughtJoeys.append(joey)
                    joey.name = "caught"
                }
                else if joey.position.y < self.dropletCatchBoundaryY {
                    missedJoeys.append(joey)
                    joey.name = "missedJoey"
                }
            }
            else {
                if joey.position.y < self.dropletCatchBoundaryY {
                    missedJoeys.append(joey)
                    joey.name = "missedJoey"
                }
            }
        }
        for joey in caughtJoeys {
            kangarooCaughtJoey(joey)
        }
        for joey in missedJoeys {
            kangarooMissedJoey(joey)
        }
        
        var fadeJoeys: [SKSpriteNode] = []
        enumerateChildNodesWithName("missedJoey") { node, _ in
            let joey = node as! SKSpriteNode
            if CGRectIntersectsRect(CGRectInset(joey.frame, 5, 5), self.fadeZoneRect) {
                fadeJoeys.append(joey)
                joey.name = "faded"
            }
        }
        for joey in fadeJoeys {
            stopAndFadeJoey(joey)
        }
        
        var caughtBoomers: [SKSpriteNode] = []
        var missedBoomers: [SKSpriteNode] = []
        enumerateChildNodesWithName("boomerang") { node, _ in
            let boomer = node as! SKSpriteNode
            if (Int(boomer.position.x) == Int(self.kangPosX)) {
                if CGRectIntersectsRect(CGRectInset(boomer.frame, 5, 5), self.catchZoneRect) {
                    caughtBoomers.append(boomer)
                    boomer.name = "caught"
                }
                else if boomer.position.y < self.dropletCatchBoundaryY {
                    missedBoomers.append(boomer)
                    boomer.name = "missedBoomer"
                }
            }
            else {
                if boomer.position.y < self.dropletCatchBoundaryY {
                    missedBoomers.append(boomer)
                    boomer.name = "missedBoomer"
                }
            }
        }
        for boomer in caughtBoomers {
            kangarooCaughtBoomer(boomer)
        }
        for boomer in missedBoomers {
            kangarooMissedBoomer(boomer)
        }
        
    }
    
    override func didEvaluateActions()  {
        checkCollisions()
    }
    
    //Can use pouch idea where joey falls behind pouch and detection is near entrance
    func kangarooCaughtJoey(joey: SKSpriteNode) {
        //runAction(caughtJoeySound)
        //println("joeyCaught")
        
        let jumpUp = SKAction.moveByX(0.0, y: 10.0, duration: 0.1)
        let jumpDown = jumpUp.reversedAction()
        let catch = SKAction.sequence([jumpUp, jumpDown])
        kangaroo.runAction(catch)
        
        joey.removeAllActions()
        joey.runAction(SKAction.removeFromParent())
        
        score++
        scoreLabel.text = "Score: \(score)"
        scoreLabelS.text = "Score: \(score)"
        
        var adjustX: CGFloat = 0
        if score >= 10 { adjustX = 10 }
        if score >= 100 { adjustX = 20 }
        
        let grow = SKAction.scaleBy(1.05, duration: 0.15)
        let adjust = SKAction.runBlock({
            self.scoreLabel.position.x = self.scoreLabelX - adjustX
            self.scoreLabelS.position.x = self.scoreLabelX + 2 - adjustX
        })
        let shrink = grow.reversedAction()
        let scoreAction = SKAction.sequence([grow, adjust, shrink])
        
        let groupScore = SKAction.group([SKAction.runBlock({self.scoreLabel.runAction(scoreAction)}),
            SKAction.runBlock({self.scoreLabelS.runAction(scoreAction)})])
        runAction(groupScore)
        
    }
    
    func kangarooMissedJoey(joey: SKSpriteNode) {
        //runAction(missedJoeySound) aaahh

        //make fade rect like catchzone, in checkcollision if missed hits fadezone, then stop and fade
        let fade = SKAction.fadeAlphaTo(0.3, duration: 0.1)
        joey.runAction(fade)

    }
    
    func stopAndFadeJoey(joey: SKSpriteNode) {
        joey.removeFromParent()
        joey.removeAllActions()
        joey.physicsBody = nil
        joey.zRotation = 0
        joey.alpha = 0.3
        joey.position.y = dropletFadeBoundaryY
        //change joey to have frown?
        addChild(joey)
        
        let dropLife = childNodeWithName("drop\(dropsLeft)")
        dropLife!.removeFromParent()
        dropsLeft--
        if(dropsLeft == 0) {
            gameState = .GameOver
        }
        
    }
    
    func kangarooCaughtBoomer(boomer: SKSpriteNode) {
        //runAction(enemyCollisionSound) ouch!
        // make kangaroo frown
        
        let shakeLeft = SKAction.moveByX(-10.0, y: 0.0, duration: 0.05)
        let shakeRight = SKAction.moveByX(20.0, y: 0.0, duration: 0.1)
        let shakeOff = SKAction.sequence([shakeLeft, shakeRight, shakeLeft])
        //turn shake off into screen shake
        kangaroo.runAction(shakeOff)
        println("shake")
        
        boomer.removeAllActions()
        boomer.runAction(SKAction.removeFromParent())
        
        let life = childNodeWithName("life\(livesLeft)")
        life!.removeFromParent()
        livesLeft--
        if(livesLeft == 0) {
            gameState = .GameOver
        }
        
    }
    
    func kangarooMissedBoomer(boomer: SKSpriteNode) {
        let fade = SKAction.fadeAlphaTo(0.0, duration: 0.18)
        let remove = SKAction.removeFromParent()
        boomer.runAction(SKAction.sequence([fade, remove]))
        
    }
    
    /****************************** Other Functions ***********************************/
    
    func debugDrawPlayableArea() {
        
        //let sceneArea = drawRectangle(sceneRect, SKColor.redColor(), 4.0)
        //addChild(sceneArea)
        
        //let dropletArea = drawRectangle(dropletRect, SKColor.yellowColor(), 6.0)
        //addChild(dropletArea)
        
        //let leftSide = drawRectangle(leftRect, SKColor.greenColor(), 10.0)
        //addChild(leftSide)
        
        //let rightSide = drawRectangle(rightRect, SKColor.redColor(), 10.0)
        //addChild(rightSide)
        
        let catchZone = drawRectangle(catchZoneRect, SKColor.blueColor(), 6.0)
        catchZone.zPosition = 2
        addChild(catchZone)
        
        let fadeZone = drawRectangle(fadeZoneRect, SKColor.whiteColor(), 6.0)
        fadeZone.zPosition = 2
        addChild(fadeZone)
        
        let testRect = CGRect(x: 300, y: 300, width: 300, height: 300)
        let test = getRoundedRectShape(rect: testRect, cornerRadius: 16, color: SKColor.blackColor(), lineWidth: 5)
        test.zPosition = 10
        addChild(test)
        
        
    }
    
}
