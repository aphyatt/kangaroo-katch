//
//  MyUtils.swift
//  ZombieConga
//
//  Created by Main Account on 10/22/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

import Foundation
import CoreGraphics
import SpriteKit


func + (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func += (inout left: CGPoint, right: CGPoint) {
  left = left + right
}

func += (inout left: String?, right: String?) {
    left! = left! + right!
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func -= (inout left: CGPoint, right: CGPoint) {
  left = left - right
}

func * (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x * right.x, y: left.y * right.y)
}

func *= (inout left: CGPoint, right: CGPoint) {
  left = left * right
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func *= (inout point: CGPoint, scalar: CGFloat) {
  point = point * scalar
}

func / (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x / right.x, y: left.y / right.y)
}

func /= (inout left: CGPoint, right: CGPoint) {
  left = left / right
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

func /= (inout point: CGPoint, scalar: CGFloat) {
  point = point / scalar
}

#if !(arch(x86_64) || arch(arm64))
func atan2(y: CGFloat, x: CGFloat) -> CGFloat {
  return CGFloat(atan2f(Float(y), Float(x)))
}

func sqrt(a: CGFloat) -> CGFloat {
  return CGFloat(sqrtf(Float(a)))
}
#endif

extension CGPoint {
  
  func length() -> CGFloat {
    return sqrt(x*x + y*y)
  }
  
  func normalized() -> CGPoint {
    return self / length()
  }
  
  var angle: CGFloat {
    return atan2(y, x)
  }
}

let π = CGFloat(M_PI)

func shortestAngleBetween(angle1: CGFloat, 
                          angle2: CGFloat) -> CGFloat {
  let twoπ = π * 2.0
  var angle = (angle2 - angle1) % twoπ
  if (angle >= π) {
    angle = angle - twoπ
  }
  if (angle <= -π) {
    angle = angle + twoπ
  }
  return angle
}

extension CGFloat {
  func sign() -> CGFloat {
    return (self >= 0.0) ? 1.0 : -1.0
  }
}

extension CGFloat {
  static func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / Float(UInt32.max))
  }

  static func random(#min: CGFloat, max: CGFloat) -> CGFloat {
    assert(min < max)
    return CGFloat.random() * (max - min) + min
  }
}

func randomInt(min: Int, max: Int) -> Int {
    assert(min <= max)
    return (min + Int(arc4random_uniform(UInt32((max - min) + 1))))
}

func delay(seconds: Double, completion:()->()) {
    let delay = seconds * Double(NSEC_PER_SEC)
    var dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
    
    dispatch_after(dispatchTime, dispatch_get_main_queue(), {
        completion
    })
}

func drawRectangle(rect: CGRect, color: UIColor, width: CGFloat) -> SKShapeNode {
    let shape = SKShapeNode()
    let path = CGPathCreateMutable()
    CGPathAddRect(path, nil, rect)
    shape.path = path
    shape.strokeColor = color
    shape.lineWidth = width
    return shape
}

func getRoundedRectShape(#rect: CGRect, #cornerRadius: CGFloat, #color: UIColor, #lineWidth: CGFloat) -> SKShapeNode {
    let p: CGMutablePathRef = CGPathCreateMutable()
    
    CGPathMoveToPoint(p, nil, rect.origin.x + cornerRadius, rect.origin.y)
    
    let maxX: CGFloat = CGRectGetMaxX(rect)
    let maxY: CGFloat = CGRectGetMaxY(rect)
    
    CGPathAddArcToPoint(p, nil, maxX, rect.origin.y, maxX, rect.origin.y + cornerRadius, cornerRadius)
    CGPathAddArcToPoint(p, nil, maxX, maxY, maxX - cornerRadius, maxY, cornerRadius)
    
    CGPathAddArcToPoint(p, nil, rect.origin.x, maxY, rect.origin.x, maxY - cornerRadius, cornerRadius ) ;
    CGPathAddArcToPoint(p, nil, rect.origin.x, rect.origin.y, rect.origin.x + cornerRadius, rect.origin.y, cornerRadius)
    
    let shape = SKShapeNode()
    shape.path = p
    shape.strokeColor = color
    shape.lineWidth = lineWidth
    return shape
}

func createShadowLabel(#font: String, #text: String, #fontSize: CGFloat, #horAlignMode: SKLabelHorizontalAlignmentMode,
    #vertAlignMode: SKLabelVerticalAlignmentMode, #labelColor: UIColor, #shadowColor: UIColor, #name: String,
    #positon: CGPoint, #shadowZPos: CGFloat, #shadowOffset: CGFloat) -> [SKLabelNode] {
        var labelArray: [SKLabelNode] = []
        
        let label = SKLabelNode(fontNamed: font)
        label.text = text
        label.fontSize = fontSize
        label.horizontalAlignmentMode = horAlignMode
        label.verticalAlignmentMode = vertAlignMode
        label.fontColor = labelColor
        label.position = positon
        label.zPosition = shadowZPos + 1
        label.name = name
        labelArray.append(label)
        
        let labelS = SKLabelNode(fontNamed: font)
        labelS.text = text
        labelS.fontSize = fontSize
        labelS.horizontalAlignmentMode = horAlignMode
        labelS.verticalAlignmentMode = vertAlignMode
        labelS.fontColor = shadowColor
        labelS.position = CGPoint(x: positon.x+2, y: positon.y-shadowOffset)
        labelS.zPosition = shadowZPos
        labelS.name = name + "S"
        labelArray.append(labelS)
        
        return labelArray
}











