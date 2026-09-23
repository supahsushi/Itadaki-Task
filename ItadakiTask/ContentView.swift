import HealthKit
import SwiftUI
import UserNotifications

struct SushiTask: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var category: TaskCategory
    var dueDate: Date
    var recurrence: TaskRecurrence = .none
    var hasReminder = false
    var isEaten = false

    var completedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case category
        case dueDate
        case recurrence
        case hasReminder
        case isEaten
        case completedAt
    }

    init(
        id: UUID = UUID(),
        title: String,
        category: TaskCategory,
        dueDate: Date,
        recurrence: TaskRecurrence = .none,
        hasReminder: Bool = false,
        isEaten: Bool = false,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.dueDate = dueDate
        self.recurrence = recurrence
        self.hasReminder = hasReminder
        self.isEaten = isEaten
        self.completedAt = completedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        title = try container.decode(String.self, forKey: .title)
        category = try container.decode(TaskCategory.self, forKey: .category)
        dueDate = try container.decode(Date.self, forKey: .dueDate)
        recurrence = try container.decodeIfPresent(TaskRecurrence.self, forKey: .recurrence) ?? .none
        hasReminder = try container.decodeIfPresent(Bool.self, forKey: .hasReminder) ?? false
        isEaten = try container.decodeIfPresent(Bool.self, forKey: .isEaten) ?? false
        completedAt = try container.decodeIfPresent(Date.self, forKey: .completedAt)
    }
}

enum TaskRecurrence: String, CaseIterable, Identifiable {
    case none = "Never"
    case daily = "Daily"
    case weekdays = "Weekdays"
    case weekends = "Weekends"
    case weekly = "Weekly"
    case custom = "Custom"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .none: "calendar.badge.plus"
        case .daily: "arrow.trianglehead.2.clockwise"
        case .weekdays: "calendar"
        case .weekends: "calendar"
        case .weekly: "calendar.badge.clock"
        case .custom: "slider.horizontal.3"
        }
    }
}

extension TaskRecurrence: Codable {
    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        switch value {
        case "One time", "Never":
            self = .none
        case "Daily":
            self = .daily
        case "Weekdays":
            self = .weekdays
        case "Weekends":
            self = .weekends
        case "Weekly":
            self = .weekly
        case "Every 3 days", "Custom":
            self = .custom
        default:
            self = .none
        }
    }
}

enum TaskCategory: String, CaseIterable, Codable, Identifiable {
    case health = "Health"
    case exercise = "Exercise"
    case sports = "Sports"
    case wellness = "Wellness"
    case work = "Work"
    case learning = "Learning"
    case home = "Home"
    case social = "Social"
    case relationships = "Relationships"
    case money = "Money"
    case creative = "Creative"
    case errands = "Errands"
    case selfCare = "Self-care"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .health: "drop.fill"
        case .exercise: "figure.run"
        case .sports: "tennisball.fill"
        case .wellness: "brain.head.profile"
        case .work: "laptopcomputer"
        case .learning: "book.fill"
        case .home: "house.fill"
        case .social: "bubble.left.and.bubble.right.fill"
        case .relationships: "heart.fill"
        case .money: "dollarsign.circle.fill"
        case .creative: "paintpalette.fill"
        case .errands: "cart.fill"
        case .selfCare: "bed.double.fill"
        case .other: "star.fill"
        }
    }

    var color: Color {
        switch self {
        case .health: .cyan
        case .exercise: .blue
        case .sports: .green
        case .wellness: .purple
        case .work: .indigo
        case .learning: .orange
        case .home: .pink
        case .social: .mint
        case .relationships: .red
        case .money: .yellow
        case .creative: .orange
        case .errands: .purple
        case .selfCare: .blue
        case .other: .yellow
        }
    }
}

enum AchievementMetric: Equatable {
    case totalTasks
    case bestDailyTasks
    case currentStreak
    case categories(Set<TaskCategory>)
}

struct AchievementDefinition: Identifiable, Equatable {
    var id: String
    var emoji: String
    var title: String
    var requirement: String
    var target: Int
    var metric: AchievementMetric

    static let all: [AchievementDefinition] = [
        AchievementDefinition(id: "first-bite", emoji: "🍣", title: "First Bite", requirement: "Complete your first task", target: 1, metric: .totalTasks),
        AchievementDefinition(id: "full-plate", emoji: "🍱", title: "Full Plate", requirement: "Complete 5 tasks in one day", target: 5, metric: .bestDailyTasks),
        AchievementDefinition(id: "chefs-special", emoji: "👨‍🍳", title: "Chef's Special", requirement: "Complete 10 tasks in one day", target: 10, metric: .bestDailyTasks),
        AchievementDefinition(id: "three-day-streak", emoji: "🔥", title: "3-Day Streak", requirement: "Complete at least one task for 3 days", target: 3, metric: .currentStreak),
        AchievementDefinition(id: "seven-day-streak", emoji: "🔥", title: "7-Day Streak", requirement: "Complete at least one task for 7 days", target: 7, metric: .currentStreak),
        AchievementDefinition(id: "fourteen-day-streak", emoji: "🌸", title: "14-Day Streak", requirement: "Complete at least one task for 14 days", target: 14, metric: .currentStreak),
        AchievementDefinition(id: "thirty-day-streak", emoji: "🏮", title: "30-Day Streak", requirement: "Complete at least one task for 30 days", target: 30, metric: .currentStreak),
        AchievementDefinition(id: "sixty-day-streak", emoji: "🌊", title: "60-Day Streak", requirement: "Complete at least one task for 60 days", target: 60, metric: .currentStreak),
        AchievementDefinition(id: "hundred-day-streak", emoji: "👑", title: "100-Day Streak", requirement: "Complete at least one task for 100 days", target: 100, metric: .currentStreak),
        AchievementDefinition(id: "sushi-regular", emoji: "🍣", title: "Sushi Regular", requirement: "Complete 25 total tasks", target: 25, metric: .totalTasks),
        AchievementDefinition(id: "sushi-lover", emoji: "🍣", title: "Sushi Lover", requirement: "Complete 100 total tasks", target: 100, metric: .totalTasks),
        AchievementDefinition(id: "omakase-master", emoji: "🍣", title: "Omakase Master", requirement: "Complete 500 total tasks", target: 500, metric: .totalTasks),
        AchievementDefinition(id: "healthy-bite", emoji: "💧", title: "Healthy Bite", requirement: "Complete 10 Health tasks", target: 10, metric: .categories([.health])),
        AchievementDefinition(id: "active-sushi", emoji: "🎾", title: "Active Sushi", requirement: "Complete 10 Exercise or Sports tasks", target: 10, metric: .categories([.exercise, .sports])),
        AchievementDefinition(id: "on-the-grind", emoji: "💻", title: "On the Grind", requirement: "Complete 10 Work tasks", target: 10, metric: .categories([.work])),
        AchievementDefinition(id: "brain-food", emoji: "📚", title: "Brain Food", requirement: "Complete 10 Learning tasks", target: 10, metric: .categories([.learning])),
        AchievementDefinition(id: "take-care", emoji: "🧘", title: "Take Care", requirement: "Complete 10 Wellness or Self-care tasks", target: 10, metric: .categories([.wellness, .selfCare])),
        AchievementDefinition(id: "good-company", emoji: "💕", title: "Good Company", requirement: "Complete 10 Social or Relationship tasks", target: 10, metric: .categories([.social, .relationships]))
    ]
}

struct CollectionCharacterProfile: Identifiable, Equatable {
    var id: String
    var name: String
    var role: String
    var assetName: String
    var sourceArtworkFilename: String
    var unlockAfterSushiEaten: Int
    var profile: String

