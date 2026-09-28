import AVFoundation
import StoreKit
import SwiftUI

extension Notification.Name {
    static let premiumStatusChanged = Notification.Name("premiumStatusChanged")
}

/// The one-time Premium unlock: scheduled reminders with the custom Chef sound.
@MainActor
final class PremiumStore: ObservableObject {
    static let shared = PremiumStore()

    /// Must match the non-consumable in-app purchase created in App Store Connect.
    nonisolated static let productID = "com.sushichamploo.itadakitask.premium"
    nonisolated private static let cacheKey = "sushiIsPremium"
    #if DEBUG
    private static let debugUnlockKey = "sushiDebugPremiumUnlock"
    #endif

    /// Last known Premium status, readable from anywhere (e.g. the reminder scheduler).
    nonisolated static var isPremiumCached: Bool {
        UserDefaults.standard.bool(forKey: cacheKey)
    }

    @Published private(set) var isPremium: Bool
    @Published private(set) var product: Product?
    @Published private(set) var isPurchasing = false
    @Published var errorMessage: String?

    private var updatesTask: Task<Void, Never>?

    private init() {
        isPremium = UserDefaults.standard.bool(forKey: Self.cacheKey)
        // Purchases can complete outside the app (Ask to Buy, another device, refunds).
        updatesTask = Task { [weak self] in
            for await update in Transaction.updates {
                if case .verified(let transaction) = update {
                    await transaction.finish()
                }
                await self?.refreshEntitlement()
            }
        }
    }

    func start() async {
        await loadProduct()
        await refreshEntitlement()
    }

    func loadProduct() async {
        guard product == nil else { return }
        product = try? await Product.products(for: [Self.productID]).first
    }

