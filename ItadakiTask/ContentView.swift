import SwiftUI

struct SushiTask: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var category: TaskCategory
    var dueDate: Date
    var recurrence: TaskRecurrence = .none
    var isEaten = false

    var completedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case category
        case dueDate
        case recurrence
        case isEaten
        case completedAt
    }

    init(
        id: UUID = UUID(),
        title: String,
        category: TaskCategory,
        dueDate: Date,
        recurrence: TaskRecurrence = .none,
        isEaten: Bool = false,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.dueDate = dueDate
        self.recurrence = recurrence
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
        isEaten = try container.decodeIfPresent(Bool.self, forKey: .isEaten) ?? false
        completedAt = try container.decodeIfPresent(Date.self, forKey: .completedAt)
    }
}

enum TaskRecurrence: String, CaseIterable, Codable, Identifiable {
    case none = "One time"
    case daily = "Daily"
    case weekdays = "Weekdays"
    case everyThreeDays = "Every 3 days"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .none: "calendar.badge.plus"
        case .daily: "arrow.trianglehead.2.clockwise"
        case .weekdays: "calendar"
        case .everyThreeDays: "repeat"
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

    var greeting: String {
        switch self {
        case .morning: "Morning omakase"
        case .noon: "Noon rush"
        case .night: "Night service"
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
        ZStack {
            SceneBackground(daypart: daypart)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    HeaderView(
                        customerName: displayName,
                        eatenCount: sushiEatenToday,
                        maxCount: mealLimit,
                        daypart: daypart
                    ) {
                        draftName = customerName
                        showingNamePrompt = true
                    }

                    ChefStageView(
                        daypart: daypart,
                        nextTask: nextTask,
                        activeCount: activeTasks.count,
                        mealIsFull: mealIsFull
                    )

                    PlateRailView(tasks: activeTasks, isLocked: mealIsFull)

                    if mealIsFull {
                        CustomerFullCard(daypart: daypart)
                    }

                    TaskBoardView(
                        tasks: todaysTasks,
                        daypart: daypart,
                        mealIsFull: mealIsFull,
                        recentlyEatenTaskIDs: recentlyEatenTaskIDs
                    ) { task in
                        complete(task)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)
                .padding(.bottom, 112)
            }

            VStack {
                Spacer()
                BottomBar(daypart: daypart) {
                    showingAddTask = true
                }
            }
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .onAppear {
            loadTasks()
            resetMealIfNeeded()
            if !hasAskedCustomerName {
                draftName = customerName
                showingNamePrompt = true
            }
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
            Text("Chef will write it on your Sushi Champloo order board.")
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
        case .everyThreeDays:
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

struct SceneBackground: View {
    var daypart: Daypart

    var body: some View {
        ZStack {
            AssetImage(name: daypart.orderAsset)
                .scaledToFill()
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    .black.opacity(0.12),
                    .black.opacity(0.04),
                    .black.opacity(0.46)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Rectangle()
                .fill(.ultraThinMaterial.opacity(0.24))
                .ignoresSafeArea()
        }
    }
}

struct HeaderView: View {
    var customerName: String
    var eatenCount: Int
    var maxCount: Int
    var daypart: Daypart
    var editName: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: editName) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(daypart.tint.gradient)
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 54, height: 54)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(customerName)
                            .font(.system(size: 20, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                        Text(daypart.greeting)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.78))
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.black.opacity(0.38), in: RoundedRectangle(cornerRadius: 22))
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(.white.opacity(0.28), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)

            VStack(spacing: 2) {
                HStack(spacing: 5) {
                    Text("🍣")
                    Text("\(eatenCount) / \(maxCount)")
                        .font(.system(size: 21, weight: .heavy, design: .rounded))
                }
                Text("eaten today")
                    .font(.system(size: 11, weight: .black, design: .rounded))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .background(.black.opacity(0.42), in: RoundedRectangle(cornerRadius: 22))
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(daypart.tint.opacity(0.8), lineWidth: 1.5)
            )
        }
    }
}

struct ChefStageView: View {
    var daypart: Daypart
    var nextTask: SushiTask?
    var activeCount: Int
    var mealIsFull: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            AssetImage(name: daypart.chefAsset)
                .scaledToFill()
                .frame(height: 332)
                .clipShape(RoundedRectangle(cornerRadius: 26))
                .overlay(
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.58)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 26))
                )

            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Sushi Champloo")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text(stageMessage)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.86))
                }

                Spacer()

                VStack(spacing: 2) {
                    Text("\(activeCount)")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                    Text("orders")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.black.opacity(0.36), in: RoundedRectangle(cornerRadius: 18))
            }
            .padding(18)
        }
        .shadow(color: .black.opacity(0.28), radius: 22, x: 0, y: 14)
    }

    private var stageMessage: String {
        if mealIsFull {
            return "Chef bows. Your customer is full."
        }
        return nextTask == nil ? "The plate is clear." : "Chef is serving your next nigiri."
    }
}