    static let sushiSeries: [CollectionCharacterProfile] = [
        CollectionCharacterProfile(
            id: "tuna-the-gamer",
            name: "Tuna the Gamer",
            role: "Gamer",
            assetName: "TunaTheGamer",
            sourceArtworkFilename: "01. Tuna the gamer.png",
            unlockAfterSushiEaten: 1,
            profile: "This is the first proper character card for the cast, Tuna, the gamer of the group, headset on, controller in hand, boba on the desk, fully set up in his neon gaming corner. I wanted these to feel like real trading cards or character select screens, stats, a fun fact, a special move and all, instead of just a portrait. Tuna's the one who's always mid level up, and I liked giving him a whole setup that actually shows that instead of just telling you."
        ),
        CollectionCharacterProfile(
            id: "salmon-the-food-tester",
            name: "Salmon the Food Tester",
            role: "Food Tester",
            assetName: "SalmonTheFoodTester",
            sourceArtworkFilename: "02. Salmon the food tester.png",
            unlockAfterSushiEaten: 3,
            profile: "Salmon's card, the resident food tester of the group, headband on, notepad in hand, giving today's testing menu a perfect 100 out of 100. She's the one who takes tasting seriously, freshness, flavor, presentation, happiness, all checked off. I liked giving her that little food test report clipboard, it felt like the right prop for someone whose whole job in this world is making sure everything is actually good before anyone else eats it."
        ),
        CollectionCharacterProfile(
            id: "tamago-the-chill-one",
            name: "Tamago the Chill One",
            role: "Chill One",
            assetName: "TamagoTheChillOne",
            sourceArtworkFilename: "03. Tamago the chill one.png",
            unlockAfterSushiEaten: 5,
            profile: "Tamago's card, and true to the name, he's just sunk into a bean bag with boba in hand, watching Sushi Quest reruns and not moving for the rest of the day. Good Food, Good Mood, Good Vibes is basically his whole personality summed up in one neon sign. Out of the whole cast he might be the one I relate to the most, snacks, a good show, and zero plans, that's a perfect day."
        ),
        CollectionCharacterProfile(
            id: "uni-the-fancy-foodie",
            name: "Uni the Fancy Foodie",
            role: "Fancy Foodie",
            assetName: "UniTheFancyFoodie",
            sourceArtworkFilename: "04. Uni the fancy foodie.png",
            unlockAfterSushiEaten: 8,
            profile: "Uni's card, crown, pearls, and all, because she's the fancy foodie of the group, sitting down to gyudon and sake like it's a five star meal every time. Good food, good vibes, good life is her whole motto. I liked giving her that little bit of luxury, since uni itself is already considered kind of a delicacy, it felt right to make her the one with the most refined taste in the whole cast."
        ),
        CollectionCharacterProfile(
            id: "unagi-the-surfer",
            name: "Unagi the Surfer",
            role: "Surfer",
            assetName: "UnagiTheSurfer",
            sourceArtworkFilename: "05. Unagi the surfer.png",
            unlockAfterSushiEaten: 10,
            profile: "Unagi's card, sunglasses on, board under his arm, living that good vibes big waves sushi days life. Out of the whole cast he's probably the most laid back, ride the waves, chase the sun, eat good sushi, live happy, that's the entire philosophy right there. I gave him the Hawaiian shirt and shaka sign because he just felt like the type to already be barefoot on the sand before anyone else even wakes up."
        ),
        CollectionCharacterProfile(
            id: "mackerel-the-photographer",
            name: "Mackerel the Photographer",
            role: "Photographer",
            assetName: "MackerelThePhotographer",
            sourceArtworkFilename: "06. Mackerel the Photographer.png",
            unlockAfterSushiEaten: 15,
            profile: "Mackerel's card, camera around his neck, bucket hat on, out chasing the perfect shot of Mt. Fuji through the cherry blossoms. Find beauty, take photos, eat good sushi, repeat, that's his whole daily plan written right there on the chalkboard. He's the one who's always got a travel log and a bag full of gear, documenting this whole world one photo at a time."
        ),
        CollectionCharacterProfile(
            id: "squid-the-dj",
            name: "Squid the DJ",
            role: "DJ",
            assetName: "SquidTheDJ",
            sourceArtworkFilename: "07. Squid the DJ.png",
            unlockAfterSushiEaten: 20,
            profile: "Squid's card, headphones on, hands on the decks, good beats good vibes perfect flow lighting up behind him. This is a different squid than DJ Tako, same job, different vibe entirely, glossy and glowing instead of grungy and rave lit. Squid can change colors and vibes to match the perfect beat is literally true for this character, and I liked leaning into that with all the shifting neon around him."
        ),
        CollectionCharacterProfile(
            id: "yellowtail-the-traveler",
            name: "Yellowtail the Traveler",
            role: "Traveler",
            assetName: "YellowtailTheTraveler",
            sourceArtworkFilename: "08. Yellowtail the Traveler.png",
            unlockAfterSushiEaten: 25,
            profile: "Yellowtail's card, passport and map in hand, suitcase covered in stickers from everywhere he's already been. New places, new tastes, new memories to treasure sums him up completely. He's the one who always finds the hidden sushi spot nobody else knew about, which felt like the perfect special skill for the traveler of the group."
        ),
        CollectionCharacterProfile(
            id: "scallop-the-fisherman",
            name: "Scallop the Fisherman",
            role: "Fisherman",
            assetName: "ScallopTheFisherman",
            sourceArtworkFilename: "09. Scallop the Fisherman.png",
            unlockAfterSushiEaten: 30,
            profile: "Scallop's card, out on his own little boat riding the Great Wave, binoculars around his neck and a net full of today's catch. Patience, passion, and the perfect catch is his whole thing. He's technically outside the original eight, a bonus character I added once the cast started feeling like it needed someone actually out on the water bringing in the fish everyone else gets to eat."
        ),
        CollectionCharacterProfile(
            id: "mama-roe-the-shopper",
            name: "Mama Roe the Shopper",
            role: "Shopper",
            assetName: "MamaRoeTheShopper",
            sourceArtworkFilename: "10. Mama Roe the shopper.png",
            unlockAfterSushiEaten: 35,
            profile: "Mama Roe's card, cart full of fresh produce and sushi snacks, a whole little family of baby roe following behind her at the store. Shopping with love, feeding happy little roes is exactly what she's about. She felt like the natural next character after the original eight, someone who takes care of everyone else in this world instead of being out on her own adventure."
        ),
        CollectionCharacterProfile(
            id: "red-snapper-the-taiko-master",
            name: "Red Snapper the Taiko Master",
            role: "Taiko Master",
            assetName: "RedSnapperTaikoMaster",
            sourceArtworkFilename: "11. Red Snapper the Taiko drum master.png",
            unlockAfterSushiEaten: 40,
            profile: "Red Snapper's card, drumsticks raised, taiko drums on either side, a whole crowd of friends drumming along behind him at what looks like a festival. Every beat brings joy, every rhythm connects us all, is basically the heart of this whole card. I wanted at least one character built entirely around a traditional performance art instead of a modern hobby, and taiko drumming felt like the perfect fit for that energy."
        ),
        CollectionCharacterProfile(
            id: "sushiroll-the-librarian",
            name: "SushiRoll the Librarian",
            role: "Librarian",
            assetName: "SushiRollTheLibrarian",
            sourceArtworkFilename: "12. SushiRoll the Librarian.png",
            unlockAfterSushiEaten: 45,
            profile: "SushiRoll's card, glasses on, arms full of books, tucked into a cozy library corner surrounded by shelves. Books nourish the soul, and every book is an adventure waiting to be rolled, which might be my favorite line out of any of these cards. She keeps the whole sushi archive in order, quiet but full of wisdom, and I liked giving this world at least one character whose whole personality is just loving to read."
        ),
        CollectionCharacterProfile(
            id: "lobster-crab-the-sumo-bros",
            name: "Lobster & Crab: The Sumo Bros",
            role: "Sumo Bros",
            assetName: "LobsterCrabSumoBros",
            sourceArtworkFilename: "13. The Sumo Bros 2.png",
            unlockAfterSushiEaten: 50,
            profile: "Lobster and Crab's card, squared off in the ring in front of a packed crowd, sumo belts on and claws raised. No retreat, only sushi glory pretty much says it all. I wanted a duo card instead of just another solo character, two shellfish brothers who settle everything in the ring, one match, one winner, eternal bragging rights. It's probably the most dramatic card in the whole set, and I love that about it."
        )
    ]
}

