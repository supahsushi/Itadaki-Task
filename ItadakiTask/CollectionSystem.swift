import Foundation

struct CollectionCharacterDefinition: Identifiable, Equatable {
    var id: String
    var name: String
    var role: String
    var about: String
    var personality: String
    var loves: String
    var funFact: String
    var artworkAssetName: String
    var sourceArtworkFilename: String
    var introduction: String

    static let sushiSeries: [CollectionCharacterDefinition] = [
        CollectionCharacterDefinition(
            id: "salmon-the-food-tester",
            name: "Salmon",
            role: "The Food Tester",
            about: "Salmon is the resident food tester of the group, headband on, notepad in hand, making sure every bite is fresh, happy, and truly worth serving.",
            personality: "Profile coming soon.",
            loves: "Profile coming soon.",
            funFact: "Profile coming soon.",
            artworkAssetName: "SalmonTheFoodTester",
            sourceArtworkFilename: "02. Salmon the food tester.png",
            introduction: "Salmon is here to taste-test the good momentum."
        ),
        CollectionCharacterDefinition(
            id: "tuna-the-gamer",
            name: "Tuna",
            role: "The Gamer",
            about: "Tuna is the gamer of the group, headset on, controller ready, always somewhere between one more level and one more snack.",
            personality: "Profile coming soon.",
            loves: "Profile coming soon.",
            funFact: "Profile coming soon.",
            artworkAssetName: "TunaTheGamer",
            sourceArtworkFilename: "01. Tuna the gamer.png",
            introduction: "Tuna just joined your party at the counter."
        ),
        CollectionCharacterDefinition(
            id: "tamago-the-chill-one",
            name: "Tamago",
            role: "The Chill One",
            about: "Tamago is the cozy one, sunk into a soft seat with boba nearby and no plans to rush a perfectly calm day.",
            personality: "Profile coming soon.",
            loves: "Profile coming soon.",
            funFact: "Profile coming soon.",
            artworkAssetName: "TamagoTheChillOne",
            sourceArtworkFilename: "03. Tamago the chill one.png",
            introduction: "Tamago arrived with soft vibes and no hurry."
        ),
        CollectionCharacterDefinition(
            id: "uni-the-fancy-foodie",
            name: "Uni",
            role: "The Fancy Foodie",
            about: "Uni is the fancy foodie of the group, bringing a little luxury, polish, and big restaurant energy to every meal.",
            personality: "Profile coming soon.",
            loves: "Profile coming soon.",
            funFact: "Profile coming soon.",
            artworkAssetName: "UniTheFancyFoodie",
            sourceArtworkFilename: "04. Uni the fancy foodie.png",
            introduction: "Uni has arrived, and the tasting menu just got fancy."
        ),
        CollectionCharacterDefinition(
            id: "unagi-the-surfer",
            name: "Unagi",
            role: "The Surfer",
            about: "Unagi is laid back, sunny, and always ready for good waves, good sushi, and an easy day by the water.",
            personality: "Profile coming soon.",
            loves: "Profile coming soon.",
            funFact: "Profile coming soon.",
            artworkAssetName: "UnagiTheSurfer",
            sourceArtworkFilename: "05. Unagi the surfer.png",
            introduction: "Unagi rode in on a wave of good energy."
        ),
        CollectionCharacterDefinition(
            id: "mackerel-the-photographer",
            name: "Mackerel",
            role: "The Photographer",
            about: "Mackerel is always chasing the perfect shot, documenting the world one beautiful sushi-side memory at a time.",
            personality: "Profile coming soon.",
            loves: "Profile coming soon.",
            funFact: "Profile coming soon.",
            artworkAssetName: "MackerelThePhotographer",
            sourceArtworkFilename: "06. Mackerel the Photographer.png",
            introduction: "Mackerel is here to capture your progress."
        ),
        CollectionCharacterDefinition(
            id: "squid-the-dj",
            name: "Squid",
            role: "The DJ",
            about: "Squid keeps the rhythm flowing, headphones on and lights shifting with every beat.",
            personality: "Profile coming soon.",
            loves: "Profile coming soon.",
            funFact: "Profile coming soon.",
            artworkAssetName: "SquidTheDJ",
            sourceArtworkFilename: "07. Squid the DJ.png",
            introduction: "Squid dropped in with a perfect little victory beat."
        ),
        CollectionCharacterDefinition(
            id: "yellowtail-the-traveler",
            name: "Yellowtail",
            role: "The Traveler",
            about: "Yellowtail carries maps, memories, and a knack for finding the hidden sushi spot nobody else knew about.",
            personality: "Profile coming soon.",
            loves: "Profile coming soon.",
            funFact: "Profile coming soon.",
            artworkAssetName: "YellowtailTheTraveler",
            sourceArtworkFilename: "08. Yellowtail the Traveler.png",
            introduction: "Yellowtail found the restaurant and brought stories."
        ),
        CollectionCharacterDefinition(
            id: "scallop-the-fisherman",
            name: "Scallop",
            role: "The Fisherman",
            about: "Scallop is patient, steady, and happiest on the water bringing in the catch that makes everyone smile.",
            personality: "Profile coming soon.",
            loves: "Profile coming soon.",
            funFact: "Profile coming soon.",
            artworkAssetName: "ScallopTheFisherman",
            sourceArtworkFilename: "09. Scallop the Fisherman.png",
            introduction: "Scallop docked nearby with today's good catch."
        ),
        CollectionCharacterDefinition(
            id: "mama-roe-the-shopper",
            name: "Mama Roe",
            role: "The Shopper",
            about: "Mama Roe takes care of everyone, cart full of fresh produce, sushi snacks, and love for the whole little crew.",
            personality: "Profile coming soon.",
            loves: "Profile coming soon.",
            funFact: "Profile coming soon.",
            artworkAssetName: "MamaRoeTheShopper",
            sourceArtworkFilename: "10. Mama Roe the shopper.png",
            introduction: "Mama Roe came by with care, snacks, and encouragement."
        ),
        CollectionCharacterDefinition(
            id: "red-snapper-the-taiko-master",
            name: "Red Snapper",
            role: "The Taiko Drum Master",
            about: "Red Snapper brings festival energy, raised drumsticks, and a rhythm that pulls everyone together.",
            personality: "Profile coming soon.",
            loves: "Profile coming soon.",
            funFact: "Profile coming soon.",
            artworkAssetName: "RedSnapperTaikoMaster",
            sourceArtworkFilename: "11. Red Snapper the Taiko drum master.png",
            introduction: "Red Snapper arrived with a celebratory drumroll."
        ),
        CollectionCharacterDefinition(
            id: "sushi-roll-the-librarian",
            name: "Sushi Roll",
            role: "The Librarian",
            about: "Sushi Roll keeps the sushi archive in order, quiet, thoughtful, and always ready with another story.",
            personality: "Profile coming soon.",
            loves: "Profile coming soon.",
            funFact: "Profile coming soon.",
            artworkAssetName: "SushiRollTheLibrarian",
            sourceArtworkFilename: "12. SushiRoll the Librarian.png",
            introduction: "Sushi Roll checked out a new chapter with you."
        ),
        CollectionCharacterDefinition(
            id: "lobster-crab-the-sumo-bros",
            name: "Lobster & Crab",
            role: "The Sumo Bros",
            about: "Lobster and Crab are a duo with big ring energy, eternal bragging rights, and no retreat from sushi glory.",
            personality: "Profile coming soon.",
            loves: "Profile coming soon.",
            funFact: "Profile coming soon.",
            artworkAssetName: "LobsterCrabSumoBros",
            sourceArtworkFilename: "13. The Sumo Bros 2.png",
            introduction: "The Sumo Bros stomped in to celebrate your win."
        )
    ]
}