struct PlateRailView: View {
    var tasks: [SushiTask]
    var isLocked: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Chef's plate", systemImage: "takeoutbag.and.cup.and.straw.fill")
                    .font(.system(size: 19, weight: .black, design: .rounded))
                Spacer()
                Text(isLocked ? "full" : "\(tasks.count) waiting")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    if tasks.isEmpty {
                        EmptyPlateView()
                    } else {
                        ForEach(tasks.prefix(8)) { task in
                            SushiPlateCard(task: task, isLocked: isLocked)
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 26))
        .overlay(
            RoundedRectangle(cornerRadius: 26)
                .stroke(.white.opacity(0.45), lineWidth: 1)
        )
    }
}

struct SushiPlateCard: View {
    var task: SushiTask
    var isLocked: Bool

    var body: some View {
        VStack(spacing: 8) {
            SushiNigiriView(category: task.category)
                .frame(width: 92, height: 64)
                .saturation(isLocked ? 0.35 : 1)
            Text(task.title)
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 112, height: 34)
            Text(task.dueDate, style: .time)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(.white.opacity(isLocked ? 0.56 : 0.78), in: RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(task.category.color.opacity(isLocked ? 0.25 : 0.55), lineWidth: 1.5)
        )
    }
}

struct EmptyPlateView: View {
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "sparkles")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.pink)
            VStack(alignment: .leading, spacing: 4) {
                Text("No nigiri waiting")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                Text("Add a task and Chef will serve one up.")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(width: 270, alignment: .leading)
        .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 22))
    }
}

struct CustomerFullCard: View {
    var daypart: Daypart

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(daypart.tint.opacity(0.16))
                    .frame(width: 78, height: 78)
                VStack(spacing: -2) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 26, weight: .black))
                        .rotationEffect(.degrees(18))
                    Text("🍣")
                        .font(.system(size: 24))
                }
                .foregroundStyle(daypart.tint)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text("Your customer is full!")
                    .font(.system(size: 21, weight: .black, design: .rounded))
                    .foregroundStyle(.primary)
                Text("Come back tomorrow for another meal.")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(18)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 26))
        .overlay(
            RoundedRectangle(cornerRadius: 26)
                .stroke(daypart.tint.opacity(0.55), lineWidth: 1.4)
        )
        .shadow(color: daypart.tint.opacity(0.18), radius: 18, x: 0, y: 10)
    }
}

struct TaskBoardView: View {
    var tasks: [SushiTask]
    var daypart: Daypart
    var mealIsFull: Bool
    var recentlyEatenTaskIDs: Set<SushiTask.ID>
    var complete: (SushiTask) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Today's Orders")
                        .font(.system(size: 26, weight: .black, design: .rounded))
                    Text("Finish the task. Eat the sushi.")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "checklist.checked")
                    .font(.system(size: 25, weight: .heavy))
                    .foregroundStyle(daypart.tint)
            }

            VStack(spacing: 10) {
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
        }
        .padding(18)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 28))
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(.white.opacity(0.52), lineWidth: 1)
        )
    }
}

struct TaskRow: View {
    var task: SushiTask
    var daypart: Daypart
    var mealIsFull: Bool
    var isEating: Bool
    var complete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(task.category.color.gradient)
                Image(systemName: task.category.icon)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
            }
            .frame(width: 54, height: 54)

            VStack(alignment: .leading, spacing: 5) {
                Text(task.title)
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(task.isEaten ? .secondary : .primary)
                    .strikethrough(task.isEaten, color: .secondary)
                    .lineLimit(2)
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                    Text(task.dueDate, style: .time)
                    Text("•")
                    Text(task.category.rawValue)
                    if task.recurrence != .none {
                        Text("•")
                        Image(systemName: task.recurrence.systemImage)
                        Text(task.recurrence.rawValue)
                    }
                }
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
            }

            Spacer()

            ZStack {
                SushiNigiriView(category: task.category)
                    .frame(width: 62, height: 44)
                    .scaleEffect(isEating ? 0.1 : 1)
                    .opacity(task.isEaten ? 0.12 : 1)
                    .rotationEffect(.degrees(isEating ? 18 : 0))

                if isEating {
                    EatenSparkles(tint: task.category.color)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(width: 66, height: 52)

            CompletionCircle(
                isComplete: task.isEaten,
                isLocked: mealIsFull && !task.isEaten,
                tint: daypart.tint,
                action: complete
            )
            .accessibilityLabel(task.isEaten ? "\(task.title) completed" : "Complete \(task.title)")
        }
        .padding(12)
        .background(.white.opacity(task.isEaten ? 0.45 : 0.82), in: RoundedRectangle(cornerRadius: 20))
        .overlay(alignment: .topTrailing) {
            if task.isEaten {
                Text("eaten")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.green.gradient, in: Capsule())
                    .offset(x: -10, y: -8)
            }
        }
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
                    .frame(width: 34, height: 34)

                Circle()
                    .fill(Color.green.gradient)
                    .frame(width: isComplete ? 34 : 4, height: isComplete ? 34 : 4)
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

