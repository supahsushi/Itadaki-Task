import SwiftUI

/// The Home tab: the player's profile, drawn over the painted "My Profile" artwork.
/// Positions are in the artwork's own pixels (853 × 1844).
struct ProfileScreen: View {
    @Binding var name: String
    var levelInfo: StreakLevelInfo
    var totalSushiEaten: Int
    var eatenToday: Int
    var mealLimit: Int
    var achievements: [Achievement]
    var characters: [CollectionCharacter]
    var navigate: (AddTaskMenuDestination) -> Void

    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var premium = PremiumStore.shared
    @State private var showingPremium = false
    @State private var showingAlarms = false
    @State private var isRestoring = false
    @State private var restoreMessage: String?
    @State private var showingNameEditor = false
    @State private var draftName = ""

    private static let artworkSize = CGSize(width: 853, height: 1844)
    private static let ink = Color(red: 0.24, green: 0.13, blue: 0.06)
    private static let softInk = Color(red: 0.43, green: 0.27, blue: 0.16)

    private static let headerLayout = HomeArtworkLayout(
        artworkSize: artworkSize,
        profilePatch: nil,
        nameLeadingX: 127, nameCenterY: 116, nameFontSize: 25,
        levelCenterY: 142, levelFontSize: 20,
        meterRect: CGRect(x: 127, y: 156, width: 93, height: 10),
        meterFill: [Color.white, Color(red: 1.0, green: 0.78, blue: 0.86)],
        countPatch: nil,
        countCenter: CGPoint(x: 772, y: 118), countFontSize: 40,
        labelPatch: nil,
        labelCenter: CGPoint(x: 733, y: 160), labelFontSize: 21, labelText: "Sushi Eaten Today"
    )

    /// Painted placeholder text in the art ("Jin", "4 / 18", "4 / 13") is covered with these.
    private static let namePatch = HomeArtworkLayout.Patch(
        rect: CGRect(x: 330, y: 748, width: 218, height: 48),
        top: Color(red: 0.988, green: 0.781, blue: 0.538),
        bottom: Color(red: 0.986, green: 0.765, blue: 0.527)
    )
    private static let badgeCountPatch = HomeArtworkLayout.Patch(
        rect: CGRect(x: 332, y: 1174, width: 72, height: 30),
        top: Color(red: 0.986, green: 0.830, blue: 0.618),
        bottom: Color(red: 0.990, green: 0.833, blue: 0.629)
    )
    private static let customerCountPatch = HomeArtworkLayout.Patch(
        rect: CGRect(x: 722, y: 1174, width: 78, height: 30),
        top: Color(red: 0.984, green: 0.818, blue: 0.609),
        bottom: Color(red: 0.990, green: 0.829, blue: 0.626)
    )

    private static let badgeSlots: [CGFloat] = [102, 186, 269, 353]
    private static let customerSlots: [CGFloat] = [502, 586, 670, 752]
    private static let slotCenterY: CGFloat = 1262
    private static let slotDiameter: CGFloat = 64