struct CollectionCharacterState: Codable, Equatable {
    var id: String
    var dateFirstMet: Date?

    var isUnlocked: Bool {
        dateFirstMet != nil
    }
}

struct CollectionCharacter: Identifiable, Equatable {
    var id: String { definition.id }
    var definition: CollectionCharacterDefinition
    var state: CollectionCharacterState

    var name: String { definition.name }
    var role: String { definition.role }
    var about: String { definition.about }
    var personality: String { definition.personality }
    var loves: String { definition.loves }
    var funFact: String { definition.funFact }
    var artworkAssetName: String { definition.artworkAssetName }
    var introduction: String { definition.introduction }
    var dateFirstMet: Date? { state.dateFirstMet }
    var isUnlocked: Bool { state.isUnlocked }
}

struct CollectionUnlockResult {
    var states: [CollectionCharacterState]
    var newlyUnlocked: CollectionCharacter?
}

enum CollectionManager {
    static let definitions = CollectionCharacterDefinition.sushiSeries

    static let achievementCharacterMap: [String: String] = [
        "first-bite": "salmon-the-food-tester",
        "full-plate": "mama-roe-the-shopper",
        "chefs-special": "uni-the-fancy-foodie",
        "three-day-streak": "tuna-the-gamer",
        "seven-day-streak": "tamago-the-chill-one",
        "fourteen-day-streak": "sushi-roll-the-librarian",
        "thirty-day-streak": "mackerel-the-photographer",
        "sixty-day-streak": "yellowtail-the-traveler",
        "hundred-day-streak": "red-snapper-the-taiko-master",
        "sushi-regular": "scallop-the-fisherman",
        "sushi-lover": "lobster-crab-the-sumo-bros",
        "omakase-master": "squid-the-dj",
        "active-sushi": "unagi-the-surfer"
    ]