enum Daypart {
    case morning
    case noon
    case night

    init(date: Date = .now) {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 5..<12: self = .morning
        case 12..<18: self = .noon
        default: self = .night
        }
    }

    var chefAsset: String {
        switch self {
        case .morning: "ChefMorning"
        case .noon: "ChefNoon"
        case .night: "ChefNight"
        }
    }

    var orderAsset: String {
        switch self {
        case .morning: "OrderMorning"
        case .noon: "OrderNoon"
        case .night: "OrderNight"
        }
    }

    var tint: Color {
        switch self {
        case .morning: Color(red: 0.98, green: 0.25, blue: 0.50)
        case .noon: Color(red: 0.00, green: 0.56, blue: 0.95)
        case .night: Color(red: 0.42, green: 0.26, blue: 0.95)
        }
    }

    var chefArtworkSize: CGSize {
        switch self {
        case .morning, .noon:
            CGSize(width: 853, height: 1844)
        case .night:
            CGSize(width: 851, height: 1847)
        }
    }

    var thankAsset: String {
        switch self {
        case .morning, .noon:
            "ThankNoon"
        case .night:
            "ThankNight"
        }
    }

    var thankArtworkSize: CGSize {
        CGSize(width: 851, height: 1848)
    }
}

struct ContentView: View {
    @AppStorage("customerName") private var customerName = ""
    @AppStorage("hasAskedCustomerName") private var hasAskedCustomerName = false
    @AppStorage("sushiTasks") private var storedTasks = ""
    @AppStorage("sushiEatenToday") private var sushiEatenToday = 0
    @AppStorage("sushiMealDayKey") private var sushiMealDayKey = ""
    @AppStorage("sushiTotalCompletions") private var sushiTotalCompletions = 0
    @AppStorage("sushiBestDailyCompletions") private var sushiBestDailyCompletions = 0
    @AppStorage("sushiCurrentStreak") private var sushiCurrentStreak = 0
    @AppStorage("sushiCompletedDayKeys") private var sushiCompletedDayKeys = ""
    @AppStorage("sushiCategoryCompletionCounts") private var sushiCategoryCompletionCounts = ""
    @AppStorage("sushiUnlockedAchievements") private var sushiUnlockedAchievements = ""
    @AppStorage("sushiAskedHealthKit") private var hasAskedHealthKit = false

    @State private var tasks: [SushiTask] = []
    @State private var showingAddTask = false
    @State private var showingNamePrompt = false
    @State private var draftName = ""
    @State private var recentlyEatenTaskIDs: Set<SushiTask.ID> = []

    private let daypart = Daypart()

