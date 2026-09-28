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

    private let ink = Color(red: 0.19, green: 0.11, blue: 0.06)
    private let paper = Color(red: 0.99, green: 0.92, blue: 0.84)
    private let paperLight = Color(red: 1.0, green: 0.96, blue: 0.91)
    private let paperEdge = Color(red: 0.82, green: 0.58, blue: 0.40)

    /// How far the name plaque rides up onto the bottom of the artwork.
    private let plaqueOverlap: CGFloat = 84
    /// Where the paper page starts, measured down from the top of the plaque.
    private let paperInset: CGFloat = 50
    /// Tall mockup-style hero: height as a fraction of the screen width.
    private let heroHeightRatio: CGFloat = 1.04
    /// How much the artwork is zoomed past full width so the character fills the hero.
    private let heroZoom: CGFloat = 1.42
    private let maxPageWidth: CGFloat = 640

    var body: some View {
        if UIImage(named: ProfileCardImage.assetName(for: character)) != nil {
            ProfileCardImage(character: character, firstVisitedText: firstVisitedText) {
                dismiss()
            }
        } else {
            drawnProfile
        }
    }

    /// Fallback for a character without a finished profile image in the asset catalog.
    private var drawnProfile: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        profileHero(width: proxy.size.width, safeTop: proxy.safeAreaInsets.top)
                        profilePage(width: proxy.size.width, safeBottom: proxy.safeAreaInsets.bottom)
                            .padding(.top, -plaqueOverlap)
                    }
                }
                .ignoresSafeArea()
                .background(overscrollBackground.ignoresSafeArea())

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(Color(red: 0.24, green: 0.12, blue: 0.06))
                        .frame(width: 42, height: 42)
                        .background(Circle().fill(Color(red: 1.0, green: 0.92, blue: 0.80)))
                        .overlay(Circle().stroke(Color.white.opacity(0.80), lineWidth: 2))
                        .shadow(color: .black.opacity(0.24), radius: 8, y: 4)
                }
                .accessibilityLabel("Back")
                // The ZStack already sits inside the safe area, so this is just below the status bar.
                .padding(.leading, 10)
                .padding(.top, 8)
            }
        }
        // Dark only so the status bar text turns white over the artwork; every color here is explicit.
        .preferredColorScheme(.dark)
    }

    /// Matches the hero at the top and the paper at the bottom, so bouncing past either end never shows a seam.
    private var overscrollBackground: some View {
        VStack(spacing: 0) {
            heroBase
            paper
        }
    }

    private let heroBase = Color(red: 0.22, green: 0.11, blue: 0.05)

    // MARK: Hero

    private var artworkAspectRatio: CGFloat {
        guard let image = UIImage(named: character.artworkAssetName), image.size.width > 0 else { return 0.75 }
        return image.size.height / image.size.width
    }

    /// Mockup-style hero: the artwork fills the top edge to edge, behind the status bar,
    /// zoomed in on the character. The corners of the wide artwork are cropped away.
    private func profileHero(width: CGFloat, safeTop: CGFloat) -> some View {
        let heroHeight = width * heroHeightRatio
        let imageWidth = width * heroZoom
        let imageHeight = imageWidth * artworkAspectRatio
        let offsetX = min(0, max(width - imageWidth, width / 2 - imageWidth * 0.52))
        let offsetY = min(0, max(heroHeight - imageHeight, -imageHeight * 0.03))

        return ZStack(alignment: .topLeading) {
            heroBase

            if UIImage(named: character.artworkAssetName) != nil {
                Image(character.artworkAssetName)
                    .resizable()
                    .frame(width: imageWidth, height: imageHeight)
                    .offset(x: offsetX, y: offsetY)
                    .accessibilityLabel("\(character.name), \(character.role) artwork")
            } else {
                ProfileCharacterArtwork(character: character)
                    .frame(width: width, height: heroHeight)
            }

            // Keeps the white status bar text readable over bright artwork.
            LinearGradient(
                colors: [Color.black.opacity(0.38), Color.black.opacity(0)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: safeTop + 36)
            .allowsHitTesting(false)

            heroBlossoms(width: width, heroHeight: heroHeight, safeTop: safeTop)
        }
        .frame(width: width, height: heroHeight, alignment: .topLeading)
        .clipped()
    }

    private func heroBlossoms(width: CGFloat, heroHeight: CGFloat, safeTop: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            blossom(size: 30).offset(x: width * 0.30, y: safeTop + 4)
            blossom(size: 22).offset(x: width * 0.40, y: safeTop - 16)
            blossom(size: 34).offset(x: -8, y: heroHeight * 0.34)
            blossom(size: 24).offset(x: 20, y: heroHeight * 0.42)
            blossom(size: 30).offset(x: 6, y: heroHeight * 0.80)
            blossom(size: 22).offset(x: width - 34, y: heroHeight * 0.74)
            Text("✦")
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundStyle(Color(red: 1.0, green: 0.84, blue: 0.30))
                .shadow(color: .white.opacity(0.70), radius: 6)
                .offset(x: width * 0.20, y: heroHeight * 0.34)
        }
        .accessibilityHidden(true)
        .allowsHitTesting(false)
    }

    // MARK: Page

    private func profilePage(width: CGFloat, safeBottom: CGFloat) -> some View {
        VStack(spacing: 12) {
            namePlaque(width: width)
                .zIndex(1)

            quoteNote(width: width)

            VStack(spacing: 13) {
                profileSection("About", character.about, accent: .about)
                profileSection("Personality", character.personality, accent: .personality)
                profileSection("Loves", character.loves, accent: .loves)
                profileSection("Fun Fact", character.funFact, accent: .funFact)
                profileSection("First Visited", firstVisitedText, accent: .firstVisited)
            }
            .frame(maxWidth: maxPageWidth)
            .padding(.horizontal, 16)
            .padding(.top, 10)
        }
        .padding(.bottom, safeBottom + 34)
        .frame(width: width)
        .background(alignment: .top) {
            paperPage
                .padding(.top, paperInset)
        }
    }

    private var paperPage: some View {
        let shape = UnevenRoundedRectangle(topLeadingRadius: 28, topTrailingRadius: 28)

        return ZStack {
            shape.fill(paper)

            SeigaihaPattern(background: paper, line: Color(red: 0.93, green: 0.55, blue: 0.45).opacity(0.13))
                .clipShape(shape)

            VStack {
                HStack(alignment: .top) {
                    blossomCluster(scale: 0.9)
                        .opacity(0.8)
                        .offset(x: 6, y: 34)
                    Spacer()
                    blossomCluster(scale: 0.9)
                        .opacity(0.8)
                        .offset(x: -6, y: 34)
                }
                Spacer()
                HStack(alignment: .bottom) {
                    blossom(size: 34)
                        .opacity(0.35)
                    Spacer()
                    ZStack {
                        blossom(size: 64).opacity(0.28)
                        blossom(size: 30).opacity(0.36).offset(x: -46, y: 20)
                    }
                    .offset(x: 14, y: 10)
                }
                .padding(.horizontal, 4)
                .padding(.bottom, 4)
            }
            .clipShape(shape)
            .allowsHitTesting(false)
        }
        .overlay(
            shape
                .stroke(Color.white.opacity(0.65), lineWidth: 2)
        )
        .shadow(color: Color(red: 0.30, green: 0.12, blue: 0.04).opacity(0.30), radius: 10, y: -3)
    }

    // MARK: Name plaque and quote

    private func namePlaque(width: CGFloat) -> some View {
        let plaqueWidth = min(width - 36, 560)
        let nameSize = min(56, width * 0.135)

        return ZStack {
            WoodPlankShape()
                .fill(woodGradient)
                .overlay(WoodGrain().clipShape(WoodPlankShape()))
                .overlay(
                    WoodPlankShape()
                        .stroke(Color(red: 0.30, green: 0.13, blue: 0.04).opacity(0.55), lineWidth: 2)
                )
                .frame(height: 94)
                .shadow(color: .black.opacity(0.30), radius: 10, y: 6)

            VStack(spacing: -4) {
                OutlinedText(
                    text: character.name,
                    font: .system(size: nameSize, weight: .black, design: .rounded),
                    fill: Color(red: 0.96, green: 0.44, blue: 0.15),
                    outline: .white,
                    width: 3.5
                )
                .shadow(color: Color(red: 0.36, green: 0.14, blue: 0.04).opacity(0.55), radius: 0, x: 0, y: 3)

                OutlinedText(
                    text: character.role,
                    font: .system(size: min(26, width * 0.062), weight: .black, design: .rounded),
                    fill: Color(red: 0.91, green: 0.18, blue: 0.40),
                    outline: .white,
                    width: 2.5
                )
                .shadow(color: Color(red: 0.36, green: 0.14, blue: 0.04).opacity(0.45), radius: 0, x: 0, y: 2)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.55)
            .padding(.horizontal, 74)
            .offset(y: -10)

            HStack {
                blossomCluster(scale: 0.78)
                    .offset(x: -4, y: 22)
                Spacer()
                plateSushi
                    .offset(x: 18, y: -4)
            }
            .padding(.horizontal, 10)
        }
        .frame(width: plaqueWidth)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(character.name), \(character.role)")
        .accessibilityAddTraits(.isHeader)
    }

    private var plateSushi: some View {
        ZStack {
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.22, green: 0.20, blue: 0.20), Color(red: 0.05, green: 0.05, blue: 0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 76, height: 30)
                .overlay(Ellipse().stroke(Color.white.opacity(0.28), lineWidth: 1.5))
                .offset(y: 16)
            Text("🍣")
                .font(.system(size: 50))
                .rotationEffect(.degrees(-8))
        }
        .shadow(color: .black.opacity(0.30), radius: 5, y: 3)
    }

    private func quoteNote(width: CGFloat) -> some View {
        Text("\u{201C}\(character.quote)\u{201D}")
            .font(.custom("Noteworthy-Bold", size: min(17, width * 0.042)))
            .foregroundStyle(ink)
            .multilineTextAlignment(.center)
            .lineSpacing(1)
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .frame(maxWidth: min(width - 60, 560))
            .background(
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 1.0, green: 0.97, blue: 0.88), Color(red: 0.99, green: 0.92, blue: 0.78)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: Color(red: 0.40, green: 0.20, blue: 0.08).opacity(0.18), radius: 5, y: 3)
            )
            .overlay(alignment: .bottomLeading) {
                blossom(size: 22)
                    .offset(x: -8, y: 9)
            }
            .overlay(alignment: .bottomTrailing) {
                blossom(size: 26)
                    .offset(x: 9, y: 11)
            }
    }

    // MARK: Sections

    private var firstVisitedText: String {
        guard let date = character.dateFirstMet else { return "Not met yet" }
        return date.formatted(date: .long, time: .omitted)
    }

    private func profileSection(_ title: String, _ value: String, accent: ProfileAccent) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: -12) {
                sectionIcon(accent)
                    .frame(width: 42, height: 42)
                    .zIndex(1)
                    .accessibilityHidden(true)

                woodLabel(title)
            }
            .padding(.leading, 6)
            .padding(.top, -8)

            Text(value)
                .font(.system(size: 15.5, weight: .regular))
                .foregroundStyle(ink)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, 20)
                .padding(.trailing, 84)
        }
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, minHeight: 78, alignment: .topLeading)
        .background(alignment: .trailing) {
            sectionDecoration(accent: accent)
                .padding(.trailing, 14)
                .padding(.top, 18)
                .accessibilityHidden(true)
                .allowsHitTesting(false)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(paperLight.opacity(0.72))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.75), lineWidth: 1.5)
                        .padding(3)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(paperEdge.opacity(0.42), lineWidth: 1.2)
                )
                .shadow(color: Color(red: 0.40, green: 0.20, blue: 0.08).opacity(0.10), radius: 5, y: 3)
        )
        .accessibilityElement(children: .combine)
    }

    private var woodGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.72, green: 0.42, blue: 0.20),
                Color(red: 0.58, green: 0.31, blue: 0.13),
                Color(red: 0.44, green: 0.22, blue: 0.08)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private func woodLabel(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.system(size: 15.5, weight: .black, design: .rounded))
            .foregroundStyle(Color(red: 1.0, green: 0.97, blue: 0.92))
            .tracking(0.8)
            .shadow(color: Color(red: 0.25, green: 0.10, blue: 0.02).opacity(0.75), radius: 0, x: 0, y: 1.5)
            .padding(.leading, 26)
            .padding(.trailing, 30)
            .padding(.vertical, 5)
            .background(
                WoodTabShape()
                    .fill(woodGradient)
                    .overlay(WoodGrain().clipShape(WoodTabShape()))
                    .overlay(
                        WoodTabShape()
                            .stroke(Color(red: 0.30, green: 0.13, blue: 0.04).opacity(0.45), lineWidth: 1.2)
                    )
                    .shadow(color: .black.opacity(0.20), radius: 3, y: 2)
            )
    }

    @ViewBuilder
    private func sectionIcon(_ accent: ProfileAccent) -> some View {
        switch accent {
        case .about:
            MakiIcon()
                .frame(width: 36, height: 36)
                .shadow(color: .black.opacity(0.22), radius: 3, y: 2)
        case .personality:
            iconEmoji("🌸")
        case .loves:
            iconEmoji("❤️")
        case .funFact:
            iconEmoji("⭐")
        case .firstVisited:
            iconEmoji("📅")
        }
    }

    private func iconEmoji(_ emoji: String) -> some View {
        Text(emoji)
            .font(.system(size: 31))
            .shadow(color: .black.opacity(0.22), radius: 3, y: 2)
    }

    @ViewBuilder
    private func sectionDecoration(accent: ProfileAccent) -> some View {
        switch accent {
        case .about:
            ZStack {
                Circle()
                    .stroke(Color(red: 0.92, green: 0.40, blue: 0.36).opacity(0.28), lineWidth: 2.5)
                    .frame(width: 60, height: 60)
                Image(systemName: "face.smiling")
                    .font(.system(size: 44, weight: .regular))
                    .foregroundStyle(Color(red: 0.92, green: 0.40, blue: 0.36).opacity(0.34))
            }
        case .personality:
            ZStack {
                Text("🍶")
                    .font(.system(size: 38))
                    .rotationEffect(.degrees(8))
                Text("♥")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(Color(red: 0.94, green: 0.30, blue: 0.42))
                    .offset(x: -30, y: -12)
                Text("♥")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(Color(red: 0.94, green: 0.30, blue: 0.42))
                    .offset(x: 30, y: -18)
            }
        case .loves:
            ZStack {
                Text("🍣")
                    .font(.system(size: 46))
                    .rotationEffect(.degrees(-10))
                Text("✦")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(Color(red: 1.0, green: 0.76, blue: 0.16))
                    .offset(x: -36, y: -14)
                Text("✦")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(Color(red: 1.0, green: 0.76, blue: 0.16))
                    .offset(x: 34, y: -24)
            }
        case .funFact:
            ZStack {
                Image(systemName: "face.smiling")
                    .font(.system(size: 38, weight: .regular))
                    .foregroundStyle(Color(red: 0.38, green: 0.20, blue: 0.10).opacity(0.62))
                ForEach(0..<3, id: \.self) { index in
                    Capsule()
                        .fill(Color(red: 0.94, green: 0.36, blue: 0.40).opacity(0.70))
                        .frame(width: 10, height: 2.5)
                        .rotationEffect(.degrees(Double(index - 1) * 28))
                        .offset(x: -36, y: CGFloat(index - 1) * 10)
                }
            }
        case .firstVisited:
            VStack(spacing: 0) {
                Text("寿司チャンプルー")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                Text("Oishii Sushi!")
                    .font(.system(size: 13, weight: .black, design: .rounded))
            }
            .foregroundStyle(Color(red: 0.92, green: 0.34, blue: 0.34).opacity(0.46))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(red: 0.92, green: 0.34, blue: 0.34).opacity(0.40), lineWidth: 2)
            )
            .rotationEffect(.degrees(-4))
        }
    }

    // MARK: Blossoms

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
}

