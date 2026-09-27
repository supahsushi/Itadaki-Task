import Foundation

struct CollectionCharacterDefinition: Identifiable, Equatable {
    var id: String
    var name: String
    var role: String
    var quote: String
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
            quote: "Salmon is here to taste-test the good momentum.",
            about: "Salmon is the resident food tester of the group, headband on, notepad in hand, making sure every bite is fresh, happy, and truly worth serving.",
            personality: "Cheerful • Curious • Food-obsessed • Helpful",
            loves: "Trying new sushi • Taste testing • Discovering new flavors • Sharing good food",
            funFact: "Salmon takes his job very seriously, but somehow his quality control usually requires a second bite.",
            artworkAssetName: "SalmonTheFoodTester",
            sourceArtworkFilename: "02. Salmon the food tester.png",
            introduction: "Salmon is here to taste-test the good momentum."
        ),
        CollectionCharacterDefinition(
            id: "tuna-the-gamer",
            name: "Tuna",
            role: "The Gamer",
            quote: "Tuna just joined your party at the counter.",
            about: "Tuna is the gamer of the group, headset on, controller ready, always somewhere between one more level and one more snack.",
            personality: "Playful • Competitive • Focused • Laid-back",
            loves: "Video games • Late-night gaming • Snacks • Playing with friends",
            funFact: "Tuna always says one more game. Nobody believes him anymore.",
            artworkAssetName: "TunaTheGamer",
            sourceArtworkFilename: "01. Tuna the gamer.png",
            introduction: "Tuna just joined your party at the counter."
        ),
        CollectionCharacterDefinition(
            id: "tamago-the-chill-one",
            name: "Tamago",
            role: "The Chill One",
            quote: "Tamago arrived with soft vibes and no hurry.",
            about: "Tamago is the cozy one, sunk into a soft seat with boba nearby and no plans to rush a perfectly calm day.",
            personality: "Calm • Cozy • Easygoing • Sweet",
            loves: "Naps • Warm drinks • Comfy blankets • Quiet afternoons",
            funFact: "Tamago has perfected the art of doing absolutely nothing and somehow making it look productive.",
            artworkAssetName: "TamagoTheChillOne",
            sourceArtworkFilename: "03. Tamago the chill one.png",
            introduction: "Tamago arrived with soft vibes and no hurry."
        ),
        CollectionCharacterDefinition(
            id: "uni-the-fancy-foodie",
            name: "Uni",
            role: "The Fancy Foodie",
            quote: "Uni has arrived, and the tasting menu just got fancy.",
            about: "Uni is the fancy foodie of the group, bringing a little luxury, polish, and big restaurant energy to every meal.",
            personality: "Sophisticated • Confident • Particular • Charming",
            loves: "Fine dining • Beautiful plating • New restaurants • Dressing up",
            funFact: "Uni can tell whether a restaurant is fancy within five seconds of seeing the table setting.",
            artworkAssetName: "UniTheFancyFoodie",
            sourceArtworkFilename: "04. Uni the fancy foodie.png",
            introduction: "Uni has arrived, and the tasting menu just got fancy."
        ),
        CollectionCharacterDefinition(
            id: "unagi-the-surfer",
            name: "Unagi",
            role: "The Surfer",
            quote: "Unagi rode in on a wave of good energy.",
            about: "Unagi is laid back, sunny, and always ready for good waves, good sushi, and an easy day by the water.",
            personality: "Adventurous • Energetic • Carefree • Optimistic",
            loves: "Surfing • Beaches • Sunshine • Ocean adventures",
            funFact: "Unagi checks the waves before checking anything else in the morning.",
            artworkAssetName: "UnagiTheSurfer",
            sourceArtworkFilename: "05. Unagi the surfer.png",
            introduction: "Unagi rode in on a wave of good energy."
        ),
        CollectionCharacterDefinition(
            id: "mackerel-the-photographer",
            name: "Mackerel",
            role: "The Photographer",
            quote: "Mackerel is here to capture your progress.",
            about: "Mackerel is always chasing the perfect shot, documenting the world one beautiful sushi-side memory at a time.",
            personality: "Observant • Creative • Patient • Curious",
            loves: "Photography • Golden hour • Exploring • Capturing memories",
            funFact: "Mackerel is always the one taking the photos, so everyone has pictures together except Mackerel. 📸",
            artworkAssetName: "MackerelThePhotographer",
            sourceArtworkFilename: "06. Mackerel the Photographer.png",
            introduction: "Mackerel is here to capture your progress."
        ),
        CollectionCharacterDefinition(
            id: "squid-the-dj",
            name: "Squid",
            role: "The DJ",
            quote: "Squid dropped in with a perfect little victory beat.",
            about: "Squid keeps the rhythm flowing, headphones on and lights shifting with every beat.",
            personality: "Energetic • Social • Creative • Fun-loving",
            loves: "Music • Dancing • Nightlife • Making playlists",
            funFact: "Squid has a playlist for everything, including making sushi, cleaning, and making another playlist.",
            artworkAssetName: "SquidTheDJ",
            sourceArtworkFilename: "07. Squid the DJ.png",
            introduction: "Squid dropped in with a perfect little victory beat."
        ),
        CollectionCharacterDefinition(
            id: "yellowtail-the-traveler",
            name: "Yellowtail",
            role: "The Traveler",
            quote: "Yellowtail found the restaurant and brought stories.",
            about: "Yellowtail carries maps, memories, and a knack for finding the hidden sushi spot nobody else knew about.",
            personality: "Adventurous • Curious • Friendly • Spontaneous",
            loves: "Traveling • New cultures • Local food • Collecting souvenirs",
            funFact: "Yellowtail's suitcase is always half-packed because another adventure could happen at any time.",
            artworkAssetName: "YellowtailTheTraveler",
            sourceArtworkFilename: "08. Yellowtail the Traveler.png",
            introduction: "Yellowtail found the restaurant and brought stories."
        ),
        CollectionCharacterDefinition(
            id: "scallop-the-fisherman",
            name: "Scallop",
            role: "The Fisherman",
            quote: "Scallop docked nearby with today's good catch.",
            about: "Scallop is patient, steady, and happiest on the water bringing in the catch that makes everyone smile.",
            personality: "Patient • Peaceful • Outdoorsy • Thoughtful",
            loves: "Fishing • Quiet mornings • The ocean • Being outdoors",
            funFact: "Scallop says fishing teaches patience, although snacks make the waiting considerably easier.",
            artworkAssetName: "ScallopTheFisherman",
            sourceArtworkFilename: "09. Scallop the Fisherman.png",
            introduction: "Scallop docked nearby with today's good catch."
        ),
        CollectionCharacterDefinition(
            id: "mama-roe-the-shopper",
            name: "Mama Roe",
            role: "The Shopper",
            quote: "Mama Roe came by with care, snacks, and encouragement.",
            about: "Mama Roe takes care of everyone, cart full of fresh produce, sushi snacks, and love for the whole little crew.",
            personality: "Caring • Organized • Resourceful • Generous",
            loves: "Shopping • Finding bargains • Cooking • Taking care of everyone",
            funFact: "Mama Roe can walk into a store for one thing and somehow leave with everything everyone needed.",
            artworkAssetName: "MamaRoeTheShopper",
            sourceArtworkFilename: "10. Mama Roe the shopper.png",
            introduction: "Mama Roe came by with care, snacks, and encouragement."
        ),
        CollectionCharacterDefinition(
            id: "red-snapper-the-taiko-master",
            name: "Red Snapper",
            role: "The Taiko Drum Master",
            quote: "Red Snapper arrived with a celebratory drumroll.",
            about: "Red Snapper brings festival energy, raised drumsticks, and a rhythm that pulls everyone together.",
            personality: "Passionate • Disciplined • Energetic • Encouraging",
            loves: "Taiko drumming • Festivals • Performing • Practicing with friends",
            funFact: "Red Snapper practices so enthusiastically that everyone in the neighborhood knows rehearsal has started.",
            artworkAssetName: "RedSnapperTaikoMaster",
            sourceArtworkFilename: "11. Red Snapper the Taiko drum master.png",
            introduction: "Red Snapper arrived with a celebratory drumroll."
        ),
        CollectionCharacterDefinition(
            id: "sushi-roll-the-librarian",
            name: "Sushi Roll",
            role: "The Librarian",
            quote: "Sushi Roll checked out a new chapter with you.",
            about: "Sushi Roll keeps the sushi archive in order, quiet, thoughtful, and always ready with another story.",
            personality: "Gentle • Thoughtful • Bookish • Organized",
            loves: "Books • Quiet spaces • Tea • Helping others find stories",
            funFact: "Sushi Roll remembers exactly where every book belongs but occasionally forgets where the tea was left.",
            artworkAssetName: "SushiRollTheLibrarian",
            sourceArtworkFilename: "12. SushiRoll the Librarian.png",
            introduction: "Sushi Roll checked out a new chapter with you."
        ),
        CollectionCharacterDefinition(
            id: "lobster-crab-the-sumo-bros",
            name: "Lobster & Crab",
            role: "The Sumo Bros",
            quote: "The Sumo Bros stomped in to celebrate your win.",
            about: "Lobster and Crab are a duo with big ring energy, eternal bragging rights, and no retreat from sushi glory.",
            personality: "Loyal • Competitive • Boisterous • Big-hearted",
            loves: "Sumo • Training together • Friendly competition • Huge meals",
            funFact: "They compete over almost everything, but neither brother will admit that sharing dinner is their favorite part of the day.",
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
    var quote: String { definition.quote }
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
