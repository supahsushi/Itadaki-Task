import Foundation
import SwiftUI

enum AchievementMetric: Equatable {
    case totalTasks
    case bestDailyTasks
    case currentStreak
    case categories(Set<TaskCategory>)
}

struct AchievementDefinition: Identifiable, Equatable {
    var id: String
    var title: String
    var description: String
    var requirement: String
    var badgeAssetName: String
    var target: Int
    var metric: AchievementMetric

    static let all: [AchievementDefinition] = [
        AchievementDefinition(id: "first-bite", title: "First Bite", description: "You tasted momentum for the first time.", requirement: "Complete your first task", badgeAssetName: "AchievementFirstBite", target: 1, metric: .totalTasks),
        AchievementDefinition(id: "full-plate", title: "Full Plate", description: "A beautiful little meal of finished orders.", requirement: "Complete 5 tasks in one day", badgeAssetName: "AchievementFullPlate", target: 5, metric: .bestDailyTasks),
        AchievementDefinition(id: "chefs-special", title: "Chef's Special", description: "A full omakase of focus in one day.", requirement: "Complete 10 tasks in one day", badgeAssetName: "AchievementChefsSpecial", target: 10, metric: .bestDailyTasks),
        AchievementDefinition(id: "three-day-streak", title: "3-Day Streak", description: "Three days of showing up.", requirement: "Complete at least one task for 3 days", badgeAssetName: "Achievement3DayStreak", target: 3, metric: .currentStreak),
        AchievementDefinition(id: "seven-day-streak", title: "7-Day Streak", description: "One whole week of steady visits.", requirement: "Complete at least one task for 7 days", badgeAssetName: "Achievement7DayStreak", target: 7, metric: .currentStreak),
        AchievementDefinition(id: "fourteen-day-streak", title: "14-Day Streak", description: "Two weeks of small wins adding up.", requirement: "Complete at least one task for 14 days", badgeAssetName: "Achievement14DayStreak", target: 14, metric: .currentStreak),
        AchievementDefinition(id: "thirty-day-streak", title: "30-Day Streak", description: "A full month at the counter.", requirement: "Complete at least one task for 30 days", badgeAssetName: "Achievement30DayStreak", target: 30, metric: .currentStreak),
        AchievementDefinition(id: "sixty-day-streak", title: "60-Day Streak", description: "Sixty days of returning to yourself.", requirement: "Complete at least one task for 60 days", badgeAssetName: "Achievement60DayStreak", target: 60, metric: .currentStreak),
        AchievementDefinition(id: "hundred-day-streak", title: "100-Day Streak", description: "A legendary regular of the restaurant.", requirement: "Complete at least one task for 100 days", badgeAssetName: "Achievement100DayStreak", target: 100, metric: .currentStreak),
        AchievementDefinition(id: "sushi-regular", title: "Sushi Regular", description: "You are becoming a familiar face here.", requirement: "Complete 25 total tasks", badgeAssetName: "AchievementSushiRegular", target: 25, metric: .totalTasks),
        AchievementDefinition(id: "sushi-lover", title: "Sushi Lover", description: "A true lover of tiny completed orders.", requirement: "Complete 100 total tasks", badgeAssetName: "AchievementSushiLover", target: 100, metric: .totalTasks),
        AchievementDefinition(id: "omakase-master", title: "Omakase Master", description: "Five hundred finished orders. Chef remembers.", requirement: "Complete 500 total tasks", badgeAssetName: "AchievementOmakaseMaster", target: 500, metric: .totalTasks),
        AchievementDefinition(id: "healthy-bite", title: "Healthy Bite", description: "You made caring for your body visible.", requirement: "Complete 10 Health tasks", badgeAssetName: "AchievementHealthyBite", target: 10, metric: .categories([.health])),
        AchievementDefinition(id: "active-sushi", title: "Active Sushi", description: "Movement became part of the meal.", requirement: "Complete 10 Exercise or Sports tasks", badgeAssetName: "AchievementActiveSushi", target: 10, metric: .categories([.exercise, .sports])),
        AchievementDefinition(id: "on-the-grind", title: "On the Grind", description: "Work orders, handled with care.", requirement: "Complete 10 Work tasks", badgeAssetName: "AchievementOnTheGrind", target: 10, metric: .categories([.work])),
        AchievementDefinition(id: "brain-food", title: "Brain Food", description: "Learning served fresh.", requirement: "Complete 10 Learning tasks", badgeAssetName: "AchievementBrainFood", target: 10, metric: .categories([.learning])),
        AchievementDefinition(id: "take-care", title: "Take Care", description: "Rest and wellness count too.", requirement: "Complete 10 Wellness or Self-care tasks", badgeAssetName: "AchievementTakeCare", target: 10, metric: .categories([.wellness, .selfCare])),
        AchievementDefinition(id: "good-company", title: "Good Company", description: "Connection is part of the good life.", requirement: "Complete 10 Social or Relationship tasks", badgeAssetName: "AchievementGoodCompany", target: 10, metric: .categories([.social, .relationships]))
    ]
}

