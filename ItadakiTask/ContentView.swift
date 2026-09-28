import HealthKit
import SwiftUI
import UserNotifications

struct SushiTask: Identifiable, Codable, Equatable {
    /// Timed tasks by time of day first, then tasks with no time.
    static func boardOrder(_ lhs: SushiTask, _ rhs: SushiTask) -> Bool {
        if lhs.hasTime != rhs.hasTime {
            return lhs.hasTime
        }
        return lhs.dueDate < rhs.dueDate
    }

    var id = UUID()
    var title: String
    var category: TaskCategory
    var dueDate: Date
    /// False for tasks with only a date ("No time"); they get no reminder and sort after timed tasks.
    var hasTime = true
    var recurrence: TaskRecurrence = .none
    var hasReminder = false
    var isEaten = false

    var completedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case category
        case dueDate
        case hasTime
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
        hasTime: Bool = true,
        recurrence: TaskRecurrence = .none,
        hasReminder: Bool = false,
        isEaten: Bool = false,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.dueDate = dueDate
        self.hasTime = hasTime
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
        hasTime = try container.decodeIfPresent(Bool.self, forKey: .hasTime) ?? true
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
    case fitness
    case healthyEating
    case productivity
    case learning
    case selfCare
    case social
    case other

    var id: String { rawValue }

    /// Reads a saved category, including the 14 categories used before the
    /// achievement rework, so older tasks and completion counts keep counting.
    init(storedValue: String) {
        if let category = TaskCategory(rawValue: storedValue) {
            self = category
            return
        }
        switch storedValue {
        case "Exercise", "Sports": self = .fitness
        case "Health": self = .healthyEating
        case "Work", "Home", "Money", "Errands": self = .productivity
        case "Learning": self = .learning
        case "Wellness", "Self-care": self = .selfCare
        case "Social", "Relationships": self = .social
        default: self = .other
        }
    }

    init(from decoder: Decoder) throws {
        self.init(storedValue: try decoder.singleValueContainer().decode(String.self))
    }

    var displayName: String {
        switch self {
        case .fitness: "Fitness"
        case .healthyEating: "Healthy Eating"
        case .productivity: "Productivity"
        case .learning: "Learning"
        case .selfCare: "Self-Care"
        case .social: "Social"
        case .other: "Other"
        }
    }

    var icon: String {
        switch self {
        case .fitness: "figure.run"
        case .healthyEating: "carrot.fill"
        case .productivity: "laptopcomputer"
        case .learning: "book.fill"
        case .selfCare: "leaf.fill"
        case .social: "bubble.left.and.bubble.right.fill"
        case .other: "star.fill"
        }
    }

    var color: Color {
        switch self {
        case .fitness: .blue
        case .healthyEating: .green
        case .productivity: .indigo
        case .learning: .orange
        case .selfCare: .purple
        case .social: .pink
        case .other: .yellow
        }
    }
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

    var thankAsset: String {
        switch self {
        case .morning, .noon:
            "ThankNoon"
        case .night:
            "ThankNight"
        }
    }

    func homeLayout(mealIsFull: Bool) -> HomeArtworkLayout {
        switch (self, mealIsFull) {
        case (.morning, false): .morningChef
        case (.noon, false): .noonChef
        case (.night, false): .nightChef
        case (.morning, true), (.noon, true): .dayThank
        case (.night, true): .nightThank
        }
    }
}

/// Where things sit in each home background, in the artwork's own pixels.
/// Some artwork paints placeholder text ("Jen", "Lv. 0", "0 / 10") into its panels,
/// so there each live value is drawn over a patch tinted to match the panel.
struct HomeArtworkLayout {
    struct Patch {
        var rect: CGRect
        var top: Color
        var bottom: Color
    }

    var artworkSize: CGSize

    /// Patches are only needed where the artwork paints placeholder text; nil means the panel is already empty.
    var profilePatch: Patch?
    var nameLeadingX: CGFloat
    var nameCenterY: CGFloat
    var nameFontSize: CGFloat
    var levelCenterY: CGFloat
    var levelFontSize: CGFloat
    var meterRect: CGRect
    var meterFill: [Color]

    var countPatch: Patch?
    var countCenter: CGPoint
    var countFontSize: CGFloat
    var labelPatch: Patch?
    var labelCenter: CGPoint
    var labelFontSize: CGFloat
    var labelText: String

    /// The painted task rows on the orders board (unused on the "customer is full" art).
    var firstRowTop: CGFloat = 0
    var rowPitch: CGFloat = 0
    var rowHeight: CGFloat = 0
    var rowMinX: CGFloat = 0
    var rowMaxX: CGFloat = 0
    var paintedRowCount: CGFloat = 5
    /// The painted "+ Add a Task" button.
    var addTaskButton: CGRect = .zero

    private static let dayMeter = [Color.white, Color(red: 1.0, green: 0.78, blue: 0.86)]
    private static let nightMeter = [Color(red: 1.0, green: 0.86, blue: 0.48), Color(red: 0.96, green: 0.68, blue: 0.28)]

    private static func brown(_ r: Double, _ g: Double, _ b: Double) -> Color {
        Color(red: r, green: g, blue: b)
    }

    static let morningChef = HomeArtworkLayout(
        artworkSize: CGSize(width: 850, height: 1850),
        profilePatch: nil,
        nameLeadingX: 120, nameCenterY: 101, nameFontSize: 24,
        levelCenterY: 126, levelFontSize: 21,
        meterRect: CGRect(x: 119, y: 140, width: 86, height: 11),
        meterFill: dayMeter,
        countPatch: nil,
        countCenter: CGPoint(x: 766, y: 113), countFontSize: 42,
        labelPatch: nil,
        labelCenter: CGPoint(x: 740, y: 147), labelFontSize: 23, labelText: "sushi eaten today",
        firstRowTop: 912, rowPitch: 80, rowHeight: 74, rowMinX: 64, rowMaxX: 790,
        addTaskButton: CGRect(x: 616, y: 851, width: 172, height: 50)
    )

    static let noonChef = HomeArtworkLayout(
        artworkSize: CGSize(width: 853, height: 1844),
        profilePatch: nil,
        nameLeadingX: 120, nameCenterY: 101, nameFontSize: 24,
        levelCenterY: 126, levelFontSize: 21,
        meterRect: CGRect(x: 119, y: 140, width: 86, height: 11),
        meterFill: dayMeter,
        countPatch: nil,
        countCenter: CGPoint(x: 768, y: 113), countFontSize: 42,
        labelPatch: nil,
        labelCenter: CGPoint(x: 742, y: 147), labelFontSize: 23, labelText: "sushi eaten today",
        firstRowTop: 908, rowPitch: 67, rowHeight: 63, rowMinX: 64, rowMaxX: 796,
        addTaskButton: CGRect(x: 623, y: 851, width: 170, height: 48)
    )

    static let nightChef = HomeArtworkLayout(
        artworkSize: CGSize(width: 851, height: 1847),
        profilePatch: nil,
        nameLeadingX: 127, nameCenterY: 131, nameFontSize: 26,
        levelCenterY: 155, levelFontSize: 22,
        meterRect: CGRect(x: 127, y: 171, width: 98, height: 13),
        meterFill: nightMeter,
        countPatch: nil,
        countCenter: CGPoint(x: 766, y: 135), countFontSize: 44,
        labelPatch: nil,
        labelCenter: CGPoint(x: 731, y: 171), labelFontSize: 25, labelText: "Sushi Eaten Today",
        firstRowTop: 863, rowPitch: 70.5, rowHeight: 65, rowMinX: 36, rowMaxX: 810,
        addTaskButton: CGRect(x: 640, y: 803, width: 165, height: 44)
    )

