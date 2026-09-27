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

            HStack {
                decorativePetal
                Spacer()
                decorativePetal
            }
            .padding(.horizontal, 20)

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
            profileSection("About", character.about, icon: "takeoutbag.and.cup.and.straw.fill", accent: .salmon)
            profileSection("Personality", character.personality, icon: "seal.fill", accent: .sakura)
            profileSection("Loves", character.loves, icon: "heart.fill", accent: .heart)
            profileSection("Fun Fact", character.funFact, icon: "star.fill", accent: .gold)
            profileSection("First Visited", firstVisitedText, icon: "calendar.badge.checkmark", accent: .calendar)
        }
        .padding(.horizontal, 18)
        .padding(.top, 10)
        .padding(.bottom, 34)
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

    private var decorativePetal: some View {
        Image(systemName: "seal.fill")
            .font(.system(size: 18, weight: .black))
            .foregroundStyle(Color(red: 1.0, green: 0.54, blue: 0.62).opacity(0.55))
            .rotationEffect(.degrees(-16))
    }

    private var firstVisitedText: String {
        guard let date = character.dateFirstMet else { return "Not met yet" }
        return date.formatted(date: .long, time: .omitted)
    }

    private func profileSection(_ title: String, _ value: String, icon: String, accent: ProfileAccent) -> some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(red: 1.0, green: 0.95, blue: 0.84).opacity(0.96))
                .overlay(alignment: .trailing) {
                    sectionWatermark(accent: accent)
                        .padding(.trailing, 18)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color(red: 0.77, green: 0.43, blue: 0.22).opacity(0.34), lineWidth: 1.5)
                )
                .shadow(color: Color(red: 0.38, green: 0.18, blue: 0.08).opacity(0.13), radius: 8, y: 5)

            VStack(alignment: .leading, spacing: 13) {
                HStack(spacing: 9) {
                    Image(systemName: icon)
                        .font(.system(size: 17, weight: .black))
                        .foregroundStyle(accent.symbolColor)
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(Color(red: 1.0, green: 0.84, blue: 0.65)))
                        .overlay(Circle().stroke(Color.white.opacity(0.8), lineWidth: 2))
                        .shadow(color: .black.opacity(0.12), radius: 4, y: 2)

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

    private func sectionWatermark(accent: ProfileAccent) -> some View {
        Image(systemName: accent.watermarkSymbol)
            .font(.system(size: accent.watermarkSize, weight: .black))
            .foregroundStyle(accent.watermarkColor)
            .rotationEffect(.degrees(accent.rotation))
    }
}

private enum ProfileAccent {
    case salmon
    case sakura
    case heart
    case gold
    case calendar

    var symbolColor: Color {
        switch self {
        case .salmon:
            return Color(red: 0.93, green: 0.35, blue: 0.16)
        case .sakura:
            return Color(red: 0.98, green: 0.36, blue: 0.52)
        case .heart:
            return Color(red: 0.92, green: 0.12, blue: 0.26)
        case .gold:
            return Color(red: 0.96, green: 0.61, blue: 0.04)
        case .calendar:
            return Color(red: 0.55, green: 0.23, blue: 0.10)
        }
    }

    var watermarkSymbol: String {
        switch self {
        case .salmon:
            return "fish.fill"
        case .sakura:
            return "seal.fill"
        case .heart:
            return "heart.fill"
        case .gold:
            return "face.smiling"
        case .calendar:
            return "stamp.fill"
        }
    }

    var watermarkColor: Color {
        switch self {
        case .salmon:
            return Color(red: 0.93, green: 0.35, blue: 0.16).opacity(0.13)
        case .sakura, .heart:
            return Color(red: 1.0, green: 0.35, blue: 0.48).opacity(0.16)
        case .gold:
            return Color(red: 0.45, green: 0.20, blue: 0.09).opacity(0.17)
        case .calendar:
            return Color(red: 0.95, green: 0.36, blue: 0.28).opacity(0.16)
        }
    }

    var watermarkSize: CGFloat {
        switch self {
        case .calendar:
            return 58
        default:
            return 48
        }
    }

    var rotation: Double {
        switch self {
        case .salmon:
            return -9
        case .sakura:
            return 12
        case .heart:
            return -10
        case .gold:
            return 0
        case .calendar:
            return -5
        }
    }
}

private struct ProfileCharacterArtwork: View {
    var character: CollectionCharacter

    var body: some View {
        if UIImage(named: character.artworkAssetName) != nil {
            Image(character.artworkAssetName)
                .resizable()
                .scaledToFill()
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