    var body: some View {
        GeometryReader { proxy in
            let frame = filledFrame(container: proxy.size)
            let mapper = ArtworkMapper(frame: frame, artworkSize: Self.artworkSize)

            ZStack(alignment: .topLeading) {
                ArtworkBackground(name: "HomeProfile", artworkSize: Self.artworkSize)

                ProfileStreakLevelOverlay(name: displayName, levelInfo: levelInfo, layout: Self.headerLayout, mapper: mapper)
                MealCountOverlay(eatenCount: eatenToday, maxCount: mealLimit, layout: Self.headerLayout, mapper: mapper)

                nameplate(mapper: mapper)
                levelCard(mapper: mapper)
                streakCard(mapper: mapper)
                totalCard(mapper: mapper)
                collectionRows(mapper: mapper)
                premiumButton(mapper: mapper)
                restoreButton(mapper: mapper)
                alarmButton(mapper: mapper)
                navigationZones(mapper: mapper)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
        }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingPremium) {
            PremiumSheet()
        }
        .sheet(isPresented: $showingAlarms) {
            ChefAlarmPickerSheet()
        }
        .alert(
            "Restore Purchase",
            isPresented: Binding(get: { restoreMessage != nil }, set: { if !$0 { restoreMessage = nil } })
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(restoreMessage ?? "")
        }
        .alert("Your name", isPresented: $showingNameEditor) {
            TextField("Name", text: $draftName)
            Button("Save") {
                let trimmed = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    name = String(trimmed.prefix(20))
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private var displayName: String {
        name.isEmpty ? "Chef's Guest" : name
    }

    // MARK: Cards

    private func nameplate(mapper: ArtworkMapper) -> some View {
        let scale = mapper.scale
        let pencil = mapper.point(CGPoint(x: 576, y: 772))
        return ZStack(alignment: .topLeading) {
            ArtworkPatch(patch: Self.namePatch, mapper: mapper)
            text(displayName, size: 40 * scale, weight: .black)
                .frame(width: 210 * scale)
                .position(mapper.point(CGPoint(x: 425, y: 772)))
                .allowsHitTesting(false)

            // The painted pencil button.
            Button {
                draftName = name
                showingNameEditor = true
            } label: {
                Color.black.opacity(0.001)
            }
            .buttonStyle(.plain)
            .frame(width: 56 * scale, height: 56 * scale)
            .position(pencil)
            .accessibilityLabel("Edit name")
        }
    }

    private func levelCard(mapper: ArtworkMapper) -> some View {
        let scale = mapper.scale
        let bar = mapper.rect(CGRect(x: 75, y: 939, width: 352, height: 17))
        return ZStack(alignment: .topLeading) {
            text("Lv. \(levelInfo.level)", size: 36 * scale, weight: .black)
                .frame(width: 180 * scale, alignment: .leading)
                .position(mapper.point(CGPoint(x: 75 + 90, y: 905)))

            text(nextLevelText, size: 19 * scale, weight: .semibold, color: Self.softInk)
                .frame(width: 200 * scale, alignment: .trailing)
                .position(mapper.point(CGPoint(x: 440 - 100, y: 907)))

            Capsule()
                .fill(LinearGradient(
                    colors: [Color(red: 1.0, green: 0.80, blue: 0.35), Color(red: 1.0, green: 0.55, blue: 0.20)],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .frame(width: max(bar.height, bar.width * levelInfo.progress), height: bar.height)
                .opacity(levelInfo.progress > 0 ? 1 : 0)
                .position(x: bar.minX + max(bar.height, bar.width * levelInfo.progress) / 2, y: bar.midY)
        }
        .allowsHitTesting(false)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Level \(levelInfo.level). \(nextLevelText)")
    }

    private func streakCard(mapper: ArtworkMapper) -> some View {
        let days = levelInfo.streakDays
        return text("\(days) \(days == 1 ? "day" : "days")", size: 46 * mapper.scale, weight: .black)
            .frame(width: 300 * mapper.scale)
            .position(mapper.point(CGPoint(x: 640, y: 928)))
            .allowsHitTesting(false)
            .accessibilityLabel("Current streak, \(days) days")
    }

    private func totalCard(mapper: ArtworkMapper) -> some View {
        text("\(totalSushiEaten) sushi", size: 44 * mapper.scale, weight: .black)
            .frame(width: 520 * mapper.scale, alignment: .leading)
            .position(mapper.point(CGPoint(x: 80 + 260, y: 1098)))
            .allowsHitTesting(false)
            .accessibilityLabel("Total sushi eaten, \(totalSushiEaten)")
    }

    private func collectionRows(mapper: ArtworkMapper) -> some View {
        let scale = mapper.scale
        let earned = achievements
            .filter(\.isUnlocked)
            .sorted { ($0.unlockDate ?? .distantPast) > ($1.unlockDate ?? .distantPast) }
        let met = characters
            .filter(\.isUnlocked)
            .sorted { ($0.dateFirstMet ?? .distantPast) > ($1.dateFirstMet ?? .distantPast) }
        let diameter = Self.slotDiameter * scale

        return ZStack(alignment: .topLeading) {
            ArtworkPatch(patch: Self.badgeCountPatch, mapper: mapper)
            text("\(earned.count) / \(achievements.count)", size: 24 * scale, weight: .bold)
                .position(mapper.point(CGPoint(x: 368, y: 1189)))

            ArtworkPatch(patch: Self.customerCountPatch, mapper: mapper)
            text("\(met.count) / \(characters.count)", size: 24 * scale, weight: .bold)
                .position(mapper.point(CGPoint(x: 761, y: 1189)))

            ForEach(Array(earned.prefix(Self.badgeSlots.count).enumerated()), id: \.element.id) { index, achievement in
                BadgeArtwork(achievement: achievement)
                    .frame(width: diameter, height: diameter)
                    .clipShape(Circle())
                    .position(mapper.point(CGPoint(x: Self.badgeSlots[index], y: Self.slotCenterY)))
            }

            ForEach(Array(met.prefix(Self.customerSlots.count).enumerated()), id: \.element.id) { index, character in
                CollectionCharacterArtwork(character: character)
                    .frame(width: diameter, height: diameter)
                    .clipShape(Circle())
                    .position(mapper.point(CGPoint(x: Self.customerSlots[index], y: Self.slotCenterY)))
            }

            // Tap either card to open the full screen.
            Button { navigate(.achievements) } label: { Color.black.opacity(0.001) }
                .buttonStyle(.plain)
                .frame(width: 380 * scale, height: 170 * scale)
                .position(mapper.point(CGPoint(x: 225, y: 1240)))
                .accessibilityLabel("Badges earned, \(earned.count) of \(achievements.count)")

            Button { navigate(.collection) } label: { Color.black.opacity(0.001) }
                .buttonStyle(.plain)
                .frame(width: 380 * scale, height: 170 * scale)
                .position(mapper.point(CGPoint(x: 625, y: 1240)))
                .accessibilityLabel("Customers met, \(met.count) of \(characters.count)")
        }
    }

    private func premiumButton(mapper: ArtworkMapper) -> some View {
        let scale = mapper.scale
        return Button {
            showingPremium = true
        } label: {
            HStack(spacing: 10 * scale) {
                Image(systemName: premium.isPremium ? "checkmark.seal.fill" : "crown.fill")
                    .font(.system(size: 26 * scale, weight: .black))
                Text(premium.isPremium ? "Premium Unlocked" : "Unlock Premium")
                    .font(.system(size: 28 * scale, weight: .black, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(width: 420 * scale, height: 62 * scale)
            .background(
                (premium.isPremium ? Color(red: 0.20, green: 0.66, blue: 0.42) : Color(red: 1.0, green: 0.27, blue: 0.51)).gradient,
                in: Capsule()
            )
            .overlay(Capsule().stroke(Color.white.opacity(0.75), lineWidth: 2))
            .shadow(color: .black.opacity(0.35), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
        .position(mapper.point(CGPoint(x: 426, y: 1398)))
        .accessibilityLabel(premium.isPremium ? "Premium unlocked" : "Unlock Premium reminders")
    }

    /// Small link under the Premium button so a previous purchase can be restored
    /// (Apple requires a visible restore option for non-consumable purchases).
    private func restoreButton(mapper: ArtworkMapper) -> some View {
        let scale = mapper.scale
        return Button {
            Task { await restore() }
        } label: {
            HStack(spacing: 8 * scale) {
                if isRestoring {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 18 * scale, weight: .black))
                }
                Text("Restore Purchase")
                    .font(.system(size: 22 * scale, weight: .bold, design: .rounded))
                    .underline()
            }
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.7), radius: 3, y: 1)
            .padding(.horizontal, 18 * scale)
            .frame(height: 40 * scale)
            .background(Color.black.opacity(0.35), in: Capsule())
        }
        .buttonStyle(.plain)
        .disabled(isRestoring)
        .position(mapper.point(CGPoint(x: 426, y: 1462)))
        .accessibilityLabel("Restore Purchase")
    }

    private func restore() async {
        isRestoring = true
        await premium.restore()
        isRestoring = false
        if premium.isPremium {
            restoreMessage = "Premium is active on this Apple ID. Your Chef reminders are ready! 🍣"
        } else {
            restoreMessage = premium.errorMessage ?? "No previous Premium purchase was found."
        }
    }

    private func alarmButton(mapper: ArtworkMapper) -> some View {
        let scale = mapper.scale
        return Button {
            showingAlarms = true
        } label: {
            HStack(spacing: 10 * scale) {
                Image(systemName: "bell.and.waves.left.and.right.fill")
                    .font(.system(size: 24 * scale, weight: .black))
                Text(premium.isPremium ? ChefAlarm.displayName(for: ChefAlarm.selected) : "Chef Alarm Sounds")
                    .font(.system(size: 25 * scale, weight: .black, design: .rounded))
                Image(systemName: "chevron.right")
                    .font(.system(size: 18 * scale, weight: .black))
            }
            .foregroundStyle(Self.ink)
            .frame(width: 420 * scale, height: 56 * scale)
            .background(Color(red: 1.0, green: 0.95, blue: 0.87), in: Capsule())
            .overlay(Capsule().stroke(Color(red: 0.91, green: 0.78, blue: 0.65), lineWidth: 2))
            .shadow(color: .black.opacity(0.30), radius: 6, y: 3)
        }
        .buttonStyle(.plain)
        .position(mapper.point(CGPoint(x: 426, y: 1530)))
        .accessibilityLabel("Chef alarm sounds")
    }

    /// The bottom menu is painted into the art; Home is this screen.
    private func navigationZones(mapper: ArtworkMapper) -> some View {
        let zones: [(label: String, x: CGFloat, action: () -> Void)] = [
            ("Open Orders", 267, { navigate(.orders) }),
            ("Back to Chef", 422, { dismiss() }),
            ("Open Collection", 578, { navigate(.collection) }),
            ("Open Achievements", 733, { navigate(.achievements) })
        ]
        return ZStack(alignment: .topLeading) {
            ForEach(zones, id: \.label) { zone in
                Button(action: zone.action) { Color.black.opacity(0.001) }
                    .buttonStyle(.plain)
                    .frame(width: 140 * mapper.scale, height: 110 * mapper.scale)
                    .position(mapper.point(CGPoint(x: zone.x, y: 1744)))
                    .accessibilityLabel(zone.label)
            }
        }
    }

    // MARK: Helpers

    private var nextLevelText: String {
        guard let daysLeft = levelInfo.daysToNextLevel else { return "Max level!" }
        return "\(daysLeft) \(daysLeft == 1 ? "day" : "days") to Lv. \(levelInfo.level + 1)"
    }

    private func text(_ string: String, size: CGFloat, weight: Font.Weight, color: Color = ink) -> some View {
        Text(string)
            .font(.system(size: size, weight: weight, design: .rounded))
            .foregroundStyle(color)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
    }

    private func filledFrame(container: CGSize) -> CGRect {
        let scale = max(container.width / Self.artworkSize.width, container.height / Self.artworkSize.height)
        let size = CGSize(width: Self.artworkSize.width * scale, height: Self.artworkSize.height * scale)
        return CGRect(
            x: (container.width - size.width) / 2,
            y: (container.height - size.height) / 2,
            width: size.width,
            height: size.height
        )
    }
}