/// A finished, full-page profile illustration from Screenshots/Collections.
/// Everything is baked into the art except the First Visited date, which is
/// written into the empty box so it stays dynamic.
private struct ProfileCardImage: View {
    var character: CollectionCharacter
    var firstVisitedText: String
    var onBack: () -> Void

    /// Size of the source illustrations, in pixels.
    private static let designSize = CGSize(width: 850, height: 1850)
    /// Where the date starts inside the First Visited box, in source pixels.
    private static let firstVisitedX: CGFloat = 172
    /// Vertical center of the First Visited box's writing line, per character, in source pixels.
    private static let firstVisitedY: [String: CGFloat] = [
        "tuna-the-gamer": 1696,
        "salmon-the-food-tester": 1676,
        "tamago-the-chill-one": 1670,
        "uni-the-fancy-foodie": 1676,
        "unagi-the-surfer": 1660,
        "mackerel-the-photographer": 1644,
        "squid-the-dj": 1656,
        "yellowtail-the-traveler": 1708,
        "scallop-the-fisherman": 1644,
        "mama-roe-the-shopper": 1716,
        "red-snapper-the-taiko-master": 1686,
        "sushi-roll-the-librarian": 1666,
        "lobster-crab-the-sumo-bros": 1666
    ]

    static func assetName(for character: CollectionCharacter) -> String {
        character.artworkAssetName + "Profile"
    }

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let scale = width / Self.designSize.width
            let height = Self.designSize.height * scale
            let dateY = (Self.firstVisitedY[character.id] ?? 1670) * scale