struct BottomBar: View {
    var daypart: Daypart
    var addTask: () -> Void

    var body: some View {
        HStack(spacing: 18) {
            BarItem(icon: "house.fill", title: "Home", isActive: true)
            BarItem(icon: "list.bullet.clipboard.fill", title: "Orders", isActive: false)

            Button(action: addTask) {
                ZStack {
                    Circle()
                        .fill(daypart.tint.gradient)
                        .frame(width: 70, height: 70)
                        .shadow(color: daypart.tint.opacity(0.45), radius: 18, x: 0, y: 8)
                    Image(systemName: "plus")
                        .font(.system(size: 29, weight: .black))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Add a Task")

            BarItem(icon: "book.closed.fill", title: "Collection", isActive: false)
            BarItem(icon: "trophy.fill", title: "Wins", isActive: false)
        }
        .padding(.horizontal, 18)
        .padding(.top, 12)
        .padding(.bottom, 18)
        .background(.black.opacity(0.62), in: UnevenRoundedRectangle(topLeadingRadius: 28, topTrailingRadius: 28))
        .overlay(
            UnevenRoundedRectangle(topLeadingRadius: 28, topTrailingRadius: 28)
                .stroke(.white.opacity(0.24), lineWidth: 1)
        )
    }
}

struct BarItem: View {
    var icon: String
    var title: String
    var isActive: Bool

    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .bold))
            Text(title)
                .font(.system(size: 11, weight: .black, design: .rounded))
        }
        .frame(maxWidth: .infinity)
        .foregroundStyle(isActive ? .pink : .white.opacity(0.78))
    }
}

struct AddTaskSheet: View {
    var daypart: Daypart
    var addTask: (SushiTask) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var category: TaskCategory = .health
    @State private var recurrence: TaskRecurrence = .none
    @State private var dueDate = Date()

    var body: some View {
        NavigationStack {
            ZStack {
                AssetImage(name: daypart.orderAsset)
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(0.25)

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Add a Task")
                                .font(.system(size: 34, weight: .black, design: .rounded))
                            Text("Tell Chef what sushi to serve on your plate.")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                        }

                        TextField("What would you like to do?", text: $title)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .padding(16)
                            .background(.white, in: RoundedRectangle(cornerRadius: 18))

                        DatePicker("Serve it at", selection: $dueDate, displayedComponents: [.hourAndMinute])
                            .font(.system(size: 16, weight: .heavy, design: .rounded))
                            .padding(16)
                            .background(.white.opacity(0.86), in: RoundedRectangle(cornerRadius: 18))

                        Picker("Repeat order", selection: $recurrence) {
                            ForEach(TaskRecurrence.allCases) { option in
                                Label(option.rawValue, systemImage: option.systemImage)
                                    .tag(option)
                            }
                        }
                        .pickerStyle(.menu)
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.white.opacity(0.86), in: RoundedRectangle(cornerRadius: 18))

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Choose a flavor")
                                .font(.system(size: 18, weight: .black, design: .rounded))

                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                                ForEach(TaskCategory.allCases) { option in
                                    Button {
                                        category = option
                                    } label: {
                                        VStack(spacing: 7) {
                                            Image(systemName: option.icon)
                                                .font(.system(size: 24, weight: .bold))
                                            Text(option.rawValue)
                                                .font(.system(size: 12, weight: .black, design: .rounded))
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.75)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 82)
                                        .foregroundStyle(category == option ? .white : .primary)
                                        .background(category == option ? option.color.gradient : Color.white.opacity(0.86).gradient, in: RoundedRectangle(cornerRadius: 18))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        HStack(spacing: 12) {
                            SushiNigiriView(category: category)
                                .frame(width: 132, height: 88)
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Nigiri preview")
                                    .font(.system(size: 18, weight: .black, design: .rounded))
                                Text("This appears on your plate until you finish the task.")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(16)
                        .background(.white.opacity(0.84), in: RoundedRectangle(cornerRadius: 22))

                        Button {
                            let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmed.isEmpty else { return }
                            addTask(SushiTask(title: trimmed, category: category, dueDate: dueDate, recurrence: recurrence))
                            dismiss()
                        } label: {
                            Text("Serve Nigiri")
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 17)
                                .foregroundStyle(.white)
                                .background(daypart.tint.gradient, in: RoundedRectangle(cornerRadius: 20))
                        }
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .opacity(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
                    }
                    .padding(22)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
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
                Text("Sushi Champloo")
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
