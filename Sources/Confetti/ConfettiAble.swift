import UIKit

protocol ConfettiAble {
  init(startingPoint: CGPoint,
       confettiColor: UIColor?, 
       flutterSpeed: CGFloat, 
       flutterType: ConfettiFlutterType)
} 