    static func initialStates() -> [CollectionCharacterState] {
        definitions.map { CollectionCharacterState(id: $0.id, dateFirstMet: nil) }
    }

    static func characters(from states: [CollectionCharacterState]) -> [CollectionCharacter] {
        let normalized = normalizedStates(states)
        return definitions.map { definition in
            CollectionCharacter(
                definition: definition,
                state: normalized[definition.id] ?? CollectionCharacterState(id: definition.id, dateFirstMet: nil)
            )
        }
    }

    static func characterID(for achievementID: String) -> String? {
        achievementCharacterMap[achievementID]
    }

    static func unlockCharacter(
        for achievement: Achievement,
        states: [CollectionCharacterState],
        metAt date: Date = .now
    ) -> CollectionUnlockResult? {
        guard let characterID = characterID(for: achievement.id) else { return nil }
        return unlockCharacter(id: characterID, states: states, metAt: achievement.unlockDate ?? date)
    }

    static func unlockCharacter(
        id: String,
        states: [CollectionCharacterState],
        metAt date: Date = .now
    ) -> CollectionUnlockResult? {
        guard definitions.contains(where: { $0.id == id }) else { return nil }
        var normalized = normalizedStates(states)
        let currentState = normalized[id] ?? CollectionCharacterState(id: id, dateFirstMet: nil)

        guard currentState.dateFirstMet == nil else {
            return CollectionUnlockResult(states: orderedStates(from: normalized), newlyUnlocked: nil)
        }

        let unlockedState = CollectionCharacterState(id: id, dateFirstMet: date)
        normalized[id] = unlockedState
        let ordered = orderedStates(from: normalized)
        let character = characters(from: ordered).first { $0.id == id }
        return CollectionUnlockResult(states: ordered, newlyUnlocked: character)
    }

    static func backfillUnlockedCharacters(
        from achievements: [Achievement],
        states: [CollectionCharacterState]
    ) -> [CollectionCharacterState] {
        var normalized = normalizedStates(states)

        for achievement in achievements where achievement.isUnlocked {
            guard let characterID = characterID(for: achievement.id) else { continue }
            guard normalized[characterID]?.dateFirstMet == nil else { continue }
            normalized[characterID] = CollectionCharacterState(
                id: characterID,
                dateFirstMet: achievement.unlockDate ?? Date.now
            )
        }

        return orderedStates(from: normalized)
    }

    static func normalizedStates(_ states: [CollectionCharacterState]) -> [String: CollectionCharacterState] {
        var normalized: [String: CollectionCharacterState] = [:]
        for state in states {
            normalized[state.id] = state
        }
        for definition in definitions where normalized[definition.id] == nil {
            normalized[definition.id] = CollectionCharacterState(id: definition.id, dateFirstMet: nil)
        }
        return normalized
    }

    private static func orderedStates(from normalized: [String: CollectionCharacterState]) -> [CollectionCharacterState] {
        definitions.map { definition in
            normalized[definition.id] ?? CollectionCharacterState(id: definition.id, dateFirstMet: nil)
        }
    }
}
