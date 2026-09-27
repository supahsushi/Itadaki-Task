import SwiftUI

struct CollectionScreen: View {
    var characters: [CollectionCharacter]

    @Environment(\.dismiss) private var dismiss
    @State private var selectedCharacter: CollectionCharacter?

    private let columns = [
        GridItem(.adaptive(minimum: 124), spacing: 14)
    ]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(characters) { character in
                        Button {
                            guard character.isUnlocked else { return }
                            selectedCharacter = character
                        } label: {
                            CollectionCharacterCell(character: character)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(accessibilityLabel(for: character))
                    }
                }
                .padding(18)
            }
            .background(Color(red: 0.98, green: 0.91, blue: 0.80))
            .navigationTitle("Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbarBackground(Color(red: 0.98, green: 0.91, blue: 0.80), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundStyle(Color(red: 0.11, green: 0.08, blue: 0.05))
                }
            }
            .fullScreenCover(item: $selectedCharacter) { character in
                CollectionCharacterProfileView(character: character)
            }
        }
        .preferredColorScheme(.light)
    }

    private func accessibilityLabel(for character: CollectionCharacter) -> String {
        character.isUnlocked ? "\(character.name), \(character.role)" : "Locked collection character"
    }
}

struct CollectionCharacterCell: View {
    var character: CollectionCharacter

    var body: some View {
        VStack(spacing: 9) {
            ZStack {
                if character.isUnlocked {
                    CollectionCharacterArtwork(character: character)
                        .frame(width: 96, height: 96)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                } else {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.45, green: 0.36, blue: 0.30),
                                    Color(red: 0.22, green: 0.16, blue: 0.13)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 96, height: 96)
                    Image(systemName: "person.fill.questionmark")
                        .font(.system(size: 42, weight: .black))
                        .foregroundStyle(.white.opacity(0.50))
                    Image(systemName: "lock.fill")
                        .font(.system(size: 19, weight: .black))
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(Circle().fill(Color.black.opacity(0.38)))
                        .offset(x: 34, y: 34)
                }
            }
            .frame(width: 104, height: 104)

            VStack(spacing: 3) {
                Text(character.isUnlocked ? character.name : "???")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(Color(red: 0.12, green: 0.08, blue: 0.06))
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)

                Text(character.isUnlocked ? character.role : "Not met yet")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.44, green: 0.31, blue: 0.22))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
        }
        .padding(11)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(red: 0.74, green: 0.42, blue: 0.22).opacity(0.28), lineWidth: 1)
        )
    }
}

struct CollectionCharacterArtwork: View {
    var character: CollectionCharacter

    var body: some View {
        if UIImage(named: character.artworkAssetName) != nil {
            Image(character.artworkAssetName)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(red: 0.86, green: 0.58, blue: 0.38).gradient)
                Image(systemName: "person.crop.square.fill")
                    .font(.system(size: 44, weight: .black))
                    .foregroundStyle(.white.opacity(0.86))
            }
        }
    }
}

struct CollectionCharacterProfileView: View {
    var character: CollectionCharacter

    @Environment(\.dismiss) private var dismiss

    private var ink: Color {
        Color(red: 0.13, green: 0.08, blue: 0.05)
    }

