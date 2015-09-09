//
//  GameScene.swift
//  KangarooKatch
//
//  Created by ADAM HYATT on 7/8/15.
//  Copyright (c) 2015 ADAM HYATT. All rights reserved.
//

import SpriteKit

class ClassicGameScene: SKScene {
    
    var gameState = GameState.GameRunning
    var controlSettings: Control
    
    let fullRect: CGRect
    let sceneRect: CGRect
    let dropletRect: CGRect
    let leftRect: CGRect
    let rightRect: CGRect
    let catchZoneRect: CGRect
    let fadeZoneRect: CGRect
    let pauseRect: CGRect
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
    let pauseX: CGFloat = 585
    let pauseY: CGFloat
    
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
    
    var dropLines: Bool = false
    var unpauseGame: Bool = false
    var mainMenuArray: [SKNode]
    
    //Variables dealing with touches (UI)
    var leftTouch: Bool = false
    var rightTouch: Bool = false
    var moveToCenterCol: Bool = false
    var kangPos: Int = 2
    var kangPosX: CGFloat = 0
    var numFingers: Int = 0
    
    //Score and Lives
    var score: Int = 0
    var joeyCount: Int
    let scoreLabelX: CGFloat
    let joeyCountX: CGFloat
    let scoreLabelY: CGFloat = 959
    var joeyCountLabel : SKLabelNode!
    var joeyCountLabelS : SKLabelNode!
    
    //Gameover vars
    var restartTap: Bool = false
    var restartTapWait: Bool = false
    let gameOverLabel = SKLabelNode(fontNamed: "Soup of Justice")
    let gameOverLabelS = SKLabelNode(fontNamed: "Soup of Justice")
    
    //Difficulty variables
    let diffLevel: Int
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
    
    init(size: CGSize, difficulty: Int, joeys: Int, controls: Control) {
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
        pauseY = size.height - 80
        pauseRect = CGRect(x: pauseX, y: pauseY, width: 60, height: 60)
        
        oneThirdX = playableMargin + (playableWidth/3)
        twoThirdX = playableMargin + (playableWidth*(2/3))
        
        scoreLabelX = oneThirdX - 160
        joeyCountX = size.width/2
        
        leftColX = (size.width/2) - (dropletRect.width/3.5)
        midColX = size.width/2
        rightColX = (size.width/2) + (dropletRect.width/3.5)
        
        controlSettings = controls
        kangSpeed = 0.1
        if(controlSettings == .Thumb) {
            kangSpeed = 0.05
        }
        if(controlSettings == .TwoThumbs) {
            kangSpeed = 0.1
        }
        
        diffLevel = difficulty
        joeyCount = joeys
        mainMenuArray = []
        
        super.init(size: size)
        
        setupScene()
        setupHUD()
        //run countdown, set stopDropping after action
        dropLines = true
        
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
        
        let pauseButton = SKSpriteNode(imageNamed: "PauseButton")
        pauseButton.position = CGPoint(x: pauseX+30, y: pauseY+30)
        pauseButton.setScale(1.5)
        pauseButton.zPosition = 10
        pauseButton.setScale(0.25)
        addChild(pauseButton)
        
        setDifficulty(diffLevel)
    }
    
    func setupHUD() {
        var HUDheight: CGFloat = 120
        let HUDrect = CGRect(x: 0, y: size.height - HUDheight, width: size.width, height: HUDheight)
        var HUDshape = drawRectangle(HUDrect, SKColor.blackColor(), 1.0)
        HUDshape.fillColor = SKColor.whiteColor()
        HUDshape.zPosition = 2
        addChild(HUDshape)
        
        var scoreY: CGFloat = 0
        var scoreSize: CGFloat = 0
        
        scoreSize = 57
        scoreY = scoreLabelY
        
        let countLabelA: [SKLabelNode] = createShadowLabel(font: "Soup of Justice", text: "Joeys: \(joeyCount)",
            fontSize: scoreSize,
            horAlignMode: horAlignModeDefault, vertAlignMode: .Center,
            labelColor: SKColor.blackColor(), shadowColor: SKColor.grayColor(),
            name: "joeyLabel",
            positon: CGPoint(x: joeyCountX, y: scoreY),
            shadowZPos: 4, shadowOffset: 4)
        joeyCountLabel = countLabelA[0]
        joeyCountLabelS = countLabelA[1]
        joeyCountLabel.runAction(SKAction.scaleYTo(1.3, duration: 0.0))
        joeyCountLabelS.runAction(SKAction.scaleYTo(1.3, duration: 0.0))
        addChild(joeyCountLabel)
        addChild(joeyCountLabelS)
    }
    
