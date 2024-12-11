import UIKit

protocol ConfettiAreaDelegate: AnyObject {
  func colorsForConfettiArea(_ confettiArea: ConfettiArea) -> [UIColor]
}

class ConfettiArea: UIView {
  weak var delegate: ConfettiAreaDelegate?
  var swayLength: CGFloat = 50.0
  var blastSpread: CGFloat = 0.1
  
  private var confettiObjectsCache: Set<ConfettiObject> = []
  private var animator: UIDynamicAnimator!
  private var gravityBehavior: UIGravityBehavior!
  private var colors: [UIColor] = []
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    commonInit()
  }
  
  private func commonInit() {
    animator = UIDynamicAnimator(referenceView: self)
    gravityBehavior = UIGravityBehavior()
    gravityBehavior.magnitude = 0.5
    animator.addBehavior(gravityBehavior)
  }
  
  private func setupDataFromDelegates() {
    if let colors = delegate?.colorsForConfettiArea(self) {
      self.colors = colors
    } else {
      self.colors = [.red, .blue, .green, .orange, .purple, .magenta, .cyan]
    }
  }
  
  func burstAt(_ point: CGPoint, confettiWidth: CGFloat, numberOfConfetti: Int) {
    setupDataFromDelegates()
    
    for _ in 0..<numberOfConfetti {
      let randomWidth = confettiWidth + self.randomFloat(between: -(confettiWidth / 2.0), and: 2.0)
      let confettiFrame = CGRect(
        x: point.x,
        y: point.y,
        width: randomWidth,
        height: randomWidth
      )
      
      // Create UI elements on main thread
      let confettiView = ConfettiView(
        frame: confettiFrame,
        flutterSpeed: self.randomFloat(between: 1.0, and: 5.0),
        flutterType: ConfettiFlutterType(rawValue: Int.random(in: 0..<ConfettiFlutterType.count.rawValue)) ?? .diagonal1
      )
      
      let color = self.colors[Int.random(in: 0..<self.colors.count)]
      confettiView.backgroundColor = color
      
      let confettiObject = ConfettiObject(
        confettiView: confettiView,
        keepWithinBounds: self.bounds,
        animator: self.animator,
        gravity: self.gravityBehavior
      )
      
      // Configure physics
      confettiObject.linearVelocity = CGPoint(
        x: self.randomFloat(between: -200.0, and: 200.0),
        y: self.randomFloat(between: -100.0, and: -400.0)
      )
      confettiObject.density = self.randomFloat(between: 0.2, and: 1.0)
      confettiObject.swayLength = self.randomFloat(between: 0.0, and: self.swayLength)
      confettiObject.delegate = self
      
      self.confettiObjectsCache.insert(confettiObject)
      
      // Add to view hierarchy and start animations on main thread
      self.addSubview(confettiView)
      self.animator.addBehavior(confettiObject.fallingBehavior)
      self.gravityBehavior.addItem(confettiView)
    }
  }
}

// Add this extension to ConfettiArea
extension ConfettiArea: @preconcurrency ConfettiObjectDelegate {
  func needToDeallocateConfettiObject(_ confettiObject: ConfettiObject) {
    confettiObjectsCache.remove(confettiObject)
  }
}

// Add these helper methods to ConfettiArea class
extension ConfettiArea {
  private func randomFloat(between smallNumber: CGFloat, and bigNumber: CGFloat) -> CGFloat {
    let diff = bigNumber - smallNumber
    return (CGFloat(arc4random()) / CGFloat(UInt32.max)) * diff + smallNumber
  }
  
  private func randomInteger(from: Int, to: Int) -> Int {
    if from == to {
      return from
    }
    return from + Int(arc4random_uniform(UInt32(to - from)))
  }
}