struct AchievementState: Codable, Equatable {
    var id: String
    var unlockedDate: Date?

    var isUnlocked: Bool {
        unlockedDate != nil
    }
}

struct Achievement: Identifiable, Equatable {
    var id: String { definition.id }
    var definition: AchievementDefinition
    var state: AchievementState
    var progress: Int

    var title: String { definition.title }
    var description: String { definition.description }
    var badgeAssetName: String { definition.badgeAssetName }
    var isUnlocked: Bool { state.isUnlocked }
    var unlockDate: Date? { state.unlockedDate }
    var target: Int { definition.target }
    var clampedProgress: Int { min(progress, target) }
    var progressFraction: Double { min(1, Double(max(0, progress)) / Double(max(1, target))) }
}

struct AchievementProgressSnapshot {
    var totalCompletions: Int
    var bestDailyCompletions: Int
    var currentStreak: Int
    var categoryCompletionCounts: [String: Int]
}

struct AchievementEvaluationResult {
    var states: [AchievementState]
    var pendingUnlockIDs: [String]
    var newlyUnlocked: [Achievement]
}

enum AchievementManager {
    static let definitions = AchievementDefinition.all

    static func initialStates() -> [AchievementState] {
        definitions.map { AchievementState(id: $0.id, unlockedDate: nil) }
    }

    static func achievements(from states: [AchievementState], progress: AchievementProgressSnapshot) -> [Achievement] {
        let normalized = normalizedStates(states)
        return definitions.map { definition in
            Achievement(
                definition: definition,
                state: normalized[definition.id] ?? AchievementState(id: definition.id, unlockedDate: nil),
                progress: value(for: definition, progress: progress)
            )
        }
    }

    static func evaluate(
        states: [AchievementState],
        pendingUnlockIDs: [String],
        progress: AchievementProgressSnapshot,
        unlockedAt date: Date = .now
    ) -> AchievementEvaluationResult {
        var normalized = normalizedStates(states)
        var pendingIDs = pendingUnlockIDs
        var newlyUnlocked: [Achievement] = []

        for definition in definitions {
            let currentState = normalized[definition.id] ?? AchievementState(id: definition.id, unlockedDate: nil)
            guard !currentState.isUnlocked else { continue }
            guard value(for: definition, progress: progress) >= definition.target else { continue }

            let unlockedState = AchievementState(id: definition.id, unlockedDate: date)
            normalized[definition.id] = unlockedState

            if !pendingIDs.contains(definition.id) {
                pendingIDs.append(definition.id)
            }

            newlyUnlocked.append(
                Achievement(
                    definition: definition,
                    state: unlockedState,
                    progress: value(for: definition, progress: progress)
                )
            )
        }

        let orderedStates = definitions.map {
            normalized[$0.id] ?? AchievementState(id: $0.id, unlockedDate: nil)
        }

        return AchievementEvaluationResult(
            states: orderedStates,
            pendingUnlockIDs: pendingIDs,
            newlyUnlocked: newlyUnlocked
        )
    }

    static func value(for definition: AchievementDefinition, progress: AchievementProgressSnapshot) -> Int {
        switch definition.metric {
        case .totalTasks:
            return progress.totalCompletions
        case .bestDailyTasks:
            return progress.bestDailyCompletions
        case .currentStreak:
            return progress.currentStreak
        case .categories(let categories):
            return categories.reduce(0) { total, category in
                total + (progress.categoryCompletionCounts[category.rawValue] ?? 0)
            }
        }
    }

    static func normalizedStates(_ states: [AchievementState]) -> [String: AchievementState] {
        var normalized: [String: AchievementState] = [:]
        for state in states {
            normalized[state.id] = state
        }
        for definition in definitions where normalized[definition.id] == nil {
            normalized[definition.id] = AchievementState(id: definition.id, unlockedDate: nil)
        }
        return normalized
    }
}
