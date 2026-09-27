import SwiftUI

struct NewCustomerArrivalView: View {
    var character: CollectionCharacter
    var welcome: () -> Void

    @State private var artworkAppears = false
    @State private var textAppears = false
    @State private var sparklesAppear = false
    @State private var canWelcome = false

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.20, green: 0.08, blue: 0.12),
                        Color(red: 0.82, green: 0.25, blue: 0.38),
                        Color(red: 1.0, green: 0.77, blue: 0.44)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                arrivalSparkles(size: proxy.size)

                VStack(spacing: 18) {
                    Spacer(minLength: proxy.size.height * 0.08)

                    VStack(spacing: 8) {
                        Text("A New Customer Has Arrived!")
                            .font(.system(size: min(30, proxy.size.width * 0.078), weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.38), radius: 4, y: 2)

                        Text("Welcome them to Itadaki Task")
                            .font(.system(size: min(16, proxy.size.width * 0.042), weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.86))
                    }
                    .multilineTextAlignment(.center)
                    .opacity(textAppears ? 1 : 0)
                    .offset(y: textAppears ? 0 : 14)
                    .animation(.spring(response: 0.72, dampingFraction: 0.78), value: textAppears)

                    ZStack {
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color.white.opacity(0.18))
                            .frame(width: min(proxy.size.width * 0.76, 330), height: min(proxy.size.width * 0.76, 330))
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.white.opacity(0.38), lineWidth: 1)
                            )

                        CollectionCharacterArtwork(character: character)
                            .frame(width: min(proxy.size.width * 0.68, 292), height: min(proxy.size.width * 0.68, 292))
                            .clipShape(RoundedRectangle(cornerRadius: 26))
                            .shadow(color: .black.opacity(0.28), radius: 18, y: 10)
                            .scaleEffect(artworkAppears ? 1 : 0.45)
                            .rotationEffect(.degrees(artworkAppears ? 0 : -6))
                            .opacity(artworkAppears ? 1 : 0)
                            .animation(.spring(response: 1.05, dampingFraction: 0.62), value: artworkAppears)
                    }

                    VStack(spacing: 7) {
                        Text(character.name)
                            .font(.system(size: min(36, proxy.size.width * 0.092), weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.34), radius: 3, y: 2)

                        Text(character.role)
                            .font(.system(size: min(20, proxy.size.width * 0.052), weight: .black, design: .rounded))
                            .foregroundStyle(Color(red: 1.0, green: 0.89, blue: 0.46))
                            .shadow(color: .black.opacity(0.32), radius: 2, y: 1)

                        Text(character.introduction)
                            .font(.system(size: min(17, proxy.size.width * 0.044), weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.90))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 24)
                    }
                    .opacity(textAppears ? 1 : 0)
                    .offset(y: textAppears ? 0 : 16)
                    .animation(.spring(response: 0.78, dampingFraction: 0.80).delay(0.10), value: textAppears)

                    Button(action: welcome) {
                        Text("Welcome")
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundStyle(Color(red: 0.42, green: 0.10, blue: 0.18))
                            .frame(width: min(proxy.size.width * 0.58, 260), height: 52)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.94))
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color(red: 1.0, green: 0.82, blue: 0.42).opacity(0.84), lineWidth: 2)
                            )
                            .shadow(color: .black.opacity(0.20), radius: 12, y: 6)
                    }
                    .buttonStyle(.plain)
                    .disabled(!canWelcome)
                    .opacity(canWelcome ? 1 : 0)
                    .scaleEffect(canWelcome ? 1 : 0.86)
                    .animation(.spring(response: 0.42, dampingFraction: 0.68), value: canWelcome)

                    Spacer(minLength: proxy.size.height * 0.06)
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
                .padding(.horizontal, 18)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .onAppear(perform: runEntrance)
        }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
    }

    private func arrivalSparkles(size: CGSize) -> some View {
        ZStack {
            ForEach(0..<18) { index in
                Image(systemName: index.isMultiple(of: 4) ? "sparkle" : "star.fill")
                    .font(.system(size: index.isMultiple(of: 3) ? 18 : 11, weight: .black))
                    .foregroundStyle(index.isMultiple(of: 2) ? Color.white : Color(red: 1.0, green: 0.87, blue: 0.38))
                    .opacity(sparklesAppear ? 0.85 : 0)
                    .scaleEffect(sparklesAppear ? 1 : 0.25)
                    .offset(
                        x: CGFloat(cos(Double(index) * .pi / 9.0) * Double(size.width * 0.42)),
                        y: CGFloat(sin(Double(index) * .pi / 9.0) * Double(size.height * 0.31))
                    )
                    .animation(
                        .spring(response: 0.92, dampingFraction: 0.62)
                            .delay(Double(index) * 0.025),
                        value: sparklesAppear
                    )
            }
        }
        .position(x: size.width * 0.5, y: size.height * 0.48)
        .allowsHitTesting(false)
    }

    private func runEntrance() {
        artworkAppears = false
        textAppears = false
        sparklesAppear = false
        canWelcome = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
            sparklesAppear = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            artworkAppears = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.05) {
            textAppears = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.75) {
            canWelcome = true
        }
    }
}
