import UIKit

protocol ConfettiObjectDelegate: AnyObject {
  func needToDeallocateConfettiObject(_ confettiObject: ConfettiObject)
}

@MainActor
class ConfettiObject: NSObject {
  private enum SwayType {
    case none
    case left
    case right
  }
  
  weak var delegate: ConfettiObjectDelegate?
  var linearVelocity: CGPoint = .zero
  var swayLength: CGFloat = 0.0
  var density: CGFloat = 1.0
  
  private var confettiView: UIView
  private var confettiAreaBounds: CGRect
  private weak var animator: UIDynamicAnimator?
  private weak var gravityBehavior: UIGravityBehavior?
  private var _fallingBehavior: UIDynamicItemBehavior?
  private var swayType: SwayType = .none
  private var swayFocalPointX: CGFloat = 0.0
  
  init(confettiView: UIView, keepWithinBounds bounds: CGRect, animator: UIDynamicAnimator, gravity: UIGravityBehavior) {
    self.confettiView = confettiView
    self.confettiAreaBounds = bounds
    self.animator = animator
    self.gravityBehavior = gravity
    super.init()
  }
  
  
  var fallingBehavior: UIDynamicItemBehavior {
    if let existing = _fallingBehavior {
      return existing
    }
    
    let behavior = UIDynamicItemBehavior(items: [confettiView])
    behavior.addLinearVelocity(linearVelocity, for: confettiView)
    
    behavior.action = { [weak self, weak behavior] in
      guard let self = self, let behavior = behavior else { return }
      
      let linearVelocity = behavior.linearVelocity(for: self.confettiView)
      if linearVelocity.y > 50.0 {
        self.handleSway()
        
        behavior.resistance = linearVelocity.y / (self.gravityBehavior?.magnitude ?? 1.0) / self.density / 100.0
      }
      
      if self.confettiView.center.y > self.confettiAreaBounds.height {
        self.cleanupObject()
      }
    }
    
    _fallingBehavior = behavior
    return behavior
  }
  
  private func handleSway() {
    switch swayType {
    case .none:
      swayFocalPointX = confettiView.center.x
      swayType = Bool.random() ? .left : .right
      
    case .left:
      _fallingBehavior?.addLinearVelocity(CGPoint(x: -10.0, y: 0.0), for: confettiView)
      
      if confettiView.center.x < (swayFocalPointX - (swayLength / 2.0)) {
        swayType = .right
      }
      
    case .right:
      _fallingBehavior?.addLinearVelocity(CGPoint(x: 10.0, y: 0.0), for: confettiView)
      
      if confettiView.center.x > (swayFocalPointX + (swayLength / 2.0)) {
        swayType = .left
      }
    }
  }
  
  private func cleanupObject() {
    _fallingBehavior?.removeItem(confettiView)
    _fallingBehavior?.action = nil
    
    if let _fallingBehavior = _fallingBehavior {
      animator?.removeBehavior(_fallingBehavior)
    }
    gravityBehavior?.removeItem(confettiView)
    
    confettiView.removeFromSuperview()
    
    _fallingBehavior = nil
    delegate?.needToDeallocateConfettiObject(self)
  }
}
