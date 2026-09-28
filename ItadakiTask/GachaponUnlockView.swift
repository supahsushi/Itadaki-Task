import SwiftUI

struct GachaponUnlockView: View {
    var achievement: Achievement
    var collect: () -> Void

    @State private var machineShake = false
    @State private var knobTurns = false
    @State private var capsuleDrops = false
    @State private var badgeAppears = false
    @State private var textAppears = false
    @State private var canCollect = false

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Image("achievement_gachapon")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
                    .scaleEffect(machineShake ? 1.014 : 1)
                    .rotationEffect(.degrees(machineShake ? -1.7 : 1.7), anchor: .center)
                    .offset(x: machineShake ? -5 : 5)
                    .animation(
                        .easeInOut(duration: 0.15)
                            .repeatCount(10, autoreverses: true),
                        value: machineShake
                    )

                Color.black.opacity(0.10)
                    .ignoresSafeArea()

                KnobTurnOverlay(isTurning: knobTurns, size: proxy.size)

                capsuleLayer(size: proxy.size)

                sparkleLayer(size: proxy.size)

                rewardTextLayer(size: proxy.size)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .ignoresSafeArea()
            .onAppear(perform: runSequence)
        }
        .preferredColorScheme(.dark)
    }

    private func capsuleLayer(size: CGSize) -> some View {
        let capsuleSize = min(size.width * 0.27, 132)
        let startY = size.height * 0.49
        let landedY = size.height * 0.69

        return ZStack {
            BadgeArtwork(achievement: achievement)
                .frame(width: capsuleSize * 0.96, height: capsuleSize * 0.96)
                .clipShape(Circle())
                .shadow(color: Color(red: 1.0, green: 0.72, blue: 0.18).opacity(0.72), radius: badgeAppears ? 22 : 0)
                .scaleEffect(badgeAppears ? 1 : 0.18)
                .opacity(badgeAppears ? 1 : 0)
                .offset(y: capsuleDrops ? landedY - startY - capsuleSize * 0.88 : -capsuleSize * 0.88)
                .animation(.spring(response: 1.0, dampingFraction: 0.66), value: badgeAppears)
        }
        .position(x: size.width * 0.5, y: startY)
    }

    private func sparkleLayer(size: CGSize) -> some View {
        ZStack {
            ForEach(0..<14) { index in
                Image(systemName: index.isMultiple(of: 3) ? "sparkle" : "star.fill")
                    .font(.system(size: index.isMultiple(of: 2) ? 16 : 11, weight: .black))
                    .foregroundStyle(index.isMultiple(of: 2) ? Color.white : Color(red: 1.0, green: 0.77, blue: 0.25))
                    .scaleEffect(badgeAppears ? 1 : 0.2)
                    .opacity(badgeAppears ? 1 : 0)
                    .offset(
                        x: CGFloat(cos(Double(index) * .pi / 7.0) * Double(size.width * 0.23)),
                        y: CGFloat(sin(Double(index) * .pi / 7.0) * Double(size.width * 0.16))
                    )
                    .animation(
                        .spring(response: 0.82, dampingFraction: 0.58)
                            .delay(Double(index) * 0.018),
                        value: badgeAppears
                    )
            }
        }
        .position(x: size.width * 0.5, y: size.height * 0.57)
    }

    private func rewardTextLayer(size: CGSize) -> some View {
        VStack(spacing: 10) {
            Spacer()

            VStack(spacing: 5) {
                Text("Achievement Unlocked!")
                    .font(.system(size: min(30, size.width * 0.075), weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.45), radius: 4, y: 2)

                Text(achievement.title)
                    .font(.system(size: min(22, size.width * 0.056), weight: .black, design: .rounded))
                    .foregroundStyle(Color(red: 1.0, green: 0.80, blue: 0.34))
                    .shadow(color: .black.opacity(0.55), radius: 3, y: 2)
            }
            .multilineTextAlignment(.center)
            .opacity(textAppears ? 1 : 0)
            .offset(y: textAppears ? 0 : 16)
            .animation(.spring(response: 0.72, dampingFraction: 0.80), value: textAppears)

            Button(action: collect) {
                Text("Collect")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(width: min(size.width * 0.58, 260), height: 52)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.24, blue: 0.52),
                                        Color(red: 1.0, green: 0.45, blue: 0.67)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.45), lineWidth: 1)
                    )
                    .shadow(color: Color(red: 1.0, green: 0.19, blue: 0.46).opacity(0.42), radius: 12, y: 6)
            }
            .buttonStyle(.plain)
            .disabled(!canCollect)
            .opacity(canCollect ? 1 : 0)
            .scaleEffect(canCollect ? 1 : 0.86)
            .animation(.spring(response: 0.42, dampingFraction: 0.68), value: canCollect)

            Spacer()
                .frame(height: max(24, size.height * 0.045))
        }
        .padding(.horizontal, 22)
        .frame(width: size.width, height: size.height)
        .background(
            LinearGradient(
                colors: [.clear, .clear, Color.black.opacity(0.48)],
                startPoint: .top,
                endPoint: .bottom
            )
            .allowsHitTesting(false)
        )
    }

    private func runSequence() {
        machineShake = false
        knobTurns = false
        capsuleDrops = false
        badgeAppears = false
        textAppears = false
        canCollect = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            machineShake = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.55) {
            knobTurns = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            capsuleDrops = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            badgeAppears = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.35) {
            textAppears = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.1) {
            canCollect = true
        }
    }
}

private struct KnobTurnOverlay: View {
    var isTurning: Bool
    var size: CGSize

    var body: some View {
        ZStack {
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.98, green: 0.73, blue: 0.34).opacity(0.38),
                            Color(red: 0.45, green: 0.20, blue: 0.06).opacity(0.28)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size.width * 0.135, height: size.width * 0.035)
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.44), lineWidth: 1)
                )
                .rotationEffect(.degrees(isTurning ? 360 : 0))
                .animation(.easeInOut(duration: 0.75), value: isTurning)
        }
        .position(x: size.width * 0.5, y: size.height * 0.615)
        .allowsHitTesting(false)
    }
}
