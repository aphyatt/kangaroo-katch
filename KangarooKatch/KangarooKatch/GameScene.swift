//
//  GameScene.swift
//  KangarooKatch
//
//  Created by ADAM HYATT on 7/8/15.
//  Copyright (c) 2015 ADAM HYATT. All rights reserved.
//

import SpriteKit

enum GameState {
    case GameRunning
    case GameOver
}

class GameScene: SKScene {
    /* NOTES:
    * TODO check collisions (for boomerangs)
    * Instead of physically moving kangaroo, run animation of it holding out pouch
    * Add animations to falling objects / kangaroo to beef up game
    * Score
    * Other screens: selection, highscore, tutorial
    * See how low timeBetweenLines can be set without lag, otherwise increase gravity
    */
    //let dropletLayerNode = SKNode()
    //let livesLayerNode = SKNode()

    let kangaroo = SKSpriteNode(imageNamed: "Kangaroo")
    let fullRect: CGRect
    let sceneRect: CGRect
    let dropletRect: CGRect
    let leftRect: CGRect
    let rightRect: CGRect
    let catchZoneRect: CGRect
    let fadeZoneRect: CGRect
    let playableMargin: CGFloat
    let horAlignModeDefault: SKLabelHorizontalAlignmentMode = .Center
    let vertAlignModeDefault: SKLabelVerticalAlignmentMode = .Baseline
    
    let dropletCatchBoundaryY: CGFloat = 330
    let dropletFadeBoundaryY: CGFloat = 100
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
    
    //Variables dealing with touches (UI)
    var leftTouch: Bool = false
    var rightTouch: Bool = false
    var moveToCenterCol: Bool = false
    var kangMoveLeft: SKAction
    var kangMoveRight: SKAction
    var kangMove2Left: SKAction
    var kangMove2Right: SKAction
    var kangPos: Int = 2
    var kangPosX: CGFloat = 0
    var numFingers: Int = 0
    
    //Score and Lives
    var score: Int = 0
    var dropsLeft: Int = 10
    var livesLeft: Int = 3
    let scoreLabelY: CGFloat = 125
    let livesLabelY: CGFloat = 80
    let dropsLabelY: CGFloat = 40
    var livesDropsX: CGFloat = 165
    var joeyLifeStartX: CGFloat
    var boomerangLifeStartX: CGFloat
    var scoreLabel : SKLabelNode!
    var scoreLabelS : SKLabelNode!
    
    //Gameover vars
    var restartTap: Bool = false
    var restartTapWait: Bool = false
    var gameState = GameState.GameRunning
    let gameOverLabel = SKLabelNode(fontNamed: "Soup of Justice")
    let gameOverLabelS = SKLabelNode(fontNamed: "Soup of Justice")
    