    var body: some View {
        GeometryReader { proxy in
            let backgroundAsset = mealIsFull ? daypart.thankAsset : daypart.chefAsset
            let backgroundArtworkSize = mealIsFull ? daypart.thankArtworkSize : daypart.chefArtworkSize
            let artworkFrame = fittedArtworkFrame(
                container: proxy.size,
                artwork: backgroundArtworkSize
            )
            let rowArea = CGRect(
                x: artworkFrame.minX + artworkFrame.width * 0.075,
                y: artworkFrame.minY + artworkFrame.height * 0.462,
                width: artworkFrame.width * 0.715,
                height: artworkFrame.height * 0.214
            )

            ZStack {
                ArtworkBackground(name: backgroundAsset, artworkSize: backgroundArtworkSize)

                ProfileStreakLevelOverlay(
                    levelInfo: streakLevelInfo,
                    artworkFrame: artworkFrame
                )

                MealCountOverlay(
                    eatenCount: sushiEatenToday,
                    maxCount: mealLimit,
                    artworkFrame: artworkFrame
                )

                OrderMenuHitZones(
                    artworkFrame: artworkFrame,
                    showsRightSideOrderButton: !mealIsFull
                ) {
                    showingAddTask = true
                }

                if !mealIsFull {
                    Button {
                        showingAddTask = true
                    } label: {
                        Color.black.opacity(0.001)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Add a Task")
                    .frame(width: artworkFrame.width * 0.19, height: artworkFrame.height * 0.036)
                    .position(
                        x: artworkFrame.minX + artworkFrame.width * 0.711,
                        y: artworkFrame.minY + artworkFrame.height * 0.423
                    )

                    TaskBoardView(
                        tasks: todaysTasks,
                        daypart: daypart,
                        mealIsFull: mealIsFull,
                        recentlyEatenTaskIDs: recentlyEatenTaskIDs
                    ) { task in
                        complete(task)
                    }
                    .frame(width: rowArea.width, height: rowArea.height)
                    .position(x: rowArea.midX, y: rowArea.midY)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
        }
        .ignoresSafeArea()
        .onAppear {
            loadTasks()
            resetMealIfNeeded()
            requestHealthKitAuthorizationIfNeeded()
        }
        .fullScreenCover(isPresented: $showingAddTask) {
            AddTaskSheet(daypart: daypart) { task in
                withAnimation(.spring(response: 0.42, dampingFraction: 0.78)) {
                    tasks.append(task)
                    saveTasks()
                }
                LocalNotificationScheduler.shared.scheduleReminder(for: task)
            }
        }
        .alert("What is the customer's name?", isPresented: $showingNamePrompt) {
            TextField("Customer name", text: $draftName)
            Button("Start order") {
                let trimmed = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
                customerName = trimmed.isEmpty ? "Chef's Guest" : trimmed
                hasAskedCustomerName = true
            }
        } message: {
            Text("Chef will write it on your Itadaki Task order board.")
        }
    }

    private var displayName: String {
        customerName.isEmpty ? "Chef's Guest" : customerName
    }

    private var activeTasks: [SushiTask] {
        todaysTasks.filter { !$0.isEaten }.sorted { $0.dueDate < $1.dueDate }
    }

    private var todaysTasks: [SushiTask] {
        tasks
            .filter { shouldShowToday($0) }
            .sorted { lhs, rhs in
                if lhs.isEaten != rhs.isEaten {
                    return !lhs.isEaten
                }
                return lhs.dueDate < rhs.dueDate
            }
    }

    private var nextTask: SushiTask? {
        activeTasks.first
    }

    private var mealLimit: Int {
        10
    }

    private var mealIsFull: Bool {
        sushiEatenToday >= mealLimit
    }

    private var streakLevelInfo: StreakLevelInfo {
        StreakLevelInfo(streakDays: sushiCurrentStreak)
    }

    private func fittedArtworkFrame(container: CGSize, artwork: CGSize) -> CGRect {
        let scale = max(container.width / artwork.width, container.height / artwork.height)
        let width = artwork.width * scale
        let height = artwork.height * scale
        return CGRect(
            x: (container.width - width) / 2,
            y: (container.height - height) / 2,
            width: width,
            height: height
        )
    }

    private func complete(_ task: SushiTask) {
        resetMealIfNeeded()
        guard !mealIsFull else { return }
        guard let index = tasks.firstIndex(of: task) else { return }
        guard !tasks[index].isEaten else { return }

        withAnimation(.spring(response: 0.48, dampingFraction: 0.72)) {
            tasks[index].isEaten = true
            let completedAt = Date.now
            tasks[index].completedAt = completedAt
            LocalNotificationScheduler.shared.cancelReminder(for: tasks[index])
            sushiEatenToday = min(sushiEatenToday + 1, mealLimit)
            recordAchievementProgress(for: tasks[index], completedAt: completedAt)
            recentlyEatenTaskIDs.insert(task.id)
            saveTasks()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            _ = withAnimation(.easeOut(duration: 0.25)) {
                recentlyEatenTaskIDs.remove(task.id)
            }
        }
    }

    private func loadTasks() {
        guard let data = storedTasks.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([SushiTask].self, from: data) else {
            tasks = []
            saveTasks()
            return
        }
        tasks = isLegacySampleSeed(decoded) ? [] : decoded
        let countBeforePruning = tasks.count
        pruneExpiredCompletedTasks()
        if tasks.count != decoded.count || tasks.count != countBeforePruning {
            saveTasks()
        }
    }

    private func isLegacySampleSeed(_ decoded: [SushiTask]) -> Bool {
        let sampleTitles = Set(["Drink water", "Play tennis", "Work on portfolio", "Read a book"])
        return decoded.count == sampleTitles.count && Set(decoded.map(\.title)) == sampleTitles
    }

    private func resetMealIfNeeded() {
        let today = Self.localDayKey(for: .now)
        let countBeforePruning = tasks.count
        pruneExpiredCompletedTasks()
        if tasks.count != countBeforePruning {
            saveTasks()
        }
        refreshCurrentStreakForToday()
        guard sushiMealDayKey != today else { return }
        sushiMealDayKey = today
        sushiEatenToday = 0
        reopenRecurringOrders(for: .now)
    }

    private func pruneExpiredCompletedTasks(now: Date = .now) {
        let expirationDate = now.addingTimeInterval(-24 * 60 * 60)
        tasks.removeAll { task in
            task.recurrence == .none && task.isEaten && (task.completedAt ?? now) <= expirationDate
        }
    }

    private func reopenRecurringOrders(for date: Date) {
        var changed = false
        for index in tasks.indices where tasks[index].isEaten && tasks[index].recurrence != .none {
            guard shouldRecur(tasks[index], on: date) else { continue }
            tasks[index].isEaten = false
            tasks[index].completedAt = nil
            changed = true
        }
        if changed {
            saveTasks()
        }
    }

    private func shouldShowToday(_ task: SushiTask) -> Bool {
        if task.isEaten {
            guard let completedAt = task.completedAt else { return true }
            return Calendar.current.isDateInToday(completedAt)
        }
        return true
    }

    private func shouldRecur(_ task: SushiTask, on date: Date) -> Bool {
        switch task.recurrence {
        case .none:
            return false
        case .daily:
            return true
        case .weekdays:
            let weekday = Calendar.current.component(.weekday, from: date)
            return (2...6).contains(weekday)
        case .weekends:
            let weekday = Calendar.current.component(.weekday, from: date)
            return weekday == 1 || weekday == 7
        case .weekly:
            guard let completedAt = task.completedAt,
                  let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: completedAt), to: Calendar.current.startOfDay(for: date)).day else {
                return false
            }
            return days >= 7
        case .custom:
            guard let completedAt = task.completedAt,
                  let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: completedAt), to: Calendar.current.startOfDay(for: date)).day else {
                return false
            }
            return days >= 3
        }
    }

    private func recordAchievementProgress(for task: SushiTask, completedAt: Date) {
        sushiTotalCompletions += 1
        sushiBestDailyCompletions = max(sushiBestDailyCompletions, sushiEatenToday)

        var categoryCounts = decodedCategoryCompletionCounts()
        categoryCounts[task.category.rawValue, default: 0] += 1
        sushiCategoryCompletionCounts = Self.encoded(categoryCounts)

        var completedDayKeys = decodedStringSet(sushiCompletedDayKeys)
        completedDayKeys.insert(Self.localDayKey(for: completedAt))
        sushiCompletedDayKeys = Self.encoded(completedDayKeys)
        sushiCurrentStreak = currentStreak(from: completedDayKeys, endingAt: completedAt)

        refreshUnlockedAchievements(categoryCounts: categoryCounts)
    }

    private func refreshUnlockedAchievements(categoryCounts: [String: Int]) {
        var unlocked = decodedStringSet(sushiUnlockedAchievements)
        for achievement in AchievementDefinition.all where achievementValue(for: achievement, categoryCounts: categoryCounts) >= achievement.target {
            unlocked.insert(achievement.id)
        }
        sushiUnlockedAchievements = Self.encoded(unlocked)
    }

    private func achievementValue(for achievement: AchievementDefinition, categoryCounts: [String: Int]) -> Int {
        switch achievement.metric {
        case .totalTasks:
            return sushiTotalCompletions
        case .bestDailyTasks:
            return sushiBestDailyCompletions
        case .currentStreak:
            return sushiCurrentStreak
        case .categories(let categories):
            return categories.reduce(0) { total, category in
                total + (categoryCounts[category.rawValue] ?? 0)
            }
        }
    }

    private func currentStreak(from completedDayKeys: Set<String>, endingAt date: Date) -> Int {
        var streak = 0
        var cursor = Calendar.current.startOfDay(for: date)

        while completedDayKeys.contains(Self.localDayKey(for: cursor)) {
            streak += 1
            guard let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previousDay
        }

        return streak
    }

    private func refreshCurrentStreakForToday() {
        let completedDayKeys = decodedStringSet(sushiCompletedDayKeys)
        let today = Calendar.current.startOfDay(for: .now)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today) ?? today

        if completedDayKeys.contains(Self.localDayKey(for: today)) {
            sushiCurrentStreak = currentStreak(from: completedDayKeys, endingAt: today)
        } else if completedDayKeys.contains(Self.localDayKey(for: yesterday)) {
            sushiCurrentStreak = currentStreak(from: completedDayKeys, endingAt: yesterday)
        } else {
            sushiCurrentStreak = 0
        }
    }

    private func decodedCategoryCompletionCounts() -> [String: Int] {
        guard let data = sushiCategoryCompletionCounts.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([String: Int].self, from: data) else {
            return [:]
        }
        return decoded
    }

    private func decodedStringSet(_ value: String) -> Set<String> {
        guard let data = value.data(using: .utf8),
              let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) else {
            return []
        }
        return decoded
    }

    private static func encoded<T: Encodable>(_ value: T) -> String {
        guard let data = try? JSONEncoder().encode(value),
              let encoded = String(data: data, encoding: .utf8) else {
            return ""
        }
        return encoded
    }

    private func saveTasks() {
        guard let data = try? JSONEncoder().encode(tasks),
              let encoded = String(data: data, encoding: .utf8) else { return }
        storedTasks = encoded
    }

    private static func localDayKey(for date: Date) -> String {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return "\(components.year ?? 0)-\(components.month ?? 0)-\(components.day ?? 0)"
    }

    private func requestHealthKitAuthorizationIfNeeded() {
        guard !hasAskedHealthKit else { return }
        hasAskedHealthKit = true
        SushiHealthKitStore.shared.requestAuthorizationIfAvailable()
    }
}

final class LocalNotificationScheduler: @unchecked Sendable {
    static let shared = LocalNotificationScheduler()

    private init() {}

    func scheduleReminder(for task: SushiTask) {
        guard task.hasReminder else { return }

        Task {
            guard await requestAuthorization() else { return }
            cancelReminder(for: task)

            let center = UNUserNotificationCenter.current()
            for request in notificationRequests(for: task) {
                do {
                    try await center.add(request)
                } catch {
                    print("Unable to schedule ItadakiTask reminder: \(error.localizedDescription)")
                }
            }
        }
    }

