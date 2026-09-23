import SwiftUI

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
    case weekly = "Weekly"
    case custom = "Custom"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .none: "calendar.badge.plus"
        case .daily: "arrow.trianglehead.2.clockwise"
        case .weekdays: "calendar"
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

    var chefArtworkSize: CGSize {
        switch self {
        case .morning, .noon:
            CGSize(width: 853, height: 1844)
        case .night:
            CGSize(width: 941, height: 1672)
        }
    }
}

struct ContentView: View {
    @AppStorage("customerName") private var customerName = ""
    @AppStorage("hasAskedCustomerName") private var hasAskedCustomerName = false
    @AppStorage("sushiTasks") private var storedTasks = ""
    @AppStorage("sushiEatenToday") private var sushiEatenToday = 0
    @AppStorage("sushiMealDayKey") private var sushiMealDayKey = ""

    @State private var tasks: [SushiTask] = []
    @State private var showingAddTask = false
    @State private var showingNamePrompt = false
    @State private var draftName = ""
    @State private var recentlyEatenTaskIDs: Set<SushiTask.ID> = []

    private let daypart = Daypart()

    var body: some View {
        ArtworkBackground(name: daypart.chefAsset, artworkSize: daypart.chefArtworkSize)
        .onAppear {
            loadTasks()
            resetMealIfNeeded()
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskSheet(daypart: daypart) { task in
                withAnimation(.spring(response: 0.42, dampingFraction: 0.78)) {
                    tasks.append(task)
                    saveTasks()
                }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
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
            tasks[index].completedAt = .now
            sushiEatenToday = min(sushiEatenToday + 1, mealLimit)
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
            tasks = SampleData.tasks
            saveTasks()
            return
        }
        tasks = decoded
    }

    private func resetMealIfNeeded() {
        let today = Self.localDayKey(for: .now)
        guard sushiMealDayKey != today else { return }
        sushiMealDayKey = today
        sushiEatenToday = 0
        reopenRecurringOrders(for: .now)
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

    private func saveTasks() {
        guard let data = try? JSONEncoder().encode(tasks),
              let encoded = String(data: data, encoding: .utf8) else { return }
        storedTasks = encoded
    }

    private static func localDayKey(for date: Date) -> String {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return "\(components.year ?? 0)-\(components.month ?? 0)-\(components.day ?? 0)"
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

            ScrollView(showsIndicators: tasks.count > 3) {
                LazyVStack(spacing: 5) {
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
        HStack(spacing: 9) {
            VStack(spacing: 3) {
                ForEach(0..<3) { _ in
                    HStack(spacing: 3) {
                        Circle().fill(Color(red: 0.54, green: 0.43, blue: 0.36).opacity(0.55))
                        Circle().fill(Color(red: 0.54, green: 0.43, blue: 0.36).opacity(0.55))
                    }
                }
            }
            .frame(width: 16)

            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(task.category.color.gradient)
                Image(systemName: task.category.icon)
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(.white)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(task.isEaten ? Color(red: 0.40, green: 0.38, blue: 0.36) : Color(red: 0.02, green: 0.12, blue: 0.33))
                    .strikethrough(task.isEaten, color: .secondary)
                    .lineLimit(2)
                HStack(spacing: 6) {
                    Text("Today")
                    Text(task.dueDate, style: .time)
                    if task.recurrence != .none {
                        Image(systemName: task.recurrence.systemImage)
                        Text(task.recurrence.rawValue)
                    }
                }
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.26, green: 0.34, blue: 0.48))
            }

            Spacer()

            ZStack {
                SushiNigiriView(category: task.category)
                    .frame(width: 56, height: 38)
                    .scaleEffect(isEating ? 0.1 : 1)
                    .opacity(task.isEaten ? 0.12 : 1)
                    .rotationEffect(.degrees(isEating ? 18 : 0))

                if isEating {
                    EatenSparkles(tint: task.category.color)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(width: 60, height: 44)

            CompletionCircle(
                isComplete: task.isEaten,
                isLocked: mealIsFull && !task.isEaten,
                tint: daypart.tint,
                action: complete
            )
            .accessibilityLabel(task.isEaten ? "\(task.title) completed" : "Complete \(task.title)")
        }
        .padding(.horizontal, 8)
        .frame(height: 49)
        .background(Color.white.opacity(task.isEaten ? 0.42 : 0.74), in: RoundedRectangle(cornerRadius: 16))
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
                    .frame(width: 32, height: 32)

                Circle()
                    .fill(Color.green.gradient)
                    .frame(width: isComplete ? 32 : 4, height: isComplete ? 32 : 4)
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
    @State private var category: TaskCategory = .health
    @State private var hasReminder = false
    @State private var recurrence: TaskRecurrence = .none
    @State private var dueDate = Date()

    var body: some View {
        GeometryReader { proxy in
            let isCompactHeight = proxy.size.height < 880
            let topPadding = max(12, proxy.safeAreaInsets.top + 4)
            let bottomPadding = max(14, proxy.safeAreaInsets.bottom + 8)
            let boardMaxHeight = proxy.size.height - topPadding - bottomPadding - 42

            ZStack {
                AssetImage(name: daypart.orderAsset)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
                    .opacity(0.72)
                    .ignoresSafeArea()

                LinearGradient(
                    colors: [.black.opacity(0.03), .black.opacity(0.08), .black.opacity(0.34)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 15, weight: .black))
                                .foregroundStyle(.white)
                                .frame(width: 34, height: 34)
                                .background(Color(red: 0.96, green: 0.22, blue: 0.54), in: Circle())
                                .shadow(color: .black.opacity(0.18), radius: 8, y: 4)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, topPadding)

                    Spacer(minLength: 0)

                    orderBoard(compact: isCompactHeight)
                        .frame(maxHeight: boardMaxHeight)
                        .padding(.horizontal, 18)
                        .padding(.bottom, bottomPadding)
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()
            }
        }
    }

    private func orderBoard(compact: Bool) -> some View {
        VStack(spacing: compact ? 7 : 9) {
            VStack(spacing: 2) {
                Text("Add a Task")
                    .font(.system(size: compact ? 24 : 27, weight: .black, design: .rounded))
                    .foregroundStyle(Color(red: 0.20, green: 0.12, blue: 0.08))
                Text("Tell Chef what you want to do!")
                    .font(.system(size: compact ? 12 : 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.36, green: 0.24, blue: 0.18))
            }

            VStack(alignment: .leading, spacing: 4) {
                TextField("What would you like to do?", text: $title)
                    .font(.system(size: compact ? 15 : 16, weight: .bold, design: .rounded))
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 14)
                    .frame(height: compact ? 38 : 42)
                    .background(.white, in: Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color(red: 0.96, green: 0.82, blue: 0.68), lineWidth: 1)
                    )

                Text("Example: Text Mom back, Water the succulents, Take a nap")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.33, green: 0.46, blue: 0.68))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }

            VStack(alignment: .leading, spacing: compact ? 5 : 7) {
                Text("Choose a category (optional)")
                    .font(.system(size: compact ? 13 : 14, weight: .black, design: .rounded))
                    .foregroundStyle(Color(red: 0.20, green: 0.12, blue: 0.08))

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 4), spacing: compact ? 6 : 7) {
                    ForEach(TaskCategory.allCases) { option in
                        CategoryTile(option: option, isSelected: category == option, compact: compact) {
                            category = option
                        }
                    }
                }
            }

            VStack(spacing: compact ? 5 : 7) {
                Toggle(isOn: $hasReminder) {
                    Label("Reminder optional", systemImage: "bell.badge")
                }
                .toggleStyle(.switch)
                .font(.system(size: 13, weight: .black, design: .rounded))

                HStack(spacing: 7) {
                    DatePicker("Date", selection: $dueDate, displayedComponents: [.date])
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                    DatePicker("Time", selection: $dueDate, displayedComponents: [.hourAndMinute])
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                }

                Menu {
                    Picker("Repeat", selection: $recurrence) {
                        ForEach(TaskRecurrence.allCases) { option in
                            Label(option.rawValue, systemImage: option.systemImage)
                                .tag(option)
                        }
                    }
                } label: {
                    HStack {
                        Label("Repeat", systemImage: "repeat")
                            .font(.system(size: 13, weight: .black, design: .rounded))
                        Spacer()
                        Text(recurrence.rawValue)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 10, weight: .black))
                    }
                    .foregroundStyle(Color(red: 0.20, green: 0.12, blue: 0.08))
                    .padding(.horizontal, 11)
                    .frame(height: compact ? 34 : 38)
                    .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(compact ? 8 : 10)
            .background(Color.white.opacity(0.62), in: RoundedRectangle(cornerRadius: 16))

            Button {
                let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                addTask(SushiTask(title: trimmed, category: category, dueDate: dueDate, recurrence: recurrence, hasReminder: hasReminder))
                dismiss()
            } label: {
                Text("Add Task")
                    .font(.system(size: compact ? 18 : 20, weight: .black, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: compact ? 45 : 50)
                    .foregroundStyle(.white)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.24, blue: 0.57),
                                Color(red: 0.94, green: 0.12, blue: 0.44)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        in: Capsule()
                    )
                    .shadow(color: Color(red: 0.94, green: 0.12, blue: 0.44).opacity(0.28), radius: 10, y: 6)
            }
            .buttonStyle(.plain)
            .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.55 : 1)
        }
        .padding(.horizontal, compact ? 14 : 18)
        .padding(.top, compact ? 11 : 14)
        .padding(.bottom, compact ? 12 : 16)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.97, blue: 0.91),
                    Color(red: 1.0, green: 0.89, blue: 0.78)
                ],
                startPoint: .top,
                endPoint: .bottom
            ),
            in: RoundedRectangle(cornerRadius: 30)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color(red: 0.55, green: 0.28, blue: 0.13).opacity(0.45), lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.26), radius: 24, y: 14)
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

enum SampleData {
    static var tasks: [SushiTask] {
        [
            SushiTask(title: "Drink water", category: .health, dueDate: hour(8)),
            SushiTask(title: "Play tennis", category: .sports, dueDate: hour(10)),
            SushiTask(title: "Work on portfolio", category: .work, dueDate: hour(13)),
            SushiTask(title: "Read a book", category: .learning, dueDate: hour(19))
        ]
    }

    private static func hour(_ hour: Int) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: .now) ?? .now
    }
}

#Preview {
    ContentView()
}