    //Difficulty variables
    var diffLevel: Int = 0
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
        //debugDrawPlayableArea()
    }
    
    override init(size: CGSize) {
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
        
        //these will eventually be animations, not actual movements
        kangMoveLeft = SKAction.moveByX(-dropletRect.width/3.5, y: 0, duration: 0.1)
        kangMoveRight = kangMoveLeft.reversedAction()
        kangMove2Left = SKAction.moveByX(2*(-dropletRect.width/3.5), y: 0, duration: 0.1)
        kangMove2Right = kangMove2Left.reversedAction()
        
        leftColX = (size.width/2) - (dropletRect.width/3.5)
        midColX = size.width/2
        rightColX = (size.width/2) + (dropletRect.width/3.5)
        
        joeyLifeStartX = livesDropsX + 130
        boomerangLifeStartX = livesDropsX + 145
        
        super.init(size: size)
        
        setupScene()
        setupLives()
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
        
        livesDropsX = 165 + playableMargin
        
        let livesLabel: [SKLabelNode] = createShadowLabel("Soup of Justice", "Lives: ", 40, .Right, vertAlignModeDefault, SKColor.blackColor(), SKColor.whiteColor(), "livesLabel", CGPoint(x: livesDropsX, y: livesLabelY), 4)
        addChild(livesLabel[0])
        addChild(livesLabel[1])
      
        let dropsLabel: [SKLabelNode] = createShadowLabel("Soup of Justice", "Drops: ", 40, .Right, vertAlignModeDefault, SKColor.blackColor(), SKColor.whiteColor(), "dropsLabel", CGPoint(x: livesDropsX, y: dropsLabelY), 4)
        addChild(dropsLabel[0])
        addChild(dropsLabel[1])
        
        let scoreLabelA: [SKLabelNode] = createShadowLabel("Soup of Justice", "Score: \(score)", 40, horAlignModeDefault, .Baseline, SKColor.blackColor(), SKColor.whiteColor(), "scoreLabel", CGPoint(x: size.width/2, y: scoreLabelY), 4)
        scoreLabel = scoreLabelA[0]
        scoreLabelS = scoreLabelA[1]
        addChild(scoreLabel)
        addChild(scoreLabelS)
        
    }
    
    func setupLives() {
        for i in 0...9 {
            let node = SKSpriteNode(imageNamed: "Egg")
            let nodeS = SKSpriteNode(imageNamed: "Egg")
            
            node.position.x = joeyLifeStartX + CGFloat(i)*35
            node.position.y = dropsLabelY+12
            node.setScale(0.05)
            node.zPosition = 5
            node.name = "drop\(i+1)"
            
            nodeS.position = node.position
            nodeS.setScale(0.05)
            nodeS.zPosition = 4
            nodeS.alpha = 0.5
            
            addChild(node)
            addChild(nodeS)
        }
        
        for i in 0...2 {
            let node = SKSpriteNode(imageNamed: "Boomerang")
            let nodeS = SKSpriteNode(imageNamed: "Boomerang")
            
            node.position.x = boomerangLifeStartX + CGFloat(i)*75
            node.position.y = livesLabelY+12
            node.setScale(0.1)
            node.zPosition = 5
            node.name = "life\(i+1)"
            
            nodeS.position = node.position
            nodeS.setScale(0.1)
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
        setupLives()
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
        gameOverLabel.text = "GAME OVER"
        gameOverLabel.fontSize = 70
        gameOverLabel.verticalAlignmentMode = .Baseline
        gameOverLabel.fontColor = SKColor.blackColor()
        gameOverLabel.position = CGPoint(x: size.width/2, y: 800)
        gameOverLabel.zPosition = 8
        gameOverLabel.alpha = 0.0
        addChild(gameOverLabel)
        
        gameOverLabelS.text = "GAME OVER"
        gameOverLabelS.fontSize = 70
        gameOverLabelS.verticalAlignmentMode = .Baseline
        gameOverLabelS.fontColor = SKColor.whiteColor()
        gameOverLabelS.position = CGPoint(x: size.width/2, y: 800-2)
        gameOverLabelS.zPosition = 7
        gameOverLabelS.alpha = 0.0
        addChild(gameOverLabelS)
        
        //fade in GAME OVER
        let wait = SKAction.waitForDuration(0.5)
        let fadeIn = SKAction.fadeAlphaTo(1.0, duration: 2.0)
        let gameOverAction = SKAction.sequence([wait, fadeIn])
        let GOgroup = SKAction.group([SKAction.runBlock({self.gameOverLabel.runAction(gameOverAction)}),
            SKAction.runBlock({self.gameOverLabelS.runAction(gameOverAction)})])
        runAction(GOgroup)
        
        //have score rise and grow under GAME OVER
        let wait2 = SKAction.waitForDuration(3.0)
        let bringToFront = SKAction.runBlock({self.scoreLabel.zPosition = 8; self.scoreLabelS.zPosition = 7})
        let rise = SKAction.moveByX(0.0, y: 600, duration: 1.0)
        let grow = SKAction.scaleBy(1.5, duration: 1.0)
        let scoreAction = SKAction.sequence([wait2, bringToFront, SKAction.group([rise, grow])])
        let scoreGroup = SKAction.group([SKAction.runBlock({self.scoreLabel.runAction(scoreAction)}),
            SKAction.runBlock({self.scoreLabelS.runAction(scoreAction)})])
        runAction(scoreGroup)
        
        //tap anywhere to restart
        let tapRestartLabel = SKLabelNode(fontNamed: "Soup of Justice")
        let tapRestartLabelS = SKLabelNode(fontNamed: "Soup of Justice")
        
        tapRestartLabel.text = "TAP ANYWHERE TO RESTART"
        tapRestartLabel.fontSize = 20
        tapRestartLabel.verticalAlignmentMode = .Baseline
        tapRestartLabel.fontColor = SKColor.blackColor()
        tapRestartLabel.position = CGPoint(x: size.width/2, y: 650)
        tapRestartLabel.zPosition = 8
        tapRestartLabel.alpha = 0.0
        addChild(tapRestartLabel)
        
        tapRestartLabelS.text = "TAP ANYWHERE TO RESTART"
        tapRestartLabelS.fontSize = 20
        tapRestartLabelS.verticalAlignmentMode = .Baseline
        tapRestartLabelS.fontColor = SKColor.whiteColor()
        tapRestartLabelS.position = CGPoint(x: size.width/2, y: 650-2)
        tapRestartLabelS.zPosition = 7
        tapRestartLabelS.alpha = 0.0
        addChild(tapRestartLabelS)
        
        let wait3 = SKAction.waitForDuration(5.0)
        let fadeIn2 = SKAction.fadeAlphaTo(1.0, duration: 0.8)
        let fadeOut = SKAction.fadeAlphaTo(0.0, duration: 0.8)
        let blink = SKAction.sequence([fadeIn2, fadeOut])
        let labelsBlink = SKAction.group([SKAction.runBlock({tapRestartLabel.runAction(SKAction.repeatActionForever(blink))}),
            SKAction.runBlock({tapRestartLabelS.runAction(SKAction.repeatActionForever(blink))})])
        let tapAction = SKAction.sequence([wait3, labelsBlink])
        runAction(tapAction)
       
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
    func getNewGroupAmount() -> Int {
        if totalLinesDropped == 0 { return 1 }
        
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
        
        return randomInt(groupAmtMin, groupAmtMax)
        
    }
    
    /**********************************************************************************************************
    * DROP NEW GROUP
    * Function drops new group, calls:
    * dropRandomLine: gets random line and drops
    * then groups a determined amount of these into one action
    ***********************************************************************************************************/
    func dropNewGroup() {
        //if true, drop a new group of lines
        let linesToDrop = getNewGroupAmount()
        let waitBeforeGroup = totalLinesDropped == 0 ?
            0.0 : NSTimeInterval(CGFloat.random(min: groupWaitTimeMin, max: groupWaitTimeMax))
        
        let groupSequence = SKAction.sequence([SKAction.runBlock(dropRandomLine), SKAction.waitForDuration(timeBetweenLines)])
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
            droplet.zPosition = 2
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
        if leftTouch {
            kangaroo.runAction(SKAction.moveToX(leftColX, duration: 0.1))
            kangPos = 1
        }
        if rightTouch {
            kangaroo.runAction(SKAction.moveToX(rightColX, duration: 0.1))
            kangPos = 3
        }
        if (!leftTouch && !rightTouch) || numFingers == 0 {
            kangaroo.runAction(SKAction.moveToX(midColX, duration: 0.1))
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
    
    func sceneUntouched(touchLocation:CGPoint) {
        let leftEndTouch = leftRect.contains(touchLocation)
        let rightEndTouch = rightRect.contains(touchLocation)
        
        if leftEndTouch || (numFingers == 0) {
            leftTouch = false
        }
        if rightEndTouch || (numFingers == 0) {
            rightTouch = false
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let touchLocation = touch.locationInNode(self)
        numFingers += touches.count
        sceneTouched(touchLocation)
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
        scoreLabel.text = "Score: \(score)"
        scoreLabelS.text = "Score: \(score)"
        scoreLabel.position.x = size.width/2
        scoreLabelS.position.x = size.width/2
        
        let grow = SKAction.scaleBy(1.2, duration: 0.1)
        let shrink = grow.reversedAction()
        let scoreAction = SKAction.sequence([grow, shrink])
        
        let groupScore = SKAction.group([SKAction.runBlock({self.scoreLabel.runAction(scoreAction)}),
            SKAction.runBlock({self.scoreLabelS.runAction(scoreAction)})])
        runAction(groupScore)
        
    }
    
    func kangarooMissedJoey(joey: SKSpriteNode) {
        //runAction(missedJoeySound) aaahh

        //make fade rect like catchzone, in checkcollision if missed hits fadezone, then stop and fade
        let fade = SKAction.fadeAlphaTo(0.3, duration: 0.1)
        joey.runAction(fade)
        
        if dropsLeft > 0 {
        let dropLife = childNodeWithName("drop\(dropsLeft)")
        dropLife!.removeFromParent()
        dropsLeft--
        if(dropsLeft == 0) {
            gameState = .GameOver
        }
        }

    }
    
    func stopAndFadeJoey(joey: SKSpriteNode) {
        joey.removeFromParent()
        joey.removeAllActions()
        joey.physicsBody = nil
        joey.zRotation = 0
        joey.alpha = 0.3
        //change joey to have frown?
        addChild(joey)
        
        let fade = SKAction.fadeAlphaTo(0.0, duration: 0.5)
        let remove = SKAction.runBlock({joey.removeFromParent()})
        let sequence = SKAction.sequence([fade, remove])
        joey.runAction(sequence)
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
        
        if livesLeft > 0 {
            let life = childNodeWithName("life\(livesLeft)")
            life!.removeFromParent()
            livesLeft--
            if(livesLeft == 0) {
                gameState = .GameOver
            }
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
        
        /*let catchZone = drawRectangle(catchZoneRect, SKColor.blueColor(), 6.0)
        catchZone.zPosition = 2
        addChild(catchZone)*/
        
        //let fadeZone = drawRectangle(fadeZoneRect, SKColor.whiteColor(), 6.0)
        //addChild(fadeZone)
        
        
    }
    
}