    private var softInk: Color {
        Color(red: 0.42, green: 0.31, blue: 0.23)
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        profileHero(width: proxy.size.width, safeTop: proxy.safeAreaInsets.top)
                        profileDetails
                    }
                }
                .ignoresSafeArea()
                .background(profileBackground.ignoresSafeArea())

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 24, weight: .black))
                        .foregroundStyle(Color(red: 0.24, green: 0.12, blue: 0.06))
                        .frame(width: 54, height: 54)
                        .background(Circle().fill(Color(red: 1.0, green: 0.90, blue: 0.75)))
                        .overlay(Circle().stroke(Color.white.opacity(0.75), lineWidth: 2))
                        .shadow(color: .black.opacity(0.20), radius: 8, y: 4)
                }
                .padding(.leading, 20)
                .padding(.top, proxy.safeAreaInsets.top + 12)
            }
        }
        .preferredColorScheme(.light)
    }

    private func profileHero(width: CGFloat, safeTop: CGFloat) -> some View {
        ZStack(alignment: .bottom) {
            ProfileCharacterArtwork(character: character)
                .frame(width: width, height: max(430, min(width * 1.18, 560)) + safeTop)
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.02),
                            Color.black.opacity(0.04),
                            Color(red: 0.24, green: 0.10, blue: 0.03).opacity(0.74)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(alignment: .topLeading) {
                    blossomBranch
                        .padding(.top, safeTop + 48)
                        .padding(.leading, 14)
                }
                .overlay(alignment: .topTrailing) {
                    Text("✦")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 1.0, green: 0.72, blue: 0.25))
                        .shadow(color: .white.opacity(0.60), radius: 5)
                        .padding(.top, safeTop + 102)
                        .padding(.trailing, 30)
                }

            VStack(spacing: 8) {
                namePlaque(width: width)

                Text("\"\(character.quote)\"")
                    .font(.system(size: min(19, width * 0.047), weight: .black, design: .rounded))
                    .foregroundStyle(Color(red: 0.25, green: 0.13, blue: 0.07))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 10)
                    .frame(maxWidth: min(width - 42, 620))
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(red: 1.0, green: 0.94, blue: 0.78).opacity(0.92))
                    )
                    .overlay(alignment: .bottomTrailing) {
                        Image(systemName: "seal.fill")
                            .font(.system(size: 18, weight: .black))
                            .foregroundStyle(Color(red: 1.0, green: 0.42, blue: 0.51).opacity(0.42))
                            .offset(x: -14, y: 8)
                    }
                    .overlay(alignment: .bottomLeading) {
                        blossom(size: 18)
                            .offset(x: 26, y: 12)
                    }
                    .overlay(alignment: .bottomTrailing) {
                        blossom(size: 18)
                            .offset(x: -24, y: 14)
                    }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, -42)
        }
        .padding(.bottom, 58)
    }

    private func namePlaque(width: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.68, green: 0.35, blue: 0.14),
                            Color(red: 0.46, green: 0.21, blue: 0.08)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 86)
                .shadow(color: .black.opacity(0.20), radius: 10, y: 5)

            RoundedRectangle(cornerRadius: 7)
                .stroke(Color(red: 0.32, green: 0.14, blue: 0.04).opacity(0.26), lineWidth: 2)
                .padding(.horizontal, 3)
                .frame(height: 80)

            HStack {
                blossomCluster(scale: 0.70)
                Spacer()
                Text("🍣")
                    .font(.system(size: 44))
                    .rotationEffect(.degrees(-9))
                    .shadow(color: .black.opacity(0.22), radius: 5, y: 3)
            }
            .padding(.horizontal, 18)

            VStack(spacing: -2) {
                Text(character.name)
                    .font(.system(size: min(52, width * 0.13), weight: .black, design: .rounded))
                    .foregroundStyle(Color(red: 0.95, green: 0.39, blue: 0.18))
                    .shadow(color: .white, radius: 0, x: 0, y: 3)
                    .shadow(color: .white, radius: 0, x: 3, y: 0)
                    .shadow(color: .white, radius: 0, x: -3, y: 0)
                    .shadow(color: .white, radius: 0, x: 0, y: -3)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)

                Text(character.role)
                    .font(.system(size: min(25, width * 0.061), weight: .black, design: .rounded))
                    .foregroundStyle(Color(red: 0.93, green: 0.19, blue: 0.42))
                    .shadow(color: .white.opacity(0.92), radius: 0, x: 0, y: 2)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.70)
            }
        }
        .frame(maxWidth: min(width - 48, 620))
    }

    private var profileDetails: some View {
        VStack(spacing: 17) {
            profileSection("About", character.about, accent: .about)
            profileIconStrip
            profileSection("Personality", character.personality, accent: .personality)
            profileSection("Loves", character.loves, accent: .loves)
            profileSection("Fun Fact", character.funFact, accent: .funFact)
            profileSection("First Visited", firstVisitedText, accent: .firstVisited)
        }
        .padding(.horizontal, 18)
        .padding(.top, 26)
        .padding(.bottom, 34)
        .background(
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.92, blue: 0.78).opacity(0.0),
                        Color(red: 1.0, green: 0.91, blue: 0.76).opacity(0.96),
                        Color(red: 0.98, green: 0.79, blue: 0.58)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .padding(.top, -92)

                ForEach(0..<8, id: \.self) { index in
                    Image(systemName: "water.waves")
                        .font(.system(size: 30, weight: .black))
                        .foregroundStyle(Color(red: 0.95, green: 0.35, blue: 0.32).opacity(0.08))
                        .offset(x: CGFloat((index % 2 == 0 ? -1 : 1) * (92 + index * 11)), y: CGFloat(index * 74 - 20))
                }
            }
        )
        .overlay(alignment: .top) {
            HStack(spacing: 16) {
                blossom(size: 19)
                Image(systemName: "water.waves")
                    .font(.system(size: 28, weight: .black))
                    .foregroundStyle(Color(red: 0.89, green: 0.30, blue: 0.26).opacity(0.16))
                blossom(size: 15)
            }
            .offset(y: -8)
            .allowsHitTesting(false)
        }
    }

    private var profileIconStrip: some View {
        HStack(spacing: 12) {
            profileMiniIcon("🍣")
            profileMiniIcon("🌸")
            profileMiniIcon("❤")
            profileMiniIcon("⭐")
            profileMiniIcon("🗓️")
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 16)
        .background(
            Capsule()
                .fill(Color(red: 1.0, green: 0.88, blue: 0.68).opacity(0.70))
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.55), lineWidth: 1)
                )
        )
        .overlay(alignment: .leading) {
            blossom(size: 15)
                .offset(x: -6, y: -10)
        }
        .overlay(alignment: .trailing) {
            blossom(size: 15)
                .offset(x: 6, y: 10)
        }
    }

    private func profileMiniIcon(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 18, weight: .black, design: .rounded))
            .frame(width: 38, height: 38)
            .background(
                Circle()
                    .fill(Color(red: 1.0, green: 0.96, blue: 0.84))
                    .shadow(color: Color(red: 0.52, green: 0.22, blue: 0.08).opacity(0.12), radius: 4, y: 2)
            )
            .overlay(
                Circle()
                    .stroke(Color(red: 0.80, green: 0.44, blue: 0.22).opacity(0.20), lineWidth: 1)
            )
    }

    private var profileBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.91, blue: 0.76),
                    Color(red: 0.99, green: 0.84, blue: 0.62),
                    Color(red: 0.96, green: 0.71, blue: 0.50)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack {
                HStack {
                    decorativeSakura
                    Spacer()
                    decorativeSakura
                }
                .padding(.horizontal, 30)
                .padding(.top, 32)

                Spacer()

                HStack {
                    decorativeSakura.opacity(0.65)
                    Spacer()
                    decorativeSakura.opacity(0.65)
                }
                .padding(.horizontal, 34)
                .padding(.bottom, 42)
            }
            .allowsHitTesting(false)
        }
    }

    private var decorativeSakura: some View {
        Image(systemName: "seal.fill")
            .font(.system(size: 32, weight: .black))
            .foregroundStyle(Color(red: 1.0, green: 0.48, blue: 0.56).opacity(0.24))
            .rotationEffect(.degrees(18))
    }

    private var firstVisitedText: String {
        guard let date = character.dateFirstMet else { return "Not met yet" }
        return date.formatted(date: .long, time: .omitted)
    }

    private var blossomBranch: some View {
        ZStack {
            Capsule()
                .fill(Color(red: 0.37, green: 0.17, blue: 0.08).opacity(0.52))
                .frame(width: 150, height: 7)
                .rotationEffect(.degrees(-24))
                .offset(x: 26, y: 5)

            blossom(size: 35).offset(x: 8, y: -12)
            blossom(size: 28).offset(x: 45, y: -23)
            blossom(size: 23).offset(x: 76, y: -6)
            blossom(size: 30).offset(x: 104, y: -28)
            blossom(size: 20).offset(x: 128, y: -2)
        }
        .frame(width: 170, height: 72, alignment: .topLeading)
    }

    private func blossom(size: CGFloat) -> some View {
        ZStack {
            ForEach(0..<5, id: \.self) { index in
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.66, blue: 0.73),
                                Color(red: 0.95, green: 0.32, blue: 0.48)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: size * 0.42, height: size * 0.62)
                    .offset(y: -size * 0.22)
                    .rotationEffect(.degrees(Double(index) * 72))
            }

            Circle()
                .fill(Color(red: 1.0, green: 0.78, blue: 0.16))
                .frame(width: size * 0.22, height: size * 0.22)
        }
        .frame(width: size, height: size)
        .shadow(color: Color(red: 0.58, green: 0.13, blue: 0.20).opacity(0.24), radius: 3, y: 2)
    }

    private func blossomCluster(scale: CGFloat) -> some View {
        ZStack {
            blossom(size: 24 * scale).offset(x: -10 * scale, y: -3 * scale)
            blossom(size: 18 * scale).offset(x: 10 * scale, y: -10 * scale)
            blossom(size: 14 * scale).offset(x: 16 * scale, y: 7 * scale)
        }
        .frame(width: 52 * scale, height: 38 * scale)
    }

    private func profileSection(_ title: String, _ value: String, accent: ProfileAccent) -> some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(red: 1.0, green: 0.95, blue: 0.84).opacity(0.96))
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "water.waves")
                        .font(.system(size: 42, weight: .black))
                        .foregroundStyle(Color(red: 0.95, green: 0.35, blue: 0.32).opacity(0.09))
                        .padding(.top, 10)
                        .padding(.trailing, 24)
                }
                .overlay(alignment: .trailing) {
                    sectionDecoration(accent: accent)
                        .padding(.trailing, 16)
                        .padding(.top, 26)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color(red: 0.77, green: 0.43, blue: 0.22).opacity(0.34), lineWidth: 1.5)
                )
                .shadow(color: Color(red: 0.38, green: 0.18, blue: 0.08).opacity(0.13), radius: 8, y: 5)

            VStack(alignment: .leading, spacing: 13) {
                HStack(spacing: 9) {
                    sectionIcon(accent)

                    woodLabel(title)
                        .offset(x: -2)

                    Spacer()
                }

                Text(value)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(ink)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.leading, 6)
                    .padding(.trailing, 72)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 15)

            if accent == .firstVisited {
                blossomCluster(scale: 0.62)
                    .offset(x: -4, y: 82)
            }
        }
    }

    private func woodLabel(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.system(size: 16, weight: .black, design: .rounded))
            .foregroundStyle(.white)
            .tracking(0.7)
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.64, green: 0.32, blue: 0.12),
                                Color(red: 0.35, green: 0.15, blue: 0.05)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .shadow(color: .black.opacity(0.18), radius: 3, y: 2)
    }

    @ViewBuilder
    private func sectionIcon(_ accent: ProfileAccent) -> some View {
        switch accent {
        case .about:
            emojiBadge("🍣", background: Color(red: 1.0, green: 0.88, blue: 0.66))
        case .personality:
            ZStack {
                Circle()
                    .fill(Color(red: 1.0, green: 0.82, blue: 0.88))
                    .frame(width: 38, height: 38)
                    .overlay(Circle().stroke(Color.white.opacity(0.82), lineWidth: 2))
                blossom(size: 28)
            }
        case .loves:
            emojiBadge("❤", background: Color(red: 1.0, green: 0.76, blue: 0.78), foreground: Color(red: 0.93, green: 0.12, blue: 0.24))
        case .funFact:
            emojiBadge("⭐", background: Color(red: 1.0, green: 0.88, blue: 0.58))
        case .firstVisited:
            emojiBadge("🗓️", background: Color(red: 1.0, green: 0.86, blue: 0.72))
        }
    }

    private func emojiBadge(_ text: String, background: Color, foreground: Color? = nil) -> some View {
        Text(text)
            .font(.system(size: 22, weight: .black, design: .rounded))
            .foregroundStyle(foreground ?? ink)
            .frame(width: 38, height: 38)
            .background(Circle().fill(background))
            .overlay(Circle().stroke(Color.white.opacity(0.82), lineWidth: 2))
            .shadow(color: .black.opacity(0.14), radius: 4, y: 2)
    }

    @ViewBuilder
    private func sectionDecoration(accent: ProfileAccent) -> some View {
        switch accent {
        case .about:
            ZStack {
                Image(systemName: "face.smiling")
                    .font(.system(size: 52, weight: .black))
                    .foregroundStyle(Color(red: 0.92, green: 0.32, blue: 0.24).opacity(0.22))
                Image(systemName: "mustache.fill")
                    .font(.system(size: 30, weight: .black))
                    .foregroundStyle(Color(red: 0.92, green: 0.32, blue: 0.24).opacity(0.14))
                    .offset(y: -22)
            }
        case .personality:
            ZStack {
                Text("🍶")
                    .font(.system(size: 43))
                    .rotationEffect(.degrees(10))
                Text("♥")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(Color(red: 0.94, green: 0.22, blue: 0.36))
                    .offset(x: -28, y: -18)
                Text("♥")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(Color(red: 0.94, green: 0.22, blue: 0.36))
                    .offset(x: -16, y: -31)
            }
        case .loves:
            ZStack {
                Text("🍣")
                    .font(.system(size: 52))
                    .rotationEffect(.degrees(-10))
                Text("✦")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(Color(red: 1.0, green: 0.72, blue: 0.12))
                    .offset(x: -34, y: -16)
                Text("✦")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(Color(red: 1.0, green: 0.72, blue: 0.12))
                    .offset(x: 33, y: -21)
            }
        case .funFact:
            Image(systemName: "face.smiling")
                .font(.system(size: 50, weight: .black))
                .foregroundStyle(Color(red: 0.44, green: 0.21, blue: 0.08).opacity(0.38))
        case .firstVisited:
            VStack(spacing: 0) {
                Text("寿司チャンプルー")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                Text("Oishii Sushi!")
                    .font(.system(size: 12, weight: .black, design: .rounded))
            }
            .foregroundStyle(Color(red: 0.92, green: 0.30, blue: 0.29).opacity(0.42))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(red: 0.92, green: 0.30, blue: 0.29).opacity(0.36), lineWidth: 2)
            )
        }
    }
}

private enum ProfileAccent {
    case about
    case personality
    case loves
    case funFact
    case firstVisited
}

private struct ProfileCharacterArtwork: View {
    var character: CollectionCharacter

    var body: some View {
        if UIImage(named: character.artworkAssetName) != nil {
            ZStack {
                Image(character.artworkAssetName)
                    .resizable()
                    .scaledToFill()
                    .blur(radius: 14)
                    .scaleEffect(1.08)
                    .opacity(0.92)

                Image(character.artworkAssetName)
                    .resizable()
                    .scaledToFit()
                    .padding(.top, 54)
                    .padding(.horizontal, 6)
                    .padding(.bottom, 54)
            }
        } else {
            RoundedRectangle(cornerRadius: 30)
                .fill(Color(red: 0.86, green: 0.58, blue: 0.38).gradient)
                .overlay {
                    Image(systemName: "person.crop.square.fill")
                        .font(.system(size: 58, weight: .black))
                        .foregroundStyle(.white.opacity(0.86))
                }
        }
    }
}