            ZStack(alignment: .topLeading) {
                ScrollView(showsIndicators: false) {
                    Image(Self.assetName(for: character))
                        .resizable()
                        .frame(width: width, height: height)
                        .overlay(alignment: .topLeading) {
                            Text(firstVisitedText)
                                .font(.system(size: 27 * scale, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(red: 0.36, green: 0.18, blue: 0.08))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .frame(width: 300 * scale, alignment: .leading)
                                .frame(height: 40 * scale)
                                .offset(x: Self.firstVisitedX * scale, y: dateY - 20 * scale)
                                .accessibilityHidden(true)
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(accessibilitySummary)
                }
                .ignoresSafeArea()
                .background(Color(red: 0.99, green: 0.92, blue: 0.84).ignoresSafeArea())

                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(Color(red: 0.24, green: 0.12, blue: 0.06))
                        .frame(width: 42, height: 42)
                        .background(Circle().fill(Color(red: 1.0, green: 0.92, blue: 0.80)))
                        .overlay(Circle().stroke(Color.white.opacity(0.80), lineWidth: 2))
                        .shadow(color: .black.opacity(0.24), radius: 8, y: 4)
                }
                .accessibilityLabel("Back")
                // The ZStack already sits inside the safe area, so this is just below the status bar.
                .padding(.leading, 10)
                .padding(.top, 8)
            }
        }
        // Dark only so the status bar text turns white over the artwork.
        .preferredColorScheme(.dark)
    }

    private var accessibilitySummary: String {
        [
            "\(character.name), \(character.role).",
            character.quote,
            "About: \(character.about)",
            "Personality: \(character.personality)",
            "Loves: \(character.loves)",
            "Fun fact: \(character.funFact)",
            "First visited: \(firstVisitedText)"
        ].joined(separator: " ")
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
            Image(character.artworkAssetName)
                .resizable()
                .scaledToFit()
                .accessibilityLabel("\(character.name), \(character.role) artwork")
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

/// Text with a solid sticker-style outline, like the lettering on the artwork.
private struct OutlinedText: View {
    var text: String
    var font: Font
    var fill: Color
    var outline: Color
    var width: CGFloat

    var body: some View {
        ZStack {
            ForEach(0..<12, id: \.self) { index in
                let angle = Double(index) * .pi / 6
                Text(text)
                    .font(font)
                    .foregroundStyle(outline)
                    .offset(x: cos(angle) * width, y: sin(angle) * width)
            }
            Text(text)
                .font(font)
                .foregroundStyle(fill)
        }
    }
}

/// A wooden sign with roughly cut ends, used for the name plaque.
private struct WoodPlankShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        path.move(to: CGPoint(x: 14, y: 3))
        path.addLine(to: CGPoint(x: w - 12, y: 0))
        path.addLine(to: CGPoint(x: w, y: h * 0.20))
        path.addLine(to: CGPoint(x: w - 7, y: h * 0.52))
        path.addLine(to: CGPoint(x: w - 1, y: h * 0.84))
        path.addLine(to: CGPoint(x: w - 14, y: h))
        path.addLine(to: CGPoint(x: 10, y: h - 3))
        path.addLine(to: CGPoint(x: 0, y: h * 0.74))
        path.addLine(to: CGPoint(x: 7, y: h * 0.44))
        path.addLine(to: CGPoint(x: 0, y: h * 0.16))
        path.closeSubpath()
        return path
    }
}