    func cancelReminder(for task: SushiTask) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: reminderIdentifiers(for: task))
    }

    private func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        if settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional {
            return true
        }

        do {
            return try await center.requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    private func notificationRequests(for task: SushiTask) -> [UNNotificationRequest] {
        let content = UNMutableNotificationContent()
        content.title = "Chef has an order for you"
        content.body = task.title
        content.sound = .default

        let calendar = Calendar.current
        let hourMinute = calendar.dateComponents([.hour, .minute], from: task.dueDate)

        switch task.recurrence {
        case .none:
            guard task.dueDate > .now else { return [] }
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.dueDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            return [UNNotificationRequest(identifier: reminderIdentifier(for: task, suffix: "once"), content: content, trigger: trigger)]
        case .daily:
            let trigger = UNCalendarNotificationTrigger(dateMatching: hourMinute, repeats: true)
            return [UNNotificationRequest(identifier: reminderIdentifier(for: task, suffix: "daily"), content: content, trigger: trigger)]
        case .weekdays:
            return (2...6).map { weekday in
                var components = hourMinute
                components.weekday = weekday
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                return UNNotificationRequest(identifier: reminderIdentifier(for: task, suffix: "weekday-\(weekday)"), content: content, trigger: trigger)
            }
        case .weekends:
            return [1, 7].map { weekday in
                var components = hourMinute
                components.weekday = weekday
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                return UNNotificationRequest(identifier: reminderIdentifier(for: task, suffix: "weekend-\(weekday)"), content: content, trigger: trigger)
            }
        case .weekly:
            var components = hourMinute
            components.weekday = calendar.component(.weekday, from: task.dueDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            return [UNNotificationRequest(identifier: reminderIdentifier(for: task, suffix: "weekly"), content: content, trigger: trigger)]
        case .custom:
            let trigger = UNCalendarNotificationTrigger(dateMatching: hourMinute, repeats: true)
            return [UNNotificationRequest(identifier: reminderIdentifier(for: task, suffix: "custom"), content: content, trigger: trigger)]
        }
    }

    private func reminderIdentifiers(for task: SushiTask) -> [String] {
        [
            reminderIdentifier(for: task, suffix: "once"),
            reminderIdentifier(for: task, suffix: "daily"),
            reminderIdentifier(for: task, suffix: "weekday-2"),
            reminderIdentifier(for: task, suffix: "weekday-3"),
            reminderIdentifier(for: task, suffix: "weekday-4"),
            reminderIdentifier(for: task, suffix: "weekday-5"),
            reminderIdentifier(for: task, suffix: "weekday-6"),
            reminderIdentifier(for: task, suffix: "weekend-1"),
            reminderIdentifier(for: task, suffix: "weekend-7"),
            reminderIdentifier(for: task, suffix: "weekly"),
            reminderIdentifier(for: task, suffix: "custom")
        ]
    }

    private func reminderIdentifier(for task: SushiTask, suffix: String) -> String {
        "itadakitask.reminder.\(task.id.uuidString).\(suffix)"
    }
}

final class SushiHealthKitStore: @unchecked Sendable {
    static let shared = SushiHealthKitStore()

    private let healthStore = HKHealthStore()

    private init() {}

    func requestAuthorizationIfAvailable() {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount),
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
            HKObjectType.workoutType()
        ].compactMap { $0 }.reduce(into: Set<HKObjectType>()) { result, type in
            result.insert(type)
        }

        healthStore.requestAuthorization(toShare: [], read: readTypes) { success, error in
            if let error {
                print("HealthKit authorization failed: \(error.localizedDescription)")
            } else if !success {
                print("HealthKit authorization was not granted.")
            }
        }
    }
}

struct ArtworkBackground: View {
    var name: String
    var artworkSize: CGSize

    var body: some View {
        GeometryReader { proxy in
            let scale = max(proxy.size.width / artworkSize.width, proxy.size.height / artworkSize.height)
            let width = artworkSize.width * scale
            let height = artworkSize.height * scale

            ZStack {
                AssetImage(name: name)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: height)
                    .clipped()
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
    }
}

struct CustomerNameText: View {
    var name: String

    var body: some View {
        Text(name)
            .font(.system(size: 19, weight: .black, design: .rounded))
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.55), radius: 2, y: 1)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
    }
}

struct StreakLevelInfo {
    private static let milestones = [0, 1, 3, 7, 14, 30, 60, 100]

    var streakDays: Int

    var level: Int {
        Self.milestones.lastIndex(where: { streakDays >= $0 }) ?? 0
    }

    var progress: Double {
        guard level < Self.milestones.count - 1 else { return 1 }
        let currentMilestone = Self.milestones[level]
        let nextMilestone = Self.milestones[level + 1]
        let span = max(1, nextMilestone - currentMilestone)
        let completed = max(0, streakDays - currentMilestone)
        return min(1, max(0, Double(completed) / Double(span)))
    }
}

struct ProfileStreakLevelOverlay: View {
    var levelInfo: StreakLevelInfo
    var artworkFrame: CGRect

    var body: some View {
        ZStack {
            Text("Lv. \(levelInfo.level)")
                .font(.system(size: max(11, artworkFrame.width * 0.019), weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.65), radius: 2, y: 1)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
                .frame(width: artworkFrame.width * 0.10, alignment: .leading)
                .position(
                    x: artworkFrame.minX + artworkFrame.width * 0.172,
                    y: artworkFrame.minY + artworkFrame.height * 0.082
                )

            ProfileLevelMeter(progress: levelInfo.progress)
                .frame(width: artworkFrame.width * 0.105, height: artworkFrame.height * 0.009)
                .position(
                    x: artworkFrame.minX + artworkFrame.width * 0.210,
                    y: artworkFrame.minY + artworkFrame.height * 0.101
                )
        }
        .allowsHitTesting(false)
    }
}

struct ProfileLevelMeter: View {
    var progress: Double

    var body: some View {
        GeometryReader { proxy in
            let fillWidth = max(0, proxy.size.width * progress)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(red: 0.65, green: 1.0, blue: 0.45))
                    .frame(width: fillWidth)
                    .shadow(color: Color(red: 0.65, green: 1.0, blue: 0.45).opacity(0.72), radius: 2)
            }
        }
        .clipShape(Capsule())
    }
}

struct MealCountText: View {
    var eatenCount: Int
    var maxCount: Int

    var body: some View {
        Text("\(eatenCount) / \(maxCount)")
            .font(.system(size: 23, weight: .black, design: .rounded))
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.55), radius: 2, y: 1)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
    }
}

struct MealCountOverlay: View {
    var eatenCount: Int
    var maxCount: Int
    var artworkFrame: CGRect

    var body: some View {
        Text("\(eatenCount) / \(maxCount)")
            .font(.system(size: max(20, artworkFrame.width * 0.037), weight: .black, design: .rounded))
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.70), radius: 2, y: 1)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .multilineTextAlignment(.center)
            .frame(width: artworkFrame.width * 0.18, height: artworkFrame.height * 0.035)
            .background(
                RoundedRectangle(cornerRadius: artworkFrame.width * 0.016)
                    .fill(Color(red: 0.25, green: 0.12, blue: 0.07).opacity(0.82))
                    .blur(radius: 0.2)
            )
            .position(
                x: artworkFrame.minX + artworkFrame.width * 0.835,
                y: artworkFrame.minY + artworkFrame.height * 0.067
            )
            .allowsHitTesting(false)
            .accessibilityLabel("\(eatenCount) of \(maxCount) sushi eaten today")
    }
}

struct ArtworkNavigationHitZones: View {
    var frame: CGRect

    var body: some View {
        ForEach(0..<5) { index in
            Button {} label: {
                Color.black.opacity(0.001)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(tabName(for: index))
            .frame(width: frame.width * 0.16, height: frame.height * 0.058)
            .position(
                x: frame.minX + frame.width * (0.13 + CGFloat(index) * 0.185),
                y: frame.minY + frame.height * 0.956
            )
        }
    }

    private func tabName(for index: Int) -> String {
        switch index {
        case 0: "Home"
        case 1: "Orders"
        case 2: "Chef"
        case 3: "Collection"
        default: "Achievements"
        }
    }
}

struct OrderMenuHitZones: View {
    var artworkFrame: CGRect
    var showsRightSideOrderButton: Bool
    var openOrders: () -> Void

    var body: some View {
        ZStack {
            Button(action: openOrders) {
                Color.black.opacity(0.001)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open Orders")
            .frame(width: artworkFrame.width * 0.17, height: artworkFrame.height * 0.063)
            .position(
                x: artworkFrame.minX + artworkFrame.width * 0.315,
                y: artworkFrame.minY + artworkFrame.height * 0.956
            )

            if showsRightSideOrderButton {
                Button(action: openOrders) {
                    Color.black.opacity(0.001)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open Orders")
                .frame(width: artworkFrame.width * 0.125, height: artworkFrame.height * 0.055)
                .position(
                    x: artworkFrame.minX + artworkFrame.width * 0.915,
                    y: artworkFrame.minY + artworkFrame.height * 0.451
                )
            }
        }
    }
}

struct CustomerFullCard: View {
    var daypart: Daypart

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "hands.sparkles.fill")
                .font(.system(size: 28, weight: .black))
                .foregroundStyle(daypart.tint)
            VStack(spacing: 2) {
                Text("Your customer is full!")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(.primary)
                Text("Come back tomorrow for another meal.")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .multilineTextAlignment(.center)
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 18))
    }
}

