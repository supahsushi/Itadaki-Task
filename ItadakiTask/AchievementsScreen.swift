import SwiftUI

struct AchievementsScreen: View {
    var achievements: [Achievement]
    var pendingUnlockIDs: [String]
    var collectedUnlockIDs: Set<String>
    var collectionCharacters: [CollectionCharacter]

    @Environment(\.dismiss) private var dismiss
    @State private var selectedAchievement: Achievement?
    #if DEBUG
    @State private var replayAchievement: Achievement?
    #endif

    private let columns = [
        GridItem(.adaptive(minimum: 104), spacing: 14)
    ]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(achievements) { achievement in
                        VStack(spacing: 8) {
                            Button {
                                selectedAchievement = achievement
                            } label: {
                                AchievementBadgeCell(
                                    achievement: achievement,
                                    isPendingReveal: pendingUnlockIDs.contains(achievement.id)
                                )
                            }
                            .buttonStyle(.plain)

                            #if DEBUG
                            if achievement.isUnlocked {
                                Button {
                                    replayAchievement = achievement
                                } label: {
                                    Label("Replay", systemImage: "play.circle.fill")
                                        .font(.system(size: 12, weight: .black, design: .rounded))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(Color(red: 1.0, green: 0.23, blue: 0.48))
                                        )
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Replay \(achievement.title) gachapon animation")
                            }
                            #endif
                        }
                    }
                }
                .padding(18)
            }
            .background(Color(red: 0.98, green: 0.91, blue: 0.80))
            .navigationTitle("Achievements")
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
            .sheet(item: $selectedAchievement) { achievement in
                AchievementDetailView(
                    achievement: achievement,
                    isRewardCollected: collectedUnlockIDs.contains(achievement.id),
                    customerMet: customerMet(for: achievement)
                )
                    .presentationDetents([.large])
                    .presentationBackground(Color(red: 0.98, green: 0.91, blue: 0.80))
            }
            #if DEBUG
            .fullScreenCover(item: $replayAchievement) { achievement in
                GachaponUnlockView(achievement: achievement) {
                    replayAchievement = nil
                }
            }
            #endif
        }
        .preferredColorScheme(.light)
    }

    private func customerMet(for achievement: Achievement) -> CollectionCharacter? {
        guard achievement.isUnlocked,
              let characterID = CollectionManager.characterID(for: achievement.id) else {
            return nil
        }
        return collectionCharacters.first { $0.id == characterID && $0.isUnlocked }
    }
}

struct AchievementBadgeCell: View {
    var achievement: Achievement
    var isPendingReveal: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                BadgeArtwork(achievement: achievement)
                    .frame(width: 86, height: 86)
                    .clipShape(Circle())
                    .saturation(achievement.isUnlocked ? 1 : 0)
                    .opacity(achievement.isUnlocked ? 1 : 0.28)

                if !achievement.isUnlocked {
                    Circle()
                        .fill(Color.black.opacity(0.44))
                    Image(systemName: "lock.fill")
                        .font(.system(size: 24, weight: .black))
                        .foregroundStyle(.white)
                }

                if isPendingReveal {
                    Circle()
                        .stroke(Color(red: 1.0, green: 0.23, blue: 0.48), lineWidth: 4)
                }
            }
            .frame(width: 92, height: 92)

            Text(achievement.title)
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(Color(red: 0.12, green: 0.08, blue: 0.06))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(height: 32, alignment: .top)

            ProgressView(value: achievement.progressFraction)
                .tint(achievement.isUnlocked ? Color(red: 1.0, green: 0.23, blue: 0.48) : Color.secondary)
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(red: 0.74, green: 0.42, blue: 0.22).opacity(0.28), lineWidth: 1)
        )
        .accessibilityLabel("\(achievement.title), \(achievement.isUnlocked ? "unlocked" : "locked")")
    }
}

struct BadgeArtwork: View {
    var achievement: Achievement

    var body: some View {
        if UIImage(named: achievement.badgeAssetName) != nil {
            Image(achievement.badgeAssetName)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                Circle()
                    .fill(Color(red: 0.87, green: 0.66, blue: 0.38).gradient)
                Image(systemName: "seal.fill")
                    .font(.system(size: 42, weight: .black))
                    .foregroundStyle(.white.opacity(0.84))
            }
        }
    }
}

struct AchievementDetailView: View {
    var achievement: Achievement
    var isRewardCollected: Bool
    var customerMet: CollectionCharacter?

    private var ink: Color {
        Color(red: 0.13, green: 0.08, blue: 0.05)
    }

    private var softInk: Color {
        Color(red: 0.42, green: 0.31, blue: 0.23)
    }

    var body: some View {
        if UIImage(named: AchievementDetailImage.assetName(for: achievement)) != nil {
            AchievementDetailImage(achievement: achievement, unlockedText: unlockedDateText)
        } else {
            drawnDetail
        }
    }

