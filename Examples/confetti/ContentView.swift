import SwiftUI
import Confetti

struct ContentView: View {
  var body: some View {
    VStack {
      Button("Woohoo! 🎉") {
        Confetti.shared.burstFromCenter()
      }
    }
    .confetti()
  }
}

#Preview {
  ContentView()
}