/// A wooden heading tab with a notched, hand-cut right end.
private struct WoodTabShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        path.move(to: CGPoint(x: 6, y: 2))
        path.addLine(to: CGPoint(x: w - 14, y: 0))
        path.addLine(to: CGPoint(x: w - 1, y: h * 0.30))
        path.addLine(to: CGPoint(x: w - 9, y: h * 0.52))
        path.addLine(to: CGPoint(x: w, y: h * 0.80))
        path.addLine(to: CGPoint(x: w - 16, y: h))
        path.addLine(to: CGPoint(x: 6, y: h - 1))
        path.addQuadCurve(to: CGPoint(x: 6, y: 2), control: CGPoint(x: -4, y: h * 0.5))
        path.closeSubpath()
        return path
    }
}

/// Faint grain lines drawn over the wood gradient.
private struct WoodGrain: View {
    var body: some View {
        Canvas { context, size in
            let lineCount = max(3, Int(size.height / 9))
            for index in 0..<lineCount {
                let y = size.height * (CGFloat(index) + 0.5) / CGFloat(lineCount)
                let wobble = CGFloat(index % 2 == 0 ? 2.2 : -1.8)
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addCurve(
                    to: CGPoint(x: size.width, y: y + wobble * 0.5),
                    control1: CGPoint(x: size.width * 0.33, y: y - wobble),
                    control2: CGPoint(x: size.width * 0.66, y: y + wobble)
                )
                let tone = index % 3 == 0 ? Color.white.opacity(0.10) : Color.black.opacity(0.12)
                context.stroke(path, with: .color(tone), lineWidth: 1)
            }
        }
        .allowsHitTesting(false)
    }
}