    /// The gachapon unlock screen's header panels (the rest of that screen is animation).
    static let gachapon = HomeArtworkLayout(
        artworkSize: CGSize(width: 851, height: 1848),
        profilePatch: nil,
        nameLeadingX: 122, nameCenterY: 110, nameFontSize: 25,
        levelCenterY: 136, levelFontSize: 21,
        meterRect: CGRect(x: 122, y: 151, width: 95, height: 11),
        meterFill: nightMeter,
        countPatch: nil,
        countCenter: CGPoint(x: 772, y: 117), countFontSize: 42,
        labelPatch: nil,
        labelCenter: CGPoint(x: 740, y: 162), labelFontSize: 22, labelText: "Sushi Eaten Today"
    )

    static let dayThank = HomeArtworkLayout(
        artworkSize: CGSize(width: 851, height: 1848),
        profilePatch: Patch(rect: CGRect(x: 118, y: 96, width: 107, height: 72), top: brown(0.304, 0.111, 0.040), bottom: brown(0.289, 0.113, 0.056)),
        nameLeadingX: 123, nameCenterY: 115, nameFontSize: 25,
        levelCenterY: 139, levelFontSize: 21,
        meterRect: CGRect(x: 122, y: 151, width: 90, height: 11),
        meterFill: dayMeter,
        countPatch: Patch(rect: CGRect(x: 712, y: 104, width: 116, height: 37), top: brown(0.298, 0.110, 0.044), bottom: brown(0.258, 0.092, 0.038)),
        countCenter: CGPoint(x: 762, y: 123), countFontSize: 42,
        labelPatch: Patch(rect: CGRect(x: 655, y: 142, width: 177, height: 26), top: brown(0.270, 0.093, 0.028), bottom: brown(0.223, 0.077, 0.026)),
        labelCenter: CGPoint(x: 736, y: 155), labelFontSize: 24, labelText: "sushi eaten today"
    )

    static let nightThank = HomeArtworkLayout(
        artworkSize: CGSize(width: 851, height: 1848),
        profilePatch: Patch(rect: CGRect(x: 118, y: 97, width: 98, height: 75), top: brown(0.264, 0.112, 0.040), bottom: brown(0.163, 0.070, 0.031)),
        nameLeadingX: 123, nameCenterY: 116, nameFontSize: 26,
        levelCenterY: 140, levelFontSize: 22,
        meterRect: CGRect(x: 122, y: 154, width: 82, height: 10),
        meterFill: dayMeter,
        countPatch: Patch(rect: CGRect(x: 712, y: 104, width: 114, height: 38), top: brown(0.201, 0.086, 0.038), bottom: brown(0.167, 0.076, 0.036)),
        countCenter: CGPoint(x: 762, y: 124), countFontSize: 42,
        labelPatch: Patch(rect: CGRect(x: 655, y: 143, width: 175, height: 27), top: brown(0.166, 0.074, 0.035), bottom: brown(0.144, 0.064, 0.033)),
        labelCenter: CGPoint(x: 736, y: 156), labelFontSize: 24, labelText: "sushi eaten today"
    )
}

/// Converts artwork pixels into screen points for one fitted artwork frame.
struct ArtworkMapper {
    var frame: CGRect
    var artworkSize: CGSize

    var scale: CGFloat { frame.width / artworkSize.width }

    func point(_ p: CGPoint) -> CGPoint {
        CGPoint(x: frame.minX + p.x * scale, y: frame.minY + p.y * scale)
    }

