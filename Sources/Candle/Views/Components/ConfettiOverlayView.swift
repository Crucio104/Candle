import SwiftUI
import Combine

public struct ConfettiParticle: Identifiable {
    public let id = UUID()
    public var x: CGFloat
    public var y: CGFloat
    public var size: CGFloat
    public var color: Color
    public var rotation: Double
    public var opacity: Double
    public var speedY: CGFloat
    public var speedX: CGFloat
}

public struct ConfettiOverlayView: View {
    @Binding var isActive: Bool
    @State private var particles: [ConfettiParticle] = []
    @State private var timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    
    private let colors: [Color] = [
        Color(red: 0.98, green: 0.62, blue: 0.26), // Gold / Amber
        Color(red: 0.99, green: 0.44, blue: 0.35), // Coral
        Color(red: 0.92, green: 0.24, blue: 0.36), // Pink
        Color(red: 0.62, green: 0.36, blue: 0.94), // Purple
        Color(red: 0.22, green: 0.52, blue: 0.96), // Blue
        Color(red: 0.16, green: 0.74, blue: 0.52), // Green
        Color.yellow
    ]
    
    public init(isActive: Binding<Bool>) {
        self._isActive = isActive
    }
    
    public var body: some View {
        GeometryReader { geo in
            ZStack {
                if isActive {
                    ForEach(particles) { p in
                        Rectangle()
                            .fill(p.color)
                            .frame(width: p.size, height: p.size * 0.6)
                            .rotationEffect(.degrees(p.rotation))
                            .opacity(p.opacity)
                            .position(x: p.x, y: p.y)
                    }
                }
            }
            .onReceive(timer) { _ in
                guard isActive else { return }
                updateParticles(in: geo.size)
            }
            .onChange(of: isActive) { _, active in
                if active {
                    spawnParticles(in: geo.size)
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    
                    // Automatically deactivate after 3.5 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                        withAnimation(.easeOut(duration: 0.8)) {
                            isActive = false
                            particles = []
                        }
                    }
                }
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
    
    private func spawnParticles(in size: CGSize) {
        var newParticles: [ConfettiParticle] = []
        for _ in 0..<75 {
            let p = ConfettiParticle(
                x: CGFloat.random(in: 20...(size.width - 20)),
                y: CGFloat.random(in: -size.height * 0.2...0),
                size: CGFloat.random(in: 7...13),
                color: colors.randomElement() ?? .orange,
                rotation: Double.random(in: 0...360),
                opacity: Double.random(in: 0.8...1.0),
                speedY: CGFloat.random(in: 3...7),
                speedX: CGFloat.random(in: -1.5...1.5)
            )
            newParticles.append(p)
        }
        self.particles = newParticles
    }
    
    private func updateParticles(in size: CGSize) {
        for i in 0..<particles.count {
            particles[i].y += particles[i].speedY
            particles[i].x += particles[i].speedX
            particles[i].rotation += 4
            if particles[i].y > size.height {
                particles[i].opacity -= 0.05
            }
        }
    }
}