struct TaskBoardView: View {
    var tasks: [SushiTask]
    var daypart: Daypart
    var mealIsFull: Bool
    var recentlyEatenTaskIDs: Set<SushiTask.ID>
    var complete: (SushiTask) -> Void

    var body: some View {
        VStack(spacing: 5) {
            if mealIsFull {
                CustomerFullCard(daypart: daypart)
            }

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 3) {
                    ForEach(tasks) { task in
                        TaskRow(
                            task: task,
                            daypart: daypart,
                            mealIsFull: mealIsFull,
                            isEating: recentlyEatenTaskIDs.contains(task.id)
                        ) {
                            complete(task)
                        }
                    }
                }
                .padding(.vertical, 1)
            }
            .frame(maxHeight: .infinity)
        }
        .padding(.vertical, 2)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

struct TaskRow: View {
    var task: SushiTask
    var daypart: Daypart
    var mealIsFull: Bool
    var isEating: Bool
    var complete: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            VStack(spacing: 3) {
                ForEach(0..<3) { _ in
                    HStack(spacing: 3) {
                        Circle().fill(Color(red: 0.54, green: 0.43, blue: 0.36).opacity(0.55))
                        Circle().fill(Color(red: 0.54, green: 0.43, blue: 0.36).opacity(0.55))
                    }
                }
            }
            .frame(width: 16)

            Text(task.title)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(task.isEaten ? Color(red: 0.40, green: 0.38, blue: 0.36) : Color(red: 0.02, green: 0.12, blue: 0.33))
                .strikethrough(task.isEaten, color: .secondary)
                .lineLimit(1)
                .truncationMode(.tail)

            Spacer()

            CompletionCircle(
                isComplete: task.isEaten,
                isLocked: mealIsFull && !task.isEaten,
                tint: daypart.tint,
                action: complete
            )
            .accessibilityLabel(task.isEaten ? "\(task.title) completed" : "Complete \(task.title)")
        }
        .padding(.horizontal, 8)
        .frame(height: 38)
    }
}

struct CompletionCircle: View {
    var isComplete: Bool
    var isLocked: Bool
    var tint: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .strokeBorder(isLocked ? Color.secondary.opacity(0.35) : tint, lineWidth: 3)
                    .frame(width: 28, height: 28)

                Circle()
                    .fill(Color.green.gradient)
                    .frame(width: isComplete ? 28 : 4, height: isComplete ? 28 : 4)
                    .opacity(isComplete ? 1 : 0)

                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(.white)
                    .scaleEffect(isComplete ? 1 : 0.2)
                    .opacity(isComplete ? 1 : 0)
            }
            .animation(.spring(response: 0.34, dampingFraction: 0.58), value: isComplete)
        }
        .buttonStyle(.plain)
        .disabled(isComplete || isLocked)
        .opacity(isLocked ? 0.42 : 1)
    }
}

struct EatenSparkles: View {
    var tint: Color

    var body: some View {
        ZStack {
            ForEach(0..<7) { index in
                Circle()
                    .fill(index.isMultiple(of: 2) ? tint : .white)
                    .frame(width: index.isMultiple(of: 2) ? 7 : 5, height: index.isMultiple(of: 2) ? 7 : 5)
                    .offset(
                        x: CGFloat(cos(Double(index) * .pi / 3.5) * 26),
                        y: CGFloat(sin(Double(index) * .pi / 3.5) * 18)
                    )
            }
            Image(systemName: "sparkles")
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(tint)
        }
    }
}

struct AddTaskSheet: View {
    var daypart: Daypart
    var addTask: (SushiTask) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var dueDate: Date
    @State private var repeatOption: AddTaskRepeatOption = .none
    @State private var showingDatePicker = false
    @State private var showingTimePicker = false

    init(daypart: Daypart, addTask: @escaping (SushiTask) -> Void) {
        self.daypart = daypart
        self.addTask = addTask
        _dueDate = State(initialValue: Self.defaultDueDate(for: daypart))
    }