    func refreshEntitlement() async {
        var owned = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Self.productID,
               transaction.revocationDate == nil {
                owned = true
            }
        }
        #if DEBUG
        if UserDefaults.standard.bool(forKey: Self.debugUnlockKey) {
            owned = true
        }
        #endif
        setPremium(owned)
    }

    func purchase() async {
        errorMessage = nil
        await loadProduct()
        guard let product else {
            errorMessage = "Premium isn't available right now. Please try again later."
            return
        }

        isPurchasing = true
        defer { isPurchasing = false }

        do {
            switch try await product.purchase() {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    await refreshEntitlement()
                } else {
                    errorMessage = "The purchase couldn't be verified."
                }
            case .pending:
                errorMessage = "Your purchase is waiting for approval."
            case .userCancelled:
                break
            @unknown default:
                break
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func restore() async {
        errorMessage = nil
        do {
            try await AppStore.sync()
        } catch {
            errorMessage = error.localizedDescription
        }
        await refreshEntitlement()
        if !isPremium && errorMessage == nil {
            errorMessage = "No previous Premium purchase was found."
        }
    }

    #if DEBUG
    /// Lets development builds test Premium before the product exists in App Store Connect.
    func setDebugUnlock(_ unlocked: Bool) async {
        UserDefaults.standard.set(unlocked, forKey: Self.debugUnlockKey)
        await refreshEntitlement()
    }
    #endif

    private func setPremium(_ value: Bool) {
        let changed = value != isPremium
        isPremium = value
        UserDefaults.standard.set(value, forKey: Self.cacheKey)
        if changed {
            NotificationCenter.default.post(name: .premiumStatusChanged, object: nil)
        }
    }
}

struct PremiumSheet: View {
    @ObservedObject private var store = PremiumStore.shared
    @Environment(\.dismiss) private var dismiss

    private let ink = Color(red: 0.19, green: 0.11, blue: 0.06)
    private let pink = Color(red: 1.0, green: 0.22, blue: 0.50)

    var body: some View {
        VStack(spacing: 18) {
            Text("🔔🍣")
                .font(.system(size: 54))
                .padding(.top, 28)

            VStack(spacing: 6) {
                Text("Chef's Reminders")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                Text("A one-time Premium unlock")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(ink.opacity(0.6))
            }
            .foregroundStyle(ink)

            VStack(alignment: .leading, spacing: 12) {
                feature("alarm.fill", "Scheduled reminders at each task's time")
                feature("speaker.wave.2.fill", "Chef's custom notification sound")
                feature("repeat", "Works with Daily, Weekdays, and Weekends tasks")
                feature("infinity", "Pay once, yours forever")
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.75), in: RoundedRectangle(cornerRadius: 18))
            .padding(.horizontal, 20)

            if store.isPremium {
                Label("Premium unlocked", systemImage: "checkmark.seal.fill")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(.green)
                    .padding(.vertical, 12)
            } else {
                Button {
                    Task { await store.purchase() }
                } label: {
                    Group {
                        if store.isPurchasing {
                            ProgressView().tint(.white)
                        } else {
                            Text(store.product.map { "Unlock for \($0.displayPrice)" } ?? "Unlock Premium")
                        }
                    }
                    .font(.system(size: 19, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(pink.gradient, in: Capsule())
                }
                .disabled(store.isPurchasing)
                .padding(.horizontal, 20)
            }

            // Always available, including after purchase (e.g. a new device or reinstall).
            Button("Restore Purchase") {
                Task { await store.restore() }
            }
            .font(.system(size: 15, weight: .bold, design: .rounded))
            .foregroundStyle(ink.opacity(0.7))

            if let message = store.errorMessage {
                Text(message)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            #if DEBUG
            Button(store.isPremium ? "Debug: turn Premium off" : "Debug: unlock for testing") {
                Task { await store.setDebugUnlock(!store.isPremium) }
            }
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .foregroundStyle(.secondary)
            #endif

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .background(Color(red: 0.99, green: 0.92, blue: 0.84).ignoresSafeArea())
        .presentationDetents([.medium, .large])
        .task { await store.loadProduct() }
        .preferredColorScheme(.light)
    }

    private func feature(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(pink)
                .frame(width: 24)
            Text(text)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(ink)
        }
    }
}

extension Notification.Name {
    static let chefAlarmChanged = Notification.Name("chefAlarmChanged")
}

/// The Premium reminder sounds bundled in Sounds/ (each under 30 seconds, as iOS requires).
enum ChefAlarm {
    static let fileNames = ["ChefAlarm001", "ChefAlarm002", "ChefAlarm003", "ChefAlarm004", "ChefAlarm005"]
    nonisolated private static let selectionKey = "sushiChefAlarm"

    static func displayName(for fileName: String) -> String {
        guard let index = fileNames.firstIndex(of: fileName) else { return "Chef Alarm" }
        return "Chef Alarm \(index + 1)"
    }

    /// The chosen sound's file name, readable from the reminder scheduler.
    nonisolated static var selected: String {
        get {
            let stored = UserDefaults.standard.string(forKey: selectionKey) ?? ""
            return fileNames.contains(stored) ? stored : fileNames[0]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: selectionKey)
            NotificationCenter.default.post(name: .chefAlarmChanged, object: nil)
        }
    }

    nonisolated static func url(for fileName: String) -> URL? {
        Bundle.main.url(forResource: fileName, withExtension: "caf")
    }
}

/// Lists the Chef alarms with previews. Anyone can listen; choosing one is Premium.
struct ChefAlarmPickerSheet: View {
    @ObservedObject private var premium = PremiumStore.shared
    @State private var selected = ChefAlarm.selected
    @State private var playing: String?
    @State private var player: AVAudioPlayer?
    @State private var showingPremium = false

    private let ink = Color(red: 0.19, green: 0.11, blue: 0.06)
    private let pink = Color(red: 1.0, green: 0.22, blue: 0.50)

    var body: some View {
        VStack(spacing: 14) {
            VStack(spacing: 4) {
                Text("Chef Alarm 🔔")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                Text(premium.isPremium ? "Pick the sound for your reminders" : "Preview the sounds. Choosing one is Premium.")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(ink.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            .foregroundStyle(ink)
            .padding(.top, 24)

            VStack(spacing: 10) {
                ForEach(ChefAlarm.fileNames, id: \.self) { name in
                    row(name)
                }
            }
            .padding(.horizontal, 18)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .background(Color(red: 0.99, green: 0.92, blue: 0.84).ignoresSafeArea())
        .presentationDetents([.medium, .large])
        .preferredColorScheme(.light)
        .sheet(isPresented: $showingPremium) {
            PremiumSheet()
        }
        .onDisappear { stop() }
    }

    private func row(_ name: String) -> some View {
        let isSelected = premium.isPremium && selected == name
        return HStack(spacing: 12) {
            Button {
                playing == name ? stop() : play(name)
            } label: {
                Image(systemName: playing == name ? "stop.circle.fill" : "play.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(pink)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(playing == name ? "Stop preview" : "Preview \(ChefAlarm.displayName(for: name))")

            Text(ChefAlarm.displayName(for: name))
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(ink)

            Spacer()

            Button {
                guard premium.isPremium else {
                    showingPremium = true
                    return
                }
                selected = name
                ChefAlarm.selected = name
            } label: {
                if isSelected {
                    Label("Selected", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                } else {
                    Label("Use", systemImage: premium.isPremium ? "circle" : "crown.fill")
                        .foregroundStyle(premium.isPremium ? ink.opacity(0.7) : Color(red: 0.95, green: 0.68, blue: 0.10))
                }
            }
            .font(.system(size: 15, weight: .bold, design: .rounded))
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .frame(height: 56)
        .background(Color.white.opacity(isSelected ? 0.95 : 0.7), in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(isSelected ? pink : .clear, lineWidth: 2))
    }

    private func play(_ name: String) {
        stop()
        guard let url = ChefAlarm.url(for: name) else { return }
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
        player = try? AVAudioPlayer(contentsOf: url)
        player?.play()
        playing = name
    }

    private func stop() {
        player?.stop()
        player = nil
        playing = nil
    }
}
