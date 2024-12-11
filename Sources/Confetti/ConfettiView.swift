import UIKit

class ConfettiView: UIView {
  private var flutterSpeed: CGFloat
  private var flutterType: ConfettiFlutterType
  private var animationAdded: Bool = false

  init(frame: CGRect, flutterSpeed: CGFloat, flutterType: ConfettiFlutterType) {
    self.flutterSpeed = flutterSpeed
    self.flutterType = flutterType
    super.init(frame: frame)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func didMoveToSuperview() {
    super.didMoveToSuperview()

    if animationAdded {
      return
    }

    animationAdded = true

    let rotationAnimation = CABasicAnimation(keyPath: "transform")
    rotationAnimation.duration = 1.0 / flutterSpeed
    rotationAnimation.repeatCount = 500

    var rotationTransform: CATransform3D

    switch flutterType {
    case .diagonal1:
      rotationTransform = CATransform3DMakeRotation(.pi, -1.0, 1.0, 0.0)
    case .diagonal2:
      rotationTransform = CATransform3DMakeRotation(.pi, 1.0, 1.0, 0.0)
    case .vertical:
      rotationTransform = CATransform3DMakeRotation(.pi, 0.0, 1.0, 0.0)
    case .horizontal:
      rotationTransform = CATransform3DMakeRotation(.pi, 1.0, 0.0, 0.0)
    case .count:
      rotationTransform = CATransform3DMakeRotation(.pi, -1.0, 1.0, 0.0)
    }

    rotationAnimation.toValue = NSValue(caTransform3D: rotationTransform)
    layer.add(rotationAnimation, forKey: "ConfettiRotationAnimation")
  }
}