    /// Fallback for an achievement without a finished detail illustration.
    private var drawnDetail: some View {
        GeometryReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    achievementHero(width: proxy.size.width)

                    VStack(spacing: 12) {
                        achievementInfoCard(
                            title: "Requirement",
                            value: achievement.definition.requirement,
                            icon: "checklist.checked"
                        )

                        achievementInfoCard(
                            title: "Progress",
                            value: "\(achievement.clampedProgress) / \(achievement.target)\(achievement.isUnlocked ? "  ✓" : "")",
                            icon: "target",
                            showsProgressBar: true
                        )

                        achievementInfoCard(
                            title: achievement.isUnlocked ? "Unlocked" : "Status",
                            value: unlockStatusText,
                            icon: achievement.isUnlocked ? "calendar.badge.checkmark" : "lock.fill"
                        )

                        achievementInfoCard(
                            title: "Reward Status",
                            value: rewardStatusText,
                            icon: "star.fill",
                            isGold: achievement.isUnlocked && isRewardCollected
                        )

                        if let customerMet {
                            customerMetCard(customerMet)
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 28)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 22)
            }
            .background(achievementBackground)
        }
        .preferredColorScheme(.light)
    }

    private func achievementHero(width: CGFloat) -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 1.0, green: 0.86, blue: 0.31).opacity(0.50),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: min(width * 0.45, 220)
                        )
                    )
                    .frame(width: min(width * 0.76, 380), height: min(width * 0.76, 380))

                DetailBadgeArtwork(achievement: achievement)
                    .frame(width: min(width * 0.68, 340))
                    .saturation(achievement.isUnlocked ? 1 : 0)
                    .opacity(achievement.isUnlocked ? 1 : 0.38)
                    .shadow(color: Color(red: 0.62, green: 0.28, blue: 0.05).opacity(0.22), radius: 18, y: 10)
                    .overlay {
                        if !achievement.isUnlocked {
                            Circle()
                                .fill(Color.black.opacity(0.34))
                            Image(systemName: "lock.fill")
                                .font(.system(size: min(48, width * 0.12), weight: .black))
                                .foregroundStyle(.white)
                        }
                    }

                Image(systemName: "sparkles")
                    .font(.system(size: 24, weight: .black))
                    .foregroundStyle(Color(red: 1.0, green: 0.77, blue: 0.25))
                    .offset(x: min(width * 0.27, 132), y: -min(width * 0.22, 104))
            }

            VStack(spacing: 6) {
                Text(achievement.title)
                    .font(.system(size: min(40, width * 0.10), weight: .black, design: .rounded))
                    .foregroundStyle(ink)
                    .multilineTextAlignment(.center)

                Text(achievement.description)
                    .font(.system(size: min(17, width * 0.044), weight: .bold, design: .rounded))
                    .foregroundStyle(softInk)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 28)
            }
        }
        .padding(.horizontal, 18)
    }

    private var achievementBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.89, blue: 0.70),
                    Color(red: 0.99, green: 0.78, blue: 0.50),
                    Color(red: 0.88, green: 0.49, blue: 0.25)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack {
                HStack {
                    waveAccent
                    Spacer()
                    sakuraAccent
                }
                .padding(.horizontal, 28)
                .padding(.top, 28)

                Spacer()

                HStack {
                    sakuraAccent.opacity(0.70)
                    Spacer()
                    waveAccent.opacity(0.70)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 36)
            }
            .allowsHitTesting(false)
        }
    }

    private var sakuraAccent: some View {
        Image(systemName: "seal.fill")
            .font(.system(size: 32, weight: .black))
            .foregroundStyle(Color(red: 1.0, green: 0.43, blue: 0.53).opacity(0.22))
            .rotationEffect(.degrees(-16))
    }

    private var waveAccent: some View {
        Image(systemName: "water.waves")
            .font(.system(size: 32, weight: .black))
            .foregroundStyle(Color(red: 0.12, green: 0.38, blue: 0.55).opacity(0.20))
    }

    private var unlockStatusText: String {
        if let unlockDate = achievement.unlockDate {
            return unlockDate.formatted(date: .abbreviated, time: .shortened)
        }
        return "Locked"
    }

    private var unlockedDateText: String {
        achievement.unlockDate?.formatted(date: .abbreviated, time: .shortened) ?? "Not unlocked yet"
    }

    private var rewardStatusText: String {
        if !achievement.isUnlocked {
            return "Reward locked"
        }
        return isRewardCollected ? "Reward Collected!" : "Reward waiting to be collected"
    }

    private func achievementInfoCard(
        title: String,
        value: String,
        icon: String,
        showsProgressBar: Bool = false,
        isGold: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack(spacing: 9) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(isGold ? Color(red: 0.64, green: 0.34, blue: 0.02) : Color.white)
                    .frame(width: 30, height: 30)
                    .background(
                        Circle()
                            .fill(isGold ? Color(red: 1.0, green: 0.79, blue: 0.22) : Color(red: 0.42, green: 0.20, blue: 0.09))
                    )

                Text(title.uppercased())
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(Color.white)
                    .tracking(1.0)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.54, green: 0.26, blue: 0.11),
                                        Color(red: 0.30, green: 0.13, blue: 0.06)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    )

                Spacer()
            }

            Text(value)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(ink)
                .fixedSize(horizontal: false, vertical: true)

            if showsProgressBar {
                ProgressView(value: achievement.progressFraction)
                    .tint(Color(red: 1.0, green: 0.22, blue: 0.47))
                    .scaleEffect(x: 1, y: 1.25, anchor: .center)
            }
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(isGold ? Color(red: 1.0, green: 0.92, blue: 0.61).opacity(0.96) : Color(red: 1.0, green: 0.96, blue: 0.88).opacity(0.95))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(isGold ? Color(red: 0.95, green: 0.58, blue: 0.09).opacity(0.56) : Color(red: 0.72, green: 0.42, blue: 0.22).opacity(0.26), lineWidth: 1.5)
        }
        .shadow(color: Color(red: 0.42, green: 0.18, blue: 0.06).opacity(0.09), radius: 9, y: 5)
    }

    private func customerMetCard(_ character: CollectionCharacter) -> some View {
        HStack(spacing: 13) {
            CollectionCharacterArtwork(character: character)
                .frame(width: 74, height: 74)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.78), lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.12), radius: 6, y: 4)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 7) {
                    Image(systemName: "person.crop.circle.badge.checkmark")
                        .font(.system(size: 13, weight: .black))
                        .foregroundStyle(Color(red: 0.93, green: 0.19, blue: 0.42))
                    Text("CUSTOMER MET")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 0.36, green: 0.20, blue: 0.12))
                        .tracking(0.9)
                }

                Text(character.name)
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(Color(red: 0.93, green: 0.19, blue: 0.42))
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)

                Text(character.role)
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.86, blue: 0.88).opacity(0.96),
                            Color(red: 1.0, green: 0.95, blue: 0.90).opacity(0.96)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(red: 0.95, green: 0.43, blue: 0.56).opacity(0.34), lineWidth: 1.5)
        }
        .shadow(color: Color(red: 0.42, green: 0.18, blue: 0.06).opacity(0.09), radius: 9, y: 5)
    }
}