    func rect(_ r: CGRect) -> CGRect {
        CGRect(x: frame.minX + r.minX * scale, y: frame.minY + r.minY * scale, width: r.width * scale, height: r.height * scale)
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
    @AppStorage("sushiAchievementStates") private var sushiAchievementStates = ""
    @AppStorage("sushiPendingAchievementUnlocks") private var sushiPendingAchievementUnlocks = ""
    @AppStorage("sushiCollectedAchievementUnlocks") private var sushiCollectedAchievementUnlocks = ""
    @AppStorage("sushiCollectionStates") private var sushiCollectionStates = ""
    @AppStorage("sushiPendingCustomerArrivals") private var sushiPendingCustomerArrivals = ""
    @AppStorage("sushiAskedHealthKit") private var hasAskedHealthKit = false
    @AppStorage("sushiRepairedSkippedWelcomes") private var hasRepairedSkippedWelcomes = false
    /// Achievements whose customer is being welcomed again, so First Visited uses the welcome day.
    @AppStorage("sushiReplayWelcomeAchievementIDs") private var sushiReplayWelcomeAchievementIDs = ""

    @State private var tasks: [SushiTask] = []
    /// The bottom-menu screen shown over the task list (Chef), or nil for the task list itself.
    /// One full-screen container swaps between them, so tabs change in place.
    @State private var activeScreen: MenuScreen?
    @State private var showingNamePrompt = false
    @State private var draftName = ""
    @State private var recentlyEatenTaskIDs: Set<SushiTask.ID> = []
    @State private var currentAchievementUnlock: Achievement?
    @State private var currentCustomerArrival: CollectionCharacter?

    private let daypart = Daypart()

    var body: some View {
        GeometryReader { proxy in
            let backgroundAsset = mealIsFull ? daypart.thankAsset : daypart.chefAsset
            let layout = daypart.homeLayout(mealIsFull: mealIsFull)
            let backgroundArtworkSize = layout.artworkSize
            let artworkFrame = fittedArtworkFrame(
                container: proxy.size,
                artwork: backgroundArtworkSize
            )
            let mapper = ArtworkMapper(frame: artworkFrame, artworkSize: layout.artworkSize)
            let rowArea = mapper.rect(CGRect(
                x: layout.rowMinX,
                y: layout.firstRowTop,
                width: layout.rowMaxX - layout.rowMinX,
                height: layout.rowPitch * (layout.paintedRowCount - 1) + layout.rowHeight
            ))
            let addTaskButton = mapper.rect(layout.addTaskButton)

            ZStack {
                ArtworkBackground(name: backgroundAsset, artworkSize: backgroundArtworkSize)

                ProfileStreakLevelOverlay(
                    name: displayName,
                    levelInfo: streakLevelInfo,
                    layout: layout,
                    mapper: mapper
                )

                MealCountOverlay(
                    eatenCount: sushiEatenToday,
                    maxCount: mealLimit,
                    layout: layout,
                    mapper: mapper
                )

                OrderMenuHitZones(
                    artworkFrame: artworkFrame,
                    openProfile: {
                        show(.profile)
                    },
                    openCollection: {
                        show(.collection)
                    },
                    openAchievements: {
                        show(.achievements)
                    }
                ) {
                    show(.orders)
                }

                if !mealIsFull {
                    Button {
                        show(.orders)
                    } label: {
                        Color.black.opacity(0.001)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Add a Task")
                    .frame(width: addTaskButton.width, height: addTaskButton.height)
                    .position(x: addTaskButton.midX, y: addTaskButton.midY)

                    TaskBoardView(
                        tasks: activeTasks,
                        daypart: daypart,
                        mealIsFull: mealIsFull,
                        recentlyEatenTaskIDs: recentlyEatenTaskIDs,
                        rowHeight: layout.rowHeight * mapper.scale,
                        rowSpacing: (layout.rowPitch - layout.rowHeight) * mapper.scale,
                        complete: { task in
                            complete(task)
                        },
                        delete: { task in
                            delete(task)
                        },
                        edit: { task in
                            activeScreen = .editing(task)
                        }
                    )
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
            migrateLegacyAchievementUnlocksIfNeeded()
            evaluateAchievements()
            repairSkippedWelcomesIfNeeded()
            migrateCollectionUnlocksIfNeeded()
            presentNextPendingCustomerArrivalIfNeeded()
            presentNextPendingAchievementUnlockIfNeeded()
            requestHealthKitAuthorizationIfNeeded()
            Task {
                await PremiumStore.shared.start()
                syncRemindersWithPremium()
            }
        }
        .fullScreenCover(isPresented: activeScreenIsPresented, onDismiss: menuScreenDismissed) {
            menuScreenContent
        }
        .fullScreenCover(item: $currentAchievementUnlock) { achievement in
            GachaponUnlockView(
                achievement: achievement,
                header: GachaponHeader(
                    name: displayName,
                    levelInfo: streakLevelInfo,
                    eatenCount: sushiEatenToday,
                    maxCount: mealLimit
                )
            ) {
                collectAchievementUnlock(achievement)
            }
        }
        .fullScreenCover(item: $currentCustomerArrival) { character in
            NewCustomerArrivalView(character: character) {
                welcomeCustomerArrival(character)
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
        .onReceive(NotificationCenter.default.publisher(for: .premiumStatusChanged)) { _ in
            syncRemindersWithPremium()
        }
        .onReceive(NotificationCenter.default.publisher(for: .chefAlarmChanged)) { _ in
            // Scheduled reminders keep the sound they were created with, so reschedule them.
            syncRemindersWithPremium()
        }
    }

    private var activeScreenIsPresented: Binding<Bool> {
        Binding(
            get: { activeScreen != nil },
            set: { if !$0 { activeScreen = nil } }
        )
    }

    /// Opens a bottom-menu screen. If one is already showing, it's swapped in place
    /// with a quick cross-fade instead of sliding back to the task list first.
    private func show(_ destination: AddTaskMenuDestination) {
        let screen: MenuScreen
        switch destination {
        case .profile: screen = .profile
        case .orders: screen = .orders
        case .collection: screen = .collection
        case .achievements: screen = .achievements
        }
        if activeScreen == nil {
            activeScreen = screen
        } else {
            withAnimation(.easeInOut(duration: 0.18)) {
                activeScreen = screen
            }
        }
    }

    private func menuScreenDismissed() {
        presentNextPendingCustomerArrivalIfNeeded()
        presentNextPendingAchievementUnlockIfNeeded()
    }

    @ViewBuilder
    private var menuScreenContent: some View {
        ZStack {
            switch activeScreen {
            case .profile:
                ProfileScreen(
                    name: $customerName,
                    levelInfo: streakLevelInfo,
                    totalSushiEaten: sushiTotalCompletions,
                    eatenToday: sushiEatenToday,
                    mealLimit: mealLimit,
                    achievements: achievements,
                    characters: collectionCharacters,
                    navigate: show
                )
                .transition(.opacity)
            case .orders:
                AddTaskSheet(
                    daypart: daypart,
                    addTask: { task in
                        withAnimation(.spring(response: 0.42, dampingFraction: 0.78)) {
                            tasks.append(task)
                            saveTasks()
                        }
                        LocalNotificationScheduler.shared.scheduleReminder(for: task)
                    },
                    openMenuDestination: show
                )
                .transition(.opacity)
            case .editing(let task):
                AddTaskSheet(
                    daypart: daypart,
                    editing: task,
                    addTask: { updated in
                        update(updated)
                    },
                    openMenuDestination: show
                )
                .id(task.id)
                .transition(.opacity)
            case .collection:
                CollectionScreen(characters: collectionCharacters)
                    .transition(.opacity)
            case .achievements:
                AchievementsScreen(
                    achievements: achievements,
                    pendingUnlockIDs: decodedStringArray(sushiPendingAchievementUnlocks),
                    collectedUnlockIDs: decodedStringSet(sushiCollectedAchievementUnlocks),
                    collectionCharacters: collectionCharacters
                )
                .transition(.opacity)
            case nil:
                Color.clear
            }
        }
    }

    private var displayName: String {
        customerName.isEmpty ? "Chef's Guest" : customerName
    }

    private var activeTasks: [SushiTask] {
        todaysTasks.filter { !$0.isEaten }.sorted(by: SushiTask.boardOrder)
    }

    private var todaysTasks: [SushiTask] {
        tasks
            .filter { shouldShowToday($0) }
            .sorted { lhs, rhs in
                if lhs.isEaten != rhs.isEaten {
                    return !lhs.isEaten
                }
                return SushiTask.boardOrder(lhs, rhs)
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

    private var achievementProgressSnapshot: AchievementProgressSnapshot {
        AchievementProgressSnapshot(
            totalCompletions: sushiTotalCompletions,
            bestDailyCompletions: sushiBestDailyCompletions,
            currentStreak: sushiCurrentStreak,
            categoryCompletionCounts: decodedCategoryCompletionCounts()
        )
    }

    private var achievements: [Achievement] {
        AchievementManager.achievements(
            from: decodedAchievementStates(),
            progress: achievementProgressSnapshot
        )
    }

    private var collectionCharacters: [CollectionCharacter] {
        CollectionManager.characters(from: decodedCollectionStates())
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

    /// Premium schedules every task's reminder; without it, none are scheduled.
    private func syncRemindersWithPremium() {
        let scheduler = LocalNotificationScheduler.shared
        scheduler.cancelAllReminders()
        guard PremiumStore.isPremiumCached else { return }
        for task in tasks where task.hasReminder {
            scheduler.scheduleReminder(for: task)
        }
    }

    /// Saves edits to an existing task and reschedules its reminders.
    private func update(_ task: SushiTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        LocalNotificationScheduler.shared.cancelReminder(for: tasks[index])
        tasks[index] = task
        saveTasks()
        LocalNotificationScheduler.shared.scheduleReminder(for: task)
    }

    /// Removes a task (and, for a repeating task, all of its future repeats).
    /// Completion history and achievement progress are unaffected.
    private func delete(_ task: SushiTask) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            tasks.removeAll { $0.id == task.id }
        }
        saveTasks()
        LocalNotificationScheduler.shared.cancelReminder(for: task)
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
            presentNextPendingAchievementUnlockIfNeeded()
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

        evaluateAchievements()
    }

    private func evaluateAchievements() {
        let result = AchievementManager.evaluate(
            states: decodedAchievementStates(),
            pendingUnlockIDs: decodedStringArray(sushiPendingAchievementUnlocks),
            progress: achievementProgressSnapshot
        )
        sushiAchievementStates = Self.encoded(result.states)
        sushiPendingAchievementUnlocks = Self.encoded(result.pendingUnlockIDs)
        sushiUnlockedAchievements = Self.encoded(Set(result.states.filter(\.isUnlocked).map(\.id)))
    }

    private func presentNextPendingAchievementUnlockIfNeeded() {
        guard currentAchievementUnlock == nil else { return }
        guard currentCustomerArrival == nil else { return }
        guard activeScreen == nil else { return }
        guard decodedStringArray(sushiPendingCustomerArrivals).isEmpty else {
            presentNextPendingCustomerArrivalIfNeeded()
            return
        }

        let collectedIDs = decodedStringSet(sushiCollectedAchievementUnlocks)
        let pendingIDs = decodedStringArray(sushiPendingAchievementUnlocks)

        guard let nextID = pendingIDs.first(where: { !collectedIDs.contains($0) }),
              let achievement = achievements.first(where: { $0.id == nextID && $0.isUnlocked }) else {
            return
        }

        DispatchQueue.main.async {
            currentAchievementUnlock = achievement
        }
    }

    private func collectAchievementUnlock(_ achievement: Achievement) {
        var collectedIDs = decodedStringSet(sushiCollectedAchievementUnlocks)
        collectedIDs.insert(achievement.id)
        sushiCollectedAchievementUnlocks = Self.encoded(collectedIDs)

        let remainingPendingIDs = decodedStringArray(sushiPendingAchievementUnlocks).filter { $0 != achievement.id }
        sushiPendingAchievementUnlocks = Self.encoded(remainingPendingIDs)

        var replayIDs = decodedStringSet(sushiReplayWelcomeAchievementIDs)
        let isReplayedWelcome = replayIDs.remove(achievement.id) != nil
        sushiReplayWelcomeAchievementIDs = Self.encoded(replayIDs)

        let unlockResult: CollectionUnlockResult?
        if isReplayedWelcome, let characterID = CollectionManager.characterID(for: achievement.id) {
            unlockResult = CollectionManager.unlockCharacter(id: characterID, states: decodedCollectionStates(), metAt: .now)
        } else {
            unlockResult = CollectionManager.unlockCharacter(for: achievement, states: decodedCollectionStates())
        }

        if let result = unlockResult {
            sushiCollectionStates = Self.encoded(result.states)
            if let character = result.newlyUnlocked {
                enqueueCustomerArrival(character.id)
            }
        }

        currentAchievementUnlock = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            if presentNextPendingCustomerArrivalIfNeeded() {
                return
            }
            presentNextPendingAchievementUnlockIfNeeded()
        }
    }

    @discardableResult
    private func presentNextPendingCustomerArrivalIfNeeded() -> Bool {
        guard currentAchievementUnlock == nil else { return false }
        guard currentCustomerArrival == nil else { return true }
        guard activeScreen == nil else { return false }

        let pendingIDs = decodedStringArray(sushiPendingCustomerArrivals)
        guard let nextID = pendingIDs.first,
              let character = collectionCharacters.first(where: { $0.id == nextID && $0.isUnlocked }) else {
            return false
        }

        DispatchQueue.main.async {
            currentCustomerArrival = character
        }
        return true
    }

    private func welcomeCustomerArrival(_ character: CollectionCharacter) {
        let remainingPendingIDs = decodedStringArray(sushiPendingCustomerArrivals).filter { $0 != character.id }
        sushiPendingCustomerArrivals = Self.encoded(remainingPendingIDs)
        currentCustomerArrival = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            presentNextPendingAchievementUnlockIfNeeded()
        }
    }

    private func enqueueCustomerArrival(_ characterID: String) {
        var pendingIDs = decodedStringArray(sushiPendingCustomerArrivals)
        guard !pendingIDs.contains(characterID) else { return }
        pendingIDs.append(characterID)
        sushiPendingCustomerArrivals = Self.encoded(pendingIDs)
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
        // Folds counts saved under the old category names into the current categories.
        var normalized: [String: Int] = [:]
        for (storedCategory, count) in decoded {
            normalized[TaskCategory(storedValue: storedCategory).rawValue, default: 0] += count
        }
        return normalized
    }

    private func decodedAchievementStates() -> [AchievementState] {
        guard let data = sushiAchievementStates.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([AchievementState].self, from: data) else {
            return AchievementManager.initialStates()
        }
        return decoded
    }

    private func decodedCollectionStates() -> [CollectionCharacterState] {
        guard let data = sushiCollectionStates.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([CollectionCharacterState].self, from: data) else {
            return CollectionManager.initialStates()
        }
        return decoded
    }

    private func decodedStringArray(_ value: String) -> [String] {
        guard let data = value.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([String].self, from: data) else {
            return []
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

    private func migrateLegacyAchievementUnlocksIfNeeded() {
        guard sushiAchievementStates.isEmpty else { return }
        let legacyUnlockedIDs = decodedStringSet(sushiUnlockedAchievements)
        guard !legacyUnlockedIDs.isEmpty else {
            sushiAchievementStates = Self.encoded(AchievementManager.initialStates())
            return
        }

        let migratedStates = AchievementManager.definitions.map { definition in
            AchievementState(
                id: definition.id,
                unlockedDate: legacyUnlockedIDs.contains(definition.id) ? Date.now : nil
            )
        }
        sushiAchievementStates = Self.encoded(migratedStates)
    }

    /// One-time repair: the legacy achievement migration unlocked some characters directly,
    /// skipping the gachapon reveal and the New Customer welcome. Send those back through
    /// the normal flow. Their achievement dates are kept; First Visited becomes the welcome day.
    private func repairSkippedWelcomesIfNeeded() {
        guard !hasRepairedSkippedWelcomes else { return }
        hasRepairedSkippedWelcomes = true

        let collectedIDs = decodedStringSet(sushiCollectedAchievementUnlocks)
        var pendingIDs = decodedStringArray(sushiPendingAchievementUnlocks)
        let skippedIDs = achievements
            .filter { $0.isUnlocked && !collectedIDs.contains($0.id) && !pendingIDs.contains($0.id) }
            .map(\.id)
            .filter { CollectionManager.characterID(for: $0) != nil }
        guard !skippedIDs.isEmpty else { return }

        let characterIDs = Set(skippedIDs.compactMap { CollectionManager.characterID(for: $0) })
        let relockedStates = decodedCollectionStates().map { state in
            characterIDs.contains(state.id) ? CollectionCharacterState(id: state.id, dateFirstMet: nil) : state
        }
        sushiCollectionStates = Self.encoded(relockedStates)

        pendingIDs.append(contentsOf: skippedIDs)
        sushiPendingAchievementUnlocks = Self.encoded(pendingIDs)
        sushiReplayWelcomeAchievementIDs = Self.encoded(decodedStringSet(sushiReplayWelcomeAchievementIDs).union(skippedIDs))
    }

    private func migrateCollectionUnlocksIfNeeded() {
        let currentStates = decodedCollectionStates()
        let pendingAchievementIDs = Set(decodedStringArray(sushiPendingAchievementUnlocks))
        let backfillableAchievements = achievements.filter { !pendingAchievementIDs.contains($0.id) }
        let backfilledStates = CollectionManager.backfillUnlockedCharacters(
            from: backfillableAchievements,
            states: currentStates
        )

        if sushiCollectionStates.isEmpty || backfilledStates != currentStates {
            sushiCollectionStates = Self.encoded(backfilledStates)
        }
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

    /// The Premium Chef alarm the user picked, or nil to fall back to the default sound.
    private static var chefSoundFile: String? {
        let name = ChefAlarm.selected
        return ChefAlarm.url(for: name) == nil ? nil : "\(name).caf"
    }

    /// Scheduled reminders are a Premium feature.
    func scheduleReminder(for task: SushiTask) {
        guard task.hasReminder, task.hasTime, PremiumStore.isPremiumCached else { return }

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

    /// Removes every scheduled reminder (used when Premium isn't active).
    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
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
        content.sound = Self.chefSoundFile.map { UNNotificationSound(named: UNNotificationSoundName($0)) } ?? .default

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

    /// Streak days still needed to reach the next level, or nil at the top level.
    var daysToNextLevel: Int? {
        guard level < Self.milestones.count - 1 else { return nil }
        return max(0, Self.milestones[level + 1] - streakDays)
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
    var name: String
    var levelInfo: StreakLevelInfo
    var layout: HomeArtworkLayout
    var mapper: ArtworkMapper

    var body: some View {
        let meter = mapper.rect(layout.meterRect)
        let leadingX = mapper.point(CGPoint(x: layout.nameLeadingX, y: 0)).x
        // Name and level may run a little past the meter, to just inside the panel edge.
        let textWidth = meter.maxX - leadingX + 6 * mapper.scale

        ZStack(alignment: .topLeading) {
            ArtworkPatch(patch: layout.profilePatch, mapper: mapper)

            Text(name)
                .font(.system(size: layout.nameFontSize * mapper.scale, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.55), radius: 1.5, y: 1)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .frame(width: textWidth, alignment: .leading)
                .position(x: leadingX + textWidth / 2, y: mapper.point(CGPoint(x: 0, y: layout.nameCenterY)).y)

            Text("Lv. \(levelInfo.level)")
                .font(.system(size: layout.levelFontSize * mapper.scale, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.95))
                .shadow(color: .black.opacity(0.55), radius: 1.5, y: 1)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(width: textWidth, alignment: .leading)
                .position(x: leadingX + textWidth / 2, y: mapper.point(CGPoint(x: 0, y: layout.levelCenterY)).y)

            ProfileLevelMeter(progress: levelInfo.progress, fill: layout.meterFill)
                .frame(width: meter.width, height: meter.height)
                .position(x: meter.midX, y: meter.midY)
        }
        .allowsHitTesting(false)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(name), level \(levelInfo.level)")
    }
}

/// Covers placeholder text painted into the artwork with the panel's own colors.
struct ArtworkPatch: View {
    var patch: HomeArtworkLayout.Patch?
    var mapper: ArtworkMapper

    var body: some View {
        if let patch {
            let rect = mapper.rect(patch.rect)
            RoundedRectangle(cornerRadius: 4 * mapper.scale)
                .fill(LinearGradient(colors: [patch.top, patch.bottom], startPoint: .top, endPoint: .bottom))
                .frame(width: rect.width, height: rect.height)
                .blur(radius: 1.2 * mapper.scale)
                .position(x: rect.midX, y: rect.midY)
        }
    }
}

struct ProfileLevelMeter: View {
    var progress: Double
    var fill: [Color]

    var body: some View {
        GeometryReader { proxy in
            let fillWidth = max(0, proxy.size.width * progress)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.22))
                Capsule()
                    .fill(LinearGradient(colors: fill, startPoint: .leading, endPoint: .trailing))
                    .frame(width: fillWidth)
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
    var layout: HomeArtworkLayout
    var mapper: ArtworkMapper

    var body: some View {
        let count = mapper.point(layout.countCenter)
        let label = mapper.point(layout.labelCenter)
        let countWidth = 116 * mapper.scale
        let labelWidth = 180 * mapper.scale

        ZStack(alignment: .topLeading) {
            ArtworkPatch(patch: layout.countPatch, mapper: mapper)
            ArtworkPatch(patch: layout.labelPatch, mapper: mapper)

            Text("\(eatenCount) / \(maxCount)")
                .font(.system(size: layout.countFontSize * mapper.scale, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.55), radius: 1.5, y: 1)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(width: countWidth)
                .position(count)

            Text(layout.labelText)
                .font(.system(size: layout.labelFontSize * mapper.scale, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.95))
                .shadow(color: .black.opacity(0.55), radius: 1.5, y: 1)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(width: labelWidth)
                .position(label)
        }
        .allowsHitTesting(false)
        .accessibilityElement(children: .ignore)
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
    var openProfile: () -> Void
    var openCollection: () -> Void
    var openAchievements: () -> Void
    var openOrders: () -> Void

    var body: some View {
        ZStack {
            Button(action: openProfile) {
                Color.black.opacity(0.001)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open Profile")
            .frame(width: artworkFrame.width * 0.17, height: artworkFrame.height * 0.063)
            .position(
                x: artworkFrame.minX + artworkFrame.width * 0.13,
                y: artworkFrame.minY + artworkFrame.height * 0.956
            )

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

            Button(action: openCollection) {
                Color.black.opacity(0.001)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open Collection")
            .frame(width: artworkFrame.width * 0.17, height: artworkFrame.height * 0.063)
            .position(
                x: artworkFrame.minX + artworkFrame.width * 0.685,
                y: artworkFrame.minY + artworkFrame.height * 0.956
            )

            Button(action: openAchievements) {
                Color.black.opacity(0.001)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open Achievements")
            .frame(width: artworkFrame.width * 0.17, height: artworkFrame.height * 0.063)
            .position(
                x: artworkFrame.minX + artworkFrame.width * 0.870,
                y: artworkFrame.minY + artworkFrame.height * 0.956
            )
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
    /// Matches the painted rows on the orders board.
    var rowHeight: CGFloat
    var rowSpacing: CGFloat
    var complete: (SushiTask) -> Void
    var delete: (SushiTask) -> Void
    var edit: (SushiTask) -> Void

    var body: some View {
        VStack(spacing: 5) {
            if mealIsFull {
                CustomerFullCard(daypart: daypart)
            }

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: rowSpacing) {
                    ForEach(tasks) { task in
                        SwipeToDeleteRow(rowHeight: rowHeight) {
                            delete(task)
                        } content: { isSwiping in
                            TaskRow(
                                task: task,
                                daypart: daypart,
                                mealIsFull: mealIsFull,
                                isEating: recentlyEatenTaskIDs.contains(task.id),
                                rowHeight: rowHeight,
                                edit: {
                                    guard !isSwiping else { return }
                                    edit(task)
                                }
                            ) {
                                // A left swipe often starts on the check circle; don't let it complete the task.
                                guard !isSwiping else { return }
                                complete(task)
                            }
                        }
                        .transition(.asymmetric(insertion: .identity, removal: .move(edge: .leading).combined(with: .opacity)))
                    }
                }
            }
            .frame(maxHeight: .infinity)
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

/// Swipe a row left to reveal a trash button; tap it to delete.
/// The task board is a ScrollView rather than a List, so it can't use `.swipeActions`.
struct SwipeToDeleteRow<Content: View>: View {
    var rowHeight: CGFloat
    var onDelete: () -> Void
    /// Receives whether a swipe is in progress or the trash button is showing,
    /// so taps inside the row can be ignored then.
    @ViewBuilder var content: (_ isSwiping: Bool) -> Content

    @State private var offset: CGFloat = 0
    @State private var isOpen = false
    @State private var isDragging = false

    private var revealWidth: CGFloat { rowHeight * 1.6 }

    var body: some View {
        ZStack(alignment: .trailing) {
            Button(action: onDelete) {
                Image(systemName: "trash.fill")
                    .font(.system(size: rowHeight * 0.45, weight: .black))
                    .foregroundStyle(.white)
                    .frame(width: revealWidth - 6, height: rowHeight)
                    .background(
                        RoundedRectangle(cornerRadius: rowHeight * 0.22)
                            .fill(Color(red: 0.90, green: 0.20, blue: 0.28).gradient)
                    )
            }
            .buttonStyle(.plain)
            .opacity(offset < 0 ? 1 : 0)
            .accessibilityHidden(true)

            content(isDragging || isOpen)
                .offset(x: offset)
                // Simultaneous so vertical scrolling of the board keeps working.
                .simultaneousGesture(
                    DragGesture(minimumDistance: 18)
                        .onChanged { value in
                            guard abs(value.translation.width) > abs(value.translation.height) else { return }
                            isDragging = true
                            let start = isOpen ? -revealWidth : 0
                            offset = min(0, max(-revealWidth * 1.3, start + value.translation.width))
                        }
                        .onEnded { _ in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                                isOpen = offset < -revealWidth / 2
                                offset = isOpen ? -revealWidth : 0
                            }
                            // Keep taps blocked briefly so the finger lifting off the circle doesn't count.
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                isDragging = false
                            }
                        }
                )
        }
        .accessibilityAction(named: "Delete") { onDelete() }
    }
}

struct TaskRow: View {
    var task: SushiTask
    var daypart: Daypart
    var mealIsFull: Bool
    var isEating: Bool
    var rowHeight: CGFloat
    var edit: () -> Void = {}
    var complete: () -> Void

    private var textColor: Color {
        task.isEaten ? Color(red: 0.40, green: 0.38, blue: 0.36) : Color(red: 0.02, green: 0.12, blue: 0.33)
    }

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

            // Tap the title area to edit the task.
            Button(action: edit) {
                HStack(spacing: 6) {
                    Text(task.title)
                        .font(.system(size: max(18, rowHeight * 0.48), weight: .black, design: .rounded))
                        .foregroundStyle(textColor)
                        .strikethrough(task.isEaten, color: .secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .layoutPriority(0)

                    HStack(spacing: 4) {
                        if task.hasTime {
                            Text("· \(task.dueDate.formatted(date: .omitted, time: .shortened))")
                                .font(.system(size: max(15, rowHeight * 0.38), weight: .bold, design: .rounded))
                        }
                        if task.recurrence != .none {
                            Image(systemName: "repeat")
                                .font(.system(size: max(13, rowHeight * 0.32), weight: .black))
                                .accessibilityLabel("Repeats \(task.recurrence.rawValue)")
                        }
                    }
                    .foregroundStyle(textColor.opacity(0.62))
                    .fixedSize()
                    .layoutPriority(1)

                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityHint("Edit task")

            Spacer()

            CompletionCircle(
                isComplete: task.isEaten,
                isLocked: mealIsFull && !task.isEaten,
                tint: daypart.tint,
                action: complete
            )
            .accessibilityLabel(task.isEaten ? "\(task.title) completed" : "Complete \(task.title)")
        }
        .padding(.horizontal, 10)
        .frame(height: rowHeight)
        .background(
            RoundedRectangle(cornerRadius: rowHeight * 0.22)
                .fill(Color.white.opacity(0.62))
        )
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

/// A screen shown in the bottom-menu container over the task list.
enum MenuScreen: Equatable {
    case profile
    case orders
    case editing(SushiTask)
    case collection
    case achievements
}

/// A bottom-menu destination a screen can switch to.
enum AddTaskMenuDestination {
    case profile
    case orders
    case collection
    case achievements
}

struct AddTaskSheet: View {
    var daypart: Daypart
    /// The task being edited, or nil when adding a new one.
    var editing: SushiTask? = nil
    var addTask: (SushiTask) -> Void
    var openMenuDestination: (AddTaskMenuDestination) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var dueDate: Date
    @State private var hasTime: Bool
    @State private var repeatOption: AddTaskRepeatOption = .none
    @State private var category: TaskCategory = .other
    @State private var remindMe = true
    @State private var showingPremium = false
    @ObservedObject private var premium = PremiumStore.shared
    @State private var showingDatePicker = false
    @State private var showingTimePicker = false

    init(
        daypart: Daypart,
        editing: SushiTask? = nil,
        addTask: @escaping (SushiTask) -> Void,
        openMenuDestination: @escaping (AddTaskMenuDestination) -> Void
    ) {
        self.daypart = daypart
        self.editing = editing
        self.addTask = addTask
        self.openMenuDestination = openMenuDestination
        _title = State(initialValue: editing?.title ?? "")
        _dueDate = State(initialValue: editing?.dueDate ?? Self.defaultDueDate(for: daypart))
        _hasTime = State(initialValue: editing?.hasTime ?? true)
        _repeatOption = State(initialValue: editing.map { AddTaskRepeatOption(recurrence: $0.recurrence) } ?? .none)
        _category = State(initialValue: editing?.category ?? .other)
        _remindMe = State(initialValue: editing?.hasReminder ?? true)
    }

    private var layout: OrderArtworkLayout { .layout(for: daypart) }

    var body: some View {
        GeometryReader { proxy in
            let artworkFrame = orderArtworkFrame(container: proxy.size)
            let mapper = ArtworkMapper(frame: artworkFrame, artworkSize: layout.artworkSize)
            let field = mapper.rect(layout.field)
            let addButton = mapper.rect(layout.addButton)
            let close = mapper.point(layout.closeCenter)

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
                .frame(width: 70 * mapper.scale, height: 70 * mapper.scale)
                .position(close)

                // The order artwork paints the bottom menu, so it needs its own tap zones.
                // Orders is this screen.
                menuHitZone("Open Profile", centerX: 0.125, artworkFrame: artworkFrame) {
                    openMenuDestination(.profile)
                }
                menuHitZone("Back to Chef", centerX: 0.5, artworkFrame: artworkFrame) {
                    dismiss()
                }
                menuHitZone("Open Collection", centerX: 0.6875, artworkFrame: artworkFrame) {
                    openMenuDestination(.collection)
                }
                menuHitZone("Open Achievements", centerX: 0.875, artworkFrame: artworkFrame) {
                    openMenuDestination(.achievements)
                }

                titleField(frame: field, scale: mapper.scale)

                dateTimeTile(
                    value: dateText,
                    tile: mapper.rect(layout.dateTile),
                    valueLeading: layout.dateValueLeading,
                    scale: mapper.scale
                ) {
                    showingDatePicker = true
                }
                .accessibilityLabel("Choose task date, \(dateText)")

                dateTimeTile(
                    value: timeText,
                    tile: mapper.rect(layout.timeTile),
                    valueLeading: layout.timeValueLeading,
                    scale: mapper.scale
                ) {
                    showingTimePicker = true
                }
                .accessibilityLabel("Choose task time, \(timeText)")

                ForEach(AddTaskRepeatOption.allCases) { option in
                    repeatButton(option: option, mapper: mapper)
                }

                categoryMenu(mapper: mapper)

                reminderButton(mapper: mapper)

                // The painted "Add Task" button; the art already has its label.
                Button {
                    submitTask()
                } label: {
                    Color.black.opacity(0.001)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add Task")
                .frame(width: addButton.width, height: addButton.height)
                .position(x: addButton.midX, y: addButton.midY)
                .disabled(trimmedTitle.isEmpty)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .sheet(isPresented: $showingPremium) {
            PremiumSheet()
        }
        .sheet(isPresented: $showingDatePicker) {
            pickerSheet(title: "Choose Date") {
                DatePicker("Date", selection: $dueDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .labelsHidden()
            }
        }
        .sheet(isPresented: $showingTimePicker) {
            // The time wheel is short, so the sheet hugs it instead of leaving empty space below.
            pickerSheet(title: "Choose Time", detents: [.height(390)]) {
                VStack(spacing: 12) {
                    Picker("Time", selection: $hasTime) {
                        Text("Time").tag(true)
                        Text("None").tag(false)
                    }
                    .pickerStyle(.segmented)

                    if hasTime {
                        DatePicker("Time", selection: $dueDate, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                    } else {
                        Text("No set time. This task stays on today's list until you finish it, with no reminder.")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, minHeight: 216)
                    }
                }
            }
        }
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func submitTask() {
        guard !trimmedTitle.isEmpty else { return }
        if var task = editing {
            task.title = String(trimmedTitle.prefix(60))
            task.category = category
            task.dueDate = dueDate
            task.hasTime = hasTime
            task.recurrence = repeatOption.recurrence
            task.hasReminder = remindMe
            addTask(task)
        } else {
            addTask(
                SushiTask(
                    title: String(trimmedTitle.prefix(60)),
                    category: category,
                    dueDate: dueDate,
                    hasTime: hasTime,
                    recurrence: repeatOption.recurrence,
                    hasReminder: remindMe
                )
            )
        }
        dismiss()
    }

    /// Sits in the empty space to the right of the painted "Repeat (Optional)" heading.
    private func categoryMenu(mapper: ArtworkMapper) -> some View {
        let scale = mapper.scale
        let centerY = (layout.timeTile.maxY + layout.repeatRowTop) / 2
        let trailing = mapper.point(CGPoint(x: layout.field.maxX, y: centerY))

        return Menu {
            Picker("Category", selection: $category) {
                ForEach(TaskCategory.allCases) { option in
                    Label(option.displayName, systemImage: option.icon)
                        .tag(option)
                }
            }
        } label: {
            HStack(spacing: 6 * scale) {
                Image(systemName: category.icon)
                    .font(.system(size: 22 * scale, weight: .black))
                    .foregroundStyle(category.color)
                Text(category == .other ? "Category" : category.displayName)
                    .font(.system(size: 24 * scale, weight: .bold, design: .rounded))
                    .foregroundStyle(Self.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Image(systemName: "chevron.down")
                    .font(.system(size: 16 * scale, weight: .black))
                    .foregroundStyle(Color(red: 0.45, green: 0.35, blue: 0.28))
            }
            .padding(.horizontal, 16 * scale)
            .frame(height: 44 * scale)
            .background(Self.tilePaper, in: Capsule())
            .overlay(Capsule().stroke(Color(red: 0.91, green: 0.78, blue: 0.65), lineWidth: 1))
        }
        .accessibilityLabel("Category, \(category.displayName)")
        .frame(width: 330 * scale, alignment: .trailing)
        .position(x: trailing.x - 165 * scale, y: trailing.y)
    }

    /// Bell toggle left of the Category menu. Reminders are Premium, so without it
    /// the bell shows a crown and opens the Premium sheet.
    private func reminderButton(mapper: ArtworkMapper) -> some View {
        let scale = mapper.scale
        let centerY = (layout.timeTile.maxY + layout.repeatRowTop) / 2
        let center = mapper.point(CGPoint(x: layout.field.maxX - 330 - 16 - 62, y: centerY))
        let isOn = premium.isPremium && remindMe && hasTime

        return Button {
            if premium.isPremium {
                remindMe.toggle()
            } else {
                showingPremium = true
            }
        } label: {
            HStack(spacing: 5 * scale) {
                Image(systemName: isOn ? "bell.fill" : "bell.slash.fill")
                    .font(.system(size: 22 * scale, weight: .black))
                    .foregroundStyle(isOn ? Self.selectedPink : Color(red: 0.55, green: 0.47, blue: 0.40))
                if !premium.isPremium {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 18 * scale, weight: .black))
                        .foregroundStyle(Color(red: 0.95, green: 0.68, blue: 0.10))
                } else {
                    Text(isOn ? "On" : "Off")
                        .font(.system(size: 22 * scale, weight: .bold, design: .rounded))
                        .foregroundStyle(Self.ink)
                }
            }
            .frame(width: 124 * scale, height: 44 * scale)
            .background(Self.tilePaper, in: Capsule())
            .overlay(Capsule().stroke(Color(red: 0.91, green: 0.78, blue: 0.65), lineWidth: 1))
            // A task with no time has nothing to remind about.
            .opacity(premium.isPremium && !hasTime ? 0.5 : 1)
        }
        .buttonStyle(.plain)
        .disabled(premium.isPremium && !hasTime)
        .accessibilityLabel(premium.isPremium ? "Reminder \(isOn ? "on" : "off")" : "Reminders, Premium")
        .position(center)
    }

    private func menuHitZone(
        _ label: String,
        centerX: CGFloat,
        artworkFrame: CGRect,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Color.black.opacity(0.001)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .frame(width: artworkFrame.width * 0.17, height: artworkFrame.height * 0.08)
        .position(
            x: artworkFrame.minX + artworkFrame.width * centerX,
            y: artworkFrame.minY + artworkFrame.height * 0.945
        )
    }

    private func orderArtworkFrame(container: CGSize) -> CGRect {
        let artworkSize = layout.artworkSize
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
        hasTime ? dueDate.formatted(.dateTime.hour().minute()) : "No time"
    }

    private static let ink = Color(red: 0.08, green: 0.13, blue: 0.26)
    /// The off-white of the painted tiles, used to cover their placeholder text.
    private static let tilePaper = Color(red: 0.988, green: 0.973, blue: 0.957)
    private static let valueBlue = Color(red: 0.02, green: 0.53, blue: 0.89)
    private static let selectedPink = Color(red: 1.0, green: 0.22, blue: 0.50)

    /// Covers the painted field (and its placeholder) with a live text field.
    private func titleField(frame: CGRect, scale: CGFloat) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 18 * scale)
                .fill(Color.white)

            if title.isEmpty {
                Text(layout.placeholder)
                    .font(.system(size: 26 * scale, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(red: 0.55, green: 0.60, blue: 0.70))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, 22 * scale)
                    .allowsHitTesting(false)
            }

            TextField("", text: $title)
                .font(.system(size: 27 * scale, weight: .bold, design: .rounded))
                .foregroundStyle(Self.ink)
                .submitLabel(.done)
                .textFieldStyle(.plain)
                .padding(.horizontal, 22 * scale)
                .padding(.trailing, 60 * scale)
        }
        .overlay(alignment: .bottomTrailing) {
            Text("\(min(title.count, 60))/60")
                .font(.system(size: 18 * scale, weight: .medium, design: .rounded))
                .foregroundStyle(Color(red: 0.45, green: 0.50, blue: 0.58))
                .padding(.trailing, 14 * scale)
                .padding(.bottom, 8 * scale)
                .allowsHitTesting(false)
        }
        .frame(width: frame.width, height: frame.height)
        .position(x: frame.midX, y: frame.midY)
        .accessibilityLabel("What would you like to do?")
        .onChange(of: title) { _, newValue in
            if newValue.count > 60 {
                title = String(newValue.prefix(60))
            }
        }
    }

    /// Keeps the painted icon, caption, and chevron; replaces only the painted value.
    private func dateTimeTile(
        value: String,
        tile: CGRect,
        valueLeading: CGFloat,
        scale: CGFloat,
        action: @escaping () -> Void
    ) -> some View {
        let valueX = tile.minX + valueLeading * scale
        let valueY = tile.minY + tile.height * 0.66
        let valueWidth = tile.maxX - 48 * scale - valueX

        return Button(action: action) {
            Color.black.opacity(0.001)
        }
        .buttonStyle(.plain)
        .frame(width: tile.width, height: tile.height)
        .position(x: tile.midX, y: tile.midY)
        .background {
            ZStack(alignment: .topLeading) {
                Self.tilePaper
                    .frame(width: valueWidth + 8 * scale, height: 30 * scale)
                    .position(x: valueX + valueWidth / 2, y: valueY)
                Text(value)
                    .font(.system(size: 23 * scale, weight: .semibold, design: .rounded))
                    .foregroundStyle(Self.valueBlue)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .frame(width: valueWidth, alignment: .leading)
                    .position(x: valueX + valueWidth / 2, y: valueY)
            }
            .allowsHitTesting(false)
        }
    }

    /// The art paints "None" as selected. When another option is chosen, None is
    /// redrawn unselected and the chosen tile gets the pink selection treatment.
    private func repeatButton(option: AddTaskRepeatOption, mapper: ArtworkMapper) -> some View {
        let rect = mapper.rect(layout.repeatButton(option))
        let scale = mapper.scale
        let isSelected = repeatOption == option
        let corner = 16 * scale

        return Button {
            repeatOption = option
            if option == .tomorrow {
                dueDate = Self.tomorrowDate(preservingTimeFrom: dueDate)
            }
        } label: {
            ZStack {
                if option == .none && !isSelected {
                    RoundedRectangle(cornerRadius: corner)
                        .fill(Self.tilePaper)
                        .padding(-3 * scale)
                    HStack(spacing: 10 * scale) {
                        Image(systemName: "nosign")
                            .font(.system(size: 24 * scale, weight: .bold))
                        Text("None")
                            .font(.system(size: 22 * scale, weight: .medium, design: .rounded))
                    }
                    .foregroundStyle(Self.ink)
                } else if isSelected && option != .none {
                    RoundedRectangle(cornerRadius: corner)
                        .fill(Self.selectedPink.opacity(0.10))
                    RoundedRectangle(cornerRadius: corner)
                        .stroke(Self.selectedPink, lineWidth: 3)
                } else {
                    Color.black.opacity(0.001)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(option.accessibilityLabel)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .frame(width: rect.width, height: rect.height)
        .position(x: rect.midX, y: rect.midY)
    }

    private func pickerSheet<Content: View>(
        title: String,
        detents: Set<PresentationDetent> = [.fraction(0.62), .large],
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationStack {
            VStack(spacing: 0) {
                content()
                    .padding(.horizontal, 18)
                    .padding(.top, 12)
                    .padding(.bottom, 34)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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
        .presentationDetents(detents)
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

/// Where the Add Task form sits in each order background, in the artwork's own pixels.
struct OrderArtworkLayout {
    var artworkSize: CGSize
    var field: CGRect
    var placeholder: String
    var dateTile: CGRect
    var timeTile: CGRect
    /// Distance from each tile's left edge to where its painted value text starts.
    var dateValueLeading: CGFloat
    var timeValueLeading: CGFloat
    var repeatRowTop: CGFloat
    var repeatRowHeight: CGFloat
    /// Left and right edges of the None, Daily, Weekdays, Weekends, and Tomorrow tiles.
    var repeatColumns: [ClosedRange<CGFloat>]
    var addButton: CGRect
    var closeCenter: CGPoint

    func repeatButton(_ option: AddTaskRepeatOption) -> CGRect {
        let index = AddTaskRepeatOption.allCases.firstIndex(of: option) ?? 0
        let column = repeatColumns[index]
        return CGRect(x: column.lowerBound, y: repeatRowTop, width: column.upperBound - column.lowerBound, height: repeatRowHeight)
    }

    static func layout(for daypart: Daypart) -> OrderArtworkLayout {
        switch daypart {
        case .morning: morning
        case .noon: noon
        case .night: night
        }
    }

    static let morning = OrderArtworkLayout(
        artworkSize: CGSize(width: 851, height: 1848),
        field: CGRect(x: 66, y: 909, width: 720, height: 74),
        placeholder: "What would you like to do?",
        dateTile: CGRect(x: 68, y: 1042, width: 350, height: 72),
        timeTile: CGRect(x: 434, y: 1042, width: 350, height: 72),
        dateValueLeading: 82, timeValueLeading: 72,
        repeatRowTop: 1172, repeatRowHeight: 66,
        repeatColumns: [65...190, 203...322, 337...478, 493...633, 648...784],
        addButton: CGRect(x: 276, y: 1262, width: 298, height: 58),
        closeCenter: CGPoint(x: 778, y: 871)
    )

    static let noon = OrderArtworkLayout(
        artworkSize: CGSize(width: 851, height: 1848),
        field: CGRect(x: 67, y: 910, width: 720, height: 72),
        placeholder: "What would you like to do?",
        dateTile: CGRect(x: 68, y: 1039, width: 350, height: 74),
        timeTile: CGRect(x: 434, y: 1039, width: 351, height: 74),
        dateValueLeading: 82, timeValueLeading: 72,
        repeatRowTop: 1173, repeatRowHeight: 64,
        repeatColumns: [67...190, 202...324, 338...479, 493...634, 648...784],
        addButton: CGRect(x: 275, y: 1261, width: 302, height: 58),
        closeCenter: CGPoint(x: 780, y: 870)
    )

    static let night = OrderArtworkLayout(
        artworkSize: CGSize(width: 851, height: 1848),
        field: CGRect(x: 65, y: 910, width: 722, height: 69),
        placeholder: "e.g. Drink water, Read a book, Go for a walk...",
        dateTile: CGRect(x: 65, y: 1033, width: 353, height: 75),
        timeTile: CGRect(x: 432, y: 1033, width: 355, height: 75),
        dateValueLeading: 82, timeValueLeading: 76,
        repeatRowTop: 1168, repeatRowHeight: 66,
        repeatColumns: [62...192, 200...326, 338...481, 493...638, 649...786],
        addButton: CGRect(x: 276, y: 1262, width: 299, height: 56),
        closeCenter: CGPoint(x: 781, y: 869)
    )
}

enum AddTaskRepeatOption: String, CaseIterable, Identifiable {
    case none
    case daily
    case weekdays
    case weekends
    case tomorrow

    var id: String { rawValue }

    /// The Add Task option that shows an existing task's repeat setting.
    init(recurrence: TaskRecurrence) {
        switch recurrence {
        case .daily: self = .daily
        case .weekdays: self = .weekdays
        case .weekends: self = .weekends
        case .none, .weekly, .custom: self = .none
        }
    }

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
                Text(option.displayName)
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
        case .fitness, .healthyEating: Color(red: 0.97, green: 0.33, blue: 0.20)
        case .productivity, .learning: Color(red: 0.98, green: 0.77, blue: 0.20)
        case .social: Color(red: 0.92, green: 0.12, blue: 0.40)
        case .selfCare, .other: Color(red: 0.08, green: 0.08, blue: 0.09)
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