    func setDifficulty(diff: Int) {
        switch diff {
        case V_EASY:
            timeBetweenLines = 0.5
            scene?.physicsWorld.gravity.dy = -7.8
            groupWaitTimeMax = 3
            groupWaitTimeMin = 2
            eggPercentage = 100
            break
        case EASY:
            timeBetweenLines = 0.46
            scene?.physicsWorld.gravity.dy = -9.0
            groupWaitTimeMax = 2.8
            groupWaitTimeMin = 1.8
            eggPercentage = 70
            break
        case MED:
            timeBetweenLines = 0.42
            scene?.physicsWorld.gravity.dy = -10.2
            groupWaitTimeMax = 2.6
            groupWaitTimeMin = 1.6
            eggPercentage = 70
            break
        case HARD:
            timeBetweenLines = 0.38
            scene?.physicsWorld.gravity.dy = -11.4
            groupWaitTimeMax = 2.4
            groupWaitTimeMin = 1.4
            eggPercentage = 75
            break
        case V_HARD:
            timeBetweenLines = 0.34
            scene?.physicsWorld.gravity.dy = -12.6
            groupWaitTimeMax = 2.2
            groupWaitTimeMin = 1.2
            eggPercentage = 90
            break
        default:
            timeBetweenLines = 0.3
            scene?.physicsWorld.gravity.dy = -13.8
            groupWaitTimeMax = 2
            groupWaitTimeMin = 1
            eggPercentage = 90
            break
        }
    }
    
    /*********************************************************************************************************
    * UPDATE
    * Function is called incredibly frequently, main game loop is here
    *********************************************************************************************************/
    override func update(currentTime: CFTimeInterval) {
        
        switch gameState {
        case .GameRunning:
            if (totalLinesDropped - lineCountBeforeDrops) == currLinesToDrop {
                dropNewGroup()
            }
            
            updateKangaroo()
            
            break
        case .Paused:
            pauseGame()
            break
        case .GameOver:
            endGame()
            break
        }
    }
    
    var pauseGameCalls: Int = 0
    func pauseGame() {
        pauseGameCalls++
        if(pauseGameCalls == 1) {
            freezeDroplets()
            showPauseMenu()
        }
        else {
            if unpauseGame {
                unpauseGame = false
                pauseGameCalls = 0
                removeChildrenInArray(mainMenuArray)
                //countdown / wait
                unfreezeDroplets()
                dropLines = true
                lineCountBeforeDrops = totalLinesDropped
                currLinesToDrop = 0
                gameState = .GameRunning
            }
        }
    }
    
