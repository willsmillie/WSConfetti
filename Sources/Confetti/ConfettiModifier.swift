import SwiftUI
import UIKit

public struct Confetti: ViewModifier {
  public static let shared = Confetti()

  static var confettiArea: ConfettiArea?
  let colors: [UIColor]
  
  init(colors: [UIColor] = [.red, .blue, .green, .orange, .purple, .magenta, .cyan]) {
    self.colors = colors
  }
  
  public func body(content: Content) -> some View {
    GeometryReader { geometry in
      content
        .overlay(
          ConfettiAreaRepresentable(
            frame: geometry.frame(in: .global),
            colors: colors
          )
          .allowsHitTesting(false)
          .edgesIgnoringSafeArea(.all)
        )
    }
  }
  
  public func burst(at point: CGPoint, width: CGFloat = 10, count: Int = 20) {
    if let area = Self.confettiArea {
      area.burstAt(point, confettiWidth: width, numberOfConfetti: count)
    }
  }
  
  public func burstFromTop(count: Int = 20) {
    guard let bounds = Self.confettiArea?.bounds else { return }
    let point = CGPoint(x: bounds.width / 2, y: 100)
    burst(at: point, count: count)
  }
  
  public func burstFromCenter(count: Int = 20) {
    guard let bounds = Self.confettiArea?.bounds else {
      return
    }
    let point = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
    burst(at: point, count: count)
  }
}

// UIViewRepresentable wrapper for ConfettiArea
struct ConfettiAreaRepresentable: UIViewRepresentable {
  let frame: CGRect
  let colors: [UIColor]
  
  init(frame: CGRect, colors: [UIColor]) {
    self.frame = frame
    self.colors = colors
  }
  
  func makeUIView(context: Context) -> UIView {
    let area = ConfettiArea(frame: frame)
    area.delegate = context.coordinator
    DispatchQueue.main.async {
      Confetti.confettiArea = area
    }
    return area
  }
  
  func updateUIView(_ uiView: UIView, context: Context) {
    uiView.frame = frame
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(colors: colors)
  }
  
  class Coordinator: NSObject, ConfettiAreaDelegate {
    let colors: [UIColor]
    
    init(colors: [UIColor]) {
      self.colors = colors
    }
    
    func colorsForConfettiArea(_ confettiArea: ConfettiArea) -> [UIColor] {
      return colors
    }
  }
}

extension View {
  public func confetti(colors: [UIColor] = [.red, .blue, .green, .orange, .purple, .magenta, .cyan]) -> some View {
    modifier(Confetti.shared)
  }
}