/// Japanese seigaiha (blue ocean wave) pattern for the paper page.
private struct SeigaihaPattern: View {
    var background: Color
    var line: Color
    var radius: CGFloat = 22

    var body: some View {
        Canvas { context, size in
            let columnStep = radius * 2
            let rowStep = radius * 0.5
            var row = 0
            var y: CGFloat = 0

            while y < size.height + radius {
                var x: CGFloat = row.isMultiple(of: 2) ? 0 : radius
                while x < size.width + radius {
                    let center = CGPoint(x: x, y: y)
                    let outer = Path(ellipseIn: CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2))
                    context.fill(outer, with: .color(background))
                    for ring in 0..<4 {
                        let ringRadius = radius * (1 - CGFloat(ring) * 0.23)
                        var arc = Path()
                        arc.addArc(center: center, radius: ringRadius, startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
                        context.stroke(arc, with: .color(line), lineWidth: 1.1)
                    }
                    x += columnStep
                }
                y += rowStep
                row += 1
            }
        }
        .allowsHitTesting(false)
    }
}

/// A little maki roll for the About heading.
private struct MakiIcon: View {
    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)
            ZStack {
                Circle()
                    .fill(Color(red: 0.12, green: 0.18, blue: 0.12))
                Circle()
                    .stroke(Color(red: 0.30, green: 0.40, blue: 0.24), lineWidth: size * 0.04)
                    .padding(size * 0.03)
                Circle()
                    .fill(Color(red: 1.0, green: 0.99, blue: 0.95))
                    .padding(size * 0.12)
                ForEach(0..<10, id: \.self) { index in
                    let angle = Double(index) * .pi / 5
                    Circle()
                        .fill(Color(red: 0.90, green: 0.88, blue: 0.82))
                        .frame(width: size * 0.08, height: size * 0.08)
                        .offset(x: cos(angle) * size * 0.27, y: sin(angle) * size * 0.27)
                }
                Circle()
                    .fill(Color(red: 0.97, green: 0.47, blue: 0.24))
                    .frame(width: size * 0.30, height: size * 0.30)
                Circle()
                    .fill(Color(red: 0.45, green: 0.72, blue: 0.28))
                    .frame(width: size * 0.12, height: size * 0.12)
                    .offset(x: size * 0.10, y: -size * 0.08)
            }
            .frame(width: size, height: size)
        }
    }
}