    var endGameCalls: Int = 0
    func endGame() {
        endGameCalls++
        if(endGameCalls == 1) {
            let wait1 = SKAction.waitForDuration(3)
            let gameOver = SKAction.runBlock({self.runGameOverAction()})
            let wait2 = SKAction.waitForDuration(7)
            let setBool = SKAction.runBlock({self.restartTapWait = true})
            runAction(SKAction.sequence([wait1, gameOver, wait2, setBool]))
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
        setDifficulty(diffLevel)
        setupScene()
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
    
    func unfreezeDroplets() {
        enumerateChildNodesWithName("*") { node, _ in
            if node.name == "joey" || node.name == "missedJoey" {
                let node = node as! SKSpriteNode
                node.zRotation = -π / 8.0
                let leftWiggle = SKAction.rotateByAngle(π/4.0, duration: 0.25)
                let rightWiggle = leftWiggle.reversedAction()
                let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle, leftWiggle, rightWiggle])
                let scaleUp = SKAction.scaleBy(1.1, duration: 0.25)
                let scaleDown = scaleUp.reversedAction()
                let fullScale = SKAction.sequence(
                    [scaleUp, scaleDown, scaleUp, scaleDown])
                let group = SKAction.group([fullScale, fullWiggle])
                node.runAction(SKAction.repeatActionForever(group))
                node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width/2)
            }
            if node.name == "boomerang" || node.name == "missedBoomer" {
                let node = node as! SKSpriteNode
                let halfSpin = SKAction.rotateByAngle(π, duration: 0.5)
                let fullSpin = SKAction.sequence([halfSpin, halfSpin])
                node.runAction(SKAction.repeatActionForever(fullSpin))
                node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width/2)
            }
        }
    }
    
    func showPauseMenu() {
        let shade = drawRectangle(fullRect, SKColor.grayColor(), 1.0)
        shade.fillColor = SKColor.grayColor()
        shade.alpha = 0.4
        shade.zPosition = 6
        shade.name = "shade"
        addChild(shade)
        
        let mmRect = CGRect(x: oneThirdX-70, y: size.height/2-300,
            width: size.width-(2*(oneThirdX-70)), height: 600)
        let mainMenu = getRoundedRectShape(rect: mmRect, cornerRadius: 16, color: SKColor.whiteColor(), lineWidth: 8)
        mainMenu.fillColor = SKColor.blackColor()
        mainMenu.zPosition = 7
        addChild(mainMenu)
        
        let paused = createShadowLabel(font: "Soup of Justice", text: "GAME PAUSED",
            fontSize: 50,
            horAlignMode: horAlignModeDefault, vertAlignMode: .Baseline,
            labelColor: SKColor.whiteColor(), shadowColor: SKColor.grayColor(),
            name: "gamePaused",
            positon: CGPoint(x: size.width/2, y: 780),
            shadowZPos: 8, shadowOffset: 2)
        addChild(paused[0])
        addChild(paused[1])
        
        let mmLabel = createShadowLabel(font: "Soup of Justice", text: "MAIN MENU",
            fontSize: 20,
            horAlignMode: horAlignModeDefault, vertAlignMode: .Baseline,
            labelColor: SKColor.whiteColor(), shadowColor: SKColor.grayColor(),
            name: "mainMenu",
            positon: CGPoint(x: oneThirdX, y: 500),
            shadowZPos: 8, shadowOffset: 2)
        addChild(mmLabel[0])
        addChild(mmLabel[1])
        
        mainMenuArray = [shade, mainMenu, paused[0], paused[1], mmLabel[0], mmLabel[1]]
    }
    
    func runGameOverAction() {
        freezeDroplets()
        let shade = drawRectangle(fullRect, SKColor.grayColor(), 1.0)
        shade.fillColor = SKColor.grayColor()
        shade.alpha = 0.4
        shade.zPosition = 6
        addChild(shade)
        
        var scoreTmp: Int = 0
        let scoreLabelA: [SKLabelNode] = createShadowLabel(font: "Soup of Justice", text: "Score: \(scoreTmp)",
            fontSize: 60,
            horAlignMode: .Left, vertAlignMode: .Center,
            labelColor: SKColor.whiteColor(), shadowColor: SKColor.grayColor(),
            name: "scoreLabel",
            positon: CGPoint(x: size.width/2, y: 780),
            shadowZPos: 7, shadowOffset: 4)
        scoreLabelA[0].runAction(SKAction.scaleYTo(1.3, duration: 0.0))
        scoreLabelA[1].runAction(SKAction.scaleYTo(1.3, duration: 0.0))
        scoreLabelA[0].alpha = 0.0
        scoreLabelA[1].alpha = 0.0
        addChild(scoreLabelA[0])
        addChild(scoreLabelA[1])
        
        //fade in score
        let wait = SKAction.waitForDuration(0.5)
        let fadeIn = SKAction.fadeAlphaTo(1.0, duration: 2.0)
        let scoreAction = SKAction.sequence([wait, fadeIn])
        let Sgroup = SKAction.group([SKAction.runBlock({scoreLabelA[0].runAction(scoreAction)}),
            SKAction.runBlock({scoreLabelA[1].runAction(scoreAction)})])
        runAction(Sgroup)
        
        while scoreTmp < score {
            scoreLabelA[0].text = "Score: \(score)"
            scoreLabelA[1].text = "Score: \(score)"
            
            var adjustX: CGFloat = 0
            if scoreTmp >= 10 { adjustX = 10 }
            if scoreTmp >= 100 { adjustX = 20 }
            let grow = SKAction.scaleBy(1.05, duration: 0.15)
            let adjust = SKAction.runBlock({
                scoreLabelA[0].position.x = self.size.width/2 - adjustX
                scoreLabelA[1].position.x = self.size.width/2 + 2 - adjustX
            })
            let shrink = grow.reversedAction()
            let scoreAction = SKAction.sequence([grow, adjust, shrink])
            
            let groupScore = SKAction.group([SKAction.runBlock({scoreLabelA[0].runAction(scoreAction)}),
                SKAction.runBlock({scoreLabelA[1].runAction(scoreAction)})])
            SKAction.sequence([groupScore, SKAction.waitForDuration(0.2)])
            scoreTmp++
        }
        
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
    * UPDATE GROUP AMOUNT
    * Based on algorithm in getNewGroupAmount, calls this function
    * to adjust speeds and difficult level
    *********************************************************************************************************/
    
    var timesthisFuncCalled: Int = 0
    var repeat: Int = 10
    func updateGroupAmount() {
        if timesthisFuncCalled == repeat {
            timesthisFuncCalled = 0
            switch diffLevel {
            case V_EASY: repeat = 10
                groupAmtMin = 2
                groupAmtMax = 3
                break
            case EASY: repeat = 10
                groupAmtMin = (groupAmtMin*2 - 1)
                groupAmtMax = (groupAmtMin*2 - 1)
                break
            case MED: repeat = 10
                groupAmtMin = (groupAmtMin*2 - 1)
                groupAmtMax = (groupAmtMin*2 - 1)
                break
            case HARD: repeat = 7
                groupAmtMin = (groupAmtMin*2 - 1)
                groupAmtMax = (groupAmtMin*2 - 1)
                break
            case V_HARD: repeat = 5
                groupAmtMin = (groupAmtMin*2 - 1)
                groupAmtMax = (groupAmtMin*2 - 1)
                break
            default: repeat = 1
                groupAmtMin = (groupAmtMin*2 - 1)
                groupAmtMax = (groupAmtMin*2 - 1)
            }
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
        var linesToDrop: Int
        if (totalLinesDropped == 0) {
            linesToDrop = 1
        }
        else {
            updateGroupAmount()
            linesToDrop = randomInt(groupAmtMin, groupAmtMax)
        }
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
    
    //CHANGE - subtract only if joey is dropped
    func changeJoeyCount() {
        joeyCount--
        joeyCountLabel.text = "Joeys: \(joeyCount)"
        joeyCountLabelS.text = "Joeys: \(joeyCount)"
        
        var adjustX: CGFloat = 20
        if joeyCount >= 100 { adjustX = 0 }
        if score >= 10 { adjustX = 10 }
        
        let grow = SKAction.scaleBy(1.05, duration: 0.15)
        let adjust = SKAction.runBlock({
            self.joeyCountLabel.position.x = self.joeyCountX - adjustX
            self.joeyCountLabelS.position.x = self.joeyCountX + 2 - adjustX
        })
        let shrink = grow.reversedAction()
        let scoreAction = SKAction.sequence([grow, adjust, shrink])
        
        let groupScore = SKAction.group([SKAction.runBlock({self.joeyCountLabel.runAction(scoreAction)}),
            SKAction.runBlock({self.joeyCountLabelS.runAction(scoreAction)})])
        runAction(groupScore)
        
        if (joeyCount == 0) { gameState = .GameOver }
        
    }
    
    /*********************** Drop Group Helper Functions ******************************/
    
    /*
    * Drops random line chosen from pickRandomLine() by making
    * three simultaneous calls to spawnDroplet
    */
    func dropRandomLine() {
        if(dropLines) {
            println("drop")
            let chosenLine = pickRandomLine()
        
            let dropLeft = SKAction.runBlock({self.spawnDroplet(1, type: chosenLine[0])})
            let dropMiddle = SKAction.runBlock({self.spawnDroplet(2, type: chosenLine[1])})
            let dropRight = SKAction.runBlock({self.spawnDroplet(3, type: chosenLine[2])})
        
            let dropLine = SKAction.group([dropLeft, dropMiddle, dropRight])
            runAction(dropLine)
            //runAction(dropLineSound) whistle down
        
            totalLinesDropped++
        }
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
                changeJoeyCount()
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
        if rightTouch && (kangPos != 1) {
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
    
    func sceneTouched(touchLocation:CGPoint) {
        switch gameState {
        case .GameOver:
            if (restartTapWait) { restartTap = true }
            break
        case .GameRunning:
            if (pauseRect.contains(touchLocation)) {
                dropLines = false
                gameState = .Paused
            }
            else {
                switch controlSettings {
                case .TwoThumbs:
                    if leftRect.contains(touchLocation) {
                        leftTouch = true
                        rightTouch = false
                    }
                    if rightRect.contains(touchLocation) {
                        rightTouch = true
                        leftTouch = false
                    }
                    break
                case .Thumb:
                    if touchLocation.x < oneThirdX {
                        leftTouch = true
                        rightTouch = false
                    }
                    if touchLocation.x > twoThirdX {
                        rightTouch = true
                        leftTouch = false
                    }
                    break
                }
            }
            break
        case .Paused:
            unpauseGame = true
            break
        }
    }
    
    func sceneUntouched(touchLocation:CGPoint) {
        if (controlSettings == .TwoThumbs) {
            let leftEndTouch = leftRect.contains(touchLocation)
            let rightEndTouch = rightRect.contains(touchLocation)
        
            if leftEndTouch || (numFingers == 0) {
                leftTouch = false
            }
            if rightEndTouch || (numFingers == 0) {
                rightTouch = false
            }
        }
        if (controlSettings == .Thumb) {
            if numFingers == 0 {
                leftTouch = false
                rightTouch = false
            }
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
        sceneTouched(touchLocation)
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let touchLocation = touch.locationInNode(self)
        trackThumb(touchLocation)
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let touchLocation = touch.locationInNode(self)
        numFingers -= touches.count
        sceneUntouched(touchLocation)
       
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
        
        //keep track of missed eggs
        
    }
    
    func kangarooCaughtBoomer(boomer: SKSpriteNode) {
        //runAction(enemyCollisionSound) ouch!
        // make kangaroo frown
        
        let shakeLeft = SKAction.moveByX(-10.0, y: 0.0, duration: 0.05)
        let shakeRight = SKAction.moveByX(20.0, y: 0.0, duration: 0.1)
        let shakeOff = SKAction.sequence([shakeLeft, shakeRight, shakeLeft])
        kangaroo.runAction(shakeOff)
        
        boomer.removeAllActions()
        boomer.runAction(SKAction.removeFromParent())
        
        //boomer catch = -2 score
        score -= 2

        
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
        
        /*let catchZone = drawRectangle(catchZoneRect, SKColor.blueColor(), 6.0)
        catchZone.zPosition = 2
        addChild(catchZone)*/
        
        //let fadeZone = drawRectangle(fadeZoneRect, SKColor.whiteColor(), 6.0)
        //addChild(fadeZone)
        
        /*let testRect = CGRect(x: 300, y: 300, width: 300, height: 300)
        let test = getRoundedRectShape(rect: testRect, cornerRadius: 16, color: SKColor.blackColor(), lineWidth: 5)
        test.zPosition = 10
        addChild(test)*/
        
        let pauseRect = drawRectangle(CGRect(x: pauseX, y: pauseY, width: 60, height: 60), SKColor.blackColor(), 6.0)
        pauseRect.zPosition = 3
        addChild(pauseRect)
        
        
    }
    
}