/// A finished, full-page achievement illustration from Screenshots/New Achievement Badges Designs.
/// Everything is baked into the art except the unlock date, which is written into
/// the empty Unlocked box so it stays dynamic.
private struct AchievementDetailImage: View {
    var achievement: Achievement
    var unlockedText: String

    /// Size of the source illustrations, in pixels.
    private static let designSize = CGSize(width: 850, height: 1850)
    /// Where the date starts inside the Unlocked box, in source pixels.
    private static let unlockedX: CGFloat = 204
    /// Vertical center of the Unlocked box's writing line, per achievement, in source pixels.
    /// Healthy Bite, On the Grind, and Brain Food have no Unlocked box in their art.
    private static let unlockedY: [String: CGFloat] = [
        "first-bite": 1440,
        "full-plate": 1444,
        "chefs-special": 1441,
        "three-day-streak": 1439,
        "seven-day-streak": 1456,
        "fourteen-day-streak": 1436,
        "thirty-day-streak": 1459,
        "sixty-day-streak": 1459,
        "sushi-regular": 1545,
        "hundred-day-streak": 1543,
        "sushi-lover": 1502,
        "omakase-master": 1553,
        "active-sushi": 1537,
        "take-care": 1632,
        "good-company": 1553
    ]

    static func assetName(for achievement: Achievement) -> String {
        achievement.definition.badgeAssetName + "Detail"
    }

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let scale = width / Self.designSize.width
            let height = Self.designSize.height * scale

            ScrollView(showsIndicators: false) {
                Image(Self.assetName(for: achievement))
                    .resizable()
                    .frame(width: width, height: height)
                    .overlay(alignment: .topLeading) {
                        if let dateY = Self.unlockedY[achievement.id] {
                            Text(unlockedText)
                                .font(.system(size: 25 * scale, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(red: 0.36, green: 0.18, blue: 0.08))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .frame(width: 400 * scale, height: 40 * scale, alignment: .leading)
                                .offset(x: Self.unlockedX * scale, y: dateY * scale - 20 * scale)
                                .accessibilityHidden(true)
                        }
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(accessibilitySummary)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .preferredColorScheme(.light)
    }

    private var accessibilitySummary: String {
        [
            "\(achievement.title) achievement.",
            achievement.definition.description,
            "Requirement: \(achievement.definition.requirement).",
            "Progress: \(achievement.clampedProgress) of \(achievement.target).",
            achievement.isUnlocked ? "Unlocked \(unlockedText)." : "Not unlocked yet."
        ].joined(separator: " ")
    }
}

private struct DetailBadgeArtwork: View {
    var achievement: Achievement

    var body: some View {
        if UIImage(named: achievement.badgeAssetName) != nil {
            Image(achievement.badgeAssetName)
                .resizable()
                .scaledToFit()
        } else {
            Circle()
                .fill(Color(red: 0.87, green: 0.66, blue: 0.38).gradient)
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    Image(systemName: "seal.fill")
                        .font(.system(size: 72, weight: .black))
                        .foregroundStyle(.white.opacity(0.84))
                }
        }
    }
}