    var body: some View {
        GeometryReader { proxy in
            let artworkFrame = orderArtworkFrame(container: proxy.size)

            ZStack {
                AssetImage(name: daypart.orderAsset)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
                    .ignoresSafeArea()

                Button {
                    dismiss()
                } label: {
                    Color.black.opacity(0.001)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close Add Task")
                .frame(width: artworkFrame.width * 0.085, height: artworkFrame.width * 0.085)
                .position(
                    x: artworkFrame.minX + artworkFrame.width * 0.915,
                    y: artworkFrame.minY + artworkFrame.height * 0.471
                )

                AddTaskTextCleanupLayer(artworkFrame: artworkFrame)

                AddTaskStaticTextLayer(
                    titleCount: min(title.count, 60),
                    dateText: dateText,
                    timeText: timeText,
                    repeatOption: repeatOption,
                    artworkFrame: artworkFrame
                )

                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: artworkFrame.width * 0.018)
                        .fill(Color.white.opacity(0.96))

                    if title.isEmpty {
                        Text("What would you like to do?")
                            .font(.system(size: max(14, artworkFrame.width * 0.019), weight: .bold, design: .rounded))
                            .foregroundStyle(Color(red: 0.45, green: 0.49, blue: 0.58).opacity(0.72))
                            .padding(.horizontal, artworkFrame.width * 0.034)
                    }

                    TextField("", text: $title)
                        .font(.system(size: max(15, artworkFrame.width * 0.020), weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 0.08, green: 0.13, blue: 0.26))
                        .submitLabel(.done)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, artworkFrame.width * 0.034)
                }
                .frame(width: artworkFrame.width * 0.84, height: artworkFrame.height * 0.039)
                .position(
                    x: artworkFrame.midX,
                    y: artworkFrame.minY + artworkFrame.height * 0.512
                )
                .accessibilityLabel("What would you like to do?")
                .onChange(of: title) { _, newValue in
                    if newValue.count > 60 {
                        title = String(newValue.prefix(60))
                    }
                }

                dateTimeButton(
                    label: dateText,
                    artworkFrame: artworkFrame,
                    centerX: 0.267,
                    centerY: 0.587,
                    width: 0.44
                ) {
                    showingDatePicker = true
                }
                .accessibilityLabel("Choose task date")

                dateTimeButton(
                    label: timeText,
                    artworkFrame: artworkFrame,
                    centerX: 0.661,
                    centerY: 0.587,
                    width: 0.40
                ) {
                    showingTimePicker = true
                }
                .accessibilityLabel("Choose task time")

                ForEach(AddTaskRepeatOption.allCases) { option in
                    repeatButton(option: option, artworkFrame: artworkFrame)
                }

                Button {
                    submitTask()
                } label: {
                    Color.black.opacity(0.001)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add Task")
                .frame(width: artworkFrame.width * 0.36, height: artworkFrame.height * 0.05)
                .position(
                    x: artworkFrame.midX,
                    y: artworkFrame.minY + artworkFrame.height * 0.702
                )
                .disabled(trimmedTitle.isEmpty)

                Text("Add Task")
                    .font(.system(size: max(19, artworkFrame.width * 0.027), weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.25), radius: 1, y: 1)
                    .allowsHitTesting(false)
                    .position(
                        x: artworkFrame.midX,
                        y: artworkFrame.minY + artworkFrame.height * 0.702
                    )
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .sheet(isPresented: $showingDatePicker) {
            pickerSheet(title: "Choose Date") {
                DatePicker("Date", selection: $dueDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .labelsHidden()
            }
        }
        .sheet(isPresented: $showingTimePicker) {
            pickerSheet(title: "Choose Time") {
                DatePicker("Time", selection: $dueDate, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
            }
        }
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func submitTask() {
        guard !trimmedTitle.isEmpty else { return }
        addTask(
            SushiTask(
                title: String(trimmedTitle.prefix(60)),
                category: .other,
                dueDate: dueDate,
                recurrence: repeatOption.recurrence,
                hasReminder: true
            )
        )
        dismiss()
    }

    private func orderArtworkFrame(container: CGSize) -> CGRect {
        let artworkSize = CGSize(width: 853, height: 1844)
        let scale = max(container.width / artworkSize.width, container.height / artworkSize.height)
        let width = artworkSize.width * scale
        let height = artworkSize.height * scale
        return CGRect(
            x: (container.width - width) / 2,
            y: (container.height - height) / 2,
            width: width,
            height: height
        )
    }

    private var dateText: String {
        if Calendar.current.isDateInToday(dueDate) {
            return "Today, \(dueDate.formatted(.dateTime.month(.abbreviated).day().year()))"
        }
        if Calendar.current.isDateInTomorrow(dueDate) {
            return "Tomorrow"
        }
        return dueDate.formatted(.dateTime.month(.abbreviated).day().year())
    }

    private var timeText: String {
        dueDate.formatted(.dateTime.hour().minute())
    }

    private func dateTimeButton(label: String, artworkFrame: CGRect, centerX: CGFloat, centerY: CGFloat, width: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Color.black.opacity(0.001)
        }
        .buttonStyle(.plain)
        .frame(width: artworkFrame.width * width, height: artworkFrame.height * 0.058)
        .position(
            x: artworkFrame.minX + artworkFrame.width * centerX,
            y: artworkFrame.minY + artworkFrame.height * centerY
        )
    }

    private func repeatButton(option: AddTaskRepeatOption, artworkFrame: CGRect) -> some View {
        Button {
            repeatOption = option
            if option == .tomorrow {
                dueDate = Self.tomorrowDate(preservingTimeFrom: dueDate)
            }
        } label: {
            RoundedRectangle(cornerRadius: artworkFrame.width * 0.018)
                .fill(Color.white.opacity(0.001))
                .overlay(
                    RoundedRectangle(cornerRadius: artworkFrame.width * 0.018)
                        .stroke(repeatOption == option ? Color(red: 1.0, green: 0.22, blue: 0.50) : .clear, lineWidth: 3)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(option.accessibilityLabel)
        .frame(width: artworkFrame.width * option.width, height: artworkFrame.height * 0.047)
        .position(
            x: artworkFrame.minX + artworkFrame.width * option.centerX,
            y: artworkFrame.minY + artworkFrame.height * 0.653
        )
    }

    private func pickerSheet<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        NavigationStack {
            VStack {
                content()
                    .padding()
                Spacer(minLength: 0)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showingDatePicker = false
                        showingTimePicker = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private static func defaultDueDate(for daypart: Daypart) -> Date {
        let calendar = Calendar.current
        let hour: Int
        switch daypart {
        case .morning:
            hour = 8
        case .noon:
            hour = 12
        case .night:
            hour = 20
        }

        return calendar.date(bySettingHour: hour, minute: 0, second: 0, of: .now) ?? .now
    }

    private static func tomorrowDate(preservingTimeFrom date: Date) -> Date {
        let calendar = Calendar.current
        let time = calendar.dateComponents([.hour, .minute, .second], from: date)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: .now) ?? date
        return calendar.date(
            bySettingHour: time.hour ?? 8,
            minute: time.minute ?? 0,
            second: time.second ?? 0,
            of: tomorrow
        ) ?? tomorrow
    }
}

struct AddTaskTextCleanupLayer: View {
    var artworkFrame: CGRect

    private var paper: Color {
        Color(red: 1.0, green: 0.91, blue: 0.78).opacity(0.98)
    }

    private var tilePaper: Color {
        Color.white.opacity(0.97)
    }

    private var pinkButton: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.36, blue: 0.58),
                Color(red: 1.0, green: 0.10, blue: 0.43)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    var body: some View {
        ZStack {
            cleanPanel(width: 0.86, height: 0.276, x: 0.50, y: 0.588)
            cleanupPatch(width: 0.84, height: 0.039, x: 0.50, y: 0.512, color: tilePaper, corner: 0.018)
            cleanupPatch(width: 0.42, height: 0.046, x: 0.267, y: 0.587, color: tilePaper, corner: 0.018)
            cleanupPatch(width: 0.36, height: 0.046, x: 0.661, y: 0.587, color: tilePaper, corner: 0.018)

            ForEach(AddTaskRepeatOption.allCases) { option in
                cleanupPatch(width: option.width, height: 0.043, x: option.centerX, y: 0.653, color: tilePaper, corner: 0.018)
            }

            buttonPatch(width: 0.36, height: 0.047, x: 0.50, y: 0.702)
            closeButtonPatch(x: 0.915, y: 0.471)
        }
        .allowsHitTesting(false)
    }

    private func cleanPanel(width: CGFloat, height: CGFloat, x: CGFloat, y: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: artworkFrame.width * 0.032)
            .fill(paper)
            .overlay(
                RoundedRectangle(cornerRadius: artworkFrame.width * 0.032)
                    .stroke(Color(red: 0.66, green: 0.38, blue: 0.18).opacity(0.24), lineWidth: 2)
            )
            .frame(width: artworkFrame.width * width, height: artworkFrame.height * height)
            .position(
                x: artworkFrame.minX + artworkFrame.width * x,
                y: artworkFrame.minY + artworkFrame.height * y
            )
    }

    private func cleanupPatch(width: CGFloat, height: CGFloat, x: CGFloat, y: CGFloat, color: Color, corner: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: artworkFrame.width * 0.014)
            .fill(color)
            .clipShape(RoundedRectangle(cornerRadius: artworkFrame.width * corner))
            .overlay(
                RoundedRectangle(cornerRadius: artworkFrame.width * corner)
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            )
            .frame(width: artworkFrame.width * width, height: artworkFrame.height * height)
            .position(
                x: artworkFrame.minX + artworkFrame.width * x,
                y: artworkFrame.minY + artworkFrame.height * y
            )
    }

    private func buttonPatch(width: CGFloat, height: CGFloat, x: CGFloat, y: CGFloat) -> some View {
        Capsule()
            .fill(pinkButton)
            .shadow(color: Color(red: 0.65, green: 0.05, blue: 0.25).opacity(0.32), radius: 4, y: 2)
            .frame(width: artworkFrame.width * width, height: artworkFrame.height * height)
            .position(
                x: artworkFrame.minX + artworkFrame.width * x,
                y: artworkFrame.minY + artworkFrame.height * y
            )
    }

    private func closeButtonPatch(x: CGFloat, y: CGFloat) -> some View {
        Circle()
            .fill(pinkButton)
            .overlay(
                Image(systemName: "xmark")
                    .font(.system(size: max(13, artworkFrame.width * 0.020), weight: .black))
                    .foregroundStyle(.white)
            )
            .shadow(color: Color(red: 0.65, green: 0.05, blue: 0.25).opacity(0.25), radius: 3, y: 1)
            .frame(width: artworkFrame.width * 0.052, height: artworkFrame.width * 0.052)
            .position(
                x: artworkFrame.minX + artworkFrame.width * x,
                y: artworkFrame.minY + artworkFrame.height * y
            )
    }
}

struct AddTaskStaticTextLayer: View {
    var titleCount: Int
    var dateText: String
    var timeText: String
    var repeatOption: AddTaskRepeatOption
    var artworkFrame: CGRect

    private var ink: Color {
        Color(red: 0.07, green: 0.09, blue: 0.15)
    }

    private var softInk: Color {
        Color(red: 0.38, green: 0.43, blue: 0.52)
    }

    var body: some View {
        ZStack {
            Text("Add a Task")
                .font(.system(size: max(19, artworkFrame.width * 0.030), weight: .black, design: .rounded))
                .foregroundStyle(ink)
                .position(x: artworkFrame.midX, y: artworkFrame.minY + artworkFrame.height * 0.470)

            Text("Tell Chef what you want to do!")
                .font(.system(size: max(10, artworkFrame.width * 0.014), weight: .semibold, design: .rounded))
                .foregroundStyle(ink.opacity(0.84))
                .position(x: artworkFrame.midX, y: artworkFrame.minY + artworkFrame.height * 0.492)

            Text("e.g. Drink water, Read a book, Go for a walk...")
                .font(.system(size: max(9.5, artworkFrame.width * 0.013), weight: .bold, design: .rounded))
                .foregroundStyle(softInk.opacity(0.78))
                .position(x: artworkFrame.midX, y: artworkFrame.minY + artworkFrame.height * 0.544)

            Text("\(titleCount)/60")
                .font(.system(size: max(9.5, artworkFrame.width * 0.013), weight: .black, design: .rounded))
                .foregroundStyle(softInk.opacity(0.80))
                .position(x: artworkFrame.minX + artworkFrame.width * 0.872, y: artworkFrame.minY + artworkFrame.height * 0.532)

            Text("Date & Time")
                .font(.system(size: max(14, artworkFrame.width * 0.019), weight: .black, design: .rounded))
                .foregroundStyle(ink)
                .frame(width: artworkFrame.width * 0.28, alignment: .leading)
                .position(x: artworkFrame.minX + artworkFrame.width * 0.215, y: artworkFrame.minY + artworkFrame.height * 0.559)

            dateTileLabel("Date", detail: dateText, x: 0.267)
            dateTileLabel("Time", detail: timeText, x: 0.661)

            Text("Repeat")
                .font(.system(size: max(14, artworkFrame.width * 0.019), weight: .black, design: .rounded))
                .foregroundStyle(ink)
                .frame(width: artworkFrame.width * 0.24, alignment: .leading)
                .position(x: artworkFrame.minX + artworkFrame.width * 0.203, y: artworkFrame.minY + artworkFrame.height * 0.631)

            ForEach(AddTaskRepeatOption.allCases) { option in
                repeatLabel(option)
            }
        }
        .allowsHitTesting(false)
    }

    private func dateTileLabel(_ title: String, detail: String, x: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(title)
                .font(.system(size: max(9, artworkFrame.width * 0.013), weight: .black, design: .rounded))
                .foregroundStyle(ink.opacity(0.92))
            Text(detail)
                .font(.system(size: max(10, artworkFrame.width * 0.015), weight: .black, design: .rounded))
                .foregroundStyle(ink)
                .lineLimit(1)
                .minimumScaleFactor(0.62)
        }
        .frame(width: artworkFrame.width * 0.23, alignment: .leading)
        .position(x: artworkFrame.minX + artworkFrame.width * x, y: artworkFrame.minY + artworkFrame.height * 0.588)
    }

    private func repeatLabel(_ option: AddTaskRepeatOption) -> some View {
        VStack(spacing: 1) {
            Text(option.title)
                .font(.system(size: max(9.5, artworkFrame.width * 0.0135), weight: .black, design: .rounded))
                .foregroundStyle(repeatOption == option ? Color(red: 1.0, green: 0.14, blue: 0.43) : ink)
                .lineLimit(1)
                .minimumScaleFactor(0.62)
            if let subtitle = option.subtitle {
                Text(subtitle)
                    .font(.system(size: max(7.5, artworkFrame.width * 0.0105), weight: .bold, design: .rounded))
                    .foregroundStyle(softInk)
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
            }
        }
        .frame(width: artworkFrame.width * option.width * 0.82)
        .position(x: artworkFrame.minX + artworkFrame.width * option.centerX, y: artworkFrame.minY + artworkFrame.height * 0.654)
    }
}

enum AddTaskRepeatOption: String, CaseIterable, Identifiable {
    case none
    case daily
    case weekdays
    case weekends
    case tomorrow

    var id: String { rawValue }

    var recurrence: TaskRecurrence {
        switch self {
        case .none, .tomorrow:
            return .none
        case .daily:
            return .daily
        case .weekdays:
            return .weekdays
        case .weekends:
            return .weekends
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .none: "Repeat none"
        case .daily: "Repeat daily"
        case .weekdays: "Repeat weekdays"
        case .weekends: "Repeat weekends"
        case .tomorrow: "Schedule tomorrow"
        }
    }

    var title: String {
        switch self {
        case .none: "None"
        case .daily: "Daily"
        case .weekdays: "Weekdays"
        case .weekends: "Weekends"
        case .tomorrow: "Tomorrow"
        }
    }

    var subtitle: String? {
        switch self {
        case .weekdays:
            return "Mon - Fri"
        case .weekends:
            return "Sat - Sun"
        default:
            return nil
        }
    }

    var centerX: CGFloat {
        switch self {
        case .none: 0.151
        case .daily: 0.305
        case .weekdays: 0.482
        case .weekends: 0.660
        case .tomorrow: 0.827
        }
    }

    var width: CGFloat {
        switch self {
        case .none: 0.145
        case .daily: 0.145
        case .weekdays: 0.175
        case .weekends: 0.175
        case .tomorrow: 0.17
        }
    }
}

struct CategoryTile: View {
    var option: TaskCategory
    var isSelected: Bool
    var compact: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: compact ? 2 : 3) {
                Image(systemName: option.icon)
                    .font(.system(size: compact ? 15 : 17, weight: .black))
                Text(option.rawValue)
                    .font(.system(size: compact ? 8.7 : 9.5, weight: .black, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.58)
            }
            .frame(maxWidth: .infinity)
            .frame(height: compact ? 40 : 46)
            .foregroundStyle(isSelected ? .white : Color(red: 0.10, green: 0.16, blue: 0.32))
            .background(isSelected ? option.color.gradient : Color.white.opacity(0.88).gradient, in: RoundedRectangle(cornerRadius: 11))
            .overlay(
                RoundedRectangle(cornerRadius: 11)
                    .stroke(isSelected ? Color.white.opacity(0.85) : Color(red: 0.91, green: 0.78, blue: 0.65), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct SushiNigiriView: View {
    var category: TaskCategory

    var toppingColor: Color {
        switch category {
        case .health, .exercise, .sports: Color(red: 0.97, green: 0.33, blue: 0.20)
        case .wellness, .work, .learning: Color(red: 0.98, green: 0.77, blue: 0.20)
        case .home, .social, .relationships: Color(red: 0.92, green: 0.12, blue: 0.40)
        case .money, .creative, .errands, .selfCare, .other: Color(red: 0.08, green: 0.08, blue: 0.09)
        }
    }

    var body: some View {
        ZStack {
            Ellipse()
                .fill(Color.black.opacity(0.12))
                .frame(width: 92, height: 18)
                .offset(y: 26)

            Capsule()
                .fill(Color(red: 1.0, green: 0.96, blue: 0.86))
                .frame(width: 82, height: 38)
                .offset(y: 13)
                .overlay(
                    VStack(spacing: 3) {
                        ForEach(0..<3) { _ in
                            Capsule()
                                .fill(.white.opacity(0.7))
                                .frame(width: 54, height: 2)
                        }
                    }
                    .offset(y: 13)
                )

            RoundedRectangle(cornerRadius: 18)
                .fill(toppingColor.gradient)
                .frame(width: 76, height: 34)
                .rotationEffect(.degrees(-5))
                .offset(y: -2)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(.white.opacity(0.45), lineWidth: 2)
                        .rotationEffect(.degrees(-5))
                        .offset(y: -2)
                )

            if toppingColor == Color(red: 0.08, green: 0.08, blue: 0.09) {
                Circle()
                    .fill(.orange)
                    .frame(width: 12, height: 12)
                    .offset(x: -12, y: -5)
                Circle()
                    .fill(.orange)
                    .frame(width: 12, height: 12)
                    .offset(x: 5, y: -2)
                Circle()
                    .fill(.orange)
                    .frame(width: 12, height: 12)
                    .offset(x: 20, y: -7)
            }
        }
    }
}

struct AssetImage: View {
    var name: String

    var body: some View {
        if UIImage(named: name) != nil {
            Image(name)
                .resizable()
        } else {
            fallback
        }
    }

    private var fallback: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.99, green: 0.47, blue: 0.22),
                    Color(red: 0.96, green: 0.15, blue: 0.49),
                    Color(red: 0.10, green: 0.18, blue: 0.38)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 18) {
                Text("寿司")
                    .font(.system(size: 76, weight: .black, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))
                Text("Itadaki Task")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
            }
        }
    }
}

#Preview {
    ContentView()
}
