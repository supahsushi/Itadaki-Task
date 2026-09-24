import SwiftUI

struct AchievementsScreen: View {
    var achievements: [Achievement]
    var pendingUnlockIDs: [String]

    @Environment(\.dismiss) private var dismiss
    @State private var selectedAchievement: Achievement?

    private let columns = [
        GridItem(.adaptive(minimum: 104), spacing: 14)
    ]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(achievements) { achievement in
                        Button {
                            selectedAchievement = achievement
                        } label: {
                            AchievementBadgeCell(
                                achievement: achievement,
                                isPendingReveal: pendingUnlockIDs.contains(achievement.id)
                            )
                        }
                        .buttonStyle(.plain)
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
                AchievementDetailView(achievement: achievement)
                    .presentationDetents([.medium])
                    .presentationBackground(Color(red: 0.98, green: 0.91, blue: 0.80))
            }
        }
        .preferredColorScheme(.light)
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

    private var ink: Color {
        Color(red: 0.13, green: 0.08, blue: 0.05)
    }

    private var softInk: Color {
        Color(red: 0.42, green: 0.31, blue: 0.23)
    }

    var body: some View {
        VStack(spacing: 16) {
            BadgeArtwork(achievement: achievement)
                .frame(width: 112, height: 112)
                .clipShape(Circle())
                .saturation(achievement.isUnlocked ? 1 : 0)
                .opacity(achievement.isUnlocked ? 1 : 0.35)
                .overlay {
                    if !achievement.isUnlocked {
                        Circle()
                            .fill(Color.black.opacity(0.40))
                        Image(systemName: "lock.fill")
                            .font(.system(size: 30, weight: .black))
                            .foregroundStyle(.white)
                    }
                }

            VStack(spacing: 6) {
                Text(achievement.title)
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundStyle(ink)
                    .multilineTextAlignment(.center)

                Text(achievement.description)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(softInk)
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: 10) {
                labeledRow("Requirement", achievement.definition.requirement)
                labeledRow("Progress", "\(achievement.clampedProgress) / \(achievement.target)")
                if let unlockDate = achievement.unlockDate {
                    labeledRow("Unlocked", unlockDate.formatted(date: .abbreviated, time: .shortened))
                } else {
                    labeledRow("Status", "Locked")
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(red: 0.74, green: 0.42, blue: 0.22).opacity(0.22), lineWidth: 1)
            )

            Spacer(minLength: 0)
        }
        .padding(22)
        .background(Color(red: 0.98, green: 0.91, blue: 0.80))
        .preferredColorScheme(.light)
    }

    private func labeledRow(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundStyle(softInk)
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(ink)
        }
    }
}
