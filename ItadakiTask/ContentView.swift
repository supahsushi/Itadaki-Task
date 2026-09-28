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
        case (.morning, false), (.noon, false): .dayChef
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

    static let dayChef = HomeArtworkLayout(
        artworkSize: CGSize(width: 853, height: 1844),
        profilePatch: nil,
        nameLeadingX: 120, nameCenterY: 104, nameFontSize: 24,
        levelCenterY: 129, levelFontSize: 21,
        meterRect: CGRect(x: 119, y: 142, width: 86, height: 11),
        meterFill: dayMeter,
        countPatch: nil,
        countCenter: CGPoint(x: 766, y: 113), countFontSize: 42,
        labelPatch: nil,
        labelCenter: CGPoint(x: 740, y: 147), labelFontSize: 23, labelText: "sushi eaten today",
        firstRowTop: 914, rowPitch: 80.75, rowHeight: 74, rowMinX: 64, rowMaxX: 793,
        addTaskButton: CGRect(x: 622, y: 852, width: 170, height: 50)
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
        firstRowTop: 862, rowPitch: 70.25, rowHeight: 65, rowMinX: 35, rowMaxX: 810,
        addTaskButton: CGRect(x: 640, y: 803, width: 165, height: 44)
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
    @State private var showingAddTask = false
    @State private var showingAchievements = false
    @State private var showingCollection = false
    @State private var menuDestinationAfterAddTask: AddTaskMenuDestination?
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
                    openCollection: {
                        showingCollection = true
                    },
                    openAchievements: {
                        showingAchievements = true
                    }
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
                    .frame(width: addTaskButton.width, height: addTaskButton.height)
                    .position(x: addTaskButton.midX, y: addTaskButton.midY)

                    TaskBoardView(
                        tasks: activeTasks,
                        daypart: daypart,
                        mealIsFull: mealIsFull,
                        recentlyEatenTaskIDs: recentlyEatenTaskIDs,
                        rowHeight: layout.rowHeight * mapper.scale,
                        rowSpacing: (layout.rowPitch - layout.rowHeight) * mapper.scale
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
            migrateLegacyAchievementUnlocksIfNeeded()
            evaluateAchievements()
            repairSkippedWelcomesIfNeeded()
            migrateCollectionUnlocksIfNeeded()
            presentNextPendingCustomerArrivalIfNeeded()
            presentNextPendingAchievementUnlockIfNeeded()
            requestHealthKitAuthorizationIfNeeded()
        }
        .fullScreenCover(isPresented: $showingAddTask, onDismiss: openMenuDestinationAfterAddTask) {
            AddTaskSheet(
                daypart: daypart,
                addTask: { task in
                    withAnimation(.spring(response: 0.42, dampingFraction: 0.78)) {
                        tasks.append(task)
                        saveTasks()
                    }
                    LocalNotificationScheduler.shared.scheduleReminder(for: task)
                },
                openMenuDestination: { destination in
                    menuDestinationAfterAddTask = destination
                    showingAddTask = false
                }
            )
        }
        .fullScreenCover(isPresented: $showingAchievements) {
            AchievementsScreen(
                achievements: achievements,
                pendingUnlockIDs: decodedStringArray(sushiPendingAchievementUnlocks),
                collectedUnlockIDs: decodedStringSet(sushiCollectedAchievementUnlocks),
                collectionCharacters: collectionCharacters
            )
        }
        .fullScreenCover(isPresented: $showingCollection) {
            CollectionScreen(characters: collectionCharacters)
        }
        .fullScreenCover(item: $currentAchievementUnlock) { achievement in
            GachaponUnlockView(achievement: achievement) {
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
        .onChange(of: showingAchievements) { _, isPresented in
            guard !isPresented else { return }
            presentNextPendingCustomerArrivalIfNeeded()
            presentNextPendingAchievementUnlockIfNeeded()
        }
        .onChange(of: showingCollection) { _, isPresented in
            guard !isPresented else { return }
            presentNextPendingCustomerArrivalIfNeeded()
            presentNextPendingAchievementUnlockIfNeeded()
        }
    }

    /// Add Task covers the home screen, so a bottom-menu tap there closes it first
    /// and opens the destination once the dismissal finishes.
    private func openMenuDestinationAfterAddTask() {
        guard let destination = menuDestinationAfterAddTask else { return }
        menuDestinationAfterAddTask = nil
        switch destination {
        case .collection:
            showingCollection = true
        case .achievements:
            showingAchievements = true
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
        guard !showingAchievements else { return }
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
        guard !showingAchievements else { return false }
        guard !showingCollection else { return false }

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
        return decoded
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
    var openCollection: () -> Void
    var openAchievements: () -> Void
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

    var body: some View {
        VStack(spacing: 5) {
            if mealIsFull {
                CustomerFullCard(daypart: daypart)
            }

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: rowSpacing) {
                    ForEach(tasks) { task in
                        TaskRow(
                            task: task,
                            daypart: daypart,
                            mealIsFull: mealIsFull,
                            isEating: recentlyEatenTaskIDs.contains(task.id),
                            rowHeight: rowHeight
                        ) {
                            complete(task)
                        }
                    }
                }
            }
            .frame(maxHeight: .infinity)
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

struct TaskRow: View {
    var task: SushiTask
    var daypart: Daypart
    var mealIsFull: Bool
    var isEating: Bool
    var rowHeight: CGFloat
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

enum AddTaskMenuDestination {
    case collection
    case achievements
}

struct AddTaskSheet: View {
    var daypart: Daypart
    var addTask: (SushiTask) -> Void
    var openMenuDestination: (AddTaskMenuDestination) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var dueDate: Date
    @State private var repeatOption: AddTaskRepeatOption = .none
    @State private var showingDatePicker = false
    @State private var showingTimePicker = false

    init(
        daypart: Daypart,
        addTask: @escaping (SushiTask) -> Void,
        openMenuDestination: @escaping (AddTaskMenuDestination) -> Void
    ) {
        self.daypart = daypart
        self.addTask = addTask
        self.openMenuDestination = openMenuDestination
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

                // The order artwork paints the bottom menu, so it needs its own tap zones.
                menuHitZone("Home", centerX: 0.13, artworkFrame: artworkFrame) {
                    dismiss()
                }
                menuHitZone("Open Collection", centerX: 0.685, artworkFrame: artworkFrame) {
                    openMenuDestination(.collection)
                }
                menuHitZone("Open Achievements", centerX: 0.870, artworkFrame: artworkFrame) {
                    openMenuDestination(.achievements)
                }

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
        .presentationDetents([.fraction(0.62), .large])
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
